# Thiết Kế Luồng Chức Năng - Hệ Thống Quản Lý Thư Viện

Thư mục này chứa các tài liệu thiết kế luồng chức năng (User Flow) cho hệ thống quản lý thư viện.

## Cấu Trúc

- `01-authentication/` - Luồng đăng ký, đăng nhập, quản lý tài khoản
- `02-book-management/` - Luồng quản lý sách và thể loại
- `03-borrow-return/` - Luồng mượn và trả sách
- `04-payment/` - Luồng quản lý phạt và thanh toán
- `05-user-management/` - Luồng quản lý người dùng (Admin)
- `06-reports/` - Luồng báo cáo và thống kê

## Quy Ước Đặt Tên

- Mỗi luồng chức năng được mô tả trong file markdown
- Sử dụng Mermaid diagrams để vẽ flowchart
- Mỗi luồng bao gồm:
  - Mô tả tổng quan
  - Diagram luồng
  - Các bước chi tiết
  - Validation rules
  - Error handling

