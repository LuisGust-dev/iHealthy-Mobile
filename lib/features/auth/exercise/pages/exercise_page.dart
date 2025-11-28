import 'package:flutter/material.dart';
import 'package:ihealthy/services/database_helper.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final _db = DatabaseHelper();

  int _totalToday = 0;
  int _dailyGoal = 30;
  List<Map<String, dynamic>> _todayExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final total = await _db.getTodayTotalExerciseMin();
    final goal = await _db.getExerciseDailyGoalMin();
    final logs = await _db.getTodayExercisesRaw();

    setState(() {
      _totalToday = total;
      _dailyGoal = goal;
      _todayExercises = logs;
      _isLoading = false;
    });
  }

  double get _progress {
    if (_dailyGoal == 0) return 0;
    final p = _totalToday / _dailyGoal;
    return p.clamp(0, 1);
  }

  String get _progressLabel => '$_totalToday min de $_dailyGoal min';

  // ===========================================
  //  SALVA EXERCÍCIO NO BANCO
  // ===========================================
  Future<void> _addExercise({
    required String type,
    required int minutes,
    required String intensity,
  }) async {
    await _db.addExercise(
      type: type,
      durationMin: minutes,
      intensity: intensity,
    );

    await _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$minutes min de $type adicionados 👟')),
    );
  }

  // ===========================================
  //  POPUP PARA DEFINIR MINUTOS + INTENSIDADE
  // ===========================================
  Future<void> _openExerciseDialog({
    required String type,
    required int defaultMinutes,
    required String defaultIntensity,
  }) async {
    final minutesController = TextEditingController(
      text: defaultMinutes.toString(),
    );
    String selectedIntensity = defaultIntensity;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            type,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Duração (minutos)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ex: 20',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Intensidade',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _intensityChip(
                    label: 'Leve',
                    selected: selectedIntensity == 'Leve',
                    onTap: () {
                      setState(() {
                        selectedIntensity = 'Leve';
                      });
                      // precisa chamar setState do dialog
                      (dialogContext as Element).markNeedsBuild();
                    },
                  ),
                  _intensityChip(
                    label: 'Moderado',
                    selected: selectedIntensity == 'Moderado',
                    onTap: () {
                      setState(() {
                        selectedIntensity = 'Moderado';
                      });
                      (dialogContext as Element).markNeedsBuild();
                    },
                  ),
                  _intensityChip(
                    label: 'Intenso',
                    selected: selectedIntensity == 'Intenso',
                    onTap: () {
                      setState(() {
                        selectedIntensity = 'Intenso';
                      });
                      (dialogContext as Element).markNeedsBuild();
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final minutes = int.tryParse(minutesController.text.trim());

                if (minutes == null || minutes <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe um tempo válido em minutos'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, {
                  'minutes': minutes,
                  'intensity': selectedIntensity,
                });
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await _addExercise(
        type: type,
        minutes: result['minutes'] as int,
        intensity: result['intensity'] as String,
      );
    }
  }

  Future<void> _changeGoal() async {
    final controller = TextEditingController(text: _dailyGoal.toString());

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar meta diária'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Meta em minutos',
              hintText: 'Ex: 30',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                if (value == null || value <= 0) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Informe um valor válido')),
                  );
                  return;
                }
                Navigator.pop(context, value);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await _db.setExerciseDailyGoalMin(result);
      await _loadData();
    }
  }

  String _formatTime(int timestampMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Row(
                      children: const [
                        Icon(
                          Icons.fitness_center,
                          color: Colors.orange,
                          size: 26,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Exercícios',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Registre suas atividades físicas',
                      style: TextStyle(color: Colors.black54),
                    ),

                    const SizedBox(height: 24),

                    // Progresso de Hoje
                    const Text(
                      'Progresso de Hoje',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: _progress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(10),
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _progressLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Exercícios rápidos
                    const Text(
                      'Exercícios Rápidos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _quickExerciseButton(
                          label: 'Corrida',
                          icon: Icons.directions_run,
                          color: Colors.deepOrange,
                          defaultMinutes: 20,
                          defaultIntensity: 'Intenso',
                        ),
                        _quickExerciseButton(
                          label: 'Caminhada',
                          icon: Icons.directions_walk,
                          color: Colors.green,
                          defaultMinutes: 15,
                          defaultIntensity: 'Leve',
                        ),
                        _quickExerciseButton(
                          label: 'Musculação',
                          icon: Icons.fitness_center,
                          color: Colors.purple,
                          defaultMinutes: 30,
                          defaultIntensity: 'Moderado',
                        ),
                        _quickExerciseButton(
                          label: 'Yoga',
                          icon: Icons.self_improvement,
                          color: Colors.lightBlue,
                          defaultMinutes: 20,
                          defaultIntensity: 'Leve',
                        ),
                        _quickExerciseButton(
                          label: 'Natação',
                          icon: Icons.pool,
                          color: Colors.blueAccent,
                          defaultMinutes: 30,
                          defaultIntensity: 'Intenso',
                        ),
                        _quickExerciseButton(
                          label: 'Ciclismo',
                          icon: Icons.pedal_bike,
                          color: Colors.amber.shade700,
                          defaultMinutes: 25,
                          defaultIntensity: 'Moderado',
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Exercícios de hoje
                    Row(
                      children: const [
                        Icon(Icons.access_time, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Exercícios de Hoje',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_todayExercises.isEmpty)
                      _emptyListPlaceholder()
                    else
                      Column(
                        children: _todayExercises.map((e) {
                          final type = e['type'] as String;
                          final duration = e['duration_min'] as int;
                          final intensity = e['intensity'] as String;
                          final time = _formatTime(e['timestamp_ms'] as int);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.sports, color: Colors.orange),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '$duration min • $intensity • $time',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 24),

                    // Meta diária
                    const Text(
                      'Meta Diária',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _changeGoal,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xfffff3e0),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_dailyGoal minutos',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tempo recomendado de exercício diário',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Alterar',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _quickExerciseButton({
    required String label,
    required IconData icon,
    required Color color,
    required int defaultMinutes,
    required String defaultIntensity,
  }) {
    return GestureDetector(
      onTap: () => _openExerciseDialog(
        type: label,
        defaultMinutes: defaultMinutes,
        defaultIntensity: defaultIntensity,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: [color.withOpacity(0.9), color]),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _intensityChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.orange.shade100,
    );
  }

  Widget _emptyListPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(Icons.directions_run, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Nenhum exercício registrado hoje',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            'Comece seu treino agora!',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
