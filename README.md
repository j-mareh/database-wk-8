📦 E-commerce Database Management System
📖 Project Overview

This project is a relational database management system (RDBMS) built in MySQL for an E-commerce Store.
It is designed to manage users, customers, products, inventory, orders, payments, and reviews efficiently while ensuring data integrity, normalization, and scalability.

The database follows best practices in normalization (up to 3NF/BCNF) to reduce redundancy and improve data integrity.

🎯 Objectives

Design and implement a complete relational database schema.

Define relationships (One-to-One, One-to-Many, Many-to-Many).

Use constraints (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK).

Provide sample data inserts to simulate real-world use.

🗂️ Database Schema
Key Entities

Users → platform login & role management.

Customers → registered buyers.

Addresses → shipping addresses for customers.

Suppliers → product providers.

Products & Categories → items for sale and their classification.

Orders & Order Items → transactions and purchased products.

Payments → order payment tracking.

Reviews → customer feedback on products.

Inventory → product stock levels.

Relationships

One-to-Many → A customer can have many orders.

Many-to-Many → Products belong to multiple categories.

One-to-One → Each order has one payment record.
