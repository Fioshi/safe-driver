import 'dart:math';
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

  // NOVO: Controlador para o PageView (Carrossel)
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    // Inicializa o PageController para o efeito de "espiar"
    _pageController = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _pageController.dispose(); // Limpa o controlador
    super.dispose();
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
    // ... (código existente sem alteração)
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
          'Olá, João!',
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
        // Removido o padding daqui para o PageView ocupar a tela toda
        child: Column(
          children: [
            // WIDGET DO CARROSSEL DE CARDS
            _buildInfoCarousel(),
            
            // O resto do conteúdo agora tem seu próprio padding
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
            )
          ],
        ),
      ),
    );
  }

  // NOVO WIDGET: CARROSSEL COM PAGEVIEW
  Widget _buildInfoCarousel() {
    return SizedBox(
      height: 180, // Altura fixa para o carrossel
      child: PageView(
        controller: _pageController,
        children: [
          // Adiciona padding em cada item do PageView
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildGoldDriverCard(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildPlanCard(context),
          ),
        ],
      ),
    );
  }

  // NOVO WIDGET: CARD "GOLD DRIVER"
  Widget _buildGoldDriverCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey[200],
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Coluna da Esquerda (Textos e Barra de Progresso)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Gold Driver',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Ranking: 560/1100', style: TextStyle(color: Colors.grey[800])),
                  const SizedBox(height: 4),
                  Text('Tempo de direção: 02h22', style: TextStyle(color: Colors.grey[800])),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.8, // 80%
                      minHeight: 8,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Coluna da Direita (Gráfico de Arco)
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: _ArcPainter(percentage: 0.52), // 52%
                child: const Center(
                  child: Text(
                    '52%',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget antigo, agora parte do carrossel
  Widget _buildPlanCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey[200],
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Meu plano\npara hoje',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      'Desafio: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Frenagem Consciente',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
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

  // ... (Restante do seu código _buildRecentActions, _buildMonitoringCard, etc. sem alteração)
  Widget _buildRecentActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          icon: Icons.route_outlined,
          label: 'Corridas',
          onTap: () {
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

// CLASSE CUSTOM PAINTER PARA DESENHAR O ARCO
class _ArcPainter extends CustomPainter {
  final double percentage;

  _ArcPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    const startAngle = -pi / 2 - pi / 4; // Começa às "10:30"
    const endAngle = pi + pi / 2; // O arco total vai até "7:30"
    final sweepAngle = endAngle * percentage;

    // Pincel para o fundo do arco
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Pincel para o preenchimento do arco
    final foregroundPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      endAngle,
      false,
      backgroundPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}