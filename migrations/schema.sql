-- ============================================
-- Library Management System - Database Schema
-- Supabase PostgreSQL
-- ============================================

-- ============================================
-- SECTION 1: ENUM TYPES
-- ============================================

-- User roles in the system
CREATE TYPE user_role AS ENUM ('reader', 'librarian', 'admin');

-- User account status
CREATE TYPE user_status AS ENUM ('pending', 'active', 'inactive');

-- Borrow request status
CREATE TYPE borrow_status AS ENUM ('pending', 'borrowed', 'returned', 'rejected');

-- Return request status
CREATE TYPE return_status AS ENUM ('pending', 'confirmed');

-- Book condition when returned
CREATE TYPE book_condition AS ENUM ('normal', 'damaged', 'lost');

-- Fine reason types
CREATE TYPE fine_reason AS ENUM ('late_return', 'damaged', 'lost');

-- Fine payment status
CREATE TYPE fine_status AS ENUM ('unpaid', 'pending_confirmation', 'paid', 'rejected');


-- ============================================
-- SECTION 2: TABLES
-- ============================================

-- --------------------------------------------
-- Table: profiles
-- Extends auth.users with additional user information
-- --------------------------------------------
CREATE TABLE profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name varchar(50) NOT NULL,
    phone varchar(20),
    address varchar(255),
    role user_role NOT NULL DEFAULT 'reader',
    status user_status NOT NULL DEFAULT 'pending',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    
    -- Constraints
    CONSTRAINT profiles_name_length CHECK (char_length(name) >= 1),
    CONSTRAINT profiles_phone_format CHECK (phone IS NULL OR phone ~ '^\+?[0-9]{9,15}$')
);

COMMENT ON TABLE profiles IS 'User profile information extending Supabase auth.users';
COMMENT ON COLUMN profiles.role IS 'User role: reader (default), librarian, or admin';
COMMENT ON COLUMN profiles.status IS 'Account status: pending (default), active, or inactive';


-- --------------------------------------------
-- Table: categories
-- Book categories/genres
-- --------------------------------------------
CREATE TABLE categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(50) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    
    -- Constraints
    CONSTRAINT categories_name_unique UNIQUE (name),
    CONSTRAINT categories_name_length CHECK (char_length(name) >= 1)
);

COMMENT ON TABLE categories IS 'Book categories/genres managed by librarians';


-- --------------------------------------------
-- Table: books
-- Book inventory
-- --------------------------------------------
CREATE TABLE books (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    title varchar(100) NOT NULL,
    author varchar(100) NOT NULL,
    publication_year int,
    isbn varchar(17),
    category_id uuid NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    description varchar(255) NOT NULL,
    quantity int NOT NULL,
    available int NOT NULL,
    borrowed int NOT NULL DEFAULT 0,
    borrow_count int NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    
    -- Constraints
    CONSTRAINT books_isbn_unique UNIQUE (isbn),
    CONSTRAINT books_title_length CHECK (char_length(title) >= 1),
    CONSTRAINT books_author_length CHECK (char_length(author) >= 1),
    CONSTRAINT books_description_length CHECK (char_length(description) >= 1),
    CONSTRAINT books_publication_year_range CHECK (
        publication_year IS NULL OR 
        (publication_year >= 1900 AND publication_year <= EXTRACT(YEAR FROM CURRENT_DATE))
    ),
    CONSTRAINT books_isbn_format CHECK (
        isbn IS NULL OR 
        isbn ~ '^(97(8|9))?\d{9}(\d|X)$'
    ),
    CONSTRAINT books_quantity_positive CHECK (quantity >= 0),
    CONSTRAINT books_available_positive CHECK (available >= 0),
    CONSTRAINT books_borrowed_positive CHECK (borrowed >= 0),
    CONSTRAINT books_borrow_count_positive CHECK (borrow_count >= 0),
    CONSTRAINT books_available_borrowed_sum CHECK (available + borrowed <= quantity)
);

COMMENT ON TABLE books IS 'Book inventory managed by librarians';
COMMENT ON COLUMN books.quantity IS 'Total number of copies';
COMMENT ON COLUMN books.available IS 'Number of copies currently available';
COMMENT ON COLUMN books.borrowed IS 'Number of copies currently borrowed';
COMMENT ON COLUMN books.borrow_count IS 'Total times this book has been borrowed (for popularity)';


