import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'services/auth_service.dart';
import 'screens/tela_menu_principal.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// Configurações do Supabase (Injetadas via --dart-define no build)
const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'SUA_URL_DO_SUPABASE',
);
const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'SUA_ANON_KEY_DO_SUPABASE',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const GrimorioApp(),
    ),
  );
}


class GrimorioApp extends StatelessWidget {
  const GrimorioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O Grimório Perdido',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFD4AF37), // Dourado Místico
        scaffoldBackgroundColor: const Color(0xFF050505), // Preto Profundo
        fontFamily: 'Georgia', // Fonte com serifa para ar antigo
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37),
          brightness: Brightness.dark,
        ),
      ),
      home: const TelaMenuPrincipal(),
    );
  }
}
