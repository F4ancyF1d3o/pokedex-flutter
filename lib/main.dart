import 'package:flutter/material.dart';

import 'screens/pokemon_catalog_screen.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF080C16);
    const cyan = Color(0xFF70F4E2);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PULSEDEX',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: cyan,
          secondary: Color(0xFFFF5277),
          surface: Color(0xFF121A29),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PokemonCatalogScreen(),
    );
  }
}
