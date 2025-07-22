import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'screens/home_screen.dart';

// Agrega esta importación si usas window_manager
// import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);

  // Pantalla completa solo en escritorio
  if (!Platform.isAndroid && !Platform.isIOS) {
    // Si tienes window_manager, descomenta estas líneas y añade window_manager a pubspec.yaml
    // await windowManager.ensureInitialized();
    // WindowOptions windowOptions = const WindowOptions(
    //   size: Size(1920, 1080),
    //   center: true,
    //   backgroundColor: Colors.transparent,
    //   fullScreen: true,
    // );
    // windowManager.waitUntilReadyToShow(windowOptions, () async {
    //   await windowManager.show();
    //   await windowManager.maximize();
    // });
    // Si no usas window_manager, puedes dejarlo así y solo el tema oscuro se aplicará
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La casa de los papelitos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        // Configuración básica de colores
        primaryColor: Colors.deepPurple.shade300,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: Colors.grey.shade800,
        dialogBackgroundColor: const Color(0xFF1E1E1E),
        
        // Tema de texto
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        
        // Barra de aplicación
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.deepPurple.shade800,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        
        // Campos de entrada
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          filled: true,
          fillColor: Colors.grey.shade900,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: const TextStyle(color: Colors.grey),
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
        
        // Botones elevados
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.deepPurple.shade700,
            foregroundColor: Colors.white,
          ),
        ),
        
        // Tarjetas
        // Usando los valores por defecto de CardTheme
        
        // Elementos de lista
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          iconColor: Colors.white,
        ),
        
        // Menú lateral
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF1E1E1E),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
