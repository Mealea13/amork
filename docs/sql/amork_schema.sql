-- Enable UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USERS & AUTHENTICATION
-- ============================================
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
    oauth_provider VARCHAR(50),
    oauth_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE TABLE user_addresses (
    address_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    label VARCHAR(50) NOT NULL,
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

CREATE TABLE user_sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    refresh_token TEXT,
    device_type VARCHAR(50),
    device_name VARCHAR(100),
    device_token VARCHAR(500),
    ip_address VARCHAR(45),
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. CATEGORIES & FOODS
-- ============================================
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(255),
    color VARCHAR(7),
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE foods (
    food_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    food_name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    original_price DECIMAL(10, 2),
    image_url VARCHAR(500),
    calories INTEGER,
    cooking_time VARCHAR(20),
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0,
    is_popular BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_spicy BOOLEAN DEFAULT FALSE,
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 3. CART
-- ============================================
CREATE TABLE cart_items (
    cart_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    food_id INTEGER NOT NULL REFERENCES foods(food_id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 4. ORDERS & PAYMENTS
-- ============================================
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN (
        'pending', 'confirmed', 'preparing', 'ready',
        'out_for_delivery', 'delivered', 'cancelled'
    )),
    delivery_street TEXT,
    delivery_city VARCHAR(100),
    delivery_district VARCHAR(100),
    delivery_postal_code VARCHAR(20),
    delivery_phone VARCHAR(20),
    note TEXT,
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    delivery_fee DECIMAL(10, 2) DEFAULT 0.00,
    tax DECIMAL(10, 2) DEFAULT 0.00,
    discount DECIMAL(10, 2) DEFAULT 0.00,
    total DECIMAL(10, 2) NOT NULL CHECK (total >= 0),
    payment_method VARCHAR(50) CHECK (payment_method IN ('cash_on_delivery', 'qr_code', 'card', 'wallet')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    estimated_delivery_time TIMESTAMP,
    delivered_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ✅ FIXED: Added special_instructions column
CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    food_id INTEGER NOT NULL REFERENCES foods(food_id) ON DELETE RESTRICT,
    food_name VARCHAR(150) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE RESTRICT,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    transaction_id VARCHAR(255),
    qr_code_data TEXT,
    payment_proof TEXT,
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 5. PROMOTIONS & COUPONS
-- ============================================
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

-- ============================================
-- 6. REVIEWS & RATINGS
-- ============================================
CREATE TABLE reviews (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    food_id INTEGER NOT NULL REFERENCES foods(food_id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(order_id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, order_id, food_id)
);

-- ============================================
-- 7. FAVORITES
-- ============================================
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
CREATE TABLE notifications (
    notification_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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
-- 9. SUPPORT
-- ============================================
CREATE TABLE support_tickets (
    ticket_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(order_id),
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'resolved', 'closed')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

-- ============================================
-- 10. APP CONFIGURATION
-- ============================================
CREATE TABLE app_settings (
    setting_id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE restaurant_info (
    info_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    logo_url VARCHAR(500),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    is_open BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_foods_category ON foods(category_id);
CREATE INDEX idx_foods_popular ON foods(is_popular) WHERE is_popular = TRUE;
CREATE INDEX idx_foods_available ON foods(is_available) WHERE is_available = TRUE;
CREATE INDEX idx_cart_user ON cart_items(user_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_reviews_food ON reviews(food_id);
CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = FALSE;

-- ============================================
-- TRIGGERS
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_foods_updated_at
    BEFORE UPDATE ON foods FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_cart_items_updated_at
    BEFORE UPDATE ON cart_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE OR REPLACE FUNCTION update_food_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE foods
    SET rating = (SELECT AVG(rating) FROM reviews WHERE food_id = NEW.food_id),
        total_reviews = (SELECT COUNT(*) FROM reviews WHERE food_id = NEW.food_id)
    WHERE food_id = NEW.food_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_food_rating_trigger
    AFTER INSERT OR UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION update_food_rating();

-- ============================================
-- APP SETTINGS SEED DATA
-- ============================================
INSERT INTO app_settings (setting_key, setting_value, description, is_public) VALUES
('delivery_fee',            '1.00',  'Default delivery fee in USD', TRUE),
('tax_rate',                '0.05',  'Tax rate 5%',                 TRUE),
('min_order_amount',        '5.00',  'Minimum order amount',        TRUE),
('free_delivery_threshold', '20.00', 'Free delivery above this',    TRUE);

-- ============================================
-- CATEGORIES SEED DATA
-- ============================================
INSERT INTO categories (category_id, name, description, icon, color, display_order) VALUES
(1, 'Food',    'Delicious main dishes',     'food_icon.webp',    '#FF6B6B', 1),
(2, 'Drink',   'Refreshing beverages',      'drink_icon.webp',   '#4ECDC4', 2),
(3, 'Dessert', 'Sweet treats and desserts', 'dessert_icon.webp', '#95E1D3', 3),
(4, 'Snack',   'Light bites and snacks',    'snack_icon.webp',   '#FFE66D', 4);

SELECT setval('categories_category_id_seq', 4);

-- ============================================
-- FOOD SEED DATA (category 1)
-- ============================================
INSERT INTO foods (food_id, category_id, food_name, description, price, original_price, image_url, calories, cooking_time, rating, is_popular, is_available) VALUES
(1,   1, 'Avocado nido Salad',  'Healthy and fresh green salad',     4.05, NULL, 'assets/images/Salad.webp',         150, '10 min', 4.5, TRUE,  TRUE),
(2,   1, 'Cambodia Fish Amork', 'Traditional Cambodian dish',        6.00, NULL, 'assets/images/amork.webp',         350, '25 min', 4.8, TRUE,  TRUE),
(3,   1, 'Special Beef Burger', 'Double beef with extra cheese',     5.50, NULL, 'assets/images/Burger.webp',        600, '15 min', 4.7, TRUE,  TRUE),
(8,   1, 'Classic Pizza',       'Cheesy classic pizza',              8.00, NULL, 'assets/images/pizza.webp',         800, '30 min', 4.6, TRUE,  TRUE),
(9,   1, 'Num Ansorm',          'Traditional sticky rice cake',      2.50, NULL, 'assets/images/ansorm.webp',        350, '10 min', 4.4, FALSE, TRUE),
(10,  1, 'Khmer Curry',         'Rich and spicy chicken curry',      5.00, NULL, 'assets/images/Curry.webp',         500, '25 min', 4.6, FALSE, TRUE),
(11,  1, 'Spicy Wings',         'Hot and spicy chicken wings',       3.00, 6.00, 'assets/images/wings grill.webp',   400, '15 min', 4.7, TRUE,  TRUE),
(12,  1, 'Fried Rice',          'Pork fried rice with egg',          2.50, 5.00, 'assets/images/Bay cha.webp',       450, '20 min', 4.5, TRUE,  TRUE),
(101, 1, 'Kuy Teav',            'Pork broth noodle soup',            3.50, NULL, 'assets/images/Kuy teav.webp',      400, '15 min', 4.5, TRUE,  TRUE),
(102, 1, 'Papaya Salad',        'Spicy and sour green papaya',       2.50, NULL, 'assets/images/Papaya Salad.webp',  120, '10 min', 4.3, TRUE,  TRUE),
(103, 1, 'Tom Yum Goong',       'Spicy Thai shrimp soup',            7.00, NULL, 'assets/images/tong yum.webp',      250, '20 min', 4.7, TRUE,  TRUE),
(104, 1, 'Sushi Platter',       'Fresh salmon and tuna sushi',      12.00, NULL, 'assets/images/Sushi.webp',         450, '15 min', 4.8, TRUE,  TRUE),
(105, 1, 'Beef Lok Lak',        'Stir-fried beef with pepper sauce', 6.50, NULL, 'assets/images/lok lak.webp',       550, '20 min', 4.6, TRUE,  TRUE),
(106, 1, 'Grilled Steak',       'Premium ribeye medium rare',       15.00, NULL, 'assets/images/Steak.webp',         700, '25 min', 4.9, TRUE,  TRUE),
(107, 1, 'Lot Cha',             'Cambodian short noodle lot cha',    1.50, NULL, 'assets/images/lot cha.webp',       500, '15 min', 4.4, FALSE, TRUE),
(108, 1, 'Spicy Ramen',         'Japanese noodle soup',              5.00, NULL, 'assets/images/Ramen.webp',         480, '15 min', 4.6, TRUE,  TRUE),
(109, 1, 'Prahok Ktis',         'Minced pork with fermented fish',   4.00, NULL, 'assets/images/Brohok.webp',        400, '20 min', 4.3, FALSE, TRUE),
(110, 1, 'Bai Sach Chrouk',     'Pork and rice breakfast',           2.00, NULL, 'assets/images/Bay sach jruk.webp', 450, '5 min',  4.5, FALSE, TRUE),
(111, 1, 'Kralan',              'Bamboo sticky rice',                1.50, NULL, 'assets/images/krolan.webp',        200, '5 min',  4.2, FALSE, TRUE),
(112, 1, 'Nom Banh Chok',       'Khmer noodles with fish gravy',     2.50, NULL, 'assets/images/Nom banh jok.webp',  300, '10 min', 4.5, FALSE, TRUE),
(113, 1, 'Beef Tacos',          'Mexican street tacos',              3.50, 7.00, 'assets/images/Tacos.webp',         300, '10 min', 4.4, FALSE, TRUE),
(114, 1, 'Pork Dumplings',      'Steamed meat dumplings',            2.00, 4.00, 'assets/images/dumpling.webp',      250, '15 min', 4.5, FALSE, TRUE),
(115, 1, 'Dim Sum',             'Assorted Chinese bites',            4.00, 8.00, 'assets/images/dum sum.webp',       350, '20 min', 4.6, FALSE, TRUE);

-- ============================================
-- DRINKS SEED DATA (category 2)
-- ============================================
INSERT INTO foods (food_id, category_id, food_name, description, price, original_price, image_url, calories, cooking_time, rating, is_popular, is_available) VALUES
(201, 2, 'Fresh Lemonade',   'Cold refreshing drink',          1.00, 2.00, 'assets/images/lemonade.webp',                 120, '2 min', 4.3, FALSE, TRUE),
(202, 2, 'Iced Coffee',      'Sweet iced coffee',              1.75, 3.50, 'assets/images/iced latte.webp',               200, '3 min', 4.5, TRUE,  TRUE),
(203, 2, 'Coca Cola',        'Classic soda',                   0.75, 1.50, 'assets/images/coke.webp',                     140, '1 min', 4.2, FALSE, TRUE),
(204, 2, 'Brown Sugar Boba', 'Milk tea with sweet pearls',     2.00, 4.00, 'assets/images/Boba.webp',                     350, '5 min', 4.7, TRUE,  TRUE),
(205, 2, 'Mango Smoothie',   'Blended fresh mango',            1.50, 3.00, 'assets/images/smoothies.webp',                250, '5 min', 4.5, FALSE, TRUE),
(206, 2, 'Green Tea',        'Healthy hot green tea',          2.50, NULL, 'assets/images/green-tea.webp',                  0, '3 min', 4.4, TRUE,  TRUE),
(207, 2, 'Matcha Latte',     'Premium Japanese matcha',        4.50, NULL, 'assets/images/matcha-latte.webp',             220, '5 min', 4.8, TRUE,  TRUE),
(208, 2, 'Americano',        'Black coffee',                   2.50, NULL, 'assets/images/pngtree-americano-coffee-.webp',  10, '3 min', 4.5, TRUE,  TRUE),
(209, 2, 'Cappuccino',       'Espresso with milk foam',        3.50, NULL, 'assets/images/coffee-cappuccino.webp',         150, '4 min', 4.6, TRUE,  TRUE),
(210, 2, 'Orange Juice',     'Freshly squeezed',               3.00, NULL, 'assets/images/orange-juice.webp',             110, '2 min', 4.5, TRUE,  TRUE),
(211, 2, 'Apple Juice',      'Sweet apple juice',              2.50, NULL, 'assets/images/apple_juice.webp',              100, '2 min', 4.3, FALSE, TRUE),
(212, 2, 'Strawberry Shake', 'Thick creamy shake',             5.00, NULL, 'assets/images/milkshake.webp',                500, '5 min', 4.6, FALSE, TRUE),
(213, 2, 'Caramel Frappe',   'Blended coffee with caramel',    5.50, NULL, 'assets/images/frappe.webp',                   550, '6 min', 4.7, FALSE, TRUE),
(214, 2, 'Hot Mocha',        'Coffee mixed with chocolate',    4.00, NULL, 'assets/images/mocha.webp',                    250, '4 min', 4.5, FALSE, TRUE),
(215, 2, 'Hot Chocolate',    'Warm cocoa with marshmallows',   3.50, NULL, 'assets/images/hot_choco.webp',                300, '5 min', 4.4, FALSE, TRUE),
(216, 2, 'Fresh Coconut',    'Whole fresh coconut',            2.00, NULL, 'assets/images/coconut.webp',                   50, '1 min', 4.5, TRUE,  TRUE),
(217, 2, 'Passion Fruit',    'Sweet and sour tropical drink',  3.00, NULL, 'assets/images/passion_fruit_juice.webp',      130, '3 min', 4.4, TRUE,  TRUE),
(218, 2, 'Club Soda',        'Sparkling water',                1.00, NULL, 'assets/images/soda.webp',                       0, '1 min', 4.0, FALSE, TRUE),
(219, 2, 'Mineral Water',    'Bottled water',                  0.50, NULL, 'assets/images/water.webp',                      0, '1 min', 4.0, FALSE, TRUE),
(220, 2, 'Energy Drink',     'Red Bull energy',                2.50, NULL, 'assets/images/Energy_drink.webp',             110, '1 min', 4.3, FALSE, TRUE);

-- ============================================
-- DESSERTS SEED DATA (category 3)
-- ============================================
INSERT INTO foods (food_id, category_id, food_name, description, price, original_price, image_url, calories, cooking_time, rating, is_popular, is_available) VALUES
(301, 3, 'Strawberry Cake',    'Sweet and creamy dessert',         2.25, 4.50, 'assets/images/cake.webp',       450, '10 min', 4.6, FALSE, TRUE),
(302, 3, 'Vanilla Ice Cream',  'Two scoops of vanilla',            1.25, 2.50, 'assets/images/ice_cream.webp',  300, '2 min',  4.5, FALSE, TRUE),
(303, 3, 'Chocolate Brownie',  'Warm chocolate fudge',             1.50, 3.00, 'assets/images/brownie.webp',    400, '5 min',  4.6, FALSE, TRUE),
(304, 3, 'Pancakes',           'Fluffy pancakes with syrup',       2.00, 4.00, 'assets/images/pancakes.webp',   350, '10 min', 4.5, FALSE, TRUE),
(305, 3, 'Belgian Waffles',    'Crispy waffles with honey',        2.25, 4.50, 'assets/images/waffles.webp',    380, '10 min', 4.6, FALSE, TRUE),
(306, 3, 'NY Cheesecake',      'Classic creamy slice',             5.00, NULL, 'assets/images/cheesecake.webp', 500, '5 min',  4.8, TRUE,  TRUE),
(307, 3, 'Tiramisu',           'Italian coffee dessert',           5.50, NULL, 'assets/images/tiramisu.webp',   450, '5 min',  4.8, TRUE,  TRUE),
(308, 3, 'Macarons (3pcs)',    'French almond cookies',            6.00, NULL, 'assets/images/macarons.webp',   200, '2 min',  4.7, TRUE,  TRUE),
(309, 3, 'Glazed Donut',       'Sweet sugar ring',                 1.50, NULL, 'assets/images/donut.webp',      250, '2 min',  4.4, FALSE, TRUE),
(310, 3, 'Churros',            'Fried dough with chocolate',       3.50, NULL, 'assets/images/churros.webp',    350, '8 min',  4.5, FALSE, TRUE),
(311, 3, 'Caramel Pudding',    'Soft flan dessert',                3.00, NULL, 'assets/images/pudding.webp',    250, '5 min',  4.4, FALSE, TRUE),
(312, 3, 'Fruit Tart',         'Crispy shell with fresh fruit',    4.00, NULL, 'assets/images/tart.webp',       300, '5 min',  4.6, FALSE, TRUE),
(313, 3, 'Mango Gelato',       'Italian style ice cream',          3.50, NULL, 'assets/images/gelato.webp',     220, '3 min',  4.7, FALSE, TRUE),
(314, 3, 'Chocolate Mousse',   'Light and airy chocolate',         4.50, NULL, 'assets/images/mousse.webp',     350, '5 min',  4.7, FALSE, TRUE),
(315, 3, 'Red Velvet Cupcake', 'Small cake with frosting',         2.50, NULL, 'assets/images/cupcake.webp',    280, '3 min',  4.5, FALSE, TRUE),
(316, 3, 'Lemon Sorbet',       'Dairy-free frozen treat',          2.50, NULL, 'assets/images/sorbet.webp',     150, '3 min',  4.4, TRUE,  TRUE),
(317, 3, 'Korean Bingsu',      'Shaved ice with sweet beans',      7.00, NULL, 'assets/images/bingsu.webp',     500, '10 min', 4.8, TRUE,  TRUE),
(318, 3, 'French Crepes',      'Thin pancake with Nutella',        4.50, NULL, 'assets/images/crepes.webp',     400, '8 min',  4.6, TRUE,  TRUE),
(319, 3, 'Chocolate Eclair',   'Cream-filled pastry',              3.50, NULL, 'assets/images/eclair.webp',     300, '5 min',  4.5, TRUE,  TRUE),
(320, 3, 'Choco Chip Cookies', 'Two warm cookies',                 2.00, NULL, 'assets/images/cookies.webp',    250, '3 min',  4.4, TRUE,  TRUE);

-- ============================================
-- SNACKS SEED DATA (category 4)
-- ============================================
INSERT INTO foods (food_id, category_id, food_name, description, price, original_price, image_url, calories, cooking_time, rating, is_popular, is_available) VALUES
(401, 4, 'Crispy Fries',      'Hot salty french fries',         1.50, 3.00, 'assets/images/fries.webp',        300, '10 min', 4.6, FALSE, TRUE),
(402, 4, 'Cheese Nachos',     'Chips with melted cheese',       2.25, 4.50, 'assets/images/nachos.webp',       400, '10 min', 4.5, FALSE, TRUE),
(403, 4, 'Onion Rings',       'Deep fried onion rings',         1.75, 3.50, 'assets/images/onion_rings.webp',  350, '15 min', 4.4, FALSE, TRUE),
(404, 4, 'Movie Popcorn',     'Buttery popcorn',                1.00, 2.00, 'assets/images/popcorn.webp',      200, '5 min',  4.3, FALSE, TRUE),
(405, 4, 'Potato Chips',      'Crunchy salted chips',           0.75, 1.50, 'assets/images/chips.webp',        150, '2 min',  4.2, FALSE, TRUE),
(406, 4, 'Soft Pretzel',      'Warm salted pretzel',            3.00, NULL, 'assets/images/pretzel.webp',      280, '5 min',  4.4, TRUE,  TRUE),
(407, 4, 'Chicken Nuggets',   '6 piece golden nuggets',         4.50, NULL, 'assets/images/nuggets.webp',      380, '10 min', 4.7, TRUE,  TRUE),
(408, 4, 'Mozzarella Sticks', 'Fried cheese with marinara',     5.00, NULL, 'assets/images/mozzarella.webp',   450, '12 min', 4.6, TRUE,  TRUE),
(409, 4, 'Garlic Bread',      'Toasted buttery bread',          3.50, NULL, 'assets/images/garlic_bread.webp', 300, '8 min',  4.5, FALSE, TRUE),
(410, 4, 'Spring Rolls',      'Crispy veggie rolls',            4.00, NULL, 'assets/images/spring_rolls.webp', 250, '10 min', 4.6, FALSE, TRUE),
(411, 4, 'Meat Samosa',       'Fried pastry with filling',      3.50, NULL, 'assets/images/samosa.webp',       350, '12 min', 4.5, FALSE, TRUE),
(412, 4, 'Edamame',           'Steamed soybeans with salt',     3.00, NULL, 'assets/images/edamame.webp',      120, '5 min',  4.4, FALSE, TRUE),
(413, 4, 'Cheese Crackers',   'Baked snack crackers',           2.00, NULL, 'assets/images/crackers.webp',     180, '2 min',  4.2, FALSE, TRUE),
(414, 4, 'Roasted Nuts',      'Mixed salted nuts',              4.00, NULL, 'assets/images/roasted_nuts.webp', 400, '2 min',  4.4, FALSE, TRUE),
(415, 4, 'Dried Fruit Mix',   'Healthy dried fruits',           3.50, NULL, 'assets/images/dried_fruit.webp',  250, '2 min',  4.3, FALSE, TRUE),
(416, 4, 'Potato Wedges',     'Thick cut seasoned fries',       3.50, NULL, 'assets/images/wedges.webp',       320, '15 min', 4.5, TRUE,  TRUE),
(417, 4, 'Corn Dog',          'Fried sausage on a stick',       2.50, NULL, 'assets/images/corn_dog.webp',     300, '10 min', 4.4, TRUE,  TRUE),
(418, 4, 'Hash Browns',       'Crispy fried potato',            2.00, NULL, 'assets/images/hash_browns.webp',  250, '8 min',  4.3, TRUE,  TRUE),
(419, 4, 'Tater Tots',        'Bite-sized potato puffs',        3.00, NULL, 'assets/images/tater_tots.webp',   280, '10 min', 4.4, TRUE,  TRUE),
(420, 4, 'Beef Jerky',        'Dried and seasoned beef',        6.00, NULL, 'assets/images/beef_jerky.webp',   200, '2 min',  4.5, TRUE,  TRUE);

SELECT setval('foods_food_id_seq', (SELECT MAX(food_id) FROM foods));

-- ============================================
-- VERIFY
-- ============================================
SELECT COUNT(*) AS total_foods FROM foods;
SELECT category_id, COUNT(*) AS count FROM foods GROUP BY category_id ORDER BY category_id;