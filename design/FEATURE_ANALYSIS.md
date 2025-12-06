# Phân Tích Tính Năng - Hệ Thống Quản Lý Thư Viện

## Tổng Quan
Tài liệu này phân tích chi tiết tất cả các tính năng được mô tả trong PRD, bao gồm luồng chính, luồng thay thế, và các trường hợp lỗi/edge cases.

---

## 2.1 QUẢN LÝ TÀI KHOẢN

### 2.1.1 Đăng Ký (User Registration)

**Feature Name:** User Registration  
**Actor:** Mọi người (không cần đăng nhập)  
**Mã số:** 2.1.1

#### Primary User Flow:
1. Người dùng click "Đăng ký" từ trang chủ/trang đăng nhập
2. Điền form: Email, Tên, Mật khẩu, Xác nhận mật khẩu
3. Hệ thống validate dữ liệu
4. Tạo tài khoản với trạng thái "Chờ xác nhận"
5. Hiển thị thông báo thành công

#### Alternative Flows:
- **A1:** Người dùng đã có tài khoản → Chuyển đến trang đăng nhập
- **A2:** Email đã tồn tại → Hiển thị lỗi, yêu cầu đăng nhập hoặc quên mật khẩu

#### Error/Edge Cases:
- Email không đúng định dạng
- Email đã tồn tại trong hệ thống
- Mật khẩu quá ngắn (< 8 ký tự) hoặc quá dài (> 16 ký tự)
- Mật khẩu xác nhận không khớp
- Tên để trống hoặc quá dài (> 50 ký tự)
- Mất kết nối mạng khi submit
- Server error khi tạo tài khoản

---

### 2.1.2 Đăng Nhập (Login)

**Feature Name:** User Login  
**Actor:** Mọi người (không cần đăng nhập)  
**Mã số:** 2.1.2

#### Primary User Flow:
1. Người dùng nhập Email & Mật khẩu
2. Hệ thống xác thực thông tin
3. Tạo JWT token (thời hạn 24h)
4. Lưu token vào localStorage/cookie
5. Chuyển hướng đến dashboard theo role (Reader/Librarian/Admin)

#### Alternative Flows:
- **A1:** Tài khoản chưa được kích hoạt → Thông báo "Chờ xác nhận"
- **A2:** Tài khoản bị vô hiệu hóa → Thông báo "Tài khoản đã bị vô hiệu hóa"
- **A3:** Quên mật khẩu → Chuyển đến trang reset password (nếu có)

#### Error/Edge Cases:
- Email không tồn tại
- Mật khẩu sai
- Email không đúng định dạng
- Mật khẩu để trống
- Token hết hạn (sau 24h)
- Rate limiting: Quá nhiều lần đăng nhập sai
- Mất kết nối mạng
- Server error

---

### 2.1.3 Hồ Sơ Cá Nhân (User Profile)

**Feature Name:** User Profile Management  
**Actor:** Độc giả (Reader)  
**Mã số:** 2.1.3

#### Primary User Flow:
1. Độc giả đăng nhập
2. Vào trang "Hồ sơ cá nhân"
3. Xem thông tin: Tên, Email, Số điện thoại, Địa chỉ, Ngày tham gia, Số lần mượn, Tổng số tiền phạt
4. Cập nhật thông tin cá nhân (nếu cần)
5. Thay đổi mật khẩu (nếu cần)

#### Alternative Flows:
- **A1:** Chỉ xem, không chỉnh sửa → Hiển thị ở chế độ read-only
- **A2:** Cập nhật thông tin → Validate và lưu
- **A3:** Thay đổi mật khẩu → Yêu cầu nhập mật khẩu cũ

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect đến trang đăng nhập
- Token hết hạn → Yêu cầu đăng nhập lại
- Thông tin không hợp lệ khi cập nhật
- Mật khẩu cũ sai khi đổi mật khẩu
- Mật khẩu mới không khớp với xác nhận
- Mất kết nối khi lưu

