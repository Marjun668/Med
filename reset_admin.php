<?php
require_once 'includes/config.php';
require_once 'includes/db.php';

// Force create the activity_logs table
$db = Database::getInstance();
$db->query("CREATE TABLE IF NOT EXISTS `activity_logs` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `user_id` int(11) NOT NULL,
    `action` varchar(50) NOT NULL,
    `details` text,
    `ip_address` varchar(50) NOT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;");

// Delete admin user if it exists
$db->query("DELETE FROM users WHERE username = 'admin'");

// Create fresh admin account with a simple, predictable password
$hashedPassword = password_hash('admin123', PASSWORD_DEFAULT);
$result = $db->query("INSERT INTO users (username, password, email, role) 
               VALUES ('admin', '$hashedPassword', 
               'admin@medcompare.ph', 'admin')");

if ($result) {
    echo "
    <!DOCTYPE html>
    <html lang='en'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Admin Reset - " . APP_NAME . "</title>
        <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css' rel='stylesheet'>
    </head>
    <body class='bg-light'>
        <div class='container py-5'>
            <div class='row justify-content-center'>
                <div class='col-md-6'>
                    <div class='card shadow'>
                        <div class='card-header bg-success text-white'>
                            <h4 class='mb-0'>Admin Account Reset</h4>
                        </div>
                        <div class='card-body p-4'>
                            <div class='alert alert-success'>
                                <p>Admin account has been reset successfully!</p>
                            </div>
                            
                            <div class='mb-4'>
                                <h5>Login Credentials:</h5>
                                <ul class='list-group'>
                                    <li class='list-group-item'><strong>Username:</strong> admin</li>
                                    <li class='list-group-item'><strong>Password:</strong> admin123</li>
                                </ul>
                            </div>
                            
                            <div class='d-grid gap-2'>
                                <a href='admin/index.php' class='btn btn-primary'>Go to Admin Login</a>
                                <a href='user/index.php' class='btn btn-outline-secondary'>Return to Homepage</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
    </html>
    ";
} else {
    echo "
    <!DOCTYPE html>
    <html lang='en'>
    <head>
        <meta charset='UTF-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <title>Admin Reset - " . APP_NAME . "</title>
        <link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css' rel='stylesheet'>
    </head>
    <body class='bg-light'>
        <div class='container py-5'>
            <div class='row justify-content-center'>
                <div class='col-md-6'>
                    <div class='card shadow'>
                        <div class='card-header bg-danger text-white'>
                            <h4 class='mb-0'>Error</h4>
                        </div>
                        <div class='card-body p-4'>
                            <div class='alert alert-danger'>
                                <p>Error resetting admin account. Please check database connection.</p>
                            </div>
                            
                            <div class='d-grid gap-2'>
                                <a href='user/index.php' class='btn btn-outline-secondary'>Return to Homepage</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </body>
    </html>
    ";
}
?>
