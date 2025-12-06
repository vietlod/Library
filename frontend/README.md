# Library Management System - Frontend

Frontend application cho hệ thống quản lý thư viện sử dụng React, Vite và TailwindCSS.

## Tech Stack

- **Framework:** React 18
- **Build Tool:** Vite
- **Styling:** TailwindCSS
- **Routing:** React Router DOM
- **Forms:** React Hook Form
- **HTTP Client:** Axios
- **Date Handling:** Day.js
- **Icons:** Heroicons

## Cấu Trúc Dự Án

```
frontend/
├── src/
│   ├── components/     # Reusable components
│   ├── contexts/       # React contexts (Auth, etc.)
│   ├── hooks/          # Custom React hooks
│   ├── layouts/        # Layout components
│   ├── pages/          # Page components
│   ├── services/       # API services
│   ├── utils/          # Utility functions
│   ├── App.jsx         # Main App component
│   ├── main.jsx        # Entry point
│   └── index.css       # Global styles
├── public/             # Static assets
├── index.html
└── package.json
```

## Cài Đặt

### 1. Cài đặt dependencies

```bash
npm install
```

### 2. Cấu hình Environment Variables

Tạo file `.env` từ `.env.example`:

```bash
cp .env.example .env
```

Cập nhật `.env`:

```env
VITE_API_URL=http://localhost:3001/api
```

## Chạy Ứng Dụng

### Development Mode

```bash
npm run dev
```

Ứng dụng sẽ chạy tại: `http://localhost:5173`

### Build Production

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Pages

- `/` - Landing Page
- `/register` - Đăng ký tài khoản
- `/login` - Đăng nhập (sẽ thêm sau)
- `/books` - Danh sách sách (sẽ thêm sau)

## Components

- `MainLayout` - Layout chung cho toàn ứng dụng
- `LandingPage` - Trang chủ
- `RegisterPage` - Trang đăng ký

## Services

- `api.js` - Axios instance với interceptors
- `auth.service.js` - Authentication services

## Contexts

- `AuthContext` - Quản lý authentication state

