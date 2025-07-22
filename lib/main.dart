import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
