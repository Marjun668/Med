<?php
$pageTitle = "User Login";
require_once 'includes/auth.php';

// Redirect if already logged in
if (isUserLoggedIn()) {
    header("Location: index.php");
    exit;
}

$error = '';
$registerSuccess = '';

// Process login form
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['login'])) {
    $username = isset($_POST['username']) ? trim($_POST['username']) : '';
    $password = isset($_POST['password']) ? $_POST['password'] : '';
    
    if (empty($username) || empty($password)) {
        $error = "Please enter both username and password.";
    } else {
        if (authenticateUser($username, $password)) {
            header("Location: index.php");
            exit;
        } else {
            $error = "Invalid username or password.";
        }
    }
}

// Process registration form
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['register'])) {
    $username = isset($_POST['reg_username']) ? trim($_POST['reg_username']) : '';
    $email = isset($_POST['reg_email']) ? trim($_POST['reg_email']) : '';
    $password = isset($_POST['reg_password']) ? $_POST['reg_password'] : '';
    $confirmPassword = isset($_POST['reg_confirm_password']) ? $_POST['reg_confirm_password'] : '';
    $firstName = isset($_POST['reg_first_name']) ? trim($_POST['reg_first_name']) : '';
    $lastName = isset($_POST['reg_last_name']) ? trim($_POST['reg_last_name']) : '';
    
    // Validate input
    $errors = [];
    if (empty($username)) {
        $errors[] = "Username is required.";
    }
    if (empty($email)) {
        $errors[] = "Email is required.";
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = "Invalid email format.";
    }
    if (empty($password)) {
        $errors[] = "Password is required.";
    } elseif (strlen($password) < 6) {
        $errors[] = "Password must be at least 6 characters.";
    }
    if ($password !== $confirmPassword) {
        $errors[] = "Passwords do not match.";
    }
    
    // Check if username or email already exists
    if (empty($errors)) {
        $db = Database::getInstance();
        $username_esc = $db->escape($username);
        $email_esc = $db->escape($email);
        
        $result = $db->query("SELECT * FROM regular_users WHERE username = '$username_esc' OR email = '$email_esc'");
        
        if ($result && $result->num_rows > 0) {
            $errors[] = "Username or email already exists.";
        }
    }
    
    if (empty($errors)) {
        $db = Database::getInstance();
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        
        $userData = [
            'username' => $username,
            'password' => $hashedPassword,
            'email' => $email,
            'first_name' => $firstName,
            'last_name' => $lastName
        ];
        
        if ($db->insert('regular_users', $userData)) {
            $registerSuccess = "Registration successful! You can now log in.";
        } else {
            $error = "Registration failed. Please try again.";
        }
    } else {
        $error = implode("<br>", $errors);
    }
}

include_once 'includes/header.php';
?>

<div class="container py-5">
    <div class="row">
        <div class="col-md-6 mb-4">
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">User Login</h4>
                </div>
                <div class="card-body p-4">
                    <?php if (!empty($error)): ?>
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <?php echo $error; ?>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <?php endif; ?>
                    
                    <?php if (!empty($registerSuccess)): ?>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <?php echo $registerSuccess; ?>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    <?php endif; ?>
                    
                    <form method="POST" action="">
                        <div class="mb-3">
                            <label for="username" class="form-label">Username</label>
                            <input type="text" class="form-control" id="username" name="username" required>
                        </div>
                        <div class="mb-3">
                            <label for="password" class="form-label">Password</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="remember" name="remember">
                            <label class="form-check-label" for="remember">Remember me</label>
                        </div>
                        <input type="hidden" name="login" value="1">
                        <button type="submit" class="btn btn-primary w-100">Login</button>
                    </form>
                </div>
            </div>
        </div>
        
        <div class="col-md-6">
            <div class="card shadow">
                <div class="card-header bg-success text-white">
                    <h4 class="mb-0">New User Registration</h4>
                </div>
                <div class="card-body p-4">
                    <form method="POST" action="">
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="reg_first_name" class="form-label">First Name</label>
                                <input type="text" class="form-control" id="reg_first_name" name="reg_first_name">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="reg_last_name" class="form-label">Last Name</label>
                                <input type="text" class="form-control" id="reg_last_name" name="reg_last_name">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="reg_username" class="form-label">Username <span class="text-danger">*</span></label>
                            <input type="text" class="form-control" id="reg_username" name="reg_username" required>
                        </div>
                        <div class="mb-3">
                            <label for="reg_email" class="form-label">Email <span class="text-danger">*</span></label>
                            <input type="email" class="form-control" id="reg_email" name="reg_email" required>
                        </div>
                        <div class="mb-3">
                            <label for="reg_password" class="form-label">Password <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="reg_password" name="reg_password" required>
                            <small class="text-muted">Password must be at least 6 characters long.</small>
                        </div>
                        <div class="mb-3">
                            <label for="reg_confirm_password" class="form-label">Confirm Password <span class="text-danger">*</span></label>
                            <input type="password" class="form-control" id="reg_confirm_password" name="reg_confirm_password" required>
                        </div>
                        <input type="hidden" name="register" value="1">
                        <!-- Register button styling fix -->
                        <button type="submit" class="btn btn-primary w-100 mb-3" style="color: #fff;">Register</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<?php include_once 'includes/footer.php'; ?>
