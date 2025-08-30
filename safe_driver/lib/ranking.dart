import 'package:flutter/material.dart';

// Modelo para estruturar os dados de um desafio
class Challenge {
  final int id;
  final String title;
  final String description;
  double progress; // Progresso pode mudar
  final int points;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.points,
  });

  // Um desafio está completo se o progresso for 100%
  bool get isCompleted => progress >= 1.0;
}

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  // Variáveis de estado para gerenciar os dados da tela
  int _totalPoints = 0;
  int _userPosition = 0;
  List<Challenge> _challenges = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Função para buscar os dados iniciais do usuário e dos desafios
  void _fetchUserData() {
    // =======================================================================
    // TODO: BACKEND - BUSCAR DADOS REAIS DO USUÁRIO E DESAFIOS
    // =======================================================================
    // Aqui você faria uma chamada ao seu backend para buscar:
    // 1. O total de pontos e a posição no ranking do usuário logado.
    // 2. A lista de desafios disponíveis para este usuário, com seu progresso atual.
    // =======================================================================

    // Usando dados mocados (fictícios) para o desenvolvimento
    setState(() {
      _totalPoints = 560;
      _userPosition = 10;
      _challenges = [
        Challenge(
            id: 1,
            title: "Economize combustível!",
            description: "Economize R\$20,00 em combustível esta semana.",
            progress: 1.0, // 100%
            points: 20),
        Challenge(
            id: 2,
            title: "Frenagem Consciente!",
            description: "Dirija 100km sem frenagens bruscas.",
            progress: 0.71, // 71%
            points: 15),
        Challenge(
            id: 3,
            title: "Maratona Segura",
            description: "Dirija por 50km mantendo a pontuação de segurança acima de 90.",
            progress: 0.95, // 95%
            points: 120),
        Challenge(
            id: 4,
            title: "Motorista Perfeito",
            description: "Complete 3 viagens sem nenhuma advertência.",
            progress: 1.0, // 100%
            points: 100),
      ];
    });
  }

  // Função para resgatar os pontos de um desafio
  void _redeemChallenge(Challenge challenge) {
    // =======================================================================
    // TODO: BACKEND - VALIDAR E SALVAR RESGATE DE PONTOS
    // =======================================================================
    // 1. Envie o ID do desafio (challenge.id) para o seu servidor.
    // 2. O servidor deve validar se o desafio realmente foi completado.
    // 3. Se for válido, o servidor adiciona os pontos ao total do usuário no banco
    //    de dados e marca o desafio como resgatado para não aparecer mais.
    // 4. A atualização no app (abaixo) só deve ocorrer se a chamada ao
    //    backend for bem-sucedida.
    // =======================================================================

    // Lógica do lado do cliente (simulação)
    setState(() {
      _totalPoints += challenge.points;
      _challenges.removeWhere((c) => c.id == challenge.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+${challenge.points} pontos! Desafio "${challenge.title}" resgatado!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Cor de fundo ajustada
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        // Cor da AppBar ajustada
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          "Ranking",
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
      // Cor do card ajustada para um cinza mais claro
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFBDBDBD),
              child: Icon(Icons.person, size: 60, color: Color(0xFFFAFAFA)),
            ),
            const SizedBox(height: 12),
            const Text(
              "User", // TODO: BACKEND - Puxar nome real do usuário
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
              _buildStatItem(Icons.star_border, "$_totalPoints", "Pontos"),
              _buildStatItem(Icons.emoji_events_outlined, "${_userPosition}°", "Posição"),
              // 4. Contador de desafios agora é dinâmico
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildChallengesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 4. Título da seção com contador dinâmico
            Text(
              "Desafios (${_challenges.length})",
              style: const TextStyle(
                color: Colors.black, // Cor do texto ajustada
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.blue),
              onPressed: () {
                // TODO: Implementar lógica de filtro
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Constrói a lista de desafios dinamicamente
            child: Column(
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
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  // 3. Lógica de resgate no onPressed
                  onPressed: challenge.isCompleted ? () => _redeemChallenge(challenge) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: challenge.isCompleted ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}