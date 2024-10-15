import 'package:flutter/material.dart';
import 'chat_screen.dart';  // Asegúrate de que esta ruta sea correcta
import 'package:url_launcher/url_launcher.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'images/logoupchiapas.png', // Coloca el logo de tu universidad aquí
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Universidad: Universidad Ejemplo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Carrera: Ingeniería en Sistemas',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Materia: Inteligencia Artificial',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Grupo: A',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Alumno: Juan Pérez',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Matrícula: 12345678',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              },
              child: const Text(
                'Ir al Chat',
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            Center(
              child: TextButton(
                onPressed: () {
                  // Abre el enlace al repositorio en el navegador
                  final url = 'https://github.com/isauraplata/api-rest-nutri-balance';
                  launch(url); // Asegúrate de tener importado el paquete 'url_launcher'
                },
                child: const Text(
                  'Ver Repositorio',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
