// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:unidades_manager/src/home.dart';
import 'package:unidades_manager/src/unidades_list.dart';
//import 'package:unidades_manager/src/.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/unidades': (context) => const UnidadesList(),
        //'/': (context) => const (title: ''),
      },
    );
  }
}