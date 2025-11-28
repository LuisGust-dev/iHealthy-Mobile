import 'package:flutter/material.dart';
import 'package:ihealthy/services/database_helper.dart';

class ConquistasPage extends StatefulWidget {
  const ConquistasPage({super.key});

  @override
  State<ConquistasPage> createState() => _ConquistasPageState();
}

class _ConquistasPageState extends State<ConquistasPage> {
  final _db = DatabaseHelper();
  List<Map<String, dynamic>> conquistas = [];

  int totalPontos = 0;
  int totalConquistas = 0;
  int totalProgresso = 0;

  String rank = "Iniciante";
  double xpPercent = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final data = await _db.getAllAchievements();

    int pontos = 0;
    int unlocked = 0;
    int progressoTotal = 0;
    int progressoMax = 0;

   for (var a in data) {
  final unlockedFlag = a['unlocked'] == 1;
  if (unlockedFlag) {
    pontos += 100; 
    unlocked++;
  }

  progressoTotal += (a['progress'] as int);
  progressoMax += (a['goal'] as int);
}


    setState(() {
      conquistas = data;
      totalPontos = pontos;
      totalConquistas = unlocked;
      totalProgresso = progressoTotal;

      xpPercent = progressoMax == 0 ? 0 : (progressoTotal / progressoMax);

      rank = _definirRank(totalPontos);
    });
  }

  // ============================================================
  // SISTEMA DE RANK
  // ============================================================

  String _definirRank(int pontos) {
    if (pontos < 200) return "Iniciante";
    if (pontos < 400) return "Entusiasta";
    if (pontos < 700) return "Intermediário";
    if (pontos < 1000) return "Avançado";
    if (pontos < 1500) return "Mestre";
    return "Lendário";
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAchievements,
          color: Colors.teal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "🏆 Conquistas",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text("Celebre seu progresso diário",
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 25),

                _cardRank(),

                const SizedBox(height: 25),
                const Text(
                  "Suas conquistas",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 15),

              ...conquistas.map((a) => _conquistaCard(a)),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //============================================================
  // CARD DO RANK (NÍVEL)
  //============================================================
  Widget _cardRank() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xfffe9bf3), Color(0xffa08bff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.star, color: Colors.yellow, size: 45),
          const SizedBox(height: 12),
          Text(
            rank,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text("Nível atual do usuário",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _nivelInfo("$totalConquistas", "Conquistas"),
              _nivelInfo("$totalPontos", "Pontos"),
              _nivelInfo("${(xpPercent * 100).toStringAsFixed(0)}%", "Progresso"),
            ],
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: xpPercent,
              minHeight: 10,
              color: Colors.yellowAccent,
              backgroundColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _nivelInfo(String valor, String label) {
    return Column(
      children: [
        Text(valor,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  //============================================================
  // CARTÕES DE CONQUISTAS
  //============================================================

  Widget _conquistaCard(Map<String, dynamic> a) {
    final bool unlocked = a['unlocked'] == 1;
    final progress = a['progress'];
    final goal = a['goal'];

    final double percent = goal == 0 ? 0 : (progress / goal);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: unlocked ? Colors.teal : Colors.grey,
                radius: 22,
                child: Icon(Icons.emoji_events,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  a['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: unlocked ? Colors.black87 : Colors.black45,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),
          Text(
            a['description'],
            style: TextStyle(
              color: unlocked ? Colors.black87 : Colors.black45,
            ),
          ),

          const SizedBox(height: 10),

          // Barra de progresso (se ainda não desbloqueou)
          if (!unlocked)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    color: Colors.teal,
                    backgroundColor: Colors.grey.shade300,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Progresso: $progress / $goal",
                    style: const TextStyle(color: Colors.black54)),
              ],
            )
          else
            Text(
              "Desbloqueado em: ${a['unlocked_date']?.substring(0, 10)}",
              style: const TextStyle(color: Colors.black54),
            ),
        ],
      ),
    );
  }
}
