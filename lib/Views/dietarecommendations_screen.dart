import 'package:flutter/material.dart';
import 'package:proyecto/Models/bmi_model.dart';
import 'package:proyecto/Servicies/firestore_services.dart';

class DietRecommendationsScreen extends StatefulWidget {
  const DietRecommendationsScreen({Key? key}) : super(key: key);

  @override
  _DietRecommendationsScreenState createState() =>
      _DietRecommendationsScreenState();
}

class _DietRecommendationsScreenState extends State<DietRecommendationsScreen> {
  final FirestoreServices firestoreServices = FirestoreServices();
  BMIData? _bmiData;
  Map<String, dynamic>? _diet;

  @override
  void initState() {
    super.initState();
    _fetchBMIData();
    _saveDietForTesting(); // Guardar dietas para pruebas
  }

  Future<void> _saveDietForTesting() async {
    await firestoreServices.saveDiets();
  }

  Future<void> _fetchBMIData() async {
    final data = await firestoreServices.getLastBMIData();
    setState(() {
      _bmiData = data;
    });
    if (data != null) {
      _fetchDietForCategory(data.bmiCategory!);
    }
  }

  Future<void> _fetchDietForCategory(String category) async {
    try {
      final diet = await firestoreServices.getDietPlanForCategory(category);
      setState(() {
        _diet = diet;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la dieta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recomendaciones Dietéticas'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orangeAccent.shade100,
              Colors.deepOrange.shade300,
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
                          Icons.fastfood,
                          color: Colors.deepOrange,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Recomendación Nutricional',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Plan semanal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Dieta del Día',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                _diet != null
                    ? DietRoutine(diet: _diet!)
                    : Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DietRoutine extends StatelessWidget {
  final Map<String, dynamic> diet;

  const DietRoutine({Key? key, required this.diet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lista de días en orden correcto
    final List<String> daysOfWeek = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    // Ordenar las entradas del mapa en base a la lista de días
    final sortedEntries = daysOfWeek
        .where((day) => diet.containsKey(day))
        .map((day) => MapEntry(day, diet[day]!))
        .toList();

    return Column(
      children: sortedEntries.map((entry) {
        final day = entry.key;
        final meals = entry.value as Map<String, dynamic>?;

        if (meals == null) {
          return SizedBox(); // Retornar un espacio vacío si meals es null
        }

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Theme(
            data: ThemeData().copyWith(
              dividerColor: Colors.transparent,
              unselectedWidgetColor: Colors.deepOrange,
              colorScheme:
                  ColorScheme.fromSwatch().copyWith(primary: Colors.deepOrange),
            ),
            child: ExpansionTile(
              leading: Icon(Icons.fastfood, color: Colors.deepOrange),
              title: Text(
                day,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              children: meals.entries.map<Widget>((meal) {
                final mealType = meal.key;
                final mealDescription = meal.value as String?;

                return ListTile(
                  title: Text(
                    mealType,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    mealDescription ?? 'Descripción no disponible',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }).toList(),
    );
  }
}
