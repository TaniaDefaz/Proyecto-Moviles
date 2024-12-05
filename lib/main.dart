import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto/Models/data_provider.dart';
import 'package:proyecto/Views/home_screen.dart';
import 'package:proyecto/Views/login_screen.dart';
import 'package:proyecto/Views/recommendations_screen.dart';
import 'package:proyecto/Views/register_screen.dart';
import 'package:proyecto/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataProvider(),
      child: MaterialApp(
        title: 'Aplicación móvil',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[200],
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => MainScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/Calculadora': (context) => BMICalculatorScreen(),
          '/recommendations': (context) => RecommendationsScreen(),
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  final bool isAuthenticated;

  MainScreen({this.selectedIndex = 0, this.isAuthenticated = false});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  late bool _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _isAuthenticated = widget.isAuthenticated;
  }

  final List<Widget> _screens = [
    LoginScreen(),
    BMICalculatorScreen(),
    RecommendationsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Iniciar Sesión',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Cálculo IMC',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Rutinas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          if (index == 0) {
            setState(() {
              _isAuthenticated = false;
            });
            _onItemTapped(index);
          } else if (_isAuthenticated && (index == 1 || index == 2)) {
            _onItemTapped(index);
          }
        },
      ),
    );
  }
}
