import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // <-- 1. IMPORT DO PACOTE HTTP
import 'dart:convert'; // <-- 2. IMPORT PARA CONVERSÃO JSON

import 'package:safe_driver/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Chave para o formulário para validação
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _corporateEmailController = TextEditingController();

  // Foco para gerenciar a navegação entre os campos
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _corporateEmailFocusNode = FocusNode();

  // Variáveis de estado para os dropdowns e UI
  String? _selectedAutomobileType;
  String? _selectedDrivingGoal;
  bool _isPasswordVisible = false;
  bool _isLoading = false; // <-- Para controlar o estado de carregamento

  // Opções para os campos de seleção
  final List<String> _automobileTypes = ['Carro', 'Moto', 'Caminhão', 'Outro'];
  final List<String> _drivingGoals = [
    'Uso Pessoal',
    'Trabalho (Motorista de App)',
    'Trabalho (Frota Corporativa)',
    'Lazer'
  ];

  @override
  void dispose() {
    // Limpeza dos controladores e focos
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _corporateEmailController.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _phoneFocusNode.dispose();
    _corporateEmailFocusNode.dispose();
    super.dispose();
  }

  // Função para lidar com o cadastro via API
  Future<void> _handleSignUp() async {
    // Valida o formulário antes de prosseguir
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ativa o indicador de carregamento
    setState(() {
      _isLoading = true;
    });

    // URL do endpoint de cadastro
    final url = Uri.parse('http://localhost:8080/api/auth/signup');

    try {
      // Monta o corpo da requisição com base no DTO
      final body = json.encode({
        "fullName": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "phoneNumber": _phoneController.text.trim(),
        "corporateEmail": _corporateEmailController.text.trim(),
        "automobileType": _selectedAutomobileType,
        "drivingGoal": _selectedDrivingGoal,
      });

      // Envia a requisição POST
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      // Trata a resposta do backend
      if (response.statusCode == 201 || response.statusCode == 200) {
        // Sucesso
        final responseData = json.decode(response.body);
        final token = responseData['token']; // Assumindo que o backend retorna um token

        // =======================================================================
        // TODO: ARMAZENAMENTO SEGURO DO TOKEN JWT
        // =======================================================================
        // É crucial armazenar o token de forma segura.
        // Pacotes como `flutter_secure_storage` são recomendados para isso.
        //
        // Exemplo:
        // final storage = FlutterSecureStorage();
        // await storage.write(key: 'jwt_token', value: token);
        // =======================================================================
        print("Cadastro bem-sucedido! Token: $token");

        // Navega para a Home e remove todas as telas anteriores da pilha
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        // Erro (ex: e-mail já existe, dados inválidos)
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Ocorreu um erro no cadastro.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Erro de conexão ou outro erro inesperado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível se conectar ao servidor. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Desativa o indicador de carregamento
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.black),
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
                  Image.asset(
                    './images/logo.png',
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.shield_outlined, size: 40);
                    },
                  ),
                  const SizedBox(height: 40),

                  const Text(
                    'Novo usuário',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- CAMPOS DO FORMULÁRIO ---

                  // Nome Completo
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Digite seu nome completo', prefixIcon: Icon(Icons.person_outline)),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Por favor, digite seu nome.';
                      if (value.trim().split(' ').length < 2) return 'Por favor, digite seu nome completo.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // E-mail
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: const InputDecoration(labelText: 'Digite seu e-mail', prefixIcon: Icon(Icons.alternate_email)),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Por favor, digite seu e-mail.';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Por favor, digite um e-mail válido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Senha
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Crie uma senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_phoneFocusNode),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, crie uma senha.';
                      if (value.length < 8) return 'A senha deve ter no mínimo 8 caracteres.';
                      if (!value.contains(RegExp(r'[A-Z]'))) return 'A senha deve conter uma letra maiúscula.';
                      if (!value.contains(RegExp(r'[a-z]'))) return 'A senha deve conter uma letra minúscula.';
                      if (!value.contains(RegExp(r'[0-9]'))) return 'A senha deve conter pelo menos um número.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Telefone
                  TextFormField(
                    controller: _phoneController,
                    focusNode: _phoneFocusNode,
                    decoration: const InputDecoration(labelText: 'Telefone (com DDD)', prefixIcon: Icon(Icons.phone_outlined)),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_corporateEmailFocusNode),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Por favor, digite seu telefone.';
                      if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 10) return 'Digite um número de telefone válido.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // E-mail Corporativo (Opcional)
                  TextFormField(
                    controller: _corporateEmailController,
                    focusNode: _corporateEmailFocusNode,
                    decoration: const InputDecoration(labelText: 'E-mail Corporativo (opcional)', prefixIcon: Icon(Icons.work_outline)),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                     validator: (value) {
                      if (value != null && value.trim().isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor, digite um e-mail válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Tipo de Automóvel
                  DropdownButtonFormField<String>(
                    value: _selectedAutomobileType,
                    decoration: const InputDecoration(labelText: 'Tipo de Automóvel', prefixIcon: Icon(Icons.directions_car_outlined)),
                    items: _automobileTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedAutomobileType = value),
                    validator: (value) => value == null ? 'Selecione o tipo de automóvel.' : null,
                  ),
                  const SizedBox(height: 20),

                  // Objetivo de Direção
                  DropdownButtonFormField<String>(
                    value: _selectedDrivingGoal,
                    decoration: const InputDecoration(labelText: 'Objetivo de Direção', prefixIcon: Icon(Icons.flag_outlined)),
                    items: _drivingGoals.map((goal) {
                      return DropdownMenuItem(value: goal, child: Text(goal));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedDrivingGoal = value),
                    validator: (value) => value == null ? 'Selecione seu objetivo.' : null,
                  ),
                  const SizedBox(height: 40),

                  // Botão de Cadastrar com indicador de loading
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: Size(screenWidth, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  const SizedBox(height: 40),

                  // Link para Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Já possui uma conta? '),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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
