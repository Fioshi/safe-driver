import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import 'package:safe_driver/trips.dart'; // Import da tela de corridas

// Enum para o período de tempo
enum TimeFrame { daily, weekly, monthly, yearly }

// Modelo para os dados do gráfico
class HistoryData {
  final String title;
  final double averagePoints;
  final double economy;
  final List<FlSpot> chartSpots;
  final Map<int, String> bottomTitles;

  HistoryData({
    required this.title,
    required this.averagePoints,
    required this.economy,
    required this.chartSpots,
    required this.bottomTitles,
  });
}

// Modelo para os dados de uma corrida (reutilizado da trips_screen)
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

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TimeFrame _selectedTimeFrame = TimeFrame.weekly;
  HistoryData? _currentData;
  List<Trip> _recentTrips = []; // Lista para as 3 últimas corridas
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistoryData(_selectedTimeFrame);
  }

  Future<void> _fetchHistoryData(TimeFrame frame) async {
    setState(() {
      _isLoading = true;
    });

    // =======================================================================
    // TODO: BACKEND - BUSCAR DADOS REAIS DO HISTÓRICO E CORRIDAS
    // =======================================================================
    // A chamada de API agora deve retornar não só os dados para o gráfico
    // (baseado no `frame`), mas também uma lista das 3 corridas mais recentes.
    // =======================================================================

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _currentData = _getMockDataForFrame(frame);
        // Popula a lista de corridas recentes com dados fictícios
        _recentTrips = [
          Trip(id: 1, dateTime: '30 de ago - 00:28', economy: 12.50, distance: 35, points: 85),
          Trip(id: 2, dateTime: '29 de ago - 18:15', economy: 7.80, distance: 22, points: 72),
          Trip(id: 3, dateTime: '29 de ago - 09:00', economy: 15.20, distance: 41, points: 91),
        ];
        _isLoading = false;
      });
    }
  }

  HistoryData _getMockDataForFrame(TimeFrame frame) {
    // ... (código existente sem alteração)
    switch (frame) {
      case TimeFrame.daily:
        return HistoryData(
          title: 'Hoje, 30 de Agosto',
          averagePoints: 85.5,
          economy: 7.50,
          chartSpots: _generateRandomSpots(12, 100),
          bottomTitles: {0: '0h', 3: '6h', 6: '12h', 9: '18h', 11: '23h'},
        );
      case TimeFrame.weekly:
        return HistoryData(
          title: 'Esta Semana',
          averagePoints: 78.3,
          economy: 42.80,
          chartSpots: _generateRandomSpots(7, 100),
          bottomTitles: {0: 'Dom', 1: 'Seg', 2: 'Ter', 3: 'Qua', 4: 'Qui', 5: 'Sex', 6: 'Sáb'},
        );
      case TimeFrame.monthly:
        return HistoryData(
          title: 'Este Mês - Agosto',
          averagePoints: 81.2,
          economy: 189.40,
          chartSpots: _generateRandomSpots(4, 100),
          bottomTitles: {0: 'Sem 1', 1: 'Sem 2', 2: 'Sem 3', 3: 'Sem 4'},
        );
      case TimeFrame.yearly:
        return HistoryData(
          title: 'Este Ano - 2025',
          averagePoints: 83.9,
          economy: 2150.70,
          chartSpots: _generateRandomSpots(12, 100),
          bottomTitles: {0: 'Jan', 2: 'Mar', 4: 'Mai', 6: 'Jul', 8: 'Set', 10: 'Dez'},
        );
    }
  }
  
  List<FlSpot> _generateRandomSpots(int count, double max) {
    final random = Random();
    return List.generate(count, (index) {
      return FlSpot(index.toDouble(), random.nextDouble() * max);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Histórico',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeFrameSelector(),
            const SizedBox(height: 24),
            _buildStatsCards(),
            const SizedBox(height: 24),
            _buildChartCard(),
            const SizedBox(height: 32),
            _buildRecentTripsSection(), // <-- WIDGET ATUALIZADO
          ],
        ),
      ),
    );
  }

  // Seção "Anteriores" agora é dinâmica
  Widget _buildRecentTripsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Anteriores',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navega para a tela com todas as corridas
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TripsScreen()),
                );
              },
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Constrói os cards das 3 corridas recentes
        _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: _recentTrips.map((trip) {
                // Adiciona um espaçamento entre os cards
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildPreviousTripCard(trip),
                );
              }).toList(),
            ),
      ],
    );
  }

  // Card de corrida agora recebe um objeto 'Trip'
  Widget _buildPreviousTripCard(Trip trip) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              'https://i.imgur.com/3o2NbA5.png',
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
                Text(trip.dateTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('R\$ ${trip.economy.toStringAsFixed(2)} economizados', style: TextStyle(color: Colors.grey[700])),
                Text('${trip.distance}km percorridos', style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    debugPrint("Botão 'Ver' da corrida ${trip.id} pressionado.");
                  },
                  child: const Text('Ver', style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
          Text('${trip.points} pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
  
  // ... (O resto do seu código, como _buildTimeFrameSelector, _buildStatsCards, _buildChartCard, etc., permanece o mesmo)
  Widget _buildTimeFrameSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[100]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTimeFrameButton('Diário', TimeFrame.daily),
          _buildTimeFrameButton('Semanal', TimeFrame.weekly),
          _buildTimeFrameButton('Mensal', TimeFrame.monthly),
          _buildTimeFrameButton('Anual', TimeFrame.yearly, hasDivider: false),
        ],
      ),
    );
  }

  Widget _buildTimeFrameButton(String text, TimeFrame frame, {bool hasDivider = true}) {
    final isSelected = _selectedTimeFrame == frame;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeFrame = frame;
            _fetchHistoryData(frame);
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: isSelected
                  ? BoxDecoration(
                      color: const Color(0xFF007BFF),
                      borderRadius: BorderRadius.circular(30.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    )
                  : null,
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (hasDivider)
              Container(
                height: 20,
                width: 1,
                color: Colors.blue[200],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard('Média', _isLoading ? '...' : _currentData!.averagePoints.toStringAsFixed(1), 'Pontos'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard('Economia', _isLoading ? '...' : _currentData!.economy.toStringAsFixed(2), 'Reais'),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isLoading ? 'Carregando...' : _currentData!.title,
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              if (value % 25 == 0 && value > 0) {
                                return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 12));
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            getTitlesWidget: (value, meta) {
                              final title = _currentData?.bottomTitles[value.toInt()];
                              if (title != null) {
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: (_currentData?.chartSpots.length ?? 1) - 1.0,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: _currentData!.chartSpots,
                          isCurved: true,
                          color: Colors.cyan,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [Colors.cyan.withOpacity(0.3), Colors.cyan.withOpacity(0.0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (LineBarSpot spot) {
                            return Colors.blueGrey.withOpacity(0.8);
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}