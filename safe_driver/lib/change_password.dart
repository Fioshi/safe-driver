import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      // Formulário válido, prossiga com a lógica
      
      // =======================================================================
      // TODO: BACKEND - LÓGICA DE VERIFICAÇÃO E ALTERAÇÃO DE SENHA
      // =======================================================================
      // O processo real de alteração de senha deve seguir estes passos:
      //
      // 1. VERIFICAR A SENHA ATUAL:
      //    Primeiro, você precisa reautenticar o usuário ou usar um endpoint
      //    no seu backend que verifique se a senha fornecida em
      //    `_currentPasswordController.text` é realmente a senha correta
      //    do usuário logado.
      //
      //    Exemplo de lógica:
      //    bool isCurrentPasswordCorrect = await meuBackend.auth.verifyPassword(
      //      password: _currentPasswordController.text
      //    );
      //
      // 2. LIDAR COM O RESULTADO:
      //    if (isCurrentPasswordCorrect) {
      //      // Se a senha atual estiver correta, prossiga para alterá-la.
      //      await meuBackend.auth.updatePassword(
      //        newPassword: _newPasswordController.text
      //      );
      //
      //      // Mostre uma mensagem de sucesso e volte para a tela de perfil.
      //      ScaffoldMessenger.of(context).showSnackBar(
      //        const SnackBar(content: Text('Senha alterada com sucesso!')),
      //      );
      //      Navigator.pop(context);
      //
      //    } else {
      //      // Se a senha atual estiver INCORRETA, mostre um erro.
      //      ScaffoldMessenger.of(context).showSnackBar(
      //        const SnackBar(content: Text('A senha atual está incorreta.')),
      //      );
      //    }
      // =======================================================================

      // Simulação de sucesso para o desenvolvimento sem backend:
      print("Senha alterada com sucesso (simulação).");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Volta para a tela de perfil após o sucesso
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          'Alterar Senha',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordField(
                        controller: _currentPasswordController,
                        label: 'Senha Atual',
                        isVisible: _isCurrentPasswordVisible,
                        onVisibilityChanged: () {
                          setState(() => _isCurrentPasswordVisible = !_isCurrentPasswordVisible);
                        },
                        // Validação básica para garantir que o campo não está vazio
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, digite sua senha atual.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _newPasswordController,
                        label: 'Nova Senha',
                        isVisible: _isNewPasswordVisible,
                        onVisibilityChanged: () {
                          setState(() => _isNewPasswordVisible = !_isNewPasswordVisible);
                        },
                        validator: (value) {
                           if (value == null || value.isEmpty) {
                            return 'Por favor, crie uma nova senha.';
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
                      const SizedBox(height: 20),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar Nova Senha',
                        isVisible: _isConfirmPasswordVisible,
                        onVisibilityChanged: () {
                          setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, confirme sua nova senha.';
                          }
                          if (value != _newPasswordController.text) {
                            return 'As senhas não correspondem.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _handleChangePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Salvar Alterações',
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
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onVisibilityChanged,
        ),
      ),
      validator: validator,
    );
  }
}