// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _fechaHora = '';

  @override
  void initState() {
    super.initState();
    _actualizarFechaHora();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _actualizarFechaHora());
  }

  void _actualizarFechaHora() {
    final ahora = DateTime.now();
    final formato = DateFormat('dd/MM/yyyy HH:mm:ss');
    setState(() {
      _fechaHora = formato.format(ahora);
    });
  }

  @override
  Widget build(BuildContext context) {
    final integrantes = [
      'Miguel Gutierrez',
      'Jheilyn Ramirez',
      'Ellyhan Rodriguez',
      'Debora Mayurel',
      'Maikel Perez',
      'Maria Sanchez',
    ];
    return Scaffold(
      drawer: MenuLateral(),
      appBar: AppBar(
        title: const Text('Bienvenido a Unidades Manager'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group, size: 80, color: Colors.blue),
              SizedBox(height: 24),
              Text(
                'Grupo 1',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Integrantes:',  
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              ...integrantes.map((nombre) => Text(
                nombre,
                style: TextStyle(fontSize: 18),
              )),
              SizedBox(height: 32),
              Text(
                'Fecha y Hora:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                _fechaHora,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage('assets/imagenes/logo-iujo.png'),
                ),
            ), child: Text(
              '...::: Menu Lateral :::...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/');
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.calculate),
          //   title: Text('Calculadora'),
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.pushNamed(context, '/calculadora');
          //   },
          // ),
          // ListTile(
          //   leading: Icon(Icons.assignment),
          //   title: Text('Formulario'),
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.pushNamed(context, '/formulario');
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Salir'),
            onTap: () {
              DialogoSalir.alert(
                context,
                title: 'Salir',
                description: '¿Está seguro que desea salir?',
                icono: 'assets/imagenes/icon_question.png',
              );
            },
          ),
        ],
      ),
    );
  }
}

abstract class DialogoSalir {
  static alert(
      BuildContext context, {
        required String title,
        required String description,
        required String icono,
      }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: SizedBox(
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Column(
                  children: [
                    SizedBox(height: 20.0),
                    Image.asset(
                      'assets/imagenes/icon_question.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 25.0),
                    Text(description),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            minWidth: 100.0,
            height: 30.0,
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el Drawer o el diálogo
              exit(0);
            },
            color: Colors.blueGrey,
            child: Text('Si', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 10.0),
          MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            minWidth: 100.0,
            height: 30.0,
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: Colors.blue,
            child: Text('No', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 10.0),
        ],
      ),
    );
  }
}