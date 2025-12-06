# Library Management System - Backend API

Backend API cho hệ thống quản lý thư viện sử dụng Express.js, Prisma ORM và Supabase.

## Tech Stack

- **Runtime:** Node.js (v18+)
- **Framework:** Express.js
- **ORM:** Prisma
- **Database:** PostgreSQL (Supabase)
- **Authentication:** Supabase Auth
- **Validation:** Joi

## Cấu Trúc Dự Án

```
backend/
├── src/
│   ├── config/          # Cấu hình (Supabase, Prisma)
│   ├── controllers/     # Business logic
│   ├── middlewares/     # Express middlewares
│   ├── routes/          # API routes
│   ├── validators/      # Joi validation schemas
│   └── index.js         # Entry point
├── prisma/
│   └── schema.prisma    # Prisma schema
├── .env                 # Environment variables
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

Cập nhật các giá trị trong `.env`:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# Database (Supabase PostgreSQL)
DATABASE_URL=postgresql://user:password@host:port/database?schema=public

# Server Configuration
PORT=3001
NODE_ENV=development

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:5173
```

### 3. Setup Database

#### Option 1: Sử dụng schema SQL có sẵn
Chạy file `migrations/schema.sql` trong Supabase SQL Editor.

#### Option 2: Sử dụng Prisma Migrate
```bash
# Generate Prisma Client
npm run prisma:generate

# Tạo migration từ schema
npm run prisma:migrate
```

### 4. Generate Prisma Client

```bash
npm run prisma:generate
```

## Chạy Ứng Dụng

### Development Mode

```bash
npm run dev
```

Server sẽ chạy tại: `http://localhost:3001`

### Production Mode

```bash
npm start
```

## API Endpoints

### Authentication

- `POST /api/auth/register` - Đăng ký tài khoản mới
- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/logout` - Đăng xuất
- `GET /api/auth/me` - Lấy thông tin người dùng hiện tại

### Health Check

- `GET /health` - Kiểm tra server

## Prisma Commands

```bash
# Generate Prisma Client
npm run prisma:generate

# Tạo migration
npm run prisma:migrate

# Mở Prisma Studio (GUI để xem database)
npm run prisma:studio
```

## Lưu Ý

- Supabase Auth được sử dụng cho authentication (email/password)
- Prisma được sử dụng cho tất cả database operations
- Database schema được quản lý qua Prisma schema file
- RLS (Row Level Security) được cấu hình trong Supabase

