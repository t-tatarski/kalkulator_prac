<?php
session_start();

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $password = $_POST['password'] ?? '';

    // Ustaw swoje hasło dostępu tutaj
    $correct_password = 'TwojeHaslo123';

    if ($password === $correct_password) {
        $_SESSION['authorized'] = true;
        header('Location: protected.php'); // strona chroniona
        exit();
    } else {
        $error = 'Niepoprawny kod dostępu.';
    }
}
?>

<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8" />
    <title>Logowanie</title>
</head>
<body>
    <h2>Podaj kod dostępu</h2>
    <?php if ($error): ?>
        <p style="color:red;"><?php echo htmlspecialchars($error); ?></p>
    <?php endif; ?>
    <form method="post" action="">
        <input type="password" name="password" placeholder="Kod dostępu" required />
        <button type="submit">Zaloguj się</button>
    </form>
</body>
</html>
