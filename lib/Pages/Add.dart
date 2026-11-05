
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Add extends StatefulWidget {
  const Add({Key? key}) : super(key: key);

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final _formKey = GlobalKey<FormState>();

  final titreController = TextEditingController();
  final descriptionController = TextEditingController();
  final lieuController = TextEditingController();
  final participantsController = TextEditingController();

  DateTime? dateRdv;
  TimeOfDay? heureDebut;
  TimeOfDay? heureFin;

  bool chargement = false;

  final String apiUrl = 'http://127.0.0.1:3000/rendez-vous';

  String formaterHeure(TimeOfDay heure) {
    return '${heure.hour.toString().padLeft(2, '0')}:'
        '${heure.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> choisirDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => dateRdv = date);
    }
  }

  Future<void> choisirHeure(bool debut) async {
    final heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (heure != null) {
      setState(() {
        if (debut) {
          heureDebut = heure;
        } else {
          heureFin = heure;
        }
      });
    }
  }

  Future<void> ajouterRendezVous() async {
    if (!_formKey.currentState!.validate()) return;

    if (dateRdv == null || heureDebut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choisis une date et une heure de début.'),
        ),
      );
      return;
    }

    setState(() => chargement = true);

    final date = '${dateRdv!.year}-'
        '${dateRdv!.month.toString().padLeft(2, '0')}-'
        '${dateRdv!.day.toString().padLeft(2, '0')}';

    try {
      final reponse = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titre': titreController.text.trim(),
          'description': descriptionController.text.trim(),
          'date_rdv': date,
          'heure_debut': formaterHeure(heureDebut!),
          'heure_fin': heureFin == null
              ? null
              : formaterHeure(heureFin!),
          'lieu': lieuController.text.trim(),
          'participants': participantsController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (reponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rendez-vous ajouté avec succès !')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${reponse.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
    } finally {
      if (mounted) setState(() => chargement = false);
    }
  }

  @override
  void dispose() {
    titreController.dispose();
    descriptionController.dispose();
    lieuController.dispose();
    participantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un rendez-vous'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre du rendez-vous',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Saisis le titre'
                        : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              ListTile(
                title: Text(dateRdv == null
                    ? 'Choisir la date'
                    : 'Date : ${dateRdv!.day}/${dateRdv!.month}/${dateRdv!.year}'),
                trailing: const Icon(Icons.calendar_month),
                onTap: choisirDate,
              ),
              const Divider(),

              ListTile(
                title: Text(heureDebut == null
                    ? 'Heure de début'
                    : 'Début : ${heureDebut!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => choisirHeure(true),
              ),

              ListTile(
                title: Text(heureFin == null
                    ? 'Heure de fin (facultative)'
                    : 'Fin : ${heureFin!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => choisirHeure(false),
              ),
              const Divider(),

              TextFormField(
                controller: lieuController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: participantsController,
                decoration: const InputDecoration(
                  labelText: 'Participants',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: chargement ? null : ajouterRendezVous,
                  icon: const Icon(Icons.save),
                  label: Text(
                    chargement ? 'Enregistrement...' : 'Enregistrer',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
