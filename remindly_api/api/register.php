<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$host = 'localhost';
$db = 'remindly';
$user = 'root';
$password = '';

$conn = new mysqli($host, $user, $password, $db);

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(['success' => false, 'message' => 'Database connection failed']));
}

$data = json_decode(file_get_contents("php://input"), true);

$name = trim($data['name'] ?? '');
$username = trim($data['username'] ?? '');
$email = trim($data['email'] ?? '');
$password_plain = $data['password'] ?? '';

// Validation
if (empty($name) || empty($username) || empty($email) || empty($password_plain)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'All fields are required']);
    exit;
}

if (strlen($password_plain) < 6) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Password must be at least 6 characters']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid email format']);
    exit;
}

// Check if username exists
$check_sql = "SELECT id FROM users WHERE username = ? OR email = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("ss", $username, $email);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

if ($check_result->num_rows > 0) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Username or email already exists']);
    exit;
}

// Hash password
$hashed_password = password_hash($password_plain, PASSWORD_DEFAULT);

// Insert user
$insert_sql = "INSERT INTO users (name, username, email, password, created_at) VALUES (?, ?, ?, ?, NOW())";
$insert_stmt = $conn->prepare($insert_sql);
$insert_stmt->bind_param("ssss", $name, $username, $email, $hashed_password);

if ($insert_stmt->execute()) {
    http_response_code(201);
    echo json_encode(['success' => true, 'message' => 'Account created successfully']);
} else {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Registration failed']);
}

$check_stmt->close();
$insert_stmt->close();
$conn->close();
?>