import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _goalNameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentAmountControler = TextEditingController();
  DateTime? _targetDate;

  @override
  void dispose() {
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _currentAmountControler.dispose();
    super.dispose();
  }

  Future<void> _addGoal() async {
    if (_goalNameController.text.isEmpty || _targetAmountController.text.isEmpty || _targetDate == null) return;

    try {
      await _firestore.collection('goals').add({
        'name': _goalNameController.text,
        'targetAmount' : double.parse(_targetAmountController.text),
        'currentAmount': _currentAmountControler.text.isNotEmpty
          ? double.parse(_currentAmountControler.text)
          : 0.0,
        'targetDate': _targetDate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _goalNameController.clear();
      _targetAmountController.clear();
      _currentAmountControler.clear();
      setState(() {
        _targetDate = null;
      });
    }
    catch (e) {
      print('Error adding goal: $e');
    }
  }

  Future<void> _updateGoal(String id, double amount) async {
    try {
      await _firestore.collection('goals').doc(id).update({
        'currentAmount' : amount,
      });
    }
    catch (e) {
      print('Error updating goal: $e');
    }
  }

  Future<void> _deleteGoal(String id) async {
    try {
      await _firestore.collection('goals').doc(id).delete();
    }
    catch (e) {
      print('Error deleting goal: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _goalNameController,
                decoration: InputDecoration(labelText: 'Goal Name'),
              ),
              TextField(
                controller: _targetAmountController,
                decoration: InputDecoration(labelText: 'Target Amount'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text(_targetDate == null
                    ? 'No date chosen'
                    : 'Target Date: ${DateFormat('yyyy-MM-dd').format(_targetDate!)}'),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Choose Date')
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addGoal();
              Navigator.pop(context);
            },
            child: Text('Add Goal'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String id, String name, double targetAmount, double currentAmount, DateTime targetDate) {
    _goalNameController.text = name;
    _targetAmountController.text = targetAmount.toString();
    _currentAmountControler.text = currentAmount.toString();
    _targetDate = targetDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Progress'),
        content: SingleChildScrollView(
          child:Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Target: \$${targetAmount.toStringAsFixed(2)}'),
              SizedBox(height: 16),
              TextField(
                controller: _currentAmountControler,
                decoration: InputDecoration(labelText: 'Current Amount'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Target Date: ${DateFormat('yyyy-MM-dd').format(targetDate)}'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateGoal(id, double.parse(_currentAmountControler.text));
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your Saving Goals',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('goals').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No goals set yet.'),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _showAddGoalDialog,
                          child: Text('Add First Goal'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    String name = data['name'] ?? 'Unnamed Goal';
                    double targetAmount = (data['targetAmount'] as num?)?.toDouble() ?? 0.0;
                    double currentAmount = (data['currentAmount'] as num?)?.toDouble() ?? 0.0;
                    DateTime targetDate = (data['targetDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(days: 30));
                    double progress = targetAmount > 0 ? currentAmount / targetAmount : 0.0;
                    progress = progress > 1.0 ? 1.0 : progress;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteGoal(doc.id),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text('Target: \$${targetAmount.toStringAsFixed(2)}'),
                            Text('Saved: \$${currentAmount.toStringAsFixed(2)}'),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0 ? Colors.green : Colors.blue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${(progress * 100).toStringAsFixed(1)}% completed',
                              textAlign: TextAlign.right,
                              style: TextStyle(color: progress >= 1.0 ? Colors.green : Colors.blue),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Target Date: ${DateFormat('yyyy-MM-dd').format(targetDate)}',
                              style: TextStyle(fontSize: 12),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () => _showEditDialog(
                                    doc.id,
                                    name,
                                    targetAmount,
                                    currentAmount,
                                    targetDate,
                                  ),
                                  child: Text('Update Progress'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: Icon(Icons.add),
      ),
    );
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
