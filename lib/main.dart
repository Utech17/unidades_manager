// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:unidades_manager/src/home.dart';
import 'package:unidades_manager/src/unidades_list.dart';
import 'package:unidades_manager/core/app_colors.dart';
import 'package:unidades_manager/src/config_screen.dart';
import 'package:http/http.dart' as http;
import 'package:unidades_manager/src/camera_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppTextColors.inverseText,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/unidades': (context) => const UnidadesList(),
        '/imagen': (context) => const CameraScreen(),
        '/configuracion': (context) => const ConfigScreen(),
      },
    );
  }
}
