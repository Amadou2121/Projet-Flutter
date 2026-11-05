
import 'package:monrdvm/Pages/HomePage.dart';
import 'package:monrdvm/Pages/RendezVous.dart';
import 'package:monrdvm/Pages/Add.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  void _setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const RendezVous(),
      const Add(),
    ];

    final titles = [
      'Accueil',
      'Vos Rencontres',
      'Ajouter une rencontre',
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(titles[_currentIndex]),
        ),
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _setCurrentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.black,
          iconSize: 30,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Rendez-vous',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Ajouter',
            ),
          ],
        ),
      ),
    );
  }
}
