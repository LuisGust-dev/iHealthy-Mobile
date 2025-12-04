import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Classe responsável por centralizar temas globais da aplicação.
class AppTheme {
  // ------------------------------------------------------------
  // CORES PADRÃO (apenas constantes sem impacto)
  // ------------------------------------------------------------
  static const Color _scaffoldBackground = Color(0xFFF5F5F5);
  static const Color _inputFillColor = Colors.white;

  // Raio padrão reutilizável para inputs
  static const double _inputBorderRadius = 25.0;

  // Padding padrão para campos de texto
  static const EdgeInsets _inputPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 18);

  // ------------------------------------------------------------
  // TEMA CLARO PRINCIPAL (getter para evitar inicialização estática)
  // ------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: _scaffoldBackground,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _inputFillColor,
        contentPadding: _inputPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputBorderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
