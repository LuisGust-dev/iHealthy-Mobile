import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ihealthy/features/auth/water/pages/water_page.dart'; // IMPORTANTE
import 'package:ihealthy/features/auth/exercise/pages/exercise_page.dart';
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
    const ExerciciosPage(),
    const HabitosPage(),
    const ProgressoPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Exercícios'),
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: 'Hábitos'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progresso'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Conquistas'),
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
  double aguaAtual = 1.5;
  double metaAgua = 2.0;

  int exercicioMin = 30;
  int metaExercicio = 45;

  List<Map<String, dynamic>> habitos = [
    {'titulo': 'Dormir 8h', 'feito': true},
    {'titulo': 'Meditar', 'feito': false},
    {'titulo': 'Ler 10 páginas', 'feito': true},
  ];

  String get mensagemMotivacional {
    if (aguaAtual >= metaAgua && exercicioMin >= metaExercicio) {
      return 'Excelente! Continue assim! 🚀';
    } else if (aguaAtual >= metaAgua * 0.5) {
      return 'Você está indo bem, continue progredindo 💪';
    } else {
      return 'Vamos começar o dia com energia! 🌞';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=47'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Criar seu objetivo para o seu futuro.",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(height: 4),
                    Text("Sexta-feira, 3 de outubro",
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Mensagem motivacional
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blueAccent),
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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Progresso de Hoje",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _buildProgressCard(
                "Hidratação",
                "${(aguaAtual / metaAgua * 100).toStringAsFixed(0)}%",
                "${(aguaAtual * 1000).toStringAsFixed(0)}ml de ${(metaAgua * 1000).toStringAsFixed(0)}ml",
                aguaAtual / metaAgua,
                Colors.blueAccent,
              ),

              _buildProgressCard(
                "Exercícios",
                "${(exercicioMin / metaExercicio * 100).toStringAsFixed(0)}%",
                "$exercicioMin min de $metaExercicio min",
                exercicioMin / metaExercicio,
                Colors.orangeAccent,
              ),

              _buildProgressCard(
                "Hábitos",
                "${((habitos.where((h) => h['feito']).length / habitos.length) * 100).toStringAsFixed(0)}%",
                "${habitos.where((h) => h['feito']).length} de ${habitos.length} hábitos",
                habitos.where((h) => h['feito']).length / habitos.length,
                Colors.green,
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ações Rápidas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickAction("+ Água", Colors.blueAccent, Icons.water_drop),
                  _buildQuickAction("+ Exercícios", Colors.orangeAccent, Icons.fitness_center),
                  _buildQuickAction("+ Hábitos", Colors.green, Icons.self_improvement),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String percent, String subtitle, double value, Color color) {
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(percent, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          LinearPercentIndicator(
            lineHeight: 10,
            percent: value.clamp(0, 1),
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

  Widget _buildQuickAction(String label, Color color, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: () {},
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
    return const _SimpleScreen(title: 'Hábitos Diários 🌱');
  }
}

class ProgressoPage extends StatelessWidget {
  const ProgressoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(title: 'Seu Progresso 📊');
  }
}

class ConquistasPage extends StatelessWidget {
  const ConquistasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScreen(title: 'Conquistas 🏅');
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
        child: Text(title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
