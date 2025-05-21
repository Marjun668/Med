-- MedCompare System Database Tracking Structure
-- Database Name: med

-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS med;
CREATE DATABASE med CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE med;

-- -----------------------------------------------------
-- Core Tables
-- -----------------------------------------------------

-- Admin Users Table
CREATE TABLE users (
  id INT(11) NOT NULL AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL,
  role ENUM('admin') NOT NULL DEFAULT 'admin',
  last_login DATETIME DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY (username),
  UNIQUE KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Regular Users Table
CREATE TABLE regular_users (
  id INT(11) NOT NULL AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL,
  first_name VARCHAR(50) DEFAULT NULL,
  last_name VARCHAR(50) DEFAULT NULL,
  status ENUM('active','inactive','banned') NOT NULL DEFAULT 'active',
  last_login DATETIME DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY (username),
  UNIQUE KEY (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Medications Table
CREATE TABLE medications (
  id INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  generic_name VARCHAR(255) DEFAULT NULL,
  dosage VARCHAR(100) NOT NULL,
  form VARCHAR(100) NOT NULL,
  description TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Pharmacies Table
CREATE TABLE pharmacies (
  id INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  contact VARCHAR(100) DEFAULT NULL,
  latitude DECIMAL(10,8) DEFAULT NULL,
  longitude DECIMAL(11,8) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Medication Prices Table
CREATE TABLE medication_prices (
  id INT(11) NOT NULL AUTO_INCREMENT,
  medication_id INT(11) NOT NULL,
  pharmacy_id INT(11) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_medication_id (medication_id),
  KEY idx_pharmacy_id (pharmacy_id),
  CONSTRAINT fk_medication_prices_medication_id FOREIGN KEY (medication_id) REFERENCES medications (id) ON DELETE CASCADE,
  CONSTRAINT fk_medication_prices_pharmacy_id FOREIGN KEY (pharmacy_id) REFERENCES pharmacies (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Tracking Tables
-- -----------------------------------------------------

-- Admin Activity Logs
CREATE TABLE admin_activity_logs (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  action VARCHAR(50) NOT NULL,
  details TEXT,
  ip_address VARCHAR(50) NOT NULL,
  user_agent TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_id (user_id),
  KEY idx_action (action),
  KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User Activity Logs
CREATE TABLE user_activity_logs (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  action VARCHAR(50) NOT NULL,
  details TEXT,
  ip_address VARCHAR(50) NOT NULL,
  user_agent TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_id (user_id),
  KEY idx_action (action),
  KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Search Logs
CREATE TABLE search_logs (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) DEFAULT NULL,
  search_query VARCHAR(255) NOT NULL,
  results_count INT(11) DEFAULT NULL,
  ip_address VARCHAR(50) NOT NULL,
  user_agent TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_search_query (search_query),
  KEY idx_user_id (user_id),
  KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Price History
CREATE TABLE price_history (
  id INT(11) NOT NULL AUTO_INCREMENT,
  medication_price_id INT(11) NOT NULL,
  old_price DECIMAL(10,2),
  new_price DECIMAL(10,2) NOT NULL,
  changed_by INT(11) NOT NULL,
  change_reason VARCHAR(100) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_medication_price_id (medication_price_id),
  KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Page View Logs
CREATE TABLE page_view_logs (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) DEFAULT NULL,
  page_url VARCHAR(255) NOT NULL,
  page_name VARCHAR(100),
  ip_address VARCHAR(50) NOT NULL,
  user_agent TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_page_url (page_url),
  KEY idx_user_id (user_id),
  KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User Favorites
CREATE TABLE favorites (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  medication_id INT(11) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY unique_user_medication (user_id, medication_id),
  KEY idx_user_id (user_id),
  KEY idx_medication_id (medication_id),
  CONSTRAINT fk_favorites_user_id FOREIGN KEY (user_id) REFERENCES regular_users (id) ON DELETE CASCADE,
  CONSTRAINT fk_favorites_medication_id FOREIGN KEY (medication_id) REFERENCES medications (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- User Session Logs
CREATE TABLE session_logs (
  id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) NOT NULL,
  user_type ENUM('admin','user') NOT NULL,
  session_id VARCHAR(100) NOT NULL,
  ip_address VARCHAR(50) NOT NULL,
  user_agent TEXT,
  login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  logout_time TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_user_id (user_id),
  KEY idx_session_id (session_id),
  KEY idx_login_time (login_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Contact Form Submissions
CREATE TABLE contact_submissions (
  id INT(11) NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  subject VARCHAR(200) NOT NULL,
  message TEXT NOT NULL,
  status ENUM('pending','read','replied') NOT NULL DEFAULT 'pending',
  ip_address VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_status (status),
  KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Error Logs
CREATE TABLE error_logs (
  id INT(11) NOT NULL AUTO_INCREMENT,
  error_code VARCHAR(50),
  error_message TEXT NOT NULL,
  error_trace TEXT,
  file_name VARCHAR(255),
  line_number INT(11),
  url VARCHAR(255),
  ip_address VARCHAR(50),
  user_id INT(11) DEFAULT NULL,
  user_type ENUM('admin','user','guest') DEFAULT 'guest',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_error_code (error_code),
  KEY idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Create Trigger for Price History Tracking
-- -----------------------------------------------------
DELIMITER $$
CREATE TRIGGER before_medication_price_update
BEFORE UPDATE ON medication_prices
FOR EACH ROW
BEGIN
  IF NEW.price != OLD.price THEN
    INSERT INTO price_history (medication_price_id, old_price, new_price, changed_by, change_reason)
    VALUES (OLD.id, OLD.price, NEW.price, @admin_user_id, @change_reason);
  END IF;
END $$
DELIMITER ;

-- -----------------------------------------------------
-- Insert default admin user
-- -----------------------------------------------------
INSERT INTO users (username, password, email, role) 
VALUES ('admin', '$2y$10$zNEGxJG5HYD80yalvJxy1.GnfR8fWq1XiDC4vjrXm7QIHBkB3kKWm', 'admin@medcompare.ph', 'admin');
-- Note: The password hash is for 'admin123'

-- -----------------------------------------------------
-- Create necessary procedures for tracking
-- -----------------------------------------------------
DELIMITER $$

-- Log Admin Activity
CREATE PROCEDURE log_admin_activity(
  IN p_user_id INT,
  IN p_action VARCHAR(50),
  IN p_details TEXT,
  IN p_ip_address VARCHAR(50),
  IN p_user_agent TEXT
)
BEGIN
  INSERT INTO admin_activity_logs (user_id, action, details, ip_address, user_agent)
  VALUES (p_user_id, p_action, p_details, p_ip_address, p_user_agent);
END $$

-- Log User Activity
CREATE PROCEDURE log_user_activity(
  IN p_user_id INT,
  IN p_action VARCHAR(50),
  IN p_details TEXT,
  IN p_ip_address VARCHAR(50),
  IN p_user_agent TEXT
)
BEGIN
  INSERT INTO user_activity_logs (user_id, action, details, ip_address, user_agent)
  VALUES (p_user_id, p_action, p_details, p_ip_address, p_user_agent);
END $$

-- Log Search Query
CREATE PROCEDURE log_search(
  IN p_user_id INT,
  IN p_search_query VARCHAR(255),
  IN p_results_count INT,
  IN p_ip_address VARCHAR(50),
  IN p_user_agent TEXT
)
BEGIN
  INSERT INTO search_logs (user_id, search_query, results_count, ip_address, user_agent)
  VALUES (p_user_id, p_search_query, p_results_count, p_ip_address, p_user_agent);
END $$

-- Log Page View
CREATE PROCEDURE log_page_view(
  IN p_user_id INT,
  IN p_page_url VARCHAR(255),
  IN p_page_name VARCHAR(100),
  IN p_ip_address VARCHAR(50),
  IN p_user_agent TEXT
)
BEGIN
  INSERT INTO page_view_logs (user_id, page_url, page_name, ip_address, user_agent)
  VALUES (p_user_id, p_page_url, p_page_name, p_ip_address, p_user_agent);
END $$

-- Log Error
CREATE PROCEDURE log_error(
  IN p_error_code VARCHAR(50),
  IN p_error_message TEXT,
  IN p_error_trace TEXT,
  IN p_file_name VARCHAR(255),
  IN p_line_number INT,
  IN p_url VARCHAR(255),
  IN p_ip_address VARCHAR(50),
  IN p_user_id INT,
  IN p_user_type ENUM('admin','user','guest')
)
BEGIN
  INSERT INTO error_logs (error_code, error_message, error_trace, file_name, line_number, url, ip_address, user_id, user_type)
  VALUES (p_error_code, p_error_message, p_error_trace, p_file_name, p_line_number, p_url, p_ip_address, p_user_id, p_user_type);
END $$

DELIMITER ;
