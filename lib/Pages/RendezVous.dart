
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RendezVous extends StatefulWidget {
  const RendezVous({Key? key}) : super(key: key);

  @override
  State<RendezVous> createState() => _RendezVous();
}

class _RendezVous extends State<RendezVous> {
  final String apiUrl = 'http://127.0.0.1:3000/rendez-vous';

  List<dynamic> events = [];
  bool chargement = true;
  String? erreur;

  @override
  void initState() {
    super.initState();
    chargerRendezVous();
  }

  // Récupérer les rendez-vous
  Future<void> chargerRendezVous() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final donnees = jsonDecode(response.body);

        if (!mounted) return;

        setState(() {
          events = donnees;
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

  // Modifier un rendez-vous
  Future<void> modifierRendezVous(
    Map<String, dynamic> event,
  ) async {
    final titreController =
        TextEditingController(text: event['titre'] ?? '');

    final descriptionController =
        TextEditingController(text: event['description'] ?? '');

    final dateController = TextEditingController(
      text: event['date_rdv'].toString().substring(0, 10),
    );

    final debutController =
        TextEditingController(text: event['heure_debut'] ?? '');

    final finController =
        TextEditingController(text: event['heure_fin'] ?? '');

    final lieuController =
        TextEditingController(text: event['lieu'] ?? '');

    final participantsController =
        TextEditingController(text: event['participants'] ?? '');

    final formKey = GlobalKey<FormState>();

    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifier le rendez-vous'),

          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titreController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Le titre est obligatoire'
                              : null,
                    ),

                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),

                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date (AAAA-MM-JJ)',
                      ),
                    ),

                    TextFormField(
                      controller: debutController,
                      decoration: const InputDecoration(
                        labelText: 'Heure de début (HH:MM:SS)',
                      ),
                    ),

                    TextFormField(
                      controller: finController,
                      decoration: const InputDecoration(
                        labelText: 'Heure de fin (HH:MM:SS)',
                      ),
                    ),

                    TextFormField(
                      controller: lieuController,
                      decoration: const InputDecoration(
                        labelText: 'Lieu',
                      ),
                    ),

                    TextFormField(
                      controller: participantsController,
                      decoration: const InputDecoration(
                        labelText: 'Participants',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuler'),
            ),

            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      try {
        final id = event['id'];

        final response = await http.put(
          Uri.parse('$apiUrl/$id'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'titre': titreController.text.trim(),
            'description': descriptionController.text.trim(),
            'date_rdv': dateController.text.trim(),
            'heure_debut': debutController.text.trim(),
            'heure_fin': finController.text.trim().isEmpty
                ? null
                : finController.text.trim(),
            'lieu': lieuController.text.trim(),
            'participants': participantsController.text.trim(),
          }),
        );

        if (!mounted) return;

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rendez-vous modifié avec succès !'),
            ),
          );

          await chargerRendezVous();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : ${response.body}'),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }

    titreController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    debutController.dispose();
    finController.dispose();
    lieuController.dispose();
    participantsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planning des rendez-vous'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: chargerRendezVous,

        child: Builder(
          builder: (context) {
            if (chargement) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (erreur != null) {
              return ListView(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      'Impossible de charger les rendez-vous.\n$erreur',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: chargerRendezVous,
                      child: const Text('Réessayer'),
                    ),
                  ),
                ],
              );
            }

            if (events.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Text('Aucun rendez-vous enregistré.'),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: events.length,

              itemBuilder: (context, index) {
                final event = events[index];

                final titre = event['titre'] ?? '';
                final description =
                    event['description'] ?? 'Aucune description';

                final date =
                    event['date_rdv'].toString().substring(0, 10);

                final heureDebut = event['heure_debut'] ?? '';
                final heureFin = event['heure_fin'] ?? '';

                final lieu = event['lieu'] ?? 'Non précisé';
                final participants =
                    event['participants'] ?? 'Non précisés';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 7),

                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      ),
                    ),

                    title: Text(
                      '$titre ($heureDebut - $heureFin)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      'Date : $date\nLieu : $lieu',
                    ),

                    isThreeLine: true,

                    trailing: const Icon(
                      Icons.info_outline,
                      color: Colors.green,
                    ),

                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: Text(titre),

                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Description : $description'),
                                  const SizedBox(height: 10),
                                  Text('Date : $date'),
                                  Text(
                                    'Heure : $heureDebut - $heureFin',
                                  ),
                                  Text('Lieu : $lieu'),
                                  Text('Participants : $participants'),
                                ],
                              ),
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('Fermer'),
                              ),

                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  modifierRendezVous(
                                    Map<String, dynamic>.from(event),
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Modifier'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
