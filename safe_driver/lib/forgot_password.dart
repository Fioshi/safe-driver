import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handlePasswordReset() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;

      // =======================================================================
      // TODO: BACKEND - LÓGICA DE ENVIO DE E-MAIL DE RECUPERAÇÃO
      // =======================================================================
      // Aqui você chamaria a função do seu backend para enviar o link de
      // recuperação para o e-mail fornecido.
      //
      // Exemplo com Firebase:
      // await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      //
      // Exemplo com Supabase:
      // await supabase.auth.resetPasswordForEmail(email);
      //
      // É importante tratar os possíveis erros (ex: e-mail não encontrado),
      // mas por segurança, a mensagem para o usuário deve ser a mesma
      // para não confirmar se um e-mail existe ou não na base de dados.
      // =======================================================================

      print('Link de recuperação enviado para: $email (Simulação)');

      // Mostra uma mensagem de confirmação genérica para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se o e-mail estiver cadastrado, um link será enviado.'),
          backgroundColor: Colors.green,
        ),
      );

      // Volta para a tela de login após a solicitação
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Recuperar Senha',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_reset, size: 60, color: Colors.blue),
                  const SizedBox(height: 30),
                  const Text(
                    'Esqueceu sua senha?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sem problemas. Insira seu endereço de e-mail abaixo e nós enviaremos um link para redefinir sua senha.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
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
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handlePasswordReset(),
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
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _handlePasswordReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Enviar Link de Recuperação',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}