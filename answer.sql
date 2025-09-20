-- E-commerce Store Database
-- Single .sql file for CREATE DATABASE, CREATE TABLE statements, and sample INSERTs
-- Designed for MySQL (InnoDB). Adjust datatypes if needed for your environment.

DROP DATABASE IF EXISTS `ecommerce_db`;
CREATE DATABASE `ecommerce_db` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
USE `ecommerce_db`;

CREATE TABLE `users` (
  `user_id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(150),
  `role` ENUM('admin','manager','support') NOT NULL DEFAULT 'support',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `customers` (
  `customer_id` INT AUTO_INCREMENT PRIMARY KEY,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `phone` VARCHAR(30),
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `addresses` (
  `address_id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT NOT NULL,
  `label` VARCHAR(50) DEFAULT 'home',
  `street` VARCHAR(255) NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `state` VARCHAR(100),
  `postal_code` VARCHAR(30),
  `country` VARCHAR(100) NOT NULL,
  `is_default` BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `categories` (
  `category_id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT,
  `parent_id` INT DEFAULT NULL,
  FOREIGN KEY (`parent_id`) REFERENCES `categories`(`category_id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `suppliers` (
  `supplier_id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(200) NOT NULL,
  `contact_email` VARCHAR(255),
  `phone` VARCHAR(50),
  `address` VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE `products` (
  `product_id` INT AUTO_INCREMENT PRIMARY KEY,
  `sku` VARCHAR(100) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `price` DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  `weight_kg` DECIMAL(8,3) DEFAULT NULL CHECK (weight_kg >= 0),
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `supplier_id` INT DEFAULT NULL,
  FOREIGN KEY (`supplier_id`) REFERENCES `suppliers`(`supplier_id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `product_categories` (
  `product_id` INT NOT NULL,
  `category_id` INT NOT NULL,
  PRIMARY KEY (`product_id`, `category_id`),
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `categories`(`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `product_images` (
  `image_id` INT AUTO_INCREMENT PRIMARY KEY,
  `product_id` INT NOT NULL,
  `url` VARCHAR(1000) NOT NULL,
  `alt_text` VARCHAR(255),
  `is_primary` BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `inventory` (
  `product_id` INT PRIMARY KEY,
  `quantity` INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  `reorder_level` INT NOT NULL DEFAULT 0,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `orders` (
  `order_id` INT AUTO_INCREMENT PRIMARY KEY,
  `customer_id` INT NOT NULL,
  `order_status` ENUM('pending','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
  `order_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `shipping_address_id` INT,
  `billing_address_id` INT,
  `total_amount` DECIMAL(12,2) NOT NULL CHECK (total_amount >= 0),
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE RESTRICT,
  FOREIGN KEY (`shipping_address_id`) REFERENCES `addresses`(`address_id`) ON DELETE SET NULL,
  FOREIGN KEY (`billing_address_id`) REFERENCES `addresses`(`address_id`) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE `order_items` (
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  `quantity` INT NOT NULL CHECK (quantity > 0),
  `line_total` DECIMAL(12,2) NOT NULL GENERATED ALWAYS AS (unit_price * quantity) VIRTUAL,
  PRIMARY KEY (`order_id`, `product_id`),
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE `payments` (
  `payment_id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL UNIQUE,
  `payment_method` ENUM('card','paypal','bank_transfer','cash_on_delivery') NOT NULL,
  `amount` DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
  `payment_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `reviews` (
  `review_id` INT AUTO_INCREMENT PRIMARY KEY,
  `product_id` INT NOT NULL,
  `customer_id` INT NOT NULL,
  `rating` TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  `title` VARCHAR(255),
  `body` TEXT,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) ON DELETE CASCADE,
  FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`) ON DELETE CASCADE,
  UNIQUE (`product_id`, `customer_id`)
) ENGINE=InnoDB;

CREATE INDEX idx_products_name ON `products`(`name`(100));
CREATE INDEX idx_orders_customer ON `orders`(`customer_id`);
CREATE INDEX idx_order_items_product ON `order_items`(`product_id`);

-- Sample Data Inserts

INSERT INTO `users` (username, email, password_hash, full_name, role)
VALUES ('admin1','admin@example.com','hashed_pw','System Admin','admin');

INSERT INTO `customers` (first_name,last_name,email,phone)
VALUES ('John','Doe','john@example.com','1234567890'),
       ('Jane','Smith','jane@example.com','9876543210');

INSERT INTO `addresses` (customer_id,label,street,city,state,postal_code,country,is_default)
VALUES (1,'home','123 Main St','Nairobi','Nairobi','00100','Kenya',TRUE),
       (2,'home','456 Market Ave','Mombasa','Coast','80100','Kenya',TRUE);

INSERT INTO `categories` (name,description)
VALUES ('Electronics','Devices and gadgets'),
       ('Clothing','Men and Women Clothing');

INSERT INTO `suppliers` (name,contact_email,phone,address)
VALUES ('Tech Supplier Ltd','supplier@example.com','11223344','Industrial Area, Nairobi');

INSERT INTO `products` (sku,name,description,price,weight_kg,supplier_id)
VALUES ('SKU001','Smartphone','Latest model smartphone',350.00,0.5,1),
       ('SKU002','Laptop','15 inch business laptop',800.00,2.0,1);

INSERT INTO `product_categories` (product_id,category_id)
VALUES (1,1), (2,1);

INSERT INTO `inventory` (product_id,quantity,reorder_level)
VALUES (1,100,10), (2,50,5);

INSERT INTO `orders` (customer_id,order_status,shipping_address_id,billing_address_id,total_amount)
VALUES (1,'processing',1,1,350.00),
       (2,'pending',2,2,800.00);

INSERT INTO `order_items` (order_id,product_id,unit_price,quantity)
VALUES (1,1,350.00,1),
       (2,2,800.00,1);

INSERT INTO `payments` (order_id,payment_method,amount,status)
VALUES (1,'card',350.00,'completed'),
       (2,'paypal',800.00,'pending');

INSERT INTO `reviews` (product_id,customer_id,rating,title,body)
VALUES (1,1,5,'Great phone','I love the battery life'),
       (2,2,4,'Good laptop','Fast and reliable for work');
