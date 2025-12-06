import { Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const LandingPage = () => {
  const { isAuthenticated, user } = useAuth();

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <div className="bg-gradient-to-br from-primary-600 to-primary-800 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-24">
          <div className="text-center">
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              Hệ Thống Quản Lý Thư Viện
            </h1>
            <p className="text-xl md:text-2xl mb-8 text-primary-100">
              Mượn trả sách dễ dàng, quản lý kho sách hiệu quả
            </p>
            <div className="flex justify-center gap-4">
              {isAuthenticated ? (
                <Link
                  to={user?.role === 'reader' ? '/reader/dashboard' : '/librarian/dashboard'}
                  className="btn-primary bg-white text-primary-600 hover:bg-primary-50 px-8 py-3 text-lg"
                >
                  Vào Dashboard
                </Link>
              ) : (
                <>
                  <Link
                    to="/register"
                    className="btn-primary bg-white text-primary-600 hover:bg-primary-50 px-8 py-3 text-lg"
                  >
                    Đăng Ký Ngay
                  </Link>
                  <Link
                    to="/login"
                    className="btn-secondary bg-transparent border-2 border-white text-white hover:bg-white hover:text-primary-600 px-8 py-3 text-lg"
                  >
                    Đăng Nhập
                  </Link>
                </>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Features Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">
            Tính Năng Nổi Bật
          </h2>
          <p className="text-lg text-gray-600">
            Hệ thống quản lý thư viện hiện đại với đầy đủ tính năng
          </p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {/* Feature 1 */}
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-4xl mb-4">📚</div>
            <h3 className="text-xl font-semibold mb-2">Quản Lý Sách</h3>
            <p className="text-gray-600">
              Tìm kiếm, xem chi tiết và quản lý kho sách một cách dễ dàng
            </p>
          </div>

          {/* Feature 2 */}
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-4xl mb-4">📖</div>
            <h3 className="text-xl font-semibold mb-2">Mượn Trả Sách</h3>
            <p className="text-gray-600">
              Độc giả có thể mượn và trả sách trực tuyến một cách nhanh chóng
            </p>
          </div>

          {/* Feature 3 */}
          <div className="bg-white p-6 rounded-lg shadow-md">
            <div className="text-4xl mb-4">📊</div>
            <h3 className="text-xl font-semibold mb-2">Báo Cáo Thống Kê</h3>
            <p className="text-gray-600">
              Xem báo cáo chi tiết về sách, mượn trả và các khoản phạt
            </p>
          </div>
        </div>
      </div>

      {/* CTA Section */}
      <div className="bg-primary-50 py-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">
            Bắt Đầu Sử Dụng Ngay
          </h2>
          <p className="text-lg text-gray-600 mb-8">
            Đăng ký tài khoản miễn phí để trải nghiệm đầy đủ tính năng
          </p>
          {!isAuthenticated && (
            <Link
              to="/register"
              className="btn-primary px-8 py-3 text-lg"
            >
              Đăng Ký Ngay
            </Link>
          )}
        </div>
      </div>
    </div>
  );
};

export default LandingPage;

