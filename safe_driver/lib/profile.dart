import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe_driver/change_password.dart';
import 'package:safe_driver/login.dart'; // <-- 1. IMPORT DA TELA DE LOGIN

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Flag para controlar o modo de edição
  bool _isEditing = false;

  // Variável de estado para armazenar o arquivo da imagem de perfil
  File? _profileImage;

  // Controladores para os campos de texto
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _corporateEmailController;

  // Variáveis de estado para os Dropdowns
  String? _selectedAutomobile;
  String? _selectedDrivingGoal;

  // Listas de opções para os Dropdowns
  final List<String> _automobileOptions = ['Carro', 'Moto', 'Caminhão', 'Outro'];
  final List<String> _drivingGoalOptions = [
    'Economia',
    'Segurança',
    'Equilibrado',
    'Boas Práticas',
    'Performance'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Alexandre Pereira');
    _emailController = TextEditingController(text: 'alexandre.p@email.com');
    _phoneController = TextEditingController(text: '(11) 98765-4321');
    _corporateEmailController = TextEditingController();
    _selectedAutomobile = _automobileOptions.first;
    _selectedDrivingGoal = _drivingGoalOptions[2];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _corporateEmailController.dispose();
    super.dispose();
  }

  // NOVA FUNÇÃO PARA EXIBIR O POPUP DE CONFIRMAÇÃO DE LOGOUT
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sair da Conta'),
          content: const Text('Tem certeza que deseja sair?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Apenas fecha o popup
              },
            ),
            TextButton(
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // =======================================================================
                // TODO: BACKEND - LÓGICA DE LOGOUT
                // =======================================================================
                // Aqui você chamaria a função do seu backend para deslogar o usuário.
                // Isso pode envolver limpar um token de sessão, etc.
                //
                // Exemplo com Firebase/Supabase:
                // await meuBackend.auth.signOut();
                // =======================================================================

                // Fecha o popup
                Navigator.of(dialogContext).pop();
                
                // Navega para a tela de Login e remove todas as telas anteriores da pilha
                if (mounted) {
                   Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Método para escolher a imagem (da Câmera ou Galeria)
  Future<void> _pickImage() async {
    // ... (código existente sem alteração)
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria de Fotos'),
              onTap: () {
                _getImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Câmera'),
              onTap: () {
                _getImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Método que de fato busca a imagem e atualiza o estado
  Future<void> _getImage(ImageSource source) async {
    // ... (código existente sem alteração)
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _toggleEdit() {
    // ... (código existente sem alteração)
    setState(() {
      if (_isEditing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informações salvas com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... (código existente sem alteração)
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          'Meu Perfil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save_outlined : Icons.edit_outlined,
              color: Colors.black,
            ),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfilePicture(),
            const SizedBox(height: 40),
            _buildInfoCard(),
            const SizedBox(height: 30),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    // ... (código existente sem alteração)
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                _profileImage != null ? FileImage(_profileImage!) : null,
            child: _profileImage == null
                ? const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  )
                : null,
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: Colors.white),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    // ... (código existente sem alteração)
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildInfoField(
              label: 'Nome Completo',
              controller: _nameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 20),
            _buildInfoField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            _buildInfoField(
              label: 'Telefone',
              controller: _phoneController,
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Automóvel',
              icon: Icons.directions_car_outlined,
              value: _selectedAutomobile,
              items: _automobileOptions,
              onChanged: (newValue) {
                setState(() {
                  _selectedAutomobile = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Objetivo de Direção',
              icon: Icons.track_changes_outlined,
              value: _selectedDrivingGoal,
              items: _drivingGoalOptions,
              onChanged: (newValue) {
                setState(() {
                  _selectedDrivingGoal = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildInfoField(
              label: 'Email Corporativo (Opcional)',
              controller: _corporateEmailController,
              icon: Icons.work_outline,
            ),
            const Divider(height: 40),
            _buildChangePasswordButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    // ... (código existente sem alteração)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // ... (código existente sem alteração)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: _isEditing ? onChanged : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton() {
    // ... (código existente sem alteração)
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.blue),
            const SizedBox(width: 12),
            const Text(
              'Trocar Senha',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTÃO DE LOGOUT ATUALIZADO
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _showLogoutConfirmationDialog, // Chama o popup de confirmação
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Sair da Conta',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}