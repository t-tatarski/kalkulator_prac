<?php
session_start();

if (!isset($_SESSION['authorized']) || $_SESSION['authorized'] !== true) {
    header('Location: login.php');
    exit();
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8" />
    <title>strona glowna</title>
</head>
<body>
    <h1>własciwa strona</h1>
    <p>dostęp tylko z kodem</p>
    <a href="logout.php">Wyloguj się</a>
</body>
</html>
