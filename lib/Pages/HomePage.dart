
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:monrdvm/Pages/RendezVous.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Adresse de notre API Node.js
  final String apiUrl = 'http://127.0.0.1:3000/rendez-vous';

  List<dynamic> rendezVous = [];
  bool chargement = true;
  String? erreur;

  @override
  void initState() {
    super.initState();
    chargerRendezVous();
  }

  // Récupérer les rendez-vous depuis MariaDB via l'API
  Future<void> chargerRendezVous() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final donnees = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          rendezVous = donnees;
          chargement = false;
          erreur = null;
        });
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erreur = e.toString();
        chargement = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final maintenant = DateTime.now();

    final prochains = rendezVous.where((rdv) {
      final date = DateTime.parse(rdv['date_rdv'].toString());
      return !date.isBefore(DateTime(
        maintenant.year,
        maintenant.month,
        maintenant.day,
      ));
    }).toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: chargerRendezVous,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Image.asset(
              "assets/images/rdv.jpg",
              height: 180,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 15),

            const Text(
              "Bienvenue dans votre App de Rendez-vous mensuel",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Votre assistant de Rendez-vous mensuel",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 25),

            // Statistiques
            if (chargement)
              const Center(child: CircularProgressIndicator())
            else if (erreur != null)
              Column(
                children: [
                  Text(
                    "Impossible de charger les données.\n$erreur",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  TextButton(
                    onPressed: chargerRendezVous,
                    child: const Text("Réessayer"),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: carteStatistique(
                      "Total des RDV",
                      rendezVous.length.toString(),
                      Icons.calendar_month,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: carteStatistique(
                      "À venir",
                      prochains.length.toString(),
                      Icons.event_available,
                      Colors.blue,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 25),

            const Text(
              "Prochains rendez-vous",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (!chargement && erreur == null && prochains.isEmpty)
              const Text("Aucun rendez-vous à venir."),

            if (!chargement && erreur == null)
              ...prochains.take(3).map((rdv) {
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.event,
                      color: Colors.green,
                    ),
                    title: Text(rdv['titre'] ?? ''),
                    subtitle: Text(
                      "${rdv['date_rdv'].toString().substring(0, 10)}"
                      " à ${rdv['heure_debut']}\n"
                      "Lieu : ${rdv['lieu'] ?? 'Non précisé'}",
                    ),
                    isThreeLine: true,
                  ),
                );
              }),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(14),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RendezVous(),
                  ),
                ).then((_) => chargerRendezVous());
              },
              icon: const Icon(Icons.calendar_month),
              label: const Text(
                "Planning",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher une statistique
  Widget carteStatistique(
    String titre,
    String valeur,
    IconData icone,
    Color couleur,
  ) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icone, color: couleur, size: 32),
            const SizedBox(height: 8),
            Text(
              valeur,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              titre,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
