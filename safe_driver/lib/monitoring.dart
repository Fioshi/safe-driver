import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // <-- Import para localização

// Enum para controlar a aba de resumo selecionada
enum SummaryTab { braking, speed, acceleration }

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  // Gerencia qual aba de resumo está ativa
  SummaryTab _selectedTab = SummaryTab.speed;

  // Variáveis de estado para o mapa dinâmico
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _determinePosition(); // Busca a localização ao iniciar a tela
  }

  // Função para obter a localização atual do dispositivo (mesma da HomeScreen)
  Future<void> _determinePosition() async {
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
      final position = await Geolocator.getCurrentPosition();
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

  // 1. Função para mostrar o popup de sucesso
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Impede que o usuário feche clicando fora
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          title: const Text('Monitoramento Concluído!', textAlign: TextAlign.center),
          content: const Text(
            'Sua viagem foi registrada com sucesso. Confira os detalhes no seu histórico.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog
                Navigator.of(context).pop(); // Volta para a HomeScreen
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Monitoramento',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonitoringCard(),
            const SizedBox(height: 24),
            _buildSummarySection(),
            const SizedBox(height: 24),
            _buildTipsSection(),
          ],
        ),
      ),
    );
  }

  // Card do topo com o mapa e status
  Widget _buildMonitoringCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // 2. Mapa agora é dinâmico
                Container(
                  width: 100,
                  height: 100,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoadingLocation
                      ? const Center(child: CircularProgressIndicator())
                      : FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentPosition ?? const LatLng(-23.5613, -46.6565),
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            if (_currentPosition != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _currentPosition!,
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.location_pin,
                                      size: 40,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              )
                          ],
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Localização atual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Em andamento', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showSuccessDialog, // <-- 1. Chama o popup
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Encerrar',
                style: TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (O restante do seu código _buildSummarySection, _buildTipsSection, etc., permanece o mesmo)
  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resumo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSummaryTabs(),
        const SizedBox(height: 16),
        _buildSummaryContent(), // Conteúdo dinâmico baseado na aba
        const SizedBox(height: 8),
        Center(
          child: Text(
            '${DateTime.now().day} de ago - ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} - Última atualização',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[100]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton('Frenagem', SummaryTab.braking),
          _buildTabButton('Velocidade', SummaryTab.speed),
          _buildTabButton('Aceleração', SummaryTab.acceleration),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, SummaryTab tab) {
    final isSelected = _selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = tab; // Atualiza a aba selecionada
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                )
              : null,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryContent() {
    switch (_selectedTab) {
      case SummaryTab.speed:
        return _buildInfoRow('Velocidade atual', '60', 'Km/h', 'Velocidade ideal', '30', 'Km/h');
      case SummaryTab.braking:
        return _buildInfoRow('Frenagens bruscas', '2', 'hoje', 'Média semanal', '5', '');
      case SummaryTab.acceleration:
        return _buildInfoRow('Acelerações bruscas', '4', 'hoje', 'Média semanal', '8', '');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoRow(String label1, String value1, String unit1, String label2, String value2, String unit2) {
    return Row(
      children: [
        Expanded(child: _buildInfoCard(label1, value1, unit1)),
        const SizedBox(width: 16),
        Expanded(child: _buildInfoCard(label2, value2, unit2)),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dicas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildHerbieCard(),
      ],
    );
  }

  Widget _buildHerbieCard() {
    return Card(
      color: Colors.grey[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Text('HERBIE', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Icon(Icons.auto_awesome, color: Colors.blue.shade700, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.mic, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(child: _buildWaveform()), // Simulação da onda
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Frenagem brusca detectada, atenção!',
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    final random = Random();
    final List<double> barHeights = List.generate(40, (index) => random.nextDouble() * 20 + 2);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: barHeights.map((height) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          width: 3,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }).toList(),
    );
  }
}