import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_driver/home_screen.dart'; // <-- 1. IMPORT DA HOME SCREEN

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Foco para gerenciar a navegação entre os campos
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // Chave para o formulário para validação
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Limpeza dos controladores e focos
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Função para lidar com o cadastro
  void _handleSignUp() {
    // Valida o formulário antes de prosseguir
    if (_formKey.currentState!.validate()) {
      // Se o formulário for válido, prossiga com a lógica de cadastro

      // =======================================================================
      // TODO: BACKEND - LÓGICA DE CRIAÇÃO DE USUÁRIO
      // =======================================================================
      // Neste ponto, você faria a chamada para o seu backend para criar
      // um novo usuário com os dados fornecidos.
      //
      // Exemplo:
      // final response = await meuBackend.auth.signUp(
      //   email: _emailController.text,
      //   password: _passwordController.text,
      //   data: {'full_name': _nameController.text}, // Metadados do usuário
      // );
      //
      // if (response.error != null) {
      //   // Se houver erro (ex: e-mail já existe), mostre uma mensagem
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(response.error.message)),
      //   );
      // } else {
      //   // Se o cadastro for bem-sucedido, navegue para a HomeScreen
      //   Navigator.of(context).pushAndRemoveUntil(...);
      // }
      // =======================================================================

      print("Cadastro Válido (Simulação). Navegando para a HomeScreen...");

      // Navega para a Home e remove todas as telas anteriores (Login, SignUp) da pilha
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false, // Este predicado remove todas as rotas
      );
    }
  }

  // Função para lidar com o login com Google
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Fundo branco como no design
      backgroundColor: Colors.white,
      // Garante que a UI não fique sob a barra de status do sistema
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Define o estilo do ícone da barra de status (brilho)
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        // Adiciona um botão de voltar automático na AppBar
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.black), // Deixa a seta preta
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Padding horizontal para os elementos
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    './images/logo.png',
                    height: 50, // Ajuste a altura conforme necessário
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.shield_outlined, size: 40);
                    },
                  ),
                  const SizedBox(height: 40),

                  // 2. Título da tela
                  const Text(
                    'Novo usuário',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 3. Campo de Nome Completo
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Digite seu nome completo',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      // Pula para o campo de e-mail ao pressionar 'next'
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, digite seu nome.';
                      }
                      if (value.trim().split(' ').length < 2) {
                        return 'Por favor, digite seu nome completo.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 4. Campo de E-mail
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Digite seu e-mail',
                      prefixIcon: const Icon(Icons.alternate_email),
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
                      // Pula para o campo de senha
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor, digite seu e-mail.';
                      }
                      // Validação simples de e-mail
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor, digite um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 5. Campo de Senha
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: !_isPasswordVisible, // Oculta/mostra a senha
                    decoration: InputDecoration(
                      labelText: 'Crie uma senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                    onFieldSubmitted: (_) => _handleSignUp(), // Submete o form
                    // VALIDAÇÕES DA SENHA ATUALIZADAS
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, crie uma senha.';
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
                  const SizedBox(height: 40),

                  // 6. Botão de Cadastrar
                  ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(screenWidth, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Cadastrar',
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
                        child: Text(
                          'OU',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 8. Botão de Entrar com Google (com imagem do Google)
                  ElevatedButton(
                    onPressed: _handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: Size(screenWidth, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          './images/google_icon.png',
                          height: 22.0,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.g_mobiledata);
                          },
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Entrar com Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 9. Link para Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Já possui uma conta? '),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Faça o login',
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