import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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

  static final List<Widget> _widgetOptions = <Widget>[
    TransactionsScreen(),
    GoalsScreen(),
    ReportsScreen(),
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

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController amountController = TextEditingController();
  String selectedCategory = 'Food';

  void saveTransaction() async {
    if (amountController.text.isEmpty) return;
    
    try {
      await _firestore.collection('transactions').add({
        'amount': double.parse(amountController.text),
        'category': selectedCategory,
        'timestamp': FieldValue.serverTimestamp(),
      });
      amountController.clear();
    } catch (e) {
      print('Error saving transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
              ),
              DropdownButton<String>(
                value: selectedCategory,
                items: ['Food', 'Rent', 'Entertainment', 'Others']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: saveTransaction,
                child: Text('Add'),
              )
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: _firestore.collection('transactions').orderBy('timestamp', descending: true).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No transactions found.'));
              }
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
                  if (data == null) return SizedBox.shrink();
                  return ListTile(
                    title: Text('Amount: \$${data['amount']}'),
                    subtitle: Text('Category: ${data['category']}'),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GoalsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Goals !', style: TextStyle(fontSize: 24)));
  }
}

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Reports', style: TextStyle(fontSize: 24)));
  }
}
