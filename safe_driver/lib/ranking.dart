import 'package:flutter/material.dart';

// NOVO: Imports para a lógica de backend
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_driver/login.dart'; // Ajuste o nome do arquivo de login se necessário


// ========================================================================= //
// MODELO DE DADOS DO USUÁRIO (pode ser movido para um arquivo separado)
// ========================================================================= //
class UserModel {
  final String fullName;
  final String? profilePictureUrl;
  final int points;
  
  // Adicionei um campo para a posição no ranking que precisaria vir da API
  final int rankingPosition;

  UserModel({
    required this.fullName,
    this.profilePictureUrl,
    required this.points,
    required this.rankingPosition,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] ?? 'Usuário',
      profilePictureUrl: json['profilePictureUrl'],
      points: json['points'] ?? 0,
      // Supondo que a API do usuário também retorne a posição no ranking
      rankingPosition: json['rankingPosition'] ?? 0,
    );
  }
}


// ========================================================================= //
// MODELO DE DADOS DO DESAFIO (modificado para bater com o payload)
// ========================================================================= //
class Challenge {
  final String userChallengeId; // Mudado de int para String (UUID)
  final String title;
  final String description;
  final double progress;
  final int points;
  final String status; // NOVO: para saber se está 'COMPLETED', etc.
  final String? redeemedAt; // NOVO: para filtrar desafios já resgatados

  Challenge({
    required this.userChallengeId,
    required this.title,
    required this.description,
    required this.progress,
    required this.points,
    required this.status,
    this.redeemedAt,
  });

  // Um desafio está pronto para resgate se o status for 'COMPLETED'
  bool get isCompleted => status == 'COMPLETED';

  factory Challenge.fromJson(Map<String, dynamic> json) {
    // O progresso pode vir como int (0) ou double (0.75). Garantimos que seja double.
    double progressValue = (json['progress'] as num?)?.toDouble() ?? 0.0;
    
    // Se o progresso vier como porcentagem (ex: 71 para 71%), descomente a linha abaixo
    // if (progressValue > 1.0) progressValue = progressValue / 100.0;

    return Challenge(
      userChallengeId: json['userChallengeId'],
      title: json['title'],
      description: json['description'],
      points: json['pointsReward'],
      status: json['status'],
      progress: progressValue,
      redeemedAt: json['redeemedAt'],
    );
  }
}


// ========================================================================= //
// WIDGET DA TELA DE RANKING
// ========================================================================= //
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  // Variáveis de estado para gerenciar os dados da tela
  UserModel? _user;
  List<Challenge> _challenges = [];
  bool _isLoading = true; // NOVO: Estado de carregamento

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // MODIFICADO: Função para buscar todos os dados da tela em paralelo
  Future<void> _fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      if (token == null) {
        _handleLogout();
        return;
      }

      final headers = {'Authorization': 'Bearer $token'};

      // Faz as duas chamadas de API em paralelo
      final results = await Future.wait([
        http.get(Uri.parse('http://localhost:8080/api/v1/users/loged'), headers: headers),
        http.get(Uri.parse('http://localhost:8080/api/v1/users/me/challenges'), headers: headers),
      ]);

      final userResponse = results[0];
      final challengesResponse = results[1];

      // Processa a resposta do usuário
      if (userResponse.statusCode == 200) {
        final userData = json.decode(utf8.decode(userResponse.bodyBytes));
        _user = UserModel.fromJson(userData);
      } else {
        throw Exception('Falha ao carregar dados do usuário: ${userResponse.statusCode}');
      }

      // Processa a resposta dos desafios
      if (challengesResponse.statusCode == 200) {
        final List<dynamic> challengesData = json.decode(utf8.decode(challengesResponse.bodyBytes));
        _challenges = challengesData
            .map((data) => Challenge.fromJson(data))
            .where((challenge) => challenge.redeemedAt == null) // Filtra desafios já resgatados
            .toList();
      } else {
        throw Exception('Falha ao carregar desafios: ${challengesResponse.statusCode}');
      }

    } catch (e) {
      print("Erro ao buscar dados: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar os dados. Tente novamente.')),
        );
        // Se o erro for de autenticação (401/403), desloga
        if (e.toString().contains('401') || e.toString().contains('403')) {
          _handleLogout();
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // MODIFICADO: Função para resgatar os pontos de um desafio
  Future<void> _redeemChallenge(Challenge challenge) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      if (token == null) {
        _handleLogout();
        return;
      }

      // ATENÇÃO: Endpoint de exemplo. Verifique qual é o seu endpoint para resgatar.
      // Geralmente é um POST para uma rota específica do desafio.
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/user-challenges/${challenge.userChallengeId}/redeem'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && mounted) {
        setState(() {
          // Adiciona os pontos ao usuário e remove o desafio da lista local
          _user = UserModel(
            fullName: _user!.fullName,
            points: _user!.points + challenge.points,
            rankingPosition: _user!.rankingPosition,
            profilePictureUrl: _user!.profilePictureUrl
          );
          _challenges.removeWhere((c) => c.userChallengeId == challenge.userChallengeId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+${challenge.points} pontos! Desafio "${challenge.title}" resgatado!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Falha ao resgatar desafio: ${response.statusCode}');
      }
    } catch (e) {
      print("Erro ao resgatar desafio: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível resgatar o desafio.'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  void _handleLogout() {
    // Implementação do logout
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text("Ranking", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // MODIFICADO: Exibe um loader enquanto os dados estão sendo carregados
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildUserProfileCard(),
                  const SizedBox(height: 24),
                  _buildChallengesSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            // MODIFICADO: Usa a foto de perfil do usuário
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _user?.profilePictureUrl != null && _user!.profilePictureUrl!.isNotEmpty
                ? NetworkImage(_user!.profilePictureUrl!)
                : null,
              child: _user?.profilePictureUrl == null || _user!.profilePictureUrl!.isEmpty
                ? const Icon(Icons.person, size: 60, color: Colors.white)
                : null,
            ),
            const SizedBox(height: 12),
            // MODIFICADO: Usa o nome do usuário
            Text(
              _user?.fullName ?? 'Carregando...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 20),
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // MODIFICADO: Dados dinâmicos
              _buildStatItem(Icons.star_border, "${_user?.points ?? 0}", "Pontos"),
              _buildStatItem(Icons.emoji_events_outlined, "${_user?.rankingPosition ?? 0}°", "Posição"),
              _buildStatItem(Icons.track_changes_outlined, "${_challenges.length}", "Desafios"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.black54, size: 30),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildChallengesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Desafios (${_challenges.length})",
              style: const TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.blue),
              onPressed: () { /* TODO: Implementar filtro */ },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _challenges.isEmpty
              ? const Padding( // Mensagem para quando não há desafios
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text("Nenhum desafio disponível no momento.", style: TextStyle(color: Colors.grey)),
                )
              : Column(
                  children: _challenges.map((challenge) {
                    return _buildChallengeItem(challenge);
                  }).toList(),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeItem(Challenge challenge) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          _buildProgressCircle(challenge.progress),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 4),
                Text(challenge.description, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: challenge.isCompleted ? () => _redeemChallenge(challenge) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: challenge.isCompleted ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Resgatar ${challenge.points} pts",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(double progress) {
    return SizedBox(
      height: 70,
      width: 70,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Center(
            child: Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}