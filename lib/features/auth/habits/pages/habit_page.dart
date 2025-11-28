import 'package:flutter/material.dart';
import 'package:ihealthy/services/database_helper.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  final _db = DatabaseHelper();

  List<Map<String, dynamic>> habits = [];
  Map<int, bool> doneToday = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  Future<void> loadHabits() async {
    final data = await _db.getAllHabits();
    final status = <int, bool>{};

    for (var h in data) {
      status[h['id']] = await _db.isHabitDoneToday(h['id']);
    }

    setState(() {
      habits = data;
      doneToday = status;
      loading = false;
    });
  }

  Future<void> toggleHabit(int id) async {
    await _db.toggleHabitDone(id);
    await loadHabits();
  }

  double get progress {
    if (habits.isEmpty) return 0;
    final done = doneToday.values.where((e) => e).length;
    return done / habits.length;
  }

  int get progressCount => doneToday.values.where((e) => e).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () => _openCreateHabit(),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: const [
                    Icon(Icons.track_changes, color: Colors.green, size: 28),
                    SizedBox(width: 8),
                    Text("Hábitos Saudáveis",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 4),
                  const Text("Construa uma rotina saudável", style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 20),

                  // Progresso
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 3))
                      ],
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Progresso de Hoje", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        color: Colors.green,
                        backgroundColor: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      SizedBox(height: 6),
                      Text("$progressCount de ${habits.length} hábitos",
                          style: const TextStyle(color: Colors.black54)),
                    ]),
                  ),

                  const SizedBox(height: 24),
                  const Text("Seus Hábitos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),

                  ...habits.map((h) => _habitItem(h)).toList(),

                  const SizedBox(height: 20),
                ]),
              ),
            ),
    );
  }

  Widget _habitItem(Map<String, dynamic> habit) {
    final id = habit['id'];
    final name = habit['name'];
    final icon = habit['icon'];
    final color = Color(int.parse(habit['color']));
    final streak = habit['streak'];
    final isDone = doneToday[id] ?? false;

    return GestureDetector(
      onTap: () => toggleHabit(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? Colors.green : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.3),
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text("Diário • $streak dias",
                  style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
          ),

          Icon(Icons.check_circle,
              size: 30, color: isDone ? Colors.green : Colors.grey.shade300),
        ]),
      ),
    );
  }

  // ================ POPUP CRIAR HÁBITO ======================

  void _openCreateHabit() {
    final nameController = TextEditingController();
    String frequency = "Diário";
    String selectedIcon = "✔";
    int selectedColor = 0xFF6C63FF;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text("Novo Hábito",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nome do Hábito",
                    hintText: "Ex: Beber 2L de água",
                  ),
                ),

                const SizedBox(height: 20),
                const Text("Frequência", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _frequencyButton("Diário", frequency, setModalState),
                    const SizedBox(width: 10),
                    _frequencyButton("Semanal", frequency, setModalState),
                  ],
                ),

                const SizedBox(height: 20),
                const Text("Ícone", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    "✔", "💧", "🏃‍♂️", "😴", "🧘‍♂️", "📚", "🥗", "🚭", "💪", "🎯"
                  ].map((e) {
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = e),
                      child: CircleAvatar(
                        backgroundColor:
                            selectedIcon == e ? Colors.green : Colors.grey.shade200,
                        child: Text(e),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Text("Cor", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 12,
                  children: [
                    0xFF2196F3,
                    0xFF4CAF50,
                    0xFFFF9800,
                    0xFF9C27B0,
                    0xFFE91E63,
                    0xFF00BCD4,
                  ].map((c) {
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = c),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(c),
                        child: selectedColor == c
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) return;

                          await _db.addHabit({
                            'name': nameController.text.trim(),
                            'icon': selectedIcon,
                            'color': selectedColor.toString(),
                            'frequency': frequency,
                            'streak': 0,
                          });

                          Navigator.pop(context);
                          loadHabits();
                        },
                        child: const Text("Adicionar Hábito"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ]),
            );
          }),
        );
      },
    );
  }

  Widget _frequencyButton(String text, String selected,
      void Function(void Function()) setStateModal) {
    final isSelected = text == selected;

    return Expanded(
      child: GestureDetector(
        onTap: () => setStateModal(() => selected = text),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
              child: Text(text,
                  style: TextStyle(
                      color: isSelected ? Colors.green : Colors.black))),
        ),
      ),
    );
  }
}
