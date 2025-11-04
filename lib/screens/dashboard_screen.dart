import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/user_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? userName;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final name = await UserService.getUserName();
    setState(() => userName = name);
  }

  void _logout() async {
    await UserService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("iHealthy Dashboard", style: GoogleFonts.poppins()),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Olá, ${userName ?? ''}! 👋\nBem-vindo ao seu painel saudável!",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 22),
        ),
      ),
    );
  }
}
