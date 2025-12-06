import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Link, useNavigate } from 'react-router-dom';
import { register } from '../services/auth.service';

const RegisterPage = () => {
  const navigate = useNavigate();
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(false);

  const {
    register: registerField,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm();

  const password = watch('password');

  const onSubmit = async (data) => {
    setError(null);
    setLoading(true);

    try {
      const response = await register(data);
      
      if (response.success) {
        // Show success message and redirect to login
        alert('Đăng ký thành công! Vui lòng đợi xác nhận từ quản trị viên.');
        navigate('/login');
      }
    } catch (err) {
      const errorMessage = err.response?.data?.message || err.response?.data?.errors?.[0]?.message || 'Đăng ký thất bại. Vui lòng thử lại.';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Đăng Ký Tài Khoản
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Hoặc{' '}
            <Link to="/login" className="font-medium text-primary-600 hover:text-primary-500">
              đăng nhập nếu đã có tài khoản
            </Link>
          </p>
        </div>

        <form className="mt-8 space-y-6" onSubmit={handleSubmit(onSubmit)}>
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
              {error}
            </div>
          )}

          <div className="space-y-4">
            {/* Email */}
            <div>
              <label htmlFor="email" className="label-field">
                Email
              </label>
              <input
                id="email"
                type="email"
                autoComplete="email"
                className={`input-field ${errors.email ? 'border-red-500' : ''}`}
                {...registerField('email', {
                  required: 'Email không được để trống',
                  pattern: {
                    value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                    message: 'Email không hợp lệ',
                  },
                })}
              />
              {errors.email && (
                <p className="error-message">{errors.email.message}</p>
              )}
            </div>

            {/* Name */}
            <div>
              <label htmlFor="name" className="label-field">
                Tên
              </label>
              <input
                id="name"
                type="text"
                autoComplete="name"
                className={`input-field ${errors.name ? 'border-red-500' : ''}`}
                {...registerField('name', {
                  required: 'Tên không được để trống',
                  maxLength: {
                    value: 50,
                    message: 'Tên không được quá 50 ký tự',
                  },
                })}
              />
              {errors.name && (
                <p className="error-message">{errors.name.message}</p>
              )}
            </div>

            {/* Password */}
            <div>
              <label htmlFor="password" className="label-field">
                Mật khẩu
              </label>
              <input
                id="password"
                type="password"
                autoComplete="new-password"
                className={`input-field ${errors.password ? 'border-red-500' : ''}`}
                {...registerField('password', {
                  required: 'Mật khẩu không được để trống',
                  minLength: {
                    value: 8,
                    message: 'Mật khẩu phải có ít nhất 8 ký tự',
                  },
                  maxLength: {
                    value: 16,
                    message: 'Mật khẩu không được quá 16 ký tự',
                  },
                })}
              />
              {errors.password && (
                <p className="error-message">{errors.password.message}</p>
              )}
            </div>

            {/* Confirm Password */}
            <div>
              <label htmlFor="confirmPassword" className="label-field">
                Xác nhận mật khẩu
              </label>
              <input
                id="confirmPassword"
                type="password"
                autoComplete="new-password"
                className={`input-field ${errors.confirmPassword ? 'border-red-500' : ''}`}
                {...registerField('confirmPassword', {
                  required: 'Xác nhận mật khẩu không được để trống',
                  validate: (value) =>
                    value === password || 'Mật khẩu xác nhận không khớp',
                })}
              />
              {errors.confirmPassword && (
                <p className="error-message">{errors.confirmPassword.message}</p>
              )}
            </div>
          </div>

          <div>
            <button
              type="submit"
              disabled={loading}
              className="w-full btn-primary py-3 text-base font-medium disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Đang xử lý...' : 'Đăng Ký'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default RegisterPage;

