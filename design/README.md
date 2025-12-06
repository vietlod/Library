# Thiết Kế Luồng Chức Năng - Hệ Thống Quản Lý Thư Viện

Thư mục này chứa các tài liệu thiết kế luồng chức năng (User Flow) cho hệ thống quản lý thư viện, được phân tích từ PRD và tạo bằng Mermaid syntax.

## Cấu Trúc

Tất cả các flowcharts được đặt tên theo quy ước: `feature.number-feature-name.md`

### Danh Sách Tính Năng

#### 2.1 Quản lý Tài Khoản
- `2.1.1-user-registration.md` - Đăng Ký
- `2.1.2-user-login.md` - Đăng Nhập
- `2.1.3-user-profile.md` - Hồ Sơ Cá Nhân

#### 2.2 Quản lý Sách
- `2.2.1-category-management.md` - Quản lý thể loại sách
- `2.2.2-add-new-book.md` - Thêm Sách Mới
- `2.2.3-book-list.md` - Xem Danh Sách Sách
- `2.2.4-book-details.md` - Xem Chi Tiết Sách
- `2.2.5-edit-delete-book.md` - Sửa & Xóa Sách

#### 2.3 Quản lý Mượn Sách
- `2.3.1-borrow-book-reader.md` - Mượn Sách (Độc Giả)
- `2.3.2-confirm-reject-borrow.md` - Mượn Sách (Nhân Viên)
- `2.3.3-borrow-history.md` - Xem Lịch Sử Mượn Sách

#### 2.4 Trả Sách
- `2.4.1-return-request.md` - Yêu Cầu Trả Sách
- `2.4.2-confirm-return.md` - Xác Nhận Trả Sách

#### 2.5 Quản lý Nợ & Phạt
- `2.5.1-fine-level-management.md` - Quản lý mức phạt
- `2.5.2-view-pay-fine-reader.md` - Xem & Thanh Toán Phạt (Độc Giả)
- `2.5.3-confirm-reject-payment.md` - Xem & Thanh Toán Phạt (Nhân Viên)

#### 2.6 Quản lý Người Dùng
- `2.6.1-user-list.md` - Danh Sách Người Dùng
- `2.6.2-assign-role.md` - Gán Vai Trò

#### 2.7 Báo Cáo & Thống Kê
- `2.7.1-dashboard-overview.md` - Báo Cáo Tổng Quan
- `2.7.2-detailed-reports.md` - Báo Cáo Chi Tiết

## Phân Tích Tính Năng

File `FEATURE_ANALYSIS.md` chứa phân tích chi tiết tất cả 20 tính năng, bao gồm:
- Feature name
- Primary user flow
- Alternative flows
- Error/edge cases

## Cấu Trúc Mỗi File Flowchart

Mỗi file flowchart bao gồm:

1. **Tổng Quan** - Mô tả ngắn gọn về tính năng
2. **Actor** - Người dùng thực hiện tính năng
3. **Mermaid Flowchart** - Diagram luồng chức năng chi tiết
4. **Các Bước Chi Tiết** - Mô tả từng bước trong luồng
5. **Validation Rules** - Quy tắc validation
6. **API Endpoints** - Các API endpoint liên quan
7. **Request/Response** - Format request và response
8. **Error Handling** - Xử lý các trường hợp lỗi

## Cách Xem Flowcharts

Các flowcharts được viết bằng Mermaid syntax. Để xem:

1. **GitHub/GitLab**: Tự động render Mermaid diagrams
2. **VS Code**: Cài extension "Markdown Preview Mermaid Support"
3. **Online**: Copy code vào https://mermaid.live/

## Quy Ước

- Mỗi tính năng có một file riêng
- Tên file theo format: `feature.number-feature-name.md`
- Sử dụng Mermaid flowchart syntax
- Bao gồm đầy đủ primary flow, alternative flows, và error handling

## Tổng Kết

- **Tổng số tính năng:** 20
- **Tổng số flowcharts:** 20
- **File phân tích:** 1 (FEATURE_ANALYSIS.md)

Tất cả các flowcharts đã được tạo dựa trên phân tích chi tiết PRD và tuân theo quy ước đặt tên yêu cầu.

