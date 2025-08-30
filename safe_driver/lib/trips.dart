import 'package:flutter/material.dart';

// Modelo para representar os dados de uma corrida
class Trip {
  final int id;
  final String dateTime;
  final double economy;
  final int distance;
  final int points;

  Trip({
    required this.id,
    required this.dateTime,
    required this.economy,
    required this.distance,
    required this.points,
  });
}

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  // Lista para armazenar as corridas
  List<Trip> _trips = [];

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  // Função para buscar os dados das corridas
  void _fetchTrips() {
    // =======================================================================
    // TODO: BACKEND - BUSCAR A LISTA DE CORRIDAS
    // =======================================================================
    // Aqui você fará uma chamada ao seu backend para buscar o histórico de
    // corridas do usuário, ordenadas da mais recente para a mais antiga.
    // =======================================================================

    // Usando dados mocados (fictícios) para o desenvolvimento
    setState(() {
      _trips = [
        Trip(id: 1, dateTime: '29 de ago - 14h30', economy: 12.50, distance: 35, points: 85),
        Trip(id: 2, dateTime: '29 de ago - 08h15', economy: 7.80, distance: 22, points: 72),
        Trip(id: 3, dateTime: '28 de ago - 19h00', economy: 15.20, distance: 41, points: 91),
        Trip(id: 4, dateTime: '27 de ago - 12h45', economy: 4.50, distance: 10, points: 65),
        Trip(id: 5, dateTime: '26 de ago - 18:30', economy: 21.00, distance: 55, points: 95),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        title: const Text(
          'Minhas Corridas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _trips.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return _buildTripCard(trip);
        },
      ),
    );
  }

  // Widget que constrói o card de uma corrida
  Widget _buildTripCard(Trip trip) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Mesmo cinza do card de histórico
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              'https://i.imgur.com/3o2NbA5.png', // URL de um placeholder de mapa
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trip.dateTime,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text('R\$ ${trip.economy.toStringAsFixed(2)} economizados', style: TextStyle(color: Colors.grey[700])),
                Text('${trip.distance}km percorridos', style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    // TODO: Navegar para uma tela de detalhes da corrida
                    debugPrint("Ver detalhes da corrida ID: ${trip.id}");
                  },
                  child: const Text(
                    'Ver',
                    style: TextStyle(
                      color: Color(0xFF007BFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${trip.points} pts',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}