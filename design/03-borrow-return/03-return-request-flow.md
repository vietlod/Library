# Luồng Yêu Cầu Trả Sách (Return Request Flow)

## Tổng Quan
Luồng cho phép độc giả yêu cầu trả sách đang mượn.

## Actor
- Độc giả (Reader) - cần đăng nhập

## Diagram

```mermaid
flowchart TD
    A[Trang Lịch sử Mượn] --> B[Danh sách Sách đang mượn]
    B --> C[Click Xin trả sách]
    C --> D{Đã có yêu cầu trả?}
    D -->|Có| E[Thông báo: Đã có yêu cầu]
    D -->|Chưa| F[Modal Xác nhận]
    F --> G{Xác nhận?}
    G -->|Hủy| B
    G -->|Xác nhận| H[Tạo Yêu cầu trả]
    H --> I[Trạng thái: Chờ xác nhận trả]
    I --> J[Thông báo: Đã gửi yêu cầu]
    J --> K[Mang sách đến thư viện]
```

## Các Bước Chi Tiết

### 1. Xem danh sách sách đang mượn
- API: `GET /api/borrows/my-borrows?status=borrowed`
- Hiển thị:
  - Tên sách
  - Tác giả
  - Ngày mượn
  - Hạn trả
  - Số ngày còn lại
  - Nút "Xin trả sách"

### 2. Kiểm tra điều kiện
- Một đơn mượn chỉ có thể có một yêu cầu trả ở trạng thái "Chờ xác nhận"
- Nếu đã có: Hiển thị "Đã có yêu cầu trả sách đang chờ xác nhận"

### 3. Click "Xin trả sách"
- Hiển thị modal xác nhận:
  - "Bạn có chắc muốn trả sách này?"
  - "Vui lòng mang sách đến thư viện để nhân viên xác nhận"

### 4. Tạo yêu cầu trả sách
- API: `POST /api/returns`
- Body:
  ```json
  {
    "borrowId": 1
  }
  ```
- Tạo return request với trạng thái: "pending"

### 5. Thông báo
- Thành công: "Yêu cầu trả sách đã được gửi. Vui lòng mang sách đến thư viện để nhân viên xác nhận."

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/borrows/my-borrows?status=borrowed` | Lấy danh sách sách đang mượn |
| POST | `/api/returns` | Tạo yêu cầu trả sách |

## Request Body

```json
{
  "borrowId": 1
}
```

## Response

### Success (201)
```json
{
  "message": "Yêu cầu trả sách đã được gửi",
  "data": {
    "id": 1,
    "borrowId": 1,
    "status": "pending",
    "requestDate": "2024-01-20T10:00:00Z"
  }
}
```

## Validation Rules

| Điều kiện | Kiểm tra |
|-----------|----------|
| Đơn mượn tồn tại | `borrowId` phải hợp lệ |
| Đơn mượn đang ở trạng thái "borrowed" | `borrow.status === 'borrowed'` |
| Chưa có yêu cầu trả chờ xác nhận | `returnRequest.status !== 'pending'` |

## Error Handling

| Lỗi | Thông báo | Status Code |
|-----|-----------|-------------|
| Không tìm thấy đơn mượn | "Không tìm thấy đơn mượn sách" | 404 |
| Đơn mượn không phải của bạn | "Bạn không có quyền trả sách này" | 403 |
| Đã có yêu cầu trả | "Đã có yêu cầu trả sách đang chờ xác nhận" | 400 |
| Đơn mượn không ở trạng thái hợp lệ | "Không thể trả sách này" | 400 |

