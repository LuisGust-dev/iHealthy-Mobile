import 'package:flutter/material.dart';
import 'package:ihealthy/services/database_helper.dart';
import '../widgets/water_circular_indicator.dart';

class WaterPage extends StatefulWidget {
  const WaterPage({super.key});

  @override
  State<WaterPage> createState() => _WaterPageState();
}

class _WaterPageState extends State<WaterPage> {
  final db = DatabaseHelper();

  int totalMl = 0;
  int goalMl = 2000;
  List<Map<String, dynamic>> logs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final total = await db.getTodayTotalMl();
    final goal = await db.getDailyGoalMl();
    final history = await db.getTodayWaterLogsRaw();

    setState(() {
      totalMl = total;
      goalMl = goal;
      logs = history;
    });
  }

  Future<void> _addWater(int amount) async {
    await db.addWater(amount);
    _loadData();
  }

  void _showCustomAmountDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Adicionar água"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Quantidade em ml",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Adicionar"),
            onPressed: () {
              final ml = int.tryParse(controller.text) ?? 0;
              if (ml > 0) _addWater(ml);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // =======================
  //     INTERFACE (UI)
  // =======================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        title: const Text("Hidratação 💧"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ===== CÍRCULO PRINCIPAL =====
            WaterCircularIndicator(
              totalMl: totalMl,
              goalMl: goalMl,
            ),

            const SizedBox(height: 20),

            // ===== META DIÁRIA =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Meta diária: $goalMl ml",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editGoalDialog,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===== BOTÕES RÁPIDOS =====
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: [
                _quickButton(200),
                _quickButton(300),
                _quickButton(500),
                _quickButton(1000),
                _customButton(),
              ],
            ),

            const SizedBox(height: 30),

            // ===== HISTÓRICO =====
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Histórico de hoje",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _quickButton(int ml) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () => _addWater(ml),
      child: Text("+ ${ml}ml",
          style: const TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _customButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: _showCustomAmountDialog,
      child: const Text("Personalizar",
          style: TextStyle(color: Colors.white, fontSize: 16)),
    );
  }

  Widget _buildHistoryList() {
    if (logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Nenhum registro ainda hoje."),
      );
    }

    return Column(
      children: logs.map((item) {
        final time = DateTime.fromMillisecondsSinceEpoch(item['timestamp_ms']);
        final hour = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

        return ListTile(
          leading: const Icon(Icons.water_drop, color: Colors.blueAccent),
          title: Text("${item['amount_ml']} ml"),
          subtitle: Text("Horário: $hour"),
        );
      }).toList(),
    );
  }

  void _editGoalDialog() {
    final controller = TextEditingController(text: goalMl.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Alterar meta diária"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Nova meta (ml)",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Salvar"),
            onPressed: () async {
              final ml = int.tryParse(controller.text) ?? goalMl;
              await db.setDailyGoalMl(ml);
              _loadData();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
