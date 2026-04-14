<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require '../PHPMailer/Exception.php';
require '../PHPMailer/PHPMailer.php';
require '../PHPMailer/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

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
$email = trim($data['email'] ?? '');

if (empty($email)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Email is required']);
    exit;
}

// Check if email exists
$check_sql = "SELECT id FROM users WHERE email = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("s", $email);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

if ($check_result->num_rows == 0) {
    http_response_code(404);
    echo json_encode(['success' => false, 'message' => 'Email not found']);
    exit;
}

$user_row = $check_result->fetch_assoc();
$user_id = $user_row['id'];

// Generate OTP
$otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
$otp_expires = date('Y-m-d H:i:s', strtotime('+10 minutes'));

// Save OTP to database
$update_sql = "UPDATE users SET otp = ?, otp_expires_at = ? WHERE id = ?";
$update_stmt = $conn->prepare($update_sql);
$update_stmt->bind_param("ssi", $otp, $otp_expires, $user_id);
$update_stmt->execute();

// Send OTP via email
try {
    $mail = new PHPMailer(true);
    $mail->isSMTP();
    $mail->Host = 'smtp.gmail.com';
    $mail->SMTPAuth = true;
    $mail->Username = 'kyleperezgomez11@gmail.com'; // CHANGE THIS
    $mail->Password = 'heav fpps ilon qswj'; // CHANGE THIS
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
    $mail->Port = 587;

    $mail->setFrom('your-email@gmail.com', 'Remindly');
    $mail->addAddress($email);
    $mail->Subject = 'Remindly - OTP for Password Reset';
    $mail->Body = "Your OTP is: <b>$otp</b><br>This OTP is valid for 10 minutes.";
    $mail->isHTML(true);

    if ($mail->send()) {
        http_response_code(200);
        echo json_encode(['success' => true, 'message' => 'OTP sent to your email']);
    } else {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => 'Failed to send OTP']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Email error']);
}

$check_stmt->close();
$update_stmt->close();
$conn->close();
?>