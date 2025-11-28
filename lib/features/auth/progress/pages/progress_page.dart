import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ihealthy/services/database_helper.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  String selectedPeriod = "week";

  double totalWater = 0;
  int totalExercise = 0;
  double habitsAverage = 0;
  double consistency = 0;

  List<FlSpot> hydrationPoints = [];

  @override
  void initState() {
    super.initState();
    loadProgressData();
  }

  Future<void> loadProgressData() async {
   final db = DatabaseHelper();


    if (selectedPeriod == "week") {
      totalWater = await db.getWaterTotalWeek();
      totalExercise = await db.getExerciseTotalWeek();
      habitsAverage = await db.getHabitsAverageWeek();
      consistency = await db.getConsistencyWeek();
      hydrationPoints = await db.getHydrationChartWeek();
    } else {
      totalWater = await db.getWaterTotalMonth();
      totalExercise = await db.getExerciseTotalMonth();
      habitsAverage = await db.getHabitsAverageMonth();
      consistency = await db.getConsistencyMonth();
      hydrationPoints = await db.getHydrationChartMonth();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Relatório de progresso",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Acompanhe a sua evolução",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),
            _buildPeriodSelector(),

            const SizedBox(height: 25),
            _buildTopCards(),

            const SizedBox(height: 18),
            _buildBottomCards(),

            const SizedBox(height: 25),
            _buildHydrationChart(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SELETOR DE PERÍODO
  // ============================================================

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month),

          const SizedBox(width: 8),
          const Text(
            "Período:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(width: 16),
          _periodButton("Semana", "week"),
          const SizedBox(width: 10),
          _periodButton("Mês", "month"),
        ],
      ),
    );
  }

  Widget _periodButton(String label, String period) {
    final bool selected = selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() => selectedPeriod = period);
        loadProgressData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CARDS DE PROGRESSO
  // ============================================================

  Widget _buildTopCards() {
    return Row(
      children: [
        Expanded(
          child: _progressCard(
            title: "Água total",
            value: "${totalWater.toStringAsFixed(1)}L",
            icon: Icons.water_drop,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _progressCard(
            title: "Exercícios",
            value: "$totalExercise min",
            icon: Icons.fitness_center,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCards() {
    return Row(
      children: [
        Expanded(
          child: _progressCard(
            title: "Hábitos",
            value: "${habitsAverage.toStringAsFixed(0)}%",
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _progressCard(
            title: "Consistência",
            value: "${consistency.toStringAsFixed(0)}%",
            icon: Icons.assignment,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _progressCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  // ============================================================
  // GRÁFICO DE HIDRATAÇÃO
  // ============================================================

  Widget _buildHydrationChart() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Hidratação Diária",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 230,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: hydrationPoints,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.blue,
                    dotData: FlDotData(show: false),
                  ),
                ],
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
