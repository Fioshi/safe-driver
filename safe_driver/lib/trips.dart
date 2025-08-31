import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart'; // <-- 1. IMPORTAR O PACOTE INTL
import 'package:latlong2/latlong.dart';

// Modelo para representar os dados de uma corrida
class Trip {
  final int id;
  // 2. ALTERAÇÃO CRÍTICA: Mudar de String para DateTime
  final DateTime dateTime;
  final double economy;
  final int distance;
  final int points;
  final LatLng location;

  Trip({
    required this.id,
    required this.dateTime, // <-- Agora é um DateTime
    required this.economy,
    required this.distance,
    required this.points,
    required this.location,
  });
}

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  // 3. ADICIONAR VARIÁVEIS DE ESTADO PARA O FILTRO
  List<Trip> _allTrips = [];      // Armazena todas as viagens, sem filtro
  List<Trip> _filteredTrips = []; // Armazena as viagens a serem exibidas (filtradas ou não)

  // Armazenam o intervalo de datas selecionado pelo usuário
  DateTime? _startDate;
  DateTime? _endDate;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  // Função para gerar uma coordenada aleatória em São Paulo
  LatLng _getRandomSpLocation() {
    const minLat = -23.65;
    const maxLat = -23.45;
    const minLng = -46.73;
    const maxLng = -46.53;

    final lat = minLat + _random.nextDouble() * (maxLat - minLat);
    final lng = minLng + _random.nextDouble() * (maxLng - minLng);

    return LatLng(lat, lng);
  }

  // Função para buscar os dados das corridas
  void _fetchTrips() {
    // ... (chamada ao backend) ...

    // Usando dados mocados com DateTime real
    final now = DateTime.now();
    setState(() {
      _allTrips = [
        // 4. ATUALIZAR DADOS MOCADOS PARA USAR DATETIME
        Trip(id: 1, dateTime: now.subtract(const Duration(days: 1, hours: 2)), economy: 12.50, distance: 35, points: 85, location: _getRandomSpLocation()),
        Trip(id: 2, dateTime: now.subtract(const Duration(days: 1, hours: 8)), economy: 7.80, distance: 22, points: 72, location: _getRandomSpLocation()),
        Trip(id: 3, dateTime: now.subtract(const Duration(days: 2, hours: 1)), economy: 15.20, distance: 41, points: 91, location: _getRandomSpLocation()),
        Trip(id: 4, dateTime: now.subtract(const Duration(days: 3, hours: 5)), economy: 4.50, distance: 10, points: 65, location: _getRandomSpLocation()),
        Trip(id: 5, dateTime: now.subtract(const Duration(days: 4, hours: 1)), economy: 21.00, distance: 55, points: 95, location: _getRandomSpLocation()),
        Trip(id: 6, dateTime: now.subtract(const Duration(days: 5, hours: 22)), economy: 9.30, distance: 18, points: 79, location: _getRandomSpLocation()),
      ];
      // Inicialmente, a lista filtrada contém todas as viagens
      _filteredTrips = _allTrips;
    });
  }

  // 5. FUNÇÃO PARA ABRIR O SELETOR DE DATAS E APLICAR O FILTRO
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2020), // Data mais antiga que pode ser selecionada
      lastDate: DateTime.now(),   // Data mais recente (hoje)
      builder: (context, child) {
        // Opcional: Customizar o tema do seletor de datas
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        // Adicionamos 1 dia ao fim para incluir o dia inteiro no filtro
        _endDate = picked.end;
        _applyFilter();
      });
    }
  }

  // 6. FUNÇÃO COM A LÓGICA DO FILTRO
  void _applyFilter() {
    setState(() {
      if (_startDate == null || _endDate == null) {
        // Se não há filtro, mostra tudo
        _filteredTrips = _allTrips;
      } else {
        // Filtra a lista original
        _filteredTrips = _allTrips.where((trip) {
          final tripDate = trip.dateTime;
          // Garante que a data da viagem esteja dentro do intervalo selecionado (inclusivo)
          // Normaliza as datas para ignorar a hora, comparando apenas o dia
          final start = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59); // Inclui o dia todo
          return tripDate.isAfter(start) && tripDate.isBefore(end);
        }).toList();
      }
    });
  }

  // 7. FUNÇÃO PARA LIMPAR O FILTRO
  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _filteredTrips = _allTrips;
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
          'Minhas Viagens',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // 8. ADICIONAR BOTÕES DE AÇÃO NA APPBAR
        actions: [
          // Botão para limpar o filtro (só aparece se um filtro estiver ativo)
          if (_startDate != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined, color: Colors.black),
              tooltip: 'Limpar Filtro',
              onPressed: _clearFilter,
            ),
          // Botão para abrir o seletor de datas
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
            tooltip: 'Filtrar por data',
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _filteredTrips.isEmpty
        // Mostra uma mensagem se nenhuma viagem for encontrada após o filtro
        ? Center(
            child: Text(
              'Nenhuma viagem encontrada para o período selecionado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          )
        : ListView.separated(
          padding: const EdgeInsets.all(16.0),
          // 9. USAR A LISTA FILTRADA
          itemCount: _filteredTrips.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final trip = _filteredTrips[index];
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
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: trip.location,
                  initialZoom: 14.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: trip.location,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 10. FORMATAR O DATETIME PARA EXIBIÇÃO
                Text(
                  // Usando 'pt_BR' para garantir o formato em português
                  DateFormat("d 'de' MMM - HH:mm", 'pt_BR').format(trip.dateTime),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text('R\$ ${trip.economy.toStringAsFixed(2)} economizados', style: TextStyle(color: Colors.grey[700])),
                Text('${trip.distance}km percorridos', style: TextStyle(color: Colors.grey[700])),
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