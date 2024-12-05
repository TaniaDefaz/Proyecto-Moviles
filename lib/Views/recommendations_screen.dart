import 'package:flutter/material.dart';
import 'package:proyecto/Models/bmi_model.dart';
import 'package:proyecto/Servicies/firestore_services.dart';
import 'package:proyecto/Views/daily_form.dart';
import 'package:proyecto/Views/dietarecommendations_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({Key? key}) : super(key: key);

  @override
  _RecommendationsScreenState createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final FirestoreServices firestoreServices = FirestoreServices();
  BMIData? _bmiData;
  Map<String, dynamic>? _routine;

  @override
  void initState() {
    super.initState();
    _fetchBMIData();
    _saveRoutinesForTesting(); // Guardar rutinas para pruebas
  }

  Future<void> _saveRoutinesForTesting() async {
    await firestoreServices.saveRoutines();
  }

  Future<void> _fetchBMIData() async {
    final data = await firestoreServices.getLastBMIData();
    setState(() {
      _bmiData = data;
    });
    if (data != null) {
      _fetchRoutineForCategory(data.bmiCategory!);
    }
  }

  Future<void> _fetchRoutineForCategory(String category) async {
    try {
      final routine = await firestoreServices.getRoutineForCategory(category);
      setState(() {
        _routine = routine;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la rutina: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recomendaciones'),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.menu, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Text(
                    'Menú',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text('Formulario'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DailyForm()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.restaurant, color: Colors.blue),
                    title: Text('Dieta'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DietRecommendationsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueAccent.shade100,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 60),
                if (_bmiData != null)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black45,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.indigo,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'IMC',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          Text(
                            _bmiData!.bmi!.toStringAsFixed(2),
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _bmiData!.bmiCategory ?? '',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_bmiData == null)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                SizedBox(height: 30),
                Text(
                  'Rutina',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                _routine != null
                    ? _buildRoutineTable(_routine!)
                    : Text('Cargando rutina...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutineTable(Map<String, dynamic> routine) {
    // Mapeo de dayX a nombres de días en español
    final dayNames = {
      'day1': 'Lunes',
      'day2': 'Martes',
      'day3': 'Miércoles',
      'day4': 'Jueves',
      'day5': 'Viernes',
      'day6': 'Sábado',
      'day7': 'Domingo',
    };

    // Ordenar las entradas según el orden de los días de la semana
    final orderedKeys = [
      'day1',
      'day2',
      'day3',
      'day4',
      'day5',
      'day6',
      'day7'
    ];

    return Column(
      children: orderedKeys.map((key) {
        if (!routine.containsKey(key))
          return SizedBox.shrink(); // Saltar si la rutina no tiene el día
        final entry = routine[key];
        final exercises = entry['exercise'] ?? 'Ejercicio no disponible';
        final cardio = entry['cardio'] ?? 'Cardio no disponible';

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            leading: Icon(Icons.fitness_center, color: Colors.indigo),
            title: Text(
              dayNames[key] ?? key, // Mostrar el nombre del día en español
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            children: [
              ListTile(
                title: Text(
                  'Ejercicio: $exercises',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Cardio: $cardio',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
