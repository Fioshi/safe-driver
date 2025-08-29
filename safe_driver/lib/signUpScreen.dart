import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      // TODO: Implementar a lógica de cadastro aqui (ex: com Supabase ou Firebase)
      print("Nome: ${_nameController.text}");
      print("Email: ${_emailController.text}");
      print("Senha: ${_passwordController.text}");

      // Mostra um feedback para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso! (Simulação)'),
          backgroundColor: Colors.green,
        ),
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
                  // 1. Logo e Nome do App
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone do logo (substitua pelo seu asset ou ícone)
                      const Icon(
                        Icons.shield_outlined, // Ícone de exemplo
                        size: 30,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 12),
                      const Text(
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
                      labelText: 'Digite sua senha',
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
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite sua senha.';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres.';
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

                  // 8. Botão de Entrar com Google
                  ElevatedButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: Image.asset(
                      'assets/images/google_logo.png', // Verifique se tem essa imagem
                      height: 22.0,
                      errorBuilder: (context, error, stackTrace) {
                         // Fallback para um ícone caso a imagem não carregue
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

                  // 9. Link para Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Já possui uma conta? '),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navegar para a tela de Login
                          print("Link 'Faça o login' pressionado!");
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
