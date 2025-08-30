import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_driver/forgot_password.dart';
import 'package:safe_driver/home_screen.dart';
import 'package:safe_driver/signUpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para os campos de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Foco para gerenciar a navegação entre os campos
  final _passwordFocusNode = FocusNode();

  // Chave para o formulário para validação
  final _formKey = GlobalKey<FormState>();

  // Estado para controlar a visibilidade da senha
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // É importante limpar os controladores e focos para evitar vazamento de memória
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Função para lidar com o login via e-mail e senha
  void _handleLogin() {
    // O método validate() aciona a validação em todos os TextFormFields do formulário
    if (_formKey.currentState!.validate()) {
      // Se o formulário for válido, prossiga com a lógica de login

      // =======================================================================
      // TODO: BACKEND - LÓGICA DE VALIDAÇÃO REAL
      // =======================================================================
      // Neste ponto, você faria a chamada para o seu backend (Firebase, Supabase, etc.)
      // para verificar se o e-mail e a senha estão corretos.
      //
      // Exemplo:
      // final response = await meuBackend.auth.signIn(
      //   email: _emailController.text,
      //   password: _passwordController.text,
      // );
      //
      // if (response.error != null) {
      //   // Se houver erro, mostre uma mensagem para o usuário
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(response.error.message)),
      //   );
      // } else {
      //   // Se o login for bem-sucedido, navegue para a HomeScreen
      //   Navigator.of(context).pushReplacement(...);
      // }
      // =======================================================================

      // Como ainda não temos backend, vamos navegar diretamente para a home.
      print("Login Válido (Simulação). Navegando para a HomeScreen...");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  // Função para lidar com o login via Google
  void _handleGoogleSignIn() {
    // TODO: Implementar a lógica de login com Google
    print("Botão 'Entrar com Google' pressionado!");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login com Google (Simulação)'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtém a largura da tela para criar botões responsivos
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar transparente para controlar o estilo da status bar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Ícones escuros na status bar
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Logo e Nome do App
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined, // Ícone de exemplo
                        size: 30,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Safe Driver',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // 2. Título da tela
                  const Text(
                    'Fazer login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 3. Campo de E-mail
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Digite seu e-mail',
                      prefixIcon: const Icon(Icons.alternate_email_outlined),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      // Pula para o campo de senha ao pressionar 'next'
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, digite seu e-mail.';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor, digite um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. Campo de Senha
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Digite sua senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    // VALIDAÇÕES DA SENHA ATUALIZADAS
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite sua senha.';
                      }
                      if (value.length < 8) {
                        return 'A senha deve ter no mínimo 8 caracteres.';
                      }
                      if (!value.contains(RegExp(r'[A-Z]'))) {
                        return 'A senha deve conter uma letra maiúscula.';
                      }
                      if (!value.contains(RegExp(r'[a-z]'))) {
                        return 'A senha deve conter uma letra minúscula.';
                      }
                      if (!value.contains(RegExp(r'[0-9]'))) {
                        return 'A senha deve conter pelo menos um número.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 5. Link "Esqueceu sua senha?"
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // NAVEGAÇÃO PARA A TELA DE ESQUECI SENHA
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen()),
                        );
                      },
                      child: const Text(
                        'Esqueceu sua senha?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 6. Botão de Acessar
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(screenWidth, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Acessar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 7. Divisor "OU"
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('OU', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 8. Botão de Entrar com Google
                  ElevatedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 22.0,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, color: Colors.black54);
                      },
                    ),
                    label: const Text(
                      'Entrar com Google',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2F2F2),
                      minimumSize: Size(screenWidth, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 9. Link para Cadastro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Ainda não possui uma conta? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          'Cadastre-se',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}