---

## 2.2 QUẢN LÝ SÁCH

### 2.2.1 Quản lý thể loại sách (Category Management)

**Feature Name:** Book Category Management  
**Actor:** Nhân viên thư viện (Librarian)  
**Mã số:** 2.2.1

#### Primary User Flow:
1. Nhân viên đăng nhập với role Librarian
2. Vào trang "Quản lý thể loại"
3. Xem danh sách thể loại ở dạng bảng
4. **Thêm:** Click "Thêm thể loại" → Nhập tên → Lưu
5. **Sửa:** Sửa trực tiếp trên bảng → Lưu
6. **Xóa:** Click "Xóa" → Xác nhận → Xóa (nếu không có sách thuộc thể loại)

#### Alternative Flows:
- **A1:** Không có thể loại nào → Hiển thị "Chưa có thể loại, hãy thêm mới"
- **A2:** Có sách thuộc thể loại → Không cho phép xóa, hiển thị cảnh báo
- **A3:** Sửa tên trùng với thể loại khác → Hiển thị lỗi

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền Librarian → 403 Forbidden
- Tên thể loại để trống
- Tên thể loại quá dài (> 50 ký tự)
- Tên thể loại trùng lặp
- Có sách đang sử dụng thể loại → Không cho xóa
- Mất kết nối khi lưu

---

### 2.2.2 Thêm Sách Mới (Add New Book)

**Feature Name:** Add New Book  
**Actor:** Nhân viên thư viện (Librarian)  
**Mã số:** 2.2.2

#### Primary User Flow:
1. Nhân viên click "Thêm Sách Mới"
2. Điền form: Tên sách, Tác giả, Năm xuất bản, ISBN, Thể loại, Mô tả, Số lượng
3. Validate dữ liệu
4. Lưu vào database với trạng thái "Có sẵn"
5. Hiển thị thông báo "Thêm sách thành công"

#### Alternative Flows:
- **A1:** ISBN đã tồn tại → Cập nhật số lượng thay vì tạo mới (hoặc báo lỗi)
- **A2:** Chưa có thể loại nào → Yêu cầu tạo thể loại trước

#### Error/Edge Cases:
- Tên sách để trống hoặc quá dài (> 100 ký tự)
- Tác giả để trống hoặc quá dài (> 100 ký tự)
- ISBN không đúng định dạng (ISBN-10 hoặc ISBN-13)
- Năm xuất bản không hợp lệ (< 1900 hoặc > năm hiện tại)
- Thể loại không tồn tại
- Mô tả để trống hoặc quá dài (> 255 ký tự)
- Số lượng <= 0 hoặc không phải số
- Mất kết nối khi lưu

---

### 2.2.3 Xem Danh Sách Sách (Book List)

**Feature Name:** Book List View  
**Actor:** Tất cả người dùng (không cần đăng nhập)  
**Mã số:** 2.2.3

#### Primary User Flow:
1. Vào trang "Danh sách sách"
2. Hiển thị danh sách sách (10 sách/trang)
3. **Tìm kiếm:** Nhập tên sách/tác giả → Filter kết quả
4. **Lọc:** Chọn thể loại → Filter kết quả
5. **Sắp xếp:** Chọn tiêu chí (Tên, Năm, Lượt mượn) → Sắp xếp lại
6. **Phân trang:** Click trang tiếp theo → Load thêm sách

#### Alternative Flows:
- **A1:** Không có sách nào → Hiển thị "Chưa có sách"
- **A2:** Không tìm thấy kết quả → Hiển thị "Không tìm thấy sách phù hợp"
- **A3:** Kết hợp nhiều filter → Áp dụng tất cả điều kiện

#### Error/Edge Cases:
- Mất kết nối khi load danh sách
- API timeout
- Dữ liệu không hợp lệ từ server
- Phân trang: Trang không tồn tại
- Search query quá dài

---

### 2.2.4 Xem Chi Tiết Sách (Book Details)

**Feature Name:** Book Details View  
**Actor:** Tất cả người dùng (không cần đăng nhập)  
**Mã số:** 2.2.4

#### Primary User Flow:
1. Click vào sách từ danh sách
2. Hiển thị chi tiết: Tên, Tác giả, ISBN, Năm xuất bản, Mô tả, Số lượng có sẵn, Số lượng đang mượn
3. **Nếu là Librarian:** Hiển thị thêm lịch sử mượn (Độc giả, Ngày mượn, Ngày hết hạn)
4. **Nếu là Reader:** Hiển thị nút "Mượn sách"

#### Alternative Flows:
- **A1:** Sách không tồn tại → 404 Not Found
- **A2:** Reader chưa đăng nhập → Yêu cầu đăng nhập để mượn
- **A3:** Sách hết → Ẩn nút "Mượn sách" hoặc hiển thị "Hết sách"

#### Error/Edge Cases:
- ID sách không hợp lệ
- Sách đã bị xóa
- Mất kết nối khi load chi tiết
- Không có quyền xem lịch sử mượn (nếu không phải Librarian)

---

### 2.2.5 Sửa & Xóa Sách (Edit & Delete Book)

**Feature Name:** Edit & Delete Book  
**Actor:** Nhân viên thư viện (Librarian)  
**Mã số:** 2.2.5

#### Primary User Flow - Sửa:
1. Xem chi tiết sách
2. Click "Sửa"
3. Chỉnh sửa thông tin
4. Click "Lưu"
5. Validate và cập nhật

#### Primary User Flow - Xóa:
1. Xem chi tiết sách
2. Click "Xóa"
3. Xác nhận trong modal
4. Kiểm tra: Không có đơn mượn hoạt động
5. Xóa sách

#### Alternative Flows:
- **A1:** Có đơn mượn hoạt động → Không cho xóa, hiển thị cảnh báo
- **A2:** Hủy thao tác → Quay lại trang chi tiết

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền Librarian → 403
- Sách đã bị xóa bởi người khác
- Có đơn mượn đang hoạt động → Không cho xóa
- Dữ liệu không hợp lệ khi sửa
- Mất kết nối khi lưu/xóa

---

## 2.3 QUẢN LÝ MƯỢN SÁCH

### 2.3.1 Mượn Sách (Độc Giả) (Borrow Book - Reader)

**Feature Name:** Borrow Book Request  
**Actor:** Độc giả (Reader)  
**Mã số:** 2.3.1

#### Primary User Flow:
1. Độc giả xem chi tiết sách
2. Click "Mượn Sách"
3. Chọn thời hạn mượn (14-30 ngày, mặc định 14)
4. Hệ thống kiểm tra điều kiện:
   - Sách còn sẵn
   - Chưa mượn quá 5 cuốn
   - Không có phạt chưa thanh toán
5. Tạo đơn mượn với trạng thái "Chờ xác nhận"
6. Thông báo thành công

#### Alternative Flows:
- **A1:** Sách hết → Hiển thị "Sách hiện đang hết"
- **A2:** Đã mượn 5 cuốn → Hiển thị "Bạn đã mượn tối đa 5 cuốn"
- **A3:** Có phạt chưa trả → Hiển thị "Vui lòng thanh toán phạt trước"

#### Error/Edge Cases:
- Chưa đăng nhập → Yêu cầu đăng nhập
- Sách đã hết khi submit
- Đã mượn quá 5 cuốn
- Có phạt chưa thanh toán
- Thời hạn mượn không hợp lệ (< 14 hoặc > 30 ngày)
- Mất kết nối khi submit
- Đã có đơn mượn chờ xác nhận cho sách này

---

### 2.3.2 Mượn Sách (Nhân Viên) (Confirm/Reject Borrow - Librarian)

**Feature Name:** Confirm/Reject Borrow Request  
**Actor:** Nhân viên thư viện (Librarian)  
**Mã số:** 2.3.2

#### Primary User Flow - Xác nhận:
1. Nhân viên vào "Quản lý mượn trả" → Tab "Chờ xác nhận mượn"
2. Xem danh sách yêu cầu mượn
3. Click "Xác nhận"
4. Hệ thống cập nhật: Trạng thái "Chờ xác nhận" → "Đã mượn"
5. Giảm số lượng sách có sẵn
6. Thông báo thành công

#### Primary User Flow - Từ chối:
1. Nhân viên vào "Quản lý mượn trả" → Tab "Chờ xác nhận mượn"
2. Xem danh sách yêu cầu mượn
3. Click "Từ chối"
4. Nhập lý do từ chối (bắt buộc)
5. Hệ thống cập nhật: Trạng thái "Chờ xác nhận" → "Bị từ chối"
6. Lưu lý do từ chối
7. Thông báo thành công

#### Alternative Flows:
- **A1:** Sách đã hết khi xác nhận → Không cho xác nhận, từ chối tự động
- **A2:** Độc giả đã mượn quá 5 cuốn → Từ chối với lý do

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền Librarian → 403
- Đơn mượn không tồn tại
- Đơn mượn đã được xử lý
- Sách đã hết khi xác nhận
- Lý do từ chối để trống
- Lý do từ chối quá dài (> 500 ký tự)
- Mất kết nối khi xác nhận/từ chối

---

### 2.3.3 Xem Lịch Sử Mượn Sách (Borrow History)

**Feature Name:** Borrow History View  
**Actor:** Độc giả (Reader)  
**Mã số:** 2.3.3

#### Primary User Flow:
1. Độc giả vào "Lịch sử mượn sách"
2. Xem danh sách theo tab/trạng thái:
   - **Đang mượn:** Tên, Tác giả, Ngày mượn, Hạn trả, Số ngày còn lại
   - **Đã trả:** Tên, Ngày mượn, Ngày trả
   - **Bị từ chối:** Tên, Tác giả, Lý do từ chối
3. **Lọc theo trạng thái:** Chọn trạng thái → Filter
4. **Gia hạn:** Click "Gia hạn" (nếu chưa hết hạn, chưa gia hạn lần nào) → +7 ngày
5. **Trả sách:** Click "Xin trả sách" → Tạo yêu cầu trả

#### Alternative Flows:
- **A1:** Không có sách nào → Hiển thị "Chưa có lịch sử mượn"
- **A2:** Đã gia hạn rồi → Ẩn nút "Gia hạn"
- **A3:** Đã quá hạn → Hiển thị "Quá hạn" và số ngày quá hạn

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Token hết hạn
- Đã gia hạn 1 lần rồi → Không cho gia hạn nữa
- Đã hết hạn → Không cho gia hạn
- Đã có yêu cầu trả chờ xác nhận → Không cho tạo yêu cầu mới
- Mất kết nối khi load lịch sử

---

## 2.4 TRẢ SÁCH

### 2.4.1 Yêu Cầu Trả Sách (Return Request)

**Feature Name:** Return Book Request  
**Actor:** Độc giả (Reader)  
**Mã số:** 2.4.1

#### Primary User Flow:
1. Độc giả vào "Lịch sử mượn sách"
2. Xem danh sách sách đang mượn
3. Click "Xin trả sách" trên sách muốn trả
4. Xác nhận trong modal
5. Hệ thống kiểm tra: Chưa có yêu cầu trả chờ xác nhận
6. Tạo yêu cầu trả với trạng thái "Chờ xác nhận"
7. Thông báo: "Vui lòng mang sách đến thư viện"

#### Alternative Flows:
- **A1:** Đã có yêu cầu trả chờ xác nhận → Hiển thị "Đã có yêu cầu trả đang chờ"
- **A2:** Hủy thao tác → Quay lại danh sách

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Đơn mượn không tồn tại
- Đơn mượn không phải của người dùng
- Đã có yêu cầu trả chờ xác nhận
- Đơn mượn không ở trạng thái "Đang mượn"
- Mất kết nối khi tạo yêu cầu

---

### 2.4.2 Xác Nhận Trả Sách (Confirm Return)

**Feature Name:** Confirm Book Return  
**Actor:** Nhân viên thư viện (Librarian)  
**Mã số:** 2.4.2

#### Primary User Flow - Bình thường:
1. Nhân viên vào "Quản lý mượn trả" → Tab "Chờ xác nhận trả"
2. Xem danh sách yêu cầu trả
3. Nhận sách vật lý từ độc giả
4. Click "Xác nhận trả"
5. Chọn tình trạng: "Bình thường"
6. Xác nhận
7. Cập nhật: Đơn mượn → "Đã trả"
8. Tăng số lượng sách có sẵn, giảm số lượng đang mượn
9. Kiểm tra trả muộn → Nếu muộn, tạo phiếu phạt "Trả muộn"

#### Primary User Flow - Hư hỏng:
1-3. (Giống như trên)
4. Click "Xác nhận trả"
5. Chọn tình trạng: "Hư hỏng"
6. Chọn mức phạt từ danh sách
7. Nhập ghi chú (bắt buộc)
8. Kiểm tra trả muộn → Nếu muộn, thêm phiếu phạt "Trả muộn"
9. Tạo phiếu phạt cho hư hỏng
10. Cập nhật đơn mượn → "Đã trả"

#### Primary User Flow - Mất:
1-3. (Giống như trên)
4. Click "Xác nhận trả"
5. Chọn tình trạng: "Mất"
6. Chọn mức phạt từ danh sách
7. Nhập ghi chú (bắt buộc)
8. Tạo phiếu phạt cho mất sách
9. Cập nhật đơn mượn → "Đã trả"

#### Alternative Flows:
- **A1:** Trả đúng hạn → Không tạo phiếu phạt trả muộn
- **A2:** Trả sớm → Không có phạt trả muộn
- **A3:** Hủy thao tác → Quay lại danh sách

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền Librarian → 403
- Yêu cầu trả không tồn tại
- Yêu cầu trả đã được xử lý
- Chưa chọn tình trạng sách
- Chưa chọn mức phạt (khi hư hỏng/mất)
- Ghi chú để trống (khi hư hỏng/mất)
- Ghi chú quá dài (> 500 ký tự)
- Mức phạt không tồn tại
- Mất kết nối khi xác nhận

---

## 2.5 QUẢN LÝ NỢ & PHẠT

### 2.5.1 Quản lý mức phạt (Fine Level Management)

**Feature Name:** Fine Level Management  
**Actor:** Quản lý viên (Admin)  
**Mã số:** 2.5.1

#### Primary User Flow:
1. Admin vào "Quản lý mức phạt"
2. Xem danh sách mức phạt ở dạng bảng
3. **Thêm:** Click "Thêm mức phạt" → Nhập: Tên, Số tiền, Ngày phạt → Lưu
4. **Sửa:** Sửa trực tiếp trên bảng → Lưu
5. **Xóa:** Click "Xóa" → Xác nhận → Xóa

#### Alternative Flows:
- **A1:** Không có mức phạt nào → Hiển thị "Chưa có mức phạt"
- **A2:** Mức phạt đang được sử dụng → Cảnh báo khi xóa (hoặc không cho xóa)

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền Admin → 403
- Tên mức phạt để trống hoặc quá dài (> 25 ký tự)
- Số tiền <= 0 hoặc không phải số
- Ngày phạt không hợp lệ
- Mức phạt đang được sử dụng → Không cho xóa
- Mất kết nối khi lưu/xóa

---

### 2.5.2 Xem & Thanh Toán Phạt (Độc Giả) (View & Pay Fine - Reader)

**Feature Name:** View & Pay Fine  
**Actor:** Độc giả (Reader)  
**Mã số:** 2.5.2

#### Primary User Flow:
1. Độc giả vào "Khoản phạt"
2. Xem danh sách phạt chưa thanh toán: Nguyên nhân, Số tiền, Ngày phạt, Trạng thái
3. Click "Thanh toán" trên phiếu phạt
4. Chọn phương thức: Chuyển khoản ngân hàng
5. Upload ảnh biên lai (optional)
6. Nhấn "Đã thanh toán"
7. Trạng thái chuyển: "Chưa thanh toán" → "Chờ xác nhận"
8. Thông báo: "Đã gửi, chờ nhân viên xác nhận"

#### Alternative Flows:
- **A1:** Không có phạt → Hiển thị "Không có khoản phạt"
- **A2:** Đã thanh toán hết → Hiển thị "Không có phạt chưa thanh toán"
- **A3:** Hủy thao tác → Quay lại danh sách

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Phiếu phạt không tồn tại
- Phiếu phạt không phải của người dùng
- Phiếu phạt đã được thanh toán
- Ảnh biên lai quá lớn (> 5MB)
- Định dạng ảnh không hợp lệ
- Mất kết nối khi submit

---

### 2.5.3 Xem & Thanh Toán Phạt (Nhân Viên) (Confirm/Reject Payment - Librarian)

**Feature Name:** Confirm/Reject Fine Payment  
**Actor:** Nhân viên thư viện (Librarian)  
**Mã số:** 2.5.3

#### Primary User Flow - Xác nhận:
1. Nhân viên vào "Quản lý phạt" → Tab "Chờ xác nhận"
2. Xem danh sách thanh toán chờ xác nhận
3. Click vào thanh toán → Xem chi tiết & ảnh biên lai
4. Kiểm tra số tiền khớp
5. Click "Xác nhận thanh toán"
6. Trạng thái: "Chờ xác nhận" → "Đã thanh toán"
7. Thông báo thành công

#### Primary User Flow - Từ chối:
1-3. (Giống như trên)
4. Kiểm tra số tiền không khớp
5. Click "Từ chối"
6. Nhập lý do từ chối
7. Trạng thái: "Chờ xác nhận" → "Từ chối"
8. Lưu lý do từ chối
9. Thông báo thành công

#### Alternative Flows:
- **A1:** Không có thanh toán chờ xác nhận → Hiển thị "Không có thanh toán chờ xác nhận"
- **A2:** Số tiền khớp nhưng có vấn đề khác → Từ chối với lý do

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền Librarian → 403
- Thanh toán không tồn tại
- Thanh toán đã được xử lý
- Lý do từ chối để trống
- Lý do từ chối quá dài (> 500 ký tự)
- Mất kết nối khi xác nhận/từ chối

---

## 2.6 QUẢN LÝ NGƯỜI DÙNG

### 2.6.1 Danh Sách Người Dùng (User List)

**Feature Name:** User List Management  
**Actor:** Quản lý viên (Admin)  
**Mã số:** 2.6.1

#### Primary User Flow:
1. Admin vào "Quản lý người dùng"
2. Xem danh sách: Email, Tên, Vai trò, Ngày tham gia, Trạng thái
3. **Tìm kiếm:** Nhập email/tên → Filter
4. **Lọc:** Chọn vai trò → Filter
5. **Vô hiệu hóa/Kích hoạt:** Click toggle → Xác nhận → Cập nhật trạng thái

#### Alternative Flows:
- **A1:** Không có người dùng → Hiển thị "Chưa có người dùng"
- **A2:** Không tìm thấy kết quả → Hiển thị "Không tìm thấy"
- **A3:** Vô hiệu hóa chính mình → Cảnh báo (hoặc không cho phép)

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền Admin → 403
- Vô hiệu hóa chính mình → Không cho phép hoặc cảnh báo
- Người dùng không tồn tại
- Mất kết nối khi cập nhật

---

### 2.6.2 Gán Vai Trò (Assign Role)

**Feature Name:** Assign User Role  
**Actor:** Quản lý viên (Admin)  
**Mã số:** 2.6.2

#### Primary User Flow:
1. Admin vào "Quản lý người dùng"
2. Click vào người dùng → Xem chi tiết
3. Click "Gán vai trò" hoặc "Thay đổi vai trò"
4. Chọn vai trò mới: Reader / Librarian / Admin
5. Xác nhận
6. Cập nhật vai trò

#### Alternative Flows:
- **A1:** Vai trò không thay đổi → Không cần cập nhật
- **A2:** Hủy thao tác → Quay lại danh sách

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền Admin → 403
- Người dùng không tồn tại
- Vai trò không hợp lệ
- Gán vai trò cho chính mình → Cảnh báo
- Mất kết nối khi cập nhật

---

## 2.7 BÁO CÁO & THỐNG KÊ

### 2.7.1 Báo Cáo Tổng Quan (Dashboard)

**Feature Name:** Dashboard Overview  
**Actor:** Quản lý viên, Nhân viên thư viện  
**Mã số:** 2.7.1

#### Primary User Flow:
1. Đăng nhập với role Admin hoặc Librarian
2. Vào Dashboard
3. Xem các thống kê:
   - Tổng số sách: Có sẵn / Đang mượn / Bị mất / Hư hỏng
   - Tổng số độc giả: Hoạt động / Vô hiệu hóa
   - Tổng đơn mượn hôm nay
   - Top 5 sách phổ biến nhất
   - Danh sách độc giả nợ quá hạn

#### Alternative Flows:
- **A1:** Chưa có dữ liệu → Hiển thị 0 hoặc "Chưa có dữ liệu"
- **A2:** Refresh dữ liệu → Reload dashboard

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền xem dashboard → 403
- Mất kết nối khi load dữ liệu
- Dữ liệu không hợp lệ từ server

---

### 2.7.2 Báo Cáo Chi Tiết (Detailed Reports)

**Feature Name:** Detailed Reports  
**Actor:** Quản lý viên, Nhân viên thư viện  
**Mã số:** 2.7.2

#### Primary User Flow:
1. Vào "Báo cáo"
2. Chọn loại báo cáo:
   - Báo cáo Sách
   - Báo cáo Mượn Trả
   - Báo cáo Phạt
   - Báo cáo Sách Mất/Hư
3. Chọn khoảng thời gian: Ngày / Tuần / Tháng / Quý / Năm
4. Xem báo cáo
5. **Xuất CSV:** Click "Xuất báo cáo" → Download file CSV

#### Alternative Flows:
- **A1:** Không có dữ liệu trong khoảng thời gian → Hiển thị "Không có dữ liệu"
- **A2:** Chọn khoảng thời gian tùy chỉnh → Filter theo ngày bắt đầu và kết thúc

#### Error/Edge Cases:
- Chưa đăng nhập → Redirect
- Không có quyền xem báo cáo → 403
- Khoảng thời gian không hợp lệ
- Mất kết nối khi load báo cáo
- Lỗi khi xuất CSV
- File CSV quá lớn

---

## TỔNG KẾT

### Tổng số tính năng: 20

### Phân loại theo Actor:
- **Mọi người (không cần đăng nhập):** 2 tính năng
- **Độc giả (Reader):** 6 tính năng
- **Nhân viên (Librarian):** 7 tính năng
- **Quản lý viên (Admin):** 5 tính năng

### Phân loại theo Module:
- **Quản lý Tài khoản:** 3 tính năng
- **Quản lý Sách:** 5 tính năng
- **Quản lý Mượn Sách:** 3 tính năng
- **Trả Sách:** 2 tính năng
- **Quản lý Nợ & Phạt:** 3 tính năng
- **Quản lý Người Dùng:** 2 tính năng
- **Báo Cáo & Thống Kê:** 2 tính năng

