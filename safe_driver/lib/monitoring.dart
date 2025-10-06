import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart'; // ALTERAÇÃO: Adicionada a importação para formatação de data/hora.

enum SummaryTab { braking, speed, acceleration }

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  SummaryTab _selectedTab = SummaryTab.speed;
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLoadingLocation = true;

  LatLng? _currentPosition;
  Position? _lastPosition;
  final List<LatLng> _routePoints = [];

  double _currentSpeed = 0.0;
  int _harshBrakingCount = 0;
  int _harshAccelerationCount = 0;
  String _herbieTip = "Dirija com segurança!";

  DateTime? _tripStartTime; 
  double _totalDistance = 0.0; 

  // ALTERAÇÃO: Nova variável de estado para guardar a hora da última atualização.
  DateTime? _lastUpdateTime;

  static const double HARSH_ACCELERATION_THRESHOLD = 2.5;
  static const double HARSH_BRAKING_THRESHOLD = -2.5;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }

  void _stopMonitoring() {
    _positionStreamSubscription?.cancel();
  }

  Future<void> _startMonitoring() async {
    // ... (lógica de permissão permanece a mesma)
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
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('A permissão de localização foi negada.')));
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

    _tripStartTime = DateTime.now();

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      if (mounted) {
        setState(() {
          // ALTERAÇÃO: Atualiza a variável com a hora atual a cada novo dado recebido.
          _lastUpdateTime = DateTime.now();

          _isLoadingLocation = false;
          _currentPosition = LatLng(position.latitude, position.longitude);
          _routePoints.add(_currentPosition!);
          _currentSpeed = position.speed * 3.6;
          _mapController.move(_currentPosition!, 16.0);
          
          if (_lastPosition != null) {
            _calculateEvents(position);

            _totalDistance += Geolocator.distanceBetween(
              _lastPosition!.latitude,
              _lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );
          }
          _lastPosition = position;
        });
      }
    });
  }

  void _calculateEvents(Position currentPosition) {
    final timeDiff = currentPosition.timestamp!.difference(_lastPosition!.timestamp!).inMilliseconds / 1000.0;
    if (timeDiff == 0) return;
    final speedDiff = currentPosition.speed - _lastPosition!.speed;
    final acceleration = speedDiff / timeDiff;

    if (acceleration > HARSH_ACCELERATION_THRESHOLD) {
      _harshAccelerationCount++;
      _herbieTip = "Aceleração brusca detectada! Cuidado ao arrancar.";
    } else if (acceleration < HARSH_BRAKING_THRESHOLD) {
      _harshBrakingCount++;
      _herbieTip = "Frenagem brusca detectada! Mantenha distância.";
    }
  }

  void _showSuccessDialog() {
    _stopMonitoring();
    showDialog(
      context: context,
      barrierDismissible: false,
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
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      },
    );
  }
 
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
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

  Widget _buildSummaryContent() {
    final tripDuration = _tripStartTime != null ? DateTime.now().difference(_tripStartTime!) : Duration.zero;
    final double distanceInKm = _totalDistance / 1000;
    
    final double averageSpeed = (tripDuration.inSeconds > 0)
        ? (distanceInKm / (tripDuration.inSeconds / 3600))
        : 0.0;

    switch (_selectedTab) {
      case SummaryTab.speed:
        return _buildInfoRow(
          'Velocidade atual', _currentSpeed.toStringAsFixed(0), 'Km/h',
          'Velocidade média', averageSpeed.toStringAsFixed(1), 'Km/h',
        );
      case SummaryTab.braking:
        return _buildInfoRow(
          'Frenagens bruscas', _harshBrakingCount.toString(), 'nesta viagem',
          'Tempo de viagem', _formatDuration(tripDuration), '',
        );
      case SummaryTab.acceleration:
        return _buildInfoRow(
          'Acelerações bruscas', _harshAccelerationCount.toString(), 'nesta viagem',
          'Distância', distanceInKm.toStringAsFixed(2), 'Km',
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
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
                            initialZoom: 16.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _routePoints,
                                  color: Colors.blue,
                                  strokeWidth: 5,
                                ),
                              ],
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
                const Expanded(
                  child: SizedBox(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Localização atual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         Text('Em andamento', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showSuccessDialog,
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
                Expanded(child: _buildWaveform()),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _herbieTip,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Resumo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildSummaryTabs(),
        const SizedBox(height: 16),
        _buildSummaryContent(),
        const SizedBox(height: 8),
        // ALTERAÇÃO: O widget de texto agora mostra a hora exata da última atualização.
        Center(
          child: _lastUpdateTime == null
              ? const Text(
                  'Aguardando primeira atualização...',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              : Text(
                  'Última atualização: ${DateFormat('HH:mm:ss').format(_lastUpdateTime!)}',
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
            _selectedTab = tab;
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

  Widget _buildInfoRow(String label1, String value1, String unit1, String label2,
      String value2, String unit2) {
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
              Text(value,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
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

  Widget _buildWaveform() {
    final random = Random();
    final List<double> barHeights =
        List.generate(40, (index) => random.nextDouble() * 20 + 2);

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