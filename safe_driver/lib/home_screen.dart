import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

// Imports das telas de navegação
import 'package:safe_driver/monitoring.dart';
import 'package:safe_driver/history.dart';
import 'package:safe_driver/ranking.dart';
import 'package:safe_driver/profile.dart';
import 'package:safe_driver/trips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    // ... (código de busca de localização existente, sem alteração)
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Por favor, ative o serviço de localização.')));
      }
      setState(() => _isLoadingLocation = false);
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('A permissão de localização foi negada.')));
        }
        setState(() => _isLoadingLocation = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('A permissão de localização foi negada permanentemente.')));
      }
      setState(() => _isLoadingLocation = false);
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
          _mapController.move(_currentPosition!, 15.0);
        });
      }
    } catch (e) {
      print("Erro ao obter localização: $e");
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _showStartMonitoringDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Iniciar Monitoramento'),
          content: const Text('Deseja iniciar o monitoramento da sua viagem?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MonitoringScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Olá, user!',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: Colors.black,
              size: 30,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPlanCard(context),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Recentes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildRecentActions(),
            const SizedBox(height: 32),
            _buildMonitoringCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context) {
    // ... (código existente sem alteração)
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey[200],
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meu plano\npara hoje',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text(
                      'Desafio: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        print("Desafio 'Frenagem Consciente' pressionado");
                      },
                      child: const Text(
                        'Frenagem Consciente',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 100,
              width: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: 0.71,
                    strokeWidth: 12,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const Center(
                    child: Text(
                      '71%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. WIDGET ATUALIZADO COM O NOVO BOTÃO "CORRIDAS"
  Widget _buildRecentActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: Icons.route_outlined, // Ícone alterado
          label: 'Corridas', // Label alterado
          onTap: () {
            // Navegação alterada para a TripsScreen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TripsScreen()),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.show_chart,
          label: 'Histórico',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.bar_chart,
          label: 'Ranking',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RankingScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    // ... (código existente sem alteração)
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMonitoringCard(BuildContext context) {
    // ... (código existente sem alteração)
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey[200],
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: _isLoadingLocation
                ? const Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text("Buscando localização..."),
                    ],
                  ))
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentPosition ?? const LatLng(-23.55052, -46.633308),
                      initialZoom: _currentPosition != null ? 15.0 : 5.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      if (_currentPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition!,
                              width: 80,
                              height: 80,
                              child: Icon(
                                Icons.location_pin,
                                size: 50,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                const Text(
                  'Monitoramento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'em tempo real',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _showStartMonitoringDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Iniciar',
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
        ],
      ),
    );
  }
}