import 'package:flutter/material.dart';
import 'package:ihealthy/services/database_helper.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ihealthy/features/auth/water/pages/water_page.dart';
import 'package:ihealthy/features/auth/exercise/pages/exercise_page.dart';
import 'package:ihealthy/features/auth/habits/pages/habit_page.dart';
import 'package:ihealthy/features/auth/progress/pages/progress_page.dart';
import 'package:ihealthy/features/auth/conquistas/pages/conquistas_page.dart'; // 🔥 IMPORTAR AQUI


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

// =======================================
// TELA PRINCIPAL COM BARRA DE NAVEGAÇÃO
// =======================================
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardPage(),
    const WaterPage(),
    const ExercisePage(),
    const HabitPage(), 
    const ProgressPage(),
    const ConquistasPage(),
  ];

  void onTabTapped(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[currentIndex],
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.local_drink), label: 'Água'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercícios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progresso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Conquistas',
          ),
        ],
      ),
    );
  }
}

// ============================
// DASHBOARD (Início)
// ============================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _db = DatabaseHelper();

  int aguaAtualMl = 0;
  int metaAguaMl = 2000;

  int exercicioMin = 0;
  int metaExercicio = 30;

  int totalHabitos = 0;
  int habitosConcluidosHoje = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final aguaHoje = await _db.getTodayTotalMl();
    final metaAgua = await _db.getDailyGoalMl();
    final exercicioHoje = await _db.getTodayTotalExerciseMin();
    final metaEx = await _db.getExerciseDailyGoalMin();

    final habitos = await _db.getAllHabits();
    int feitos = 0;

    for (var h in habitos) {
      bool done = await _db.isHabitDoneToday(h['id']);
      if (done) feitos++;
    }

    setState(() {
      aguaAtualMl = aguaHoje;
      metaAguaMl = metaAgua;
      exercicioMin = exercicioHoje;
      metaExercicio = metaEx;

      totalHabitos = habitos.length;
      habitosConcluidosHoje = feitos;

      isLoading = false;
    });
  }

  double _aguaPercent() {
    if (metaAguaMl == 0) return 0;
    return (aguaAtualMl / metaAguaMl).clamp(0, 1);
  }

  double _exPercent() {
    if (metaExercicio == 0) return 0;
    return (exercicioMin / metaExercicio).clamp(0, 1);
  }

  double _habitosPercent() {
    if (totalHabitos == 0) return 0;
    return (habitosConcluidosHoje / totalHabitos).clamp(0, 1);
  }

  String get mensagemMotivacional {
    final aguaOk = aguaAtualMl >= metaAguaMl;
    final exOk = exercicioMin >= metaExercicio;
    final habitosOk = totalHabitos > 0 && habitosConcluidosHoje == totalHabitos;

    if (aguaOk && exOk && habitosOk) {
      return "Dia perfeito! Você está brilhando! ✨🔥";
    }

    if (aguaOk || exOk || habitosOk) {
      return "Ótimo! Continue assim que você está no caminho certo! 💪";
    }

    return "Vamos começar o dia com energia positiva! 🌞";
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.teal,
          onRefresh: _loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // ==============================
                // CABEÇALHO
                // ==============================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xffcbbcf6),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=47',
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Criar seu objetivo para o seu futuro.",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Sexta-feira, 3 de outubro",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==============================
                // MENSAGEM
                // ==============================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_emotions, color: Colors.teal),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mensagemMotivacional,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ==============================
                // PROGRESSO HOJE
                // ==============================
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Progresso de Hoje",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // HIDRATAÇÃO
                _buildProgressCard(
                  "Hidratação",
                  "${(_aguaPercent() * 100).toStringAsFixed(0)}%",
                  "$aguaAtualMl ml de $metaAguaMl ml",
                  _aguaPercent(),
                  Colors.blueAccent,
                ),

                // EXERCÍCIOS
                _buildProgressCard(
                  "Exercícios",
                  "${(_exPercent() * 100).toStringAsFixed(0)}%",
                  "$exercicioMin min de $metaExercicio min",
                  _exPercent(),
                  Colors.orangeAccent,
                ),

                // HÁBITOS (AGORA REAL)
                _buildProgressCard(
                  "Hábitos",
                  "${(_habitosPercent() * 100).toStringAsFixed(0)}%",
                  "$habitosConcluidosHoje de $totalHabitos hábitos",
                  _habitosPercent(),
                  Colors.green,
                ),

                const SizedBox(height: 20),

                // ==============================
                // AÇÕES RÁPIDAS
                // ==============================
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Ações Rápidas",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      "+ Água",
                      Colors.blueAccent,
                      Icons.water_drop,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WaterPage()),
                      ).then((_) => _loadDashboardData()),
                    ),
                    _buildQuickAction(
                      "+ Exercícios",
                      Colors.orangeAccent,
                      Icons.fitness_center,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExercisePage()),
                      ).then((_) => _loadDashboardData()),
                    ),
                    _buildQuickAction(
                      "+ Hábitos",
                      Colors.green,
                      Icons.self_improvement,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HabitosPage()),
                      ).then((_) => _loadDashboardData()),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================
  // COMPONENTES
  // ============================
  Widget _buildProgressCard(
    String title,
    String percent,
    String subtitle,
    double value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                percent,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: value,
            progressColor: color,
            backgroundColor: color.withOpacity(0.2),
            barRadius: const Radius.circular(10),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

// ====================================
// Telas Secundárias (temporárias)
// ====================================
class ExerciciosPage extends StatelessWidget {
  const ExerciciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(title: 'Treinos e Exercícios 🏋️‍♂️');
  }
}

class HabitosPage extends StatelessWidget {
  const HabitosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const HabitPage();
  }
}

class ProgressoPage extends StatelessWidget {
  const ProgressoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(title: 'Seu Progresso 📊');
  }
}



// Template de tela simples
class _SimpleScreen extends StatelessWidget {
  final String title;
  const _SimpleScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
