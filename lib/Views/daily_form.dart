import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/Servicies/firestore_services.dart';
import 'package:proyecto/Views/report.dart';

class DailyForm extends StatefulWidget {
  @override
  _DailyFormState createState() => _DailyFormState();
}

class _DailyFormState extends State<DailyForm> {
  final TextEditingController weightController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool exercisedToday = false;
  String exerciseType = 'Cardio';
  bool followedDiet = false;
  bool ateAsPlanned = false;
  bool stayedWithinCalorieGoal = false;
  bool completedPlannedExercise = false;
  bool metDietPlan = false;

  final FirestoreServices _firestoreServices = FirestoreServices();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  double? userHeight; // Variable para la altura del usuario

  @override
  void initState() {
    super.initState();
    _loadUserHeight();
  }

  @override
  void dispose() {
    weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserHeight() async {
    final height = await _firestoreServices.getUserHeight();
    setState(() {
      userHeight = height;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _saveDailyData() async {
    final user = _auth.currentUser;
    if (user != null && userHeight != null) {
      // Verificar si userHeight es nulo
      final dailyData = {
        'weight': double.tryParse(weightController.text),
        'height': userHeight, // Usar la altura recuperada
        'exercisedToday': exercisedToday,
        'exerciseType': exerciseType,
        'followedDiet': followedDiet,
        'ateAsPlanned': ateAsPlanned,
        'stayedWithinCalorieGoal': stayedWithinCalorieGoal,
        'completedPlannedExercise': completedPlannedExercise,
        'metDietPlan': metDietPlan,
        'date': Timestamp.fromDate(selectedDate),
        'userId': user.uid,
      };

      await _firestoreServices.addDailyData(dailyData);

      // Limpiar los campos después de guardar
      weightController.clear();
      setState(() {
        exercisedToday = false;
        followedDiet = false;
        ateAsPlanned = false;
        stayedWithinCalorieGoal = false;
        completedPlannedExercise = false;
        metDietPlan = false;
        exerciseType = 'Cardio';
        selectedDate = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro Diario'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () => _selectDate(context),
                child: Text(
                    'Fecha: ${selectedDate.toLocal().toString().split(' ')[0]}'),
              ),
              if (userHeight != null) ...[
                Text('Altura (m): ${userHeight!.toStringAsFixed(2)}'),
              ] else ...[
                CircularProgressIndicator(), // Mostrar indicador mientras se carga
              ],
              TextField(
                controller: weightController,
                decoration: InputDecoration(labelText: 'Peso Actual (kg)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SwitchListTile(
                title: Text('¿Realizaste ejercicio hoy?'),
                value: exercisedToday,
                onChanged: (bool value) {
                  setState(() {
                    exercisedToday = value;
                  });
                },
              ),
              if (exercisedToday) ...[
                DropdownButton<String>(
                  value: exerciseType,
                  items: ['Cardio', 'Fuerza', 'Flexibilidad', 'Otro']
                      .map((String type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      exerciseType = newValue!;
                    });
                  },
                ),
              ],
              SwitchListTile(
                title: Text('¿Seguiste tu plan de dieta hoy?'),
                value: followedDiet,
                onChanged: (bool value) {
                  setState(() {
                    followedDiet = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('¿Comiste según lo planeado?'),
                value: ateAsPlanned,
                onChanged: (bool value) {
                  setState(() {
                    ateAsPlanned = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('¿Te mantuviste dentro de tu meta calórica?'),
                value: stayedWithinCalorieGoal,
                onChanged: (bool value) {
                  setState(() {
                    stayedWithinCalorieGoal = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('¿Completaste el ejercicio planeado?'),
                value: completedPlannedExercise,
                onChanged: (bool value) {
                  setState(() {
                    completedPlannedExercise = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('¿Cumpliste con el plan de dieta?'),
                value: metDietPlan,
                onChanged: (bool value) {
                  setState(() {
                    metDietPlan = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveDailyData,
                child: Text('Guardar Registro Diario'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportScreen()),
                  );
                },
                child: Text('Ir a Reportes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
