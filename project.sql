-- حذف قاعدة البيانات إذا كانت موجودة
DROP DATABASE IF EXISTS shamdeals_dba;

CREATE DATABASE IF NOT EXISTS shamdeals_dba;
USE shamdeals_dba;

-- جدول المستخدمين
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) UNIQUE,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    user_type ENUM('buyer', 'seller', 'both') DEFAULT 'both'
);

INSERT INTO Users (username, email, password_hash, phone_number, user_type)
VALUES
('ahmad', 'ahmad@mail.com', 'hash1', '0999999991', 'seller'),
('sara', 'sara@mail.com', 'hash2', '0999999992', 'buyer'),
('khaled', 'khaled@mail.com', 'hash3', '0999999993', 'both'),
('lina', 'lina@mail.com', 'hash4', '0999999994', 'seller'),
('omar', 'omar@mail.com', 'hash5', '0999999995', 'buyer');

-- جدول التصنيفات
CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);

INSERT INTO Categories (category_name, description)
VALUES
('عقارات', 'بيع وشراء وتأجير العقارات'),
('سيارات', 'بيع وشراء وتأجير السيارات'),
('أراضي', 'بيع وشراء الأراضي'),
('مكاتب', 'تأجير المكاتب التجارية'),
('محلات', 'تأجير وبيع المحلات التجارية');

-- جدول الإعلانات
CREATE TABLE Listings (
    listing_id INT AUTO_INCREMENT PRIMARY KEY,
    seller_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'SYP',
    listing_type ENUM('sale', 'rent') NOT NULL,
    location VARCHAR(255),
    posted_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'sold', 'rented', 'pending', 'inactive') DEFAULT 'active',
    views_count INT DEFAULT 0,
    FOREIGN KEY (seller_id) REFERENCES Users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE RESTRICT
);

INSERT INTO Listings (seller_id, category_id, title, description, price, listing_type, location)
VALUES
(1, 1, 'شقة للبيع في دمشق', 'شقة 3 غرف وصالون', 120000000, 'sale', 'دمشق - المزة'),
(3, 2, 'Toyota Corolla 2015', 'Well maintained car', 7500.00, 'sale', 'Aleppo'),
(4, 1, 'منزل للإيجار في اللاذقية', 'منزل مفروش', 3000000, 'rent', 'اللاذقية - الرمل'),
(3, 3, 'أرض زراعية للبيع', 'أرض مساحتها 2 دونم', 50000000, 'sale', 'ريف دمشق - دوما'),
(4, 4, 'مكتب تجاري للإيجار', 'مكتب مجهز بالكامل', 1500000, 'rent', 'حلب - الجميلية'),
(1, 2, 'Honda Civic 2017', 'Used, in good condition', 8500.00, 'sale', 'Damascus'),
(4, 2, 'Ford Focus 2018', 'Reliable compact car', 9000.00, 'sale', 'Homs'),
(5, 2, 'BMW 320i 2019', 'Luxury sedan', 15000.00, 'sale', 'Latakia'),
(2, 2, 'Mercedes C200 2020', 'Excellent condition', 18000.00, 'sale', 'Hama');

-- جدول الخصائص
CREATE TABLE Properties (
    property_id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT UNIQUE NOT NULL,
    property_type ENUM('apartment', 'house', 'land', 'commercial', 'office') NOT NULL,
    area_sqm DECIMAL(10, 2),
    amenities JSON,
    city VARCHAR(100) NOT NULL,
    district VARCHAR(100),
    FOREIGN KEY (listing_id) REFERENCES Listings(listing_id) ON DELETE CASCADE
);

INSERT INTO Properties (listing_id, property_type, area_sqm, amenities, city, district)
VALUES
(1, 'apartment', 120.50, '{"elevator": true, "parking": true}', 'دمشق', 'المزة'),
(3, 'house', 180.00, '{"garden": true, "ac": true}', 'اللاذقية', 'الرمل'),
(4, 'land', 2000.00, '{"water": true}', 'ريف دمشق', 'دوما'),
(5, 'office', 60.00, '{"internet": true, "furniture": true}', 'حلب', 'الجميلية'),
(9, 'commercial', 100.00, '{"parking": true}', 'دمشق', 'البرامكة');


-- جدول السيارات (Vehicles) مع 5 سجلات صحيحة
CREATE TABLE Vehicles (
    vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT UNIQUE NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year YEAR NOT NULL,
    fuel_type ENUM('petrol', 'diesel', 'electric', 'hybrid'),
    FOREIGN KEY (listing_id) REFERENCES Listings(listing_id) ON DELETE CASCADE
);

