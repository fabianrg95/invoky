import 'package:flutter/material.dart';

class AppTheme {
  // Paleta de colores Cosmic Night
  static const Color cosmicDark = Color(0xFF0A0E17);
  static const Color cosmicPrimary = Color(0xFF7C4DFF);
  static const Color cosmicSecondary = Color(0xFF5E35B1);
  static const Color cosmicBackground = Color(0xFF121927);
  static const Color cosmicSurface = Color(0xFF1A2232);
  static const Color cosmicText = Color(0xFFE0E0E0);
  static const Color cosmicTextSecondary = Color(0xFF9E9E9E);
  static const Color cosmicAccent = Color(0xFF00B0FF);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      // Configuración básica de colores
      primaryColor: cosmicPrimary,
      scaffoldBackgroundColor: cosmicBackground,
      cardColor: cosmicSurface,
      dividerColor: Colors.white12,
      colorScheme: const ColorScheme.dark(
        primary: cosmicPrimary,
        secondary: cosmicAccent,
        surface: cosmicSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: cosmicText,
        onSurfaceVariant: cosmicText,
      ),
      
      // Tema de texto
      textTheme: TextTheme(
        displayLarge: const TextStyle(color: cosmicText, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(color: cosmicText, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: const TextStyle(color: cosmicText, fontSize: 24, fontWeight: FontWeight.bold),
        headlineMedium: const TextStyle(color: cosmicText, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: const TextStyle(color: cosmicText, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: const TextStyle(color: cosmicText, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(color: cosmicText, fontSize: 16),
        titleSmall: const TextStyle(color: cosmicTextSecondary, fontSize: 14),
        bodyLarge: const TextStyle(color: cosmicText, fontSize: 16),
        bodyMedium: const TextStyle(color: cosmicTextSecondary, fontSize: 14),
        labelLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
        bodySmall: TextStyle(color: cosmicText.withValues(alpha: 0.7), fontSize: 12),
      ),
      
      // Barra de aplicación
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: cosmicSurface,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: cosmicText,
        ),
        iconTheme: const IconThemeData(color: cosmicText),
        actionsIconTheme: const IconThemeData(color: cosmicText),
      ),
      
      // Campos de entrada
      inputDecorationTheme: InputDecorationTheme(
                        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                      ),
      
      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: cosmicPrimary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      
      // Tarjetas
      cardTheme: ThemeData.dark().cardTheme.copyWith(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        color: cosmicSurface,
      ),
      
      // Elementos de lista
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        iconColor: cosmicPrimary,
        textColor: cosmicText,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      
      // Menú lateral
      drawerTheme: DrawerThemeData(
        backgroundColor: cosmicSurface,
        elevation: 0,
        width: 280,
      ),
      
      // Estilo de los botones de acción flotantes
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cosmicPrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ), dialogTheme: DialogThemeData(backgroundColor: cosmicSurface),
      
    );
  }
}
