<?php
$host = 'localhost';
$dbname = 'web_server_db';
$user = 'postgres';
$password = 'postgres';

$conn = null;
$login_message = '';

try {
    $conn = pg_connect("host=$host dbname=$dbname user=$user password=$password");

    if (!$conn) {
        throw new Exception("Falha na conexão com o banco de dados.");
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $username = $_POST['username'];
        $password = $_POST['password'];

        $query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
        
        $result = pg_query($conn, $query);

        if (!$result) {
            $login_message = "<div class='error'>Erro na query: " . pg_last_error($conn) . "</div>";
        } else {
            if (pg_num_rows($result) > 0) {
                // Login bem-sucedido
                $user_data = pg_fetch_assoc($result);
                $login_message = "<div class='success'>Login bem-sucedido! Bem-vindo, " . htmlspecialchars($user_data['username']) . ". Seu cargo é: " . htmlspecialchars($user_data['role']) . "</div>";
                // REDIRECIONAMENTO PARA A PÁGINA DE BEM-VINDO
            } else {
                // Login falhou
                $login_message = "<div class='error'>Usuário ou senha inválidos.</div>";
            }
        }
    }
} catch (Exception $e) {
    $login_message = "<div class='error'>Erro: " . $e->getMessage() . "</div>";
} finally {
    if ($conn) {
        pg_close($conn);
    }
}
?>

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login SQL Injection (Vulnerável)</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 400px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f9f9f9;
            color: #333;
        }
        .login-form {
            display: flex;
            flex-direction: column;
            gap: 15px;
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        input, button {
            padding: 10px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        input:focus {
            outline: none;
            border-color: #dc3545; /* Cor para indicar vulnerabilidade */
            box-shadow: 0 0 5px rgba(220, 53, 69, 0.5);
        }
        button {
            background: #dc3545; /* Cor vermelha */
            color: white;
            border: none;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        button:hover {
            background: #c82333;
        }
        #result {
            margin-top: 20px;
            padding: 10px;
            border-radius: 4px;
            font-size: 14px;
        }
        .success {
            background: #d4edda;
            color: #155724;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
        }
    </style>
</head>
<body>
    <h2>Login Vulnerável a SQL Injection</h2>
    <form class="login-form" method="POST" action="">
        <label for="username">Usuário</label>
        <input type="text" id="username" name="username" placeholder="Digite seu usuário" required>
        <label for="password">Senha</label>
        <input type="password" id="password" name="password" placeholder="Digite sua senha" required>
        <button type="submit">Entrar</button>
    </form>
    <div id="result">
        <?php echo $login_message; ?>
    </div>
    <p>Não tem conta? Esta é apenas uma página de teste.</p>
</body>
</html>
