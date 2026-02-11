-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USERS & AUTHENTICATION
-- ============================================

-- Users Table
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fullname VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    profile_image VARCHAR(500),
    date_of_birth DATE,
    gender VARCHAR(20) CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    member_type VARCHAR(20) DEFAULT 'regular' CHECK (member_type IN ('regular', 'premium', 'vip')),
    email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    oauth_provider VARCHAR(50), -- 'google', 'facebook', etc.
    oauth_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- User Addresses
CREATE TABLE user_addresses (
    address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    label VARCHAR(50) NOT NULL, -- 'Home', 'Office', etc.
    street TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Sessions (for token management)
CREATE TABLE user_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    refresh_token TEXT,
    device_type VARCHAR(50), -- 'android', 'ios', 'web'
    device_name VARCHAR(100),
    device_token VARCHAR(500), -- FCM token for push notifications
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. CATEGORIES & FOOD ITEMS
-- ============================================

-- Categories Table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(255),
    color VARCHAR(7), -- Hex color code
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Food Items Table
CREATE TABLE foods (
    food_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    food_name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    image_url VARCHAR(500),
    calories INTEGER,
    cooking_time VARCHAR(20), -- '20 min', '30 min', etc.
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0,
    is_popular BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_spicy BOOLEAN DEFAULT FALSE,
    spicy_level INTEGER CHECK (spicy_level BETWEEN 0 AND 5),
    tags TEXT[], -- Array of tags: ['traditional', 'healthy', 'new']
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Food Ingredients (Base ingredients)
CREATE TABLE food_ingredients (
    ingredient_id SERIAL PRIMARY KEY,
    food_id INTEGER NOT NULL REFERENCES foods(food_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    quantity VARCHAR(50), -- '200g', '2 stalks', etc.
    is_required BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Additional Ingredients (Optional add-ons with price)
CREATE TABLE additional_ingredients (
    additional_ingredient_id SERIAL PRIMARY KEY,
    food_id INTEGER NOT NULL REFERENCES foods(food_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. SHOPPING CART
-- ============================================

-- Cart Items
CREATE TABLE cart_items (
    cart_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    food_id INTEGER NOT NULL REFERENCES foods(food_id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cart Item Additional Ingredients (Many-to-Many)
CREATE TABLE cart_item_additions (
    cart_addition_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_item_id UUID NOT NULL REFERENCES cart_items(cart_item_id) ON DELETE CASCADE,
    additional_ingredient_id INTEGER NOT NULL REFERENCES additional_ingredients(additional_ingredient_id) ON DELETE CASCADE,
    quantity INTEGER DEFAULT 1,
    price_at_addition DECIMAL(10, 2) NOT NULL -- Store price at time of adding
);

-- ============================================
-- 4. ORDERS & PAYMENTS
-- ============================================

-- Orders Table
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    order_number VARCHAR(20) UNIQUE NOT NULL, -- e.g., 'ORD-20250206-0001'
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending', 'confirmed', 'preparing', 'ready',
        'out_for_delivery', 'delivered', 'cancelled'
    )),
    -- Delivery Information
    delivery_address_id UUID REFERENCES user_addresses(address_id),
    delivery_street TEXT,
    delivery_city VARCHAR(100),
    delivery_district VARCHAR(100),
    delivery_postal_code VARCHAR(20),
    delivery_phone VARCHAR(20),
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    -- Order Note
    note TEXT,
    -- Pricing
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    delivery_fee DECIMAL(10, 2) DEFAULT 0.00 CHECK (delivery_fee >= 0),
    tax DECIMAL(10, 2) DEFAULT 0.00 CHECK (tax >= 0),
    discount DECIMAL(10, 2) DEFAULT 0.00 CHECK (discount >= 0),
    total DECIMAL(10, 2) NOT NULL CHECK (total >= 0),
    -- Payment
    payment_method VARCHAR(50) CHECK (payment_method IN ('cash_on_delivery', 'qr_code', 'card', 'wallet')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    -- Tracking
    estimated_delivery_time TIMESTAMP,
    delivered_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order Items
CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    food_id INTEGER NOT NULL REFERENCES foods(food_id) ON DELETE RESTRICT,
    food_name VARCHAR(150) NOT NULL, -- Store name for historical records
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT,
    subtotal DECIMAL(10, 2) NOT NULL, -- quantity × unit_price
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order Item Additional Ingredients
CREATE TABLE order_item_additions (
    order_addition_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_item_id UUID NOT NULL REFERENCES order_items(order_item_id) ON DELETE CASCADE,
    ingredient_name VARCHAR(100) NOT NULL,
    quantity INTEGER DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL
);

-- Order Status History (Track all status changes)
CREATE TABLE order_status_history (
    history_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    note TEXT,
    changed_by UUID REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments Table
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE RESTRICT,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    transaction_id VARCHAR(255), -- External payment gateway transaction ID
    qr_code_data TEXT, -- QR code content for QR payments
    payment_proof TEXT, -- Base64 image or URL
    paid_at TIMESTAMP,
    refunded_at TIMESTAMP,
    refund_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 5. PROMOTIONS & COUPONS
-- ============================================

-- Promotions
CREATE TABLE promotions (
    promotion_id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    discount_type VARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed_amount')),
    discount_value DECIMAL(10, 2) NOT NULL,
    min_order_amount DECIMAL(10, 2) DEFAULT 0,
    max_discount_amount DECIMAL(10, 2),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Coupons
CREATE TABLE coupons (
    coupon_id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) CHECK (discount_type IN ('percentage', 'fixed_amount')),
    discount_value DECIMAL(10, 2) NOT NULL,
    min_order_amount DECIMAL(10, 2) DEFAULT 0,
    max_discount_amount DECIMAL(10, 2),
    max_usage_count INTEGER,
    current_usage_count INTEGER DEFAULT 0,
    max_usage_per_user INTEGER DEFAULT 1,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Coupon Usage
CREATE TABLE user_coupon_usage (
    usage_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    coupon_id INTEGER NOT NULL REFERENCES coupons(coupon_id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(order_id),
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, coupon_id, order_id)
);

-- ============================================
-- 6. REVIEWS & RATINGS
-- ============================================

-- Reviews
CREATE TABLE reviews (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    food_id INTEGER NOT NULL REFERENCES foods(food_id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(order_id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    images TEXT[], -- Array of image URLs
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, order_id, food_id) -- One review per food per order
);

-- Review Helpfulness (Users mark reviews as helpful)
CREATE TABLE review_helpfulness (
    helpfulness_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    review_id UUID NOT NULL REFERENCES reviews(review_id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    is_helpful BOOLEAN NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(review_id, user_id)
);

-- ============================================
-- 7. FAVORITES
-- ============================================

-- User Favorites
CREATE TABLE favorites (
    favorite_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    food_id INTEGER NOT NULL REFERENCES foods(food_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, food_id)
);

-- ============================================
-- 8. NOTIFICATIONS
-- ============================================

-- Notifications
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 'order_update', 'promotion', 'new_item', etc.
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    data JSONB, -- Additional data (order_id, food_id, etc.)
    image_url VARCHAR(500),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notification Settings
CREATE TABLE notification_settings (
    setting_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    order_updates BOOLEAN DEFAULT TRUE,
    promotions BOOLEAN DEFAULT TRUE,
    new_items BOOLEAN DEFAULT FALSE,
    push_enabled BOOLEAN DEFAULT TRUE,
    email_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 9. SUPPORT & FEEDBACK
-- ============================================

-- Support Tickets
CREATE TABLE support_tickets (
    ticket_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(order_id),
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- Support Messages
CREATE TABLE support_messages (
    message_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID NOT NULL REFERENCES support_tickets(ticket_id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(user_id),
    is_staff_reply BOOLEAN DEFAULT FALSE,
    message TEXT NOT NULL,
    attachments TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 10. APP CONFIGURATION
-- ============================================

-- App Settings
CREATE TABLE app_settings (
    setting_id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    description TEXT,
    data_type VARCHAR(20) DEFAULT 'string', -- 'string', 'number', 'boolean', 'json'
    is_public BOOLEAN DEFAULT FALSE, -- Can be accessed by mobile app
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Restaurant Information
CREATE TABLE restaurant_info (
    info_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    logo_url VARCHAR(500),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    opening_hours JSONB, -- {"monday": {"open": "08:00", "close": "22:00"}, ...}
    is_open BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_oauth ON users(oauth_provider, oauth_id);

-- Sessions
CREATE INDEX idx_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_sessions_token ON user_sessions(token);

-- Addresses
CREATE INDEX idx_addresses_user ON user_addresses(user_id);

-- Foods
CREATE INDEX idx_foods_category ON foods(category_id);
CREATE INDEX idx_foods_popular ON foods(is_popular) WHERE is_popular = TRUE;
CREATE INDEX idx_foods_available ON foods(is_available) WHERE is_available = TRUE;
CREATE INDEX idx_foods_rating ON foods(rating DESC);

-- Cart
CREATE INDEX idx_cart_user ON cart_items(user_id);
CREATE INDEX idx_cart_food ON cart_items(food_id);

-- Orders
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_number ON orders(order_number);
CREATE INDEX idx_orders_created ON orders(created_at DESC);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);

-- Order Items
CREATE INDEX idx_order_items_order ON order_items(order_id);

-- Payments
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);

-- Reviews
CREATE INDEX idx_reviews_food ON reviews(food_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating DESC);

-- Favorites
CREATE INDEX idx_favorites_user ON favorites(user_id);

-- Notifications
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;

-- Support
CREATE INDEX idx_tickets_user ON support_tickets(user_id);
CREATE INDEX idx_tickets_status ON support_tickets(status);

-- ============================================
-- TRIGGERS FOR AUTO-UPDATE
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply trigger to relevant tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_addresses_updated_at BEFORE UPDATE ON user_addresses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_foods_updated_at BEFORE UPDATE ON foods
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cart_items_updated_at BEFORE UPDATE ON cart_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_settings_updated_at BEFORE UPDATE ON notification_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- VIEWS FOR COMMON QUERIES
-- ============================================

-- View: Food with Average Rating
CREATE OR REPLACE VIEW v_foods_with_ratings AS
SELECT
    f.*,
    COALESCE(AVG(r.rating), 0) as avg_rating,
    COUNT(r.review_id) as review_count
FROM foods f
LEFT JOIN reviews r ON f.food_id = r.food_id
GROUP BY f.food_id;

-- View: User Order Statistics
CREATE OR REPLACE VIEW v_user_order_stats AS
SELECT
    u.user_id,
    u.fullname,
    u.email,
    COUNT(o.order_id) as total_orders,
    SUM(o.total) as total_spent,
    AVG(o.total) as avg_order_value,
    MAX(o.created_at) as last_order_date
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id AND o.status != 'cancelled'
GROUP BY u.user_id, u.fullname, u.email;

-- View: Popular Foods
CREATE OR REPLACE VIEW v_popular_foods AS
SELECT 
    f.*,
    COUNT(DISTINCT oi.order_id) as order_count,
    SUM(oi.quantity) as total_sold
FROM foods f
LEFT JOIN order_items oi ON f.food_id = oi.food_id
GROUP BY f.food_id
ORDER BY order_count DESC, total_sold DESC;

-- View: Active Promotions
CREATE OR REPLACE VIEW v_active_promotions AS
SELECT * FROM promotions
WHERE is_active = TRUE
  AND CURRENT_TIMESTAMP BETWEEN start_date AND end_date;

-- View: Active Coupons
CREATE OR REPLACE VIEW v_active_coupons AS
SELECT * FROM coupons
WHERE is_active = TRUE
  AND CURRENT_TIMESTAMP BETWEEN start_date AND end_date
  AND (max_usage_count IS NULL OR current_usage_count < max_usage_count);

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert Default Categories
INSERT INTO categories (name, description, icon, color, display_order) VALUES
('Food', 'Delicious Cambodian main dishes', 'food_icon.png', '#FF6B6B', 1),
('Drink', 'Refreshing beverages and drinks', 'drink_icon.png', '#4ECDC4', 2),
('Snack', 'Light bites and snacks', 'snack_icon.png', '#FFE66D', 3),
('Dessert', 'Sweet treats and desserts', 'dessert_icon.png', '#95E1D3', 4);

-- Insert Sample Foods
INSERT INTO foods (category_id, food_name, description, price, calories, cooking_time, rating, is_popular) VALUES
(1, 'Cambodia Fish Amork', 'Traditional Cambodian fish dish with coconut cream', 6.00, 350, '25 min', 4.8, TRUE),
(1, 'Avocado ndo Salad', 'Fresh salad with avocado and vegetables', 5.00, 220, '10 min', 4.5, TRUE),
(2, 'Cambodia Fish Amork Drink', 'Refreshing coconut-based drink', 3.00, 120, '5 min', 4.2, FALSE);

-- Insert App Settings
INSERT INTO app_settings (setting_key, setting_value, description, data_type, is_public) VALUES
('delivery_fee', '1.00', 'Default delivery fee in USD', 'number', TRUE),
('tax_rate', '0.05', 'Tax rate (5%)', 'number', TRUE),
('min_order_amount', '5.00', 'Minimum order amount', 'number', TRUE),
('free_delivery_threshold', '20.00', 'Free delivery above this amount', 'number', TRUE),
('max_delivery_distance', '10', 'Maximum delivery distance in km', 'number', TRUE);

-- ============================================
-- FUNCTIONS FOR CALCULATIONS
-- ============================================

-- Function: Calculate Order Total
CREATE OR REPLACE FUNCTION calculate_order_total(
    p_order_id UUID
)
RETURNS TABLE (
    subtotal DECIMAL(10,2),
    delivery_fee DECIMAL(10,2),
    tax DECIMAL(10,2),
    discount DECIMAL(10,2),
    total DECIMAL(10,2)
) AS $$
DECLARE
    v_subtotal DECIMAL(10,2);
    v_delivery_fee DECIMAL(10,2);
    v_tax DECIMAL(10,2);
    v_discount DECIMAL(10,2);
    v_tax_rate DECIMAL(5,4);
BEGIN
    -- Calculate subtotal from order items
    SELECT COALESCE(SUM(oi.subtotal + COALESCE(oia_sum.total, 0)), 0)
    INTO v_subtotal
    FROM order_items oi
    LEFT JOIN (
        SELECT order_item_id, SUM(subtotal) as total
        FROM order_item_additions
        GROUP BY order_item_id
    ) oia_sum ON oi.order_item_id = oia_sum.order_item_id
    WHERE oi.order_id = p_order_id;
    -- Get delivery fee from settings
    SELECT CAST(setting_value AS DECIMAL(10,2))
    INTO v_delivery_fee
    FROM app_settings
    WHERE setting_key = 'delivery_fee';
    -- Get tax rate
    SELECT CAST(setting_value AS DECIMAL(5,4))
    INTO v_tax_rate
    FROM app_settings
    WHERE setting_key = 'tax_rate';
    -- Calculate tax
    v_tax := v_subtotal * v_tax_rate;
    -- Get discount (if any coupon applied)
    v_discount := 0; -- Implement coupon logic here
    -- Return calculated values
    RETURN QUERY SELECT
        v_subtotal,
        v_delivery_fee,
        v_tax,
        v_discount,
        (v_subtotal + v_delivery_fee + v_tax - v_discount) as total;
END;
$$ LANGUAGE plpgsql;

-- Function: Update Food Rating
CREATE OR REPLACE FUNCTION update_food_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE foods
    SET 
        rating = (SELECT AVG(rating) FROM reviews WHERE food_id = NEW.food_id),
        total_reviews = (SELECT COUNT(*) FROM reviews WHERE food_id = NEW.food_id)
    WHERE food_id = NEW.food_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger: Auto-update food rating when review is added/updated
CREATE TRIGGER update_food_rating_trigger
AFTER INSERT OR UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_food_rating();

-- ============================================
-- GRANT PERMISSIONS (Adjust based on your user)
-- ============================================

-- Example: Grant all privileges to your app user
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO amork_app_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO amork_app_user;

-- ============================================
-- DATABASE READY FOR USE!
-- ============================================