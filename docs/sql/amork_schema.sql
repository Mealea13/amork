-- Database Schema for Amork App
-- PostgreSQL Password: Mealea13042004

CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    fullname VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    password_text TEXT NOT NULL, 
    phone_number VARCHAR(20),
    membership_type VARCHAR(20) DEFAULT 'Member', 
    profile_image_url TEXT
);

CREATE TABLE IF NOT EXISTS foods (
    food_id SERIAL PRIMARY KEY,
    food_name VARCHAR(100) NOT NULL,
    food_description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    calories INTEGER,
    cooking_time VARCHAR(20),
    image_url TEXT
);

-- Seed Data for Initial Testing
INSERT INTO users (fullname, email, password_text, phone_number, membership_type)
VALUES ('Mealea', 'loopy@gmail.com', 'Mealea13042004', '+855 12345678', 'VIP')
ON CONFLICT (email) DO NOTHING;

INSERT INTO foods (food_name, food_description, price, calories, cooking_time, image_url)
VALUES
('Cambodia Fish Amork', 'Traditional Khmer steamed curry fish.', 6.00, 44, '25 min', 'http://192.168.1.86:5000/images/amork.png'),
('Avocado Nido Salad', 'Fresh healthy green salad with avocado.', 4.05, 32, '15 min', 'http://192.168.1.86:5000/images/salad.png')
ON CONFLICT DO NOTHING;