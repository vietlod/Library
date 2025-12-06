const { supabase } = require('../config/supabase');
const prisma = require('../config/prisma');

/**
 * Register a new user
 * POST /api/auth/register
 */
const register = async (req, res) => {
  try {
    const { email, name, password } = req.body;

    // Register user with Supabase Auth
    // This will also trigger the handle_new_user() function to create profile
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          name: name // This will be used by the trigger to set the name in profiles
        }
      }
    });

    if (authError) {
      // Handle specific error cases
      if (authError.message.includes('already registered') || authError.message.includes('already exists')) {
        return res.status(400).json({
          success: false,
          message: 'Email này đã được sử dụng'
        });
      }
      
      console.error('Supabase Auth Error:', authError);
      return res.status(400).json({
        success: false,
        message: authError.message || 'Đăng ký thất bại'
      });
    }

    // Get the created profile using Prisma
    const profile = await prisma.profile.findUnique({
      where: { id: authData.user.id },
      select: {
        id: true,
        name: true,
        role: true,
        status: true,
        createdAt: true
      }
    });

    return res.status(201).json({
      success: true,
      message: 'Đăng ký thành công! Vui lòng đợi xác nhận.',
      data: {
        id: authData.user.id,
        email: authData.user.email,
        name: profile?.name || name,
        role: profile?.role || 'reader',
        status: profile?.status || 'pending',
        createdAt: profile?.createdAt || authData.user.created_at
      }
    });

  } catch (error) {
    console.error('Registration error:', error);
    return res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi đăng ký'
    });
  }
};

/**
 * Login user
 * POST /api/auth/login
 */
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Sign in with Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (authError) {
      return res.status(401).json({
        success: false,
        message: 'Email hoặc mật khẩu không đúng'
      });
    }

    // Get user profile using Prisma
    const profile = await prisma.profile.findUnique({
      where: { id: authData.user.id },
      select: {
        id: true,
        name: true,
        phone: true,
        address: true,
        role: true,
        status: true,
        createdAt: true
      }
    });

    if (!profile) {
      return res.status(500).json({
        success: false,
        message: 'Không thể lấy thông tin người dùng'
      });
    }

    // Check account status
    if (profile.status === 'pending') {
      return res.status(403).json({
        success: false,
        message: 'Tài khoản của bạn chưa được kích hoạt'
      });
    }

    if (profile.status === 'inactive') {
      return res.status(403).json({
        success: false,
        message: 'Tài khoản của bạn đã bị vô hiệu hóa'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Đăng nhập thành công',
      data: {
        token: authData.session.access_token,
        refreshToken: authData.session.refresh_token,
        expiresAt: authData.session.expires_at,
        user: {
          id: profile.id,
          email: authData.user.email,
          name: profile.name,
          phone: profile.phone,
          address: profile.address,
          role: profile.role,
          status: profile.status,
          createdAt: profile.createdAt
        }
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    return res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi đăng nhập'
    });
  }
};

/**
 * Logout user
 * POST /api/auth/logout
 */
const logout = async (req, res) => {
  try {
    const { error } = await supabase.auth.signOut();

    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Đăng xuất thất bại'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Đăng xuất thành công'
    });

  } catch (error) {
    console.error('Logout error:', error);
    return res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi khi đăng xuất'
    });
  }
};

/**
 * Get current user profile
 * GET /api/auth/me
 */
const getMe = async (req, res) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Vui lòng đăng nhập'
      });
    }

    const token = authHeader.split(' ')[1];

    // Verify the token and get user
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return res.status(401).json({
        success: false,
        message: 'Phiên đăng nhập đã hết hạn'
      });
    }

    // Get user profile using Prisma
    const profile = await prisma.profile.findUnique({
      where: { id: user.id },
      select: {
        id: true,
        name: true,
        phone: true,
        address: true,
        role: true,
        status: true,
        createdAt: true
      }
    });

    if (!profile) {
      return res.status(500).json({
        success: false,
        message: 'Không thể lấy thông tin người dùng'
      });
    }

    return res.status(200).json({
      success: true,
      data: {
        id: profile.id,
        email: user.email,
        name: profile.name,
        phone: profile.phone,
        address: profile.address,
        role: profile.role,
        status: profile.status,
        createdAt: profile.createdAt
      }
    });

  } catch (error) {
    console.error('Get me error:', error);
    return res.status(500).json({
      success: false,
      message: 'Đã xảy ra lỗi'
    });
  }
};

module.exports = {
  register,
  login,
  logout,
  getMe
};

