<?php
require_once '../includes/config.php';
require_once '../includes/db.php';

// This page will force reset the admin account
$db = Database::getInstance();

// Delete admin user if it exists
$db->query("DELETE FROM users WHERE username = 'admin'");

// Create fresh admin account
$hashedPassword = password_hash('admin123', PASSWORD_DEFAULT);
$result = $db->query("INSERT INTO users (username, password, email, role) 
               VALUES ('admin', '$hashedPassword', 
               'admin@medcompare.ph', 'admin')");

if ($result) {
    echo "Admin account has been reset successfully.<br>";
    echo "Username: admin<br>";
    echo "Password: admin123<br>";
    echo "<a href='index.php'>Go to login page</a>";
} else {
    echo "Error resetting admin account. Please check database connection.";
}
?>
