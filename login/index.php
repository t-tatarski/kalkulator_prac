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
    <h1>Witamy stronie glownej zabezpieczonej!</h1>
    <p>Tylko osoby z kodem dostępu mogą tu wejść.</p>
    <a href="logout.php">Wyloguj się</a>
</body>
</html>
