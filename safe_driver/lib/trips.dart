import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
// ALTERAÇÃO: Importar o SharedPreferences para ler o token
import 'package:shared_preferences/shared_preferences.dart';

class Trip {
  final String id;
  final DateTime dateTime;
  final double economy;
  final double distance;
  final int points;
  final LatLng location;

  Trip({
    required this.id,
    required this.dateTime,
    required this.economy,
    required this.distance,
    required this.points,
    required this.location,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['tripId'],
      dateTime: DateTime.parse(json['startTime']),
      economy: (json['economySavedBrl'] as num).toDouble(),
      distance: (json['distanceKm'] as num).toDouble(),
      points: json['pointsEarned'],
      location: LatLng(
        (json['endLatitude'] as num).toDouble(),
        (json['endLongitude'] as num).toDouble(),
      ),
    );
  }
}

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<Trip> _allTrips = [];
  List<Trip> _filteredTrips = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTripsFromApi();
  }

  // ALTERAÇÃO: Função agora lê o token e o envia na requisição.
  Future<void> _fetchTripsFromApi() async {
    // 1. Acessa o SharedPreferences para buscar o token salvo.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    // 2. Verifica se o token existe. Se não, o usuário não está autenticado.
    if (token == null) {
      print("Token não encontrado. Acesso não autorizado.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão expirada. Faça o login novamente.'))
        );
      }
      setState(() => _isLoading = false);
      return; // Interrompe a execução da função.
    }

    // 3. Corrige a URL e monta o cabeçalho de autorização.
    // Lembre-se: '10.0.2.2' para emulador Android, IP da máquina para iOS/físico.
    const String apiUrl = 'http://localhost:8080/api/v1/users/me/trips';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // 4. Envia a requisição GET com os cabeçalhos de autenticação.
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> tripsJson = jsonDecode(utf8.decode(response.bodyBytes));
        final List<Trip> fetchedTrips =
            tripsJson.map((json) => Trip.fromJson(json)).toList();

        setState(() {
          _allTrips = fetchedTrips;
          _filteredTrips = _allTrips;
          _isLoading = false;
        });
      } else {
        // Trata outros status de erro, como 401/403 (token inválido/expirado).
        print('Falha ao carregar viagens. Status: ${response.statusCode}');
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao buscar dados: ${response.statusCode}'))
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro de conexão: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro de conexão. Verifique a rede.'))
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // A função _fetchTrips original não é mais necessária, mas pode ser mantida se preferir.
  // void _fetchTrips() {
  //   _fetchTripsFromApi();
  // }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
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
        _endDate = picked.end;
        _applyFilter();
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_startDate == null || _endDate == null) {
        _filteredTrips = _allTrips;
      } else {
        _filteredTrips = _allTrips.where((trip) {
          final tripDate = trip.dateTime;
          final start =
              DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
          final end =
              DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
          return tripDate.isAfter(start) && tripDate.isBefore(end);
        }).toList();
      }
    });
  }

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
        actions: [
          if (_startDate != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined, color: Colors.black),
              tooltip: 'Limpar Filtro',
              onPressed: _clearFilter,
            ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
            tooltip: 'Filtrar por data',
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTrips.isEmpty
              ? Center(
                  child: Text(
                    _allTrips.isEmpty
                        ? 'Você ainda não possui viagens.'
                        : 'Nenhuma viagem encontrada para o período selecionado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredTrips.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final trip = _filteredTrips[index];
                    return _buildTripCard(trip);
                  },
                ),
    );
  }

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
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                Text(
                  DateFormat("d 'de' MMM - HH:mm", 'pt_BR').format(trip.dateTime),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text('R\$ ${trip.economy.toStringAsFixed(2)} economizados',
                    style: TextStyle(color: Colors.grey[700])),
                Text('${trip.distance.toStringAsFixed(1)}km percorridos',
                    style: TextStyle(color: Colors.grey[700])),
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