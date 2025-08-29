import 'package:flutter/material.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo claro, como solicitado
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar transparente para mesclar com o fundo
        elevation: 0,
        title: const Text(
          "Ranking",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
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

  // Card principal com as informações do usuário
  Widget _buildUserProfileCard() {
    return Card(
      color: const Color(0xFFE0E0E0), // Cinza claro para o card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            // Ícone de perfil e nome
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFBDBDBD),
              child: Icon(
                Icons.person,
                size: 60,
                color: Color(0xFFFAFAFA),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "User",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            // Card interno com as estatísticas
            _buildStatsCard(),
          ],
        ),
      ),
    );
  }

  // Card branco com Pontos, Posição e Desafios
  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(Icons.star_border, "560", "Pontos"),
              _buildStatItem(Icons.emoji_events_outlined, "10°", "Posição"),
              _buildStatItem(Icons.track_changes_outlined, "18", "Desafios"),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para um item de estatística individual
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
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Seção de Desafios
  Widget _buildChallengesSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Desafios",
              style: TextStyle(
                color: Colors.black, // Cor do texto ajustada para o fundo claro
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
        // Card com a lista de desafios
        Card(
          color: const Color(0xFFE0E0E0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildChallengeItem(
                  title: "Economize combustível!",
                  description: "Economize \$20,00 em combustível esta semana.",
                  progress: 1.0, // 100%
                  points: 20,
                  isCompleted: true,
                ),
                const Divider(color: Colors.grey),
                _buildChallengeItem(
                  title: "Frenagem Consciente!",
                  description: "Dirija 100km sem frenagens bruscas.",
                  progress: 0.71, // 71%
                  points: 15,
                  isCompleted: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget para um item de desafio individual
  Widget _buildChallengeItem({
    required String title,
    required String description,
    required double progress,
    required int points,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          _buildProgressCircle(progress),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: isCompleted ? () {} : null, // Habilita/desabilita o botão
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted ? Colors.blue : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Resgatar $points pts",
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

  // Círculo de progresso customizado
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
            backgroundColor: Colors.white,
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
