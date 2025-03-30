import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fl_chart/fl_chart.dart';

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
  String selectedCategory = 'Deposit';

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

  void editTransaction(String id, double amount, String category) {
    amountController.text = amount.toString();
    selectedCategory = category;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: selectedCategory,
              items: ['Deposit','Food', 'Rent', 'Entertainment', 'Others']
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('transactions').doc(id).update({
                'amount': double.parse(amountController.text),
                'category': selectedCategory,
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void deleteTransaction(String id) async {
    await _firestore.collection('transactions').doc(id).delete();
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
                items: ['Deposit','Food', 'Rent', 'Entertainment', 'Others']
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
                  Map? data = doc.data() as Map?;
                  if (data == null) return SizedBox.shrink();
                  return ListTile(
                    title: Text(
                      'Amount: \$${data['amount']}',
                      style: TextStyle(
                        color: data['category'] == 'Deposit' ? Colors.green : Colors.black,
                      ),
                    ),
                    subtitle: Text('Category: ${data['category']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => editTransaction(doc.id, data['amount'], data['category']),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => deleteTransaction(doc.id),
                        ),
                      ],
                    ),
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
    return Center(child: Text('Goals - Coming Soon!', style: TextStyle(fontSize: 24)));
  }
}

class ReportsScreen extends StatelessWidget {
  Future<Map<String, double>> fetchData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    double income = 0;
    double expenses = 0;

    final querySnapshot = await firestore.collection('transactions').get();
    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      double amount = (data['amount'] as num).toDouble();
      if (data['category'] == 'Deposit') {
        income += amount;
      } else {
        expenses += amount;
      }
    }

    return {'Income': income, 'Expenses': expenses};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        double income = snapshot.data!['Income']!;
        double expenses = snapshot.data!['Expenses']!;
        double total = income - expenses;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Income vs. Expenses',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [BarChartRodData(toY: income, color: Colors.green)],
                        showingTooltipIndicators: [0],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [BarChartRodData(toY: expenses, color: Colors.red)],
                        showingTooltipIndicators: [0],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return Text('Income');
                              case 1:
                                return Text('Expenses');
                              default:
                                return Text('');
                            }
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              Text(
                'Net Amount: ${total}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: total >= 0 ? Colors.green : Colors.red, // Green for positive, red for negative
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
