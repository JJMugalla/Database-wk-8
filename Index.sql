-- Library Management System Database Schema
CREATE DATABASE IF NOT EXISTS LibraryManagement;
USE LibraryManagement;

-- Authors Table
CREATE TABLE Authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Publishers Table
CREATE TABLE Publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Books Table
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author_id INT NOT NULL,
    publisher_id INT NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    publication_year YEAR,
    genre VARCHAR(50),
    pages INT,
    language VARCHAR(30),
    total_copies INT DEFAULT 0,
    available_copies INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES Authors(author_id) ON DELETE CASCADE,
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id) ON DELETE CASCADE,
    CHECK (available_copies <= total_copies AND available_copies >= 0)
);

-- Members Table
CREATE TABLE Members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    date_of_birth DATE,
    membership_date DATE DEFAULT (CURRENT_DATE),
    membership_status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Loans Table (Borrowing Records)
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    loan_date DATE DEFAULT (CURRENT_DATE),
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    fine_amount DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE,
    CHECK (due_date > loan_date),
    CHECK (return_date IS NULL OR return_date >= loan_date)
);

-- Reservations Table
CREATE TABLE Reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    reservation_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Pending', 'Fulfilled', 'Cancelled') DEFAULT 'Pending',
    notification_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE
);

-- Fines Table
CREATE TABLE Fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    member_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    reason VARCHAR(255),
    paid BOOLEAN DEFAULT FALSE,
    payment_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES Loans(loan_id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(member_id) ON DELETE CASCADE
);

-- Indexes for Performance Optimization
CREATE INDEX idx_books_title ON Books(title);
CREATE INDEX idx_books_isbn ON Books(isbn);
CREATE INDEX idx_books_author ON Books(author_id);
CREATE INDEX idx_loans_dates ON Loans(loan_date, due_date, return_date);
CREATE INDEX idx_members_email ON Members(email);
CREATE INDEX idx_members_status ON Members(membership_status);
CREATE INDEX idx_loans_status ON Loans(status);
CREATE INDEX idx_reservations_status ON Reservations(status);

-- Trigger to update available copies when a loan is created or returned
DELIMITER //
CREATE TRIGGER after_loan_insert
AFTER INSERT ON Loans
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NULL THEN
        UPDATE Books 
        SET available_copies = available_copies - 1 
        WHERE book_id = NEW.book_id;
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_loan_update
AFTER UPDATE ON Loans
FOR EACH ROW
BEGIN
    IF OLD.return_date IS NULL AND NEW.return_date IS NOT NULL THEN
        UPDATE Books 
        SET available_copies = available_copies + 1 
        WHERE book_id = NEW.book_id;
    END IF;
END;//
DELIMITER ;