INSERT INTO Vehicles (listing_id, make, model, year, fuel_type)
VALUES
(2, 'Toyota', 'Corolla', 2015,  'petrol'),
(6, 'Honda', 'Civic', 2017,  'petrol'),
(7, 'Ford', 'Focus', 2018,  'diesel'),
(8, 'BMW', '320i', 2019,  'hybrid'),
(9, 'Mercedes', 'C200', 2020, 'petrol');

-- جدول العقود
CREATE TABLE Contracts (
    contract_id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    buyer_id INT NOT NULL,
    contract_type ENUM('sale', 'rent') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    agreed_price DECIMAL(15, 2) NOT NULL,
    contract_status ENUM('active', 'completed', 'cancelled') DEFAULT 'active',
    contract_details TEXT,
    signed_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    contract_file_url VARCHAR(255),
    FOREIGN KEY (listing_id) REFERENCES Listings(listing_id) ON DELETE RESTRICT,
    FOREIGN KEY (buyer_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);

INSERT INTO Contracts (listing_id, buyer_id, contract_type, start_date, end_date, agreed_price, contract_status, contract_details, contract_file_url)
VALUES
(1, 2, 'sale', '2025-01-01', '2025-12-31', 120000000, 'completed', 'تم البيع بشكل نهائي', 'contracts/1.pdf'),
(2, 5, 'sale', '2025-02-01', '2025-12-31', 70000000, 'completed', 'تم البيع', 'contracts/2.pdf'),
(3, 3, 'rent', '2025-03-01', '2026-03-01', 3000000, 'active', 'عقد إيجار سنوي', 'contracts/3.pdf'),
(4, 2, 'sale', '2025-04-01', '2025-12-31', 50000000, 'active', 'عقد بيع أرض', 'contracts/4.pdf'),
(5, 5, 'rent', '2025-05-01', '2026-05-01', 1500000, 'active', 'عقد إيجار مكتب', 'contracts/5.pdf');


-- جدول المدفوعات
CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    contract_id INT NOT NULL,
    payer_id INT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('cash', 'bank_transfer', 'online_gateway') NOT NULL,
    payment_receipt_url VARCHAR(250),
    FOREIGN KEY (contract_id) REFERENCES Contracts(contract_id) ON DELETE RESTRICT,
    FOREIGN KEY (payer_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);

INSERT INTO Payments (contract_id, payer_id, amount, payment_method, payment_receipt_url)
VALUES
(1, 2, 120000000, 'bank_transfer', 'receipts/1.pdf'),
(2, 5, 70000000, 'cash', 'receipts/2.pdf'),
(3, 3, 3000000, 'bank_transfer', 'receipts/3.pdf'),
(4, 2, 25000000, 'online_gateway', 'receipts/4.pdf'),
(5, 5, 1500000, 'cash', 'receipts/5.pdf');

-- جدول التقييمات
CREATE TABLE Ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT,
    reviewer_id INT NOT NULL,
    rating_value TINYINT NOT NULL CHECK (rating_value BETWEEN 1 AND 5),
    comment TEXT,
    rating_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES Listings(listing_id) ON DELETE SET NULL,
    FOREIGN KEY (reviewer_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

INSERT INTO Ratings (listing_id, reviewer_id, rating_value, comment)
VALUES
(1, 3, 5, 'شقة رائعة وتعامل ممتاز'),
(2, 2, 4, 'السيارة بحالة جيدة'),
(3, 5, 5, 'المنزل نظيف ومرتب'),
(4, 1, 3, 'الأرض بعيدة قليلاً عن الخدمات'),
(5, 2, 4, 'المكتب مجهز بشكل جيد');

-- جدول الإشعارات
CREATE TABLE Notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    related_entity_id INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

INSERT INTO Notifications (user_id, notification_type, message, related_entity_id)
VALUES
(1, 'listing', 'تم نشر إعلانك بنجاح', 1),
(2, 'contract', 'تم توقيع عقد جديد', 1),
(3, 'payment', 'تم استلام دفعة جديدة', 3),
(4, 'rating', 'حصل إعلانك على تقييم جديد', 5),
(5, 'listing', 'تم تحديث حالة إعلانك', 2);

-- جدول الوسائط المتعددة
CREATE TABLE Multimedia (
    media_id INT AUTO_INCREMENT PRIMARY KEY,
    listing_id INT NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    media_type ENUM('image', 'video') NOT NULL,
    upload_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),
    FOREIGN KEY (listing_id) REFERENCES Listings(listing_id) ON DELETE CASCADE
);

INSERT INTO Multimedia (listing_id, file_path, media_type, description)
VALUES
(1, 'images/apt1.jpg', 'image', 'صورة الشقة من الخارج'),
(2, 'images/car1.jpg', 'image', 'صورة السيارة'),
(3, 'images/house1.jpg', 'image', 'منزل للإيجار'),
(4, 'images/land1.jpg', 'image', 'صورة الأرض'),
(5, 'videos/office1.mp4', 'video', 'جولة في المكتب');
