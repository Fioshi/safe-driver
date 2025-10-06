import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safe_driver/change_password.dart';
import 'package:safe_driver/login.dart';

// NOVO: Imports para a lógica de backend
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserModel {
  final String userId;
  final String fullName;
  final String email;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final String? corporateEmail;
  final String? automobileType;
  final String drivingGoal;
  final String createdAt;
  final int points;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.profilePictureUrl,
    this.phoneNumber,
    this.corporateEmail,
    this.automobileType,
    required this.drivingGoal,
    required this.createdAt,
    required this.points,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      fullName: json['fullName'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
      phoneNumber: json['phoneNumber'],
      corporateEmail: json['corporateEmail'],
      automobileType: json['automobileType'],
      drivingGoal: json['drivingGoal'] ?? 'Nenhuma meta definida',
      createdAt: json['createdAt'],
      points: json['points'] ?? 0,
    );
  }
}


// ========================================================================= //
// WIDGET DA TELA DE PERFIL
// ========================================================================= //
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  File? _profileImage;

  // NOVO: Adiciona estado de carregamento
  bool _isLoading = true;
  UserModel? _user; // Armazena os dados do usuário

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _corporateEmailController;

  String? _selectedAutomobile;
  String? _selectedDrivingGoal;

  final List<String> _automobileOptions = ['Carro', 'Moto', 'Caminhão', 'Outro'];
  final List<String> _drivingGoalOptions = ['Economia', 'Segurança', 'Equilibrado', 'Boas Práticas', 'Performance'];

  @override
  void initState() {
    super.initState();
    // Inicializa os controllers vazios, eles serão preenchidos pela API
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _corporateEmailController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _corporateEmailController.dispose();
    super.dispose();
  }

  // NOVO: Função para buscar e preencher os dados do usuário
  Future<void> _fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      if (token == null) {
        _handleLogout();
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/users/loged'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        _user = UserModel.fromJson(data);
        // Preenche os campos da UI com os dados recebidos
        _nameController.text = _user!.fullName;
        _emailController.text = _user!.email;
        _phoneController.text = _user!.phoneNumber ?? '';
        _corporateEmailController.text = _user!.corporateEmail ?? '';
        _selectedAutomobile = _automobileOptions.contains(_user!.automobileType) ? _user!.automobileType : null;
        _selectedDrivingGoal = _drivingGoalOptions.contains(_user!.drivingGoal) ? _user!.drivingGoal : null;
        
        setState(() => _isLoading = false);
      } else {
        _handleLogout();
      }
    } catch (e) {
      print("Erro ao buscar dados do perfil: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // NOVO: Função para salvar os dados atualizados
  Future<void> _saveUserData() async {
    setState(() => _isLoading = true);
    
    // TODO: BACKEND - Lógica de upload da imagem de perfil
    // O upload de imagem (File) é mais complexo (multipart request).
    // Por enquanto, vamos focar em salvar os dados de texto.
    if (_profileImage != null) {
      print("Lógica de upload de imagem a ser implementada.");
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      if (token == null) {
        _handleLogout();
        return;
      }
      
      // ATENÇÃO: Verifique se este é o seu endpoint e método (PUT/PATCH) corretos para ATUALIZAR um usuário.
      // Geralmente é um PUT ou PATCH para /api/v1/users/{userId} ou /api/v1/users/me
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/v1/users/me'), // Endpoint de exemplo
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'fullName': _nameController.text,
          'email': _emailController.text, // Se o e-mail puder ser alterado
          'phoneNumber': _phoneController.text,
          'corporateEmail': _corporateEmailController.text,
          'automobileType': _selectedAutomobile,
          'drivingGoal': _selectedDrivingGoal,
        }),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informações salvas com sucesso!'), backgroundColor: Colors.green),
        );
      } else {
        throw Exception('Falha ao salvar os dados: ${response.body}');
      }
    } catch (e) {
      print("Erro ao salvar dados do perfil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar. Tente novamente.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  // MODIFICADO: Função de logout com limpeza do token
  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

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
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Sair', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleLogout(); // Chama a função de logout real
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
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

  Future<void> _getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // Se estava editando, agora vai salvar
        _saveUserData();
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text('Meu Perfil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_outlined : Icons.edit_outlined, color: Colors.black),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
    ImageProvider? backgroundImage;
    if (_profileImage != null) {
      backgroundImage = FileImage(_profileImage!);
    } else if (_user?.profilePictureUrl != null && _user!.profilePictureUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(_user!.profilePictureUrl!);
    }

    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? const Icon(Icons.person, size: 80, color: Colors.white)
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
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildInfoField(label: 'Nome Completo', controller: _nameController, icon: Icons.person_outline),
            const SizedBox(height: 20),
            _buildInfoField(label: 'Email', controller: _emailController, icon: Icons.email_outlined),
            const SizedBox(height: 20),
            _buildInfoField(label: 'Telefone', controller: _phoneController, icon: Icons.phone_outlined),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Automóvel',
              icon: Icons.directions_car_outlined,
              value: _selectedAutomobile,
              items: _automobileOptions,
              onChanged: (newValue) => setState(() => _selectedAutomobile = newValue),
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Objetivo de Direção',
              icon: Icons.track_changes_outlined,
              value: _selectedDrivingGoal,
              items: _drivingGoalOptions,
              onChanged: (newValue) => setState(() => _selectedDrivingGoal = newValue),
            ),
            const SizedBox(height: 20),
            _buildInfoField(label: 'Email Corporativo (Opcional)', controller: _corporateEmailController, icon: Icons.work_outline),
            const Divider(height: 40),
            _buildChangePasswordButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({required String label, required TextEditingController controller, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: _isEditing,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required IconData icon, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))).toList(),
          onChanged: _isEditing ? onChanged : null,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen())),
      borderRadius: BorderRadius.circular(12),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, color: Colors.blue),
            SizedBox(width: 12),
            Text('Trocar Senha', style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _showLogoutConfirmationDialog,
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: const Text('Sair da Conta', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}