-- --------------------------------------------
-- Table: borrows
-- Borrow records/requests
-- --------------------------------------------
CREATE TABLE borrows (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    book_id uuid NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
    status borrow_status NOT NULL DEFAULT 'pending',
    request_date timestamptz NOT NULL DEFAULT now(),
    duration_days int NOT NULL,
    borrow_date timestamptz,
    due_date timestamptz,
    return_date timestamptz,
    rejection_reason text,
    is_extended boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    
    -- Constraints
    CONSTRAINT borrows_duration_range CHECK (duration_days >= 14 AND duration_days <= 30),
    CONSTRAINT borrows_dates_logic CHECK (
        (borrow_date IS NULL AND due_date IS NULL) OR
        (borrow_date IS NOT NULL AND due_date IS NOT NULL AND due_date > borrow_date)
    ),
    CONSTRAINT borrows_return_after_borrow CHECK (
        return_date IS NULL OR 
        (borrow_date IS NOT NULL AND return_date >= borrow_date)
    ),
    CONSTRAINT borrows_rejection_reason_required CHECK (
        (status = 'rejected' AND rejection_reason IS NOT NULL) OR
        (status != 'rejected')
    )
);

COMMENT ON TABLE borrows IS 'Borrow requests and records';
COMMENT ON COLUMN borrows.duration_days IS 'Requested borrow duration (14-30 days)';
COMMENT ON COLUMN borrows.is_extended IS 'Whether the borrow period has been extended (max 1 time)';


-- --------------------------------------------
-- Table: return_requests
-- Return requests from readers
-- --------------------------------------------
CREATE TABLE return_requests (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    borrow_id uuid NOT NULL REFERENCES borrows(id) ON DELETE RESTRICT,
    status return_status NOT NULL DEFAULT 'pending',
    condition book_condition,
    request_date timestamptz NOT NULL DEFAULT now(),
    confirmed_date timestamptz,
    confirmed_by uuid REFERENCES profiles(id) ON DELETE SET NULL,
    note varchar(500),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    
    -- Each borrow can only have one pending/confirmed return request
    CONSTRAINT return_requests_borrow_unique UNIQUE (borrow_id),
    CONSTRAINT return_requests_confirmed_logic CHECK (
        (status = 'confirmed' AND condition IS NOT NULL AND confirmed_date IS NOT NULL) OR
        (status = 'pending')
    ),
    CONSTRAINT return_requests_note_required CHECK (
        (condition IN ('damaged', 'lost') AND note IS NOT NULL) OR
        (condition = 'normal' OR condition IS NULL)
    )
);

COMMENT ON TABLE return_requests IS 'Return requests from readers, confirmed by librarians';
COMMENT ON COLUMN return_requests.condition IS 'Book condition when returned: normal, damaged, or lost';


-- --------------------------------------------
-- Table: fine_levels
-- Configurable fine amounts (managed by admin)
-- --------------------------------------------
CREATE TABLE fine_levels (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name varchar(25) NOT NULL,
    amount decimal(10, 2) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    
    -- Constraints
    CONSTRAINT fine_levels_name_length CHECK (char_length(name) >= 1),
    CONSTRAINT fine_levels_amount_positive CHECK (amount > 0)
);

COMMENT ON TABLE fine_levels IS 'Configurable fine levels managed by admin';


-- --------------------------------------------
-- Table: fines
-- Fine records for readers
-- --------------------------------------------
CREATE TABLE fines (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    borrow_id uuid REFERENCES borrows(id) ON DELETE SET NULL,
    fine_level_id uuid REFERENCES fine_levels(id) ON DELETE SET NULL,
    reason fine_reason NOT NULL,
    amount decimal(10, 2) NOT NULL,
    status fine_status NOT NULL DEFAULT 'unpaid',
    payment_date timestamptz,
    receipt_image_url text,
    note varchar(500),
    rejection_reason varchar(500),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    
    -- Constraints
    CONSTRAINT fines_amount_positive CHECK (amount > 0),
    CONSTRAINT fines_payment_date_logic CHECK (
        (status IN ('paid', 'pending_confirmation') AND payment_date IS NOT NULL) OR
        (status IN ('unpaid', 'rejected'))
    ),
    CONSTRAINT fines_rejection_reason_required CHECK (
        (status = 'rejected' AND rejection_reason IS NOT NULL) OR
        (status != 'rejected')
    )
);

COMMENT ON TABLE fines IS 'Fine records for readers';
COMMENT ON COLUMN fines.reason IS 'Fine reason: late_return, damaged, or lost';
COMMENT ON COLUMN fines.status IS 'Payment status: unpaid, pending_confirmation, paid, or rejected';


-- ============================================
-- SECTION 3: INDEXES
-- ============================================

-- Profiles indexes
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_status ON profiles(status);
CREATE INDEX idx_profiles_role_status ON profiles(role, status);

-- Categories indexes (name is already unique, so has index)

-- Books indexes
CREATE INDEX idx_books_category_id ON books(category_id);
CREATE INDEX idx_books_title ON books USING gin(to_tsvector('simple', title));
CREATE INDEX idx_books_author ON books USING gin(to_tsvector('simple', author));
CREATE INDEX idx_books_available ON books(available) WHERE available > 0;
CREATE INDEX idx_books_borrow_count ON books(borrow_count DESC);

-- Borrows indexes
CREATE INDEX idx_borrows_user_id ON borrows(user_id);
CREATE INDEX idx_borrows_book_id ON borrows(book_id);
CREATE INDEX idx_borrows_status ON borrows(status);
CREATE INDEX idx_borrows_user_status ON borrows(user_id, status);
CREATE INDEX idx_borrows_due_date ON borrows(due_date) WHERE status = 'borrowed';

-- Return requests indexes
CREATE INDEX idx_return_requests_status ON return_requests(status);
CREATE INDEX idx_return_requests_confirmed_by ON return_requests(confirmed_by);

-- Fines indexes
CREATE INDEX idx_fines_user_id ON fines(user_id);
CREATE INDEX idx_fines_status ON fines(status);
CREATE INDEX idx_fines_user_status ON fines(user_id, status);
CREATE INDEX idx_fines_borrow_id ON fines(borrow_id);


-- ============================================
-- SECTION 4: FUNCTIONS & TRIGGERS
-- ============================================

-- Function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all tables
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_books_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_borrows_updated_at
    BEFORE UPDATE ON borrows
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_return_requests_updated_at
    BEFORE UPDATE ON return_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fine_levels_updated_at
    BEFORE UPDATE ON fine_levels
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fines_updated_at
    BEFORE UPDATE ON fines
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();


-- Function to create profile when new user signs up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, name)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', 'New User')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();


-- Function to get user role
CREATE OR REPLACE FUNCTION get_user_role(user_id uuid)
RETURNS user_role AS $$
DECLARE
    v_role user_role;
BEGIN
    SELECT role INTO v_role FROM profiles WHERE id = user_id;
    RETURN v_role;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Function to check if user is admin or librarian
CREATE OR REPLACE FUNCTION is_staff(user_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = user_id 
        AND role IN ('admin', 'librarian')
        AND status = 'active'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin(user_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles 
        WHERE id = user_id 
        AND role = 'admin'
        AND status = 'active'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================
-- SECTION 5: ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE borrows ENABLE ROW LEVEL SECURITY;
ALTER TABLE return_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE fine_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE fines ENABLE ROW LEVEL SECURITY;


-- --------------------------------------------
-- RLS Policies: profiles
-- --------------------------------------------

-- Users can view their own profile
CREATE POLICY profiles_select_own ON profiles
    FOR SELECT
    USING (auth.uid() = id);

-- Staff can view all profiles
CREATE POLICY profiles_select_staff ON profiles
    FOR SELECT
    USING (is_staff(auth.uid()));

-- Users can update their own profile (except role and status)
CREATE POLICY profiles_update_own ON profiles
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (
        auth.uid() = id AND
        role = (SELECT role FROM profiles WHERE id = auth.uid()) AND
        status = (SELECT status FROM profiles WHERE id = auth.uid())
    );

-- Admin can update any profile
CREATE POLICY profiles_update_admin ON profiles
    FOR UPDATE
    USING (is_admin(auth.uid()));

-- Profile is created by trigger, no direct insert needed
-- But admin can insert if needed
CREATE POLICY profiles_insert_admin ON profiles
    FOR INSERT
    WITH CHECK (is_admin(auth.uid()) OR auth.uid() = id);


-- --------------------------------------------
-- RLS Policies: categories
-- --------------------------------------------

-- Everyone can view categories
CREATE POLICY categories_select_all ON categories
    FOR SELECT
    USING (true);

-- Only librarians and admins can insert/update/delete
CREATE POLICY categories_insert_staff ON categories
    FOR INSERT
    WITH CHECK (is_staff(auth.uid()));

CREATE POLICY categories_update_staff ON categories
    FOR UPDATE
    USING (is_staff(auth.uid()));

CREATE POLICY categories_delete_staff ON categories
    FOR DELETE
    USING (is_staff(auth.uid()));


-- --------------------------------------------
-- RLS Policies: books
-- --------------------------------------------

-- Everyone can view books
CREATE POLICY books_select_all ON books
    FOR SELECT
    USING (true);

-- Only librarians and admins can insert/update/delete
CREATE POLICY books_insert_staff ON books
    FOR INSERT
    WITH CHECK (is_staff(auth.uid()));

CREATE POLICY books_update_staff ON books
    FOR UPDATE
    USING (is_staff(auth.uid()));

CREATE POLICY books_delete_staff ON books
    FOR DELETE
    USING (is_staff(auth.uid()));


-- --------------------------------------------
-- RLS Policies: borrows
-- --------------------------------------------

-- Users can view their own borrows
CREATE POLICY borrows_select_own ON borrows
    FOR SELECT
    USING (auth.uid() = user_id);

-- Staff can view all borrows
CREATE POLICY borrows_select_staff ON borrows
    FOR SELECT
    USING (is_staff(auth.uid()));

-- Active readers can insert borrows (create borrow requests)
CREATE POLICY borrows_insert_reader ON borrows
    FOR INSERT
    WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE id = auth.uid() 
            AND role = 'reader' 
            AND status = 'active'
        )
    );

-- Users can update their own pending borrows (for extension)
CREATE POLICY borrows_update_own ON borrows
    FOR UPDATE
    USING (auth.uid() = user_id AND status IN ('pending', 'borrowed'));

-- Staff can update any borrow (for confirm/reject)
CREATE POLICY borrows_update_staff ON borrows
    FOR UPDATE
    USING (is_staff(auth.uid()));


-- --------------------------------------------
-- RLS Policies: return_requests
-- --------------------------------------------

-- Users can view their own return requests
CREATE POLICY return_requests_select_own ON return_requests
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM borrows 
            WHERE borrows.id = return_requests.borrow_id 
            AND borrows.user_id = auth.uid()
        )
    );

-- Staff can view all return requests
CREATE POLICY return_requests_select_staff ON return_requests
    FOR SELECT
    USING (is_staff(auth.uid()));

-- Users can create return requests for their own borrows
CREATE POLICY return_requests_insert_own ON return_requests
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM borrows 
            WHERE borrows.id = borrow_id 
            AND borrows.user_id = auth.uid()
            AND borrows.status = 'borrowed'
        )
    );

-- Only staff can update return requests (for confirmation)
CREATE POLICY return_requests_update_staff ON return_requests
    FOR UPDATE
    USING (is_staff(auth.uid()));


-- --------------------------------------------
-- RLS Policies: fine_levels
-- --------------------------------------------

-- Everyone can view fine levels
CREATE POLICY fine_levels_select_all ON fine_levels
    FOR SELECT
    USING (true);

-- Only admin can manage fine levels
CREATE POLICY fine_levels_insert_admin ON fine_levels
    FOR INSERT
    WITH CHECK (is_admin(auth.uid()));

CREATE POLICY fine_levels_update_admin ON fine_levels
    FOR UPDATE
    USING (is_admin(auth.uid()));

CREATE POLICY fine_levels_delete_admin ON fine_levels
    FOR DELETE
    USING (is_admin(auth.uid()));


-- --------------------------------------------
-- RLS Policies: fines
-- --------------------------------------------

-- Users can view their own fines
CREATE POLICY fines_select_own ON fines
    FOR SELECT
    USING (auth.uid() = user_id);

-- Staff can view all fines
CREATE POLICY fines_select_staff ON fines
    FOR SELECT
    USING (is_staff(auth.uid()));

-- Only staff can insert fines
CREATE POLICY fines_insert_staff ON fines
    FOR INSERT
    WITH CHECK (is_staff(auth.uid()));

-- Users can update their own unpaid fines (to submit payment)
CREATE POLICY fines_update_own ON fines
    FOR UPDATE
    USING (auth.uid() = user_id AND status = 'unpaid');

-- Staff can update any fine
CREATE POLICY fines_update_staff ON fines
    FOR UPDATE
    USING (is_staff(auth.uid()));


-- ============================================
-- SECTION 6: INITIAL DATA (Optional)
-- ============================================

-- Insert default fine levels
INSERT INTO fine_levels (name, amount) VALUES
    ('Trả muộn (1 ngày)', 5000),
    ('Trả muộn (1 tuần)', 20000),
    ('Hư hỏng nhẹ', 50000),
    ('Hư hỏng nặng', 100000),
    ('Mất sách', 200000);

-- Insert default categories
INSERT INTO categories (name) VALUES
    ('Văn học'),
    ('Khoa học'),
    ('Công nghệ'),
    ('Kinh tế'),
    ('Lịch sử'),
    ('Tâm lý'),
    ('Giáo dục'),
    ('Thiếu nhi'),
    ('Truyện tranh'),
    ('Khác');


-- ============================================
-- END OF SCHEMA
-- ============================================

