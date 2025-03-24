import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    const ScreenOne(),
    const ScreenTwo(),
    const ScreenThree(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Finance App')),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.star_outline), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.request_page), label: 'Reports'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ScreenOne extends StatelessWidget {
  const ScreenOne();
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Home', style: TextStyle(fontSize: 24)));
  }
}

class ScreenTwo extends StatelessWidget {
  const ScreenTwo();
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Goals', style: TextStyle(fontSize: 24)));
  }
}

class ScreenThree extends StatelessWidget {
  const ScreenThree();
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Reports', style: TextStyle(fontSize: 24)));
  }
}
