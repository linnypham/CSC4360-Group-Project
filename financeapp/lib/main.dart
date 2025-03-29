import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  static List<Widget> _widgetOptions = <Widget>[];

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      TransactionScreen(),
      GoalsScreen(),
      ReportsScreen(),
    ];
  }

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Transactions'),
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

class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isIncome;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'],
    );
  }
}

class Category {
  final String name;
  final double limit;
  double spent;

  Category({
    required this.name,
    required this.limit,
    this.spent = 0.00,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'limit': limit,
      'spent': spent,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      name: map['name'],
      limit: map['limit'],
      spent: map['spent'],
    );
  }
}

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Transaction> transactions = [];
  List<Category> categories = [
    Category(name: 'Food', limit: 500),
    Category(name: 'Transport', limit: 300),
    Category(name: 'Entertainment', limit: 200),
    Category(name: 'Rent', limit: 1000),
    Category(name: 'Utilities', limit: 300),
  ];
  String filterCategory = 'All';
  bool showIncomes = true;
  bool showExpenses = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final List<dynamic> transactionsList = json.decode(transactionsJson);
      setState(() {
        transactions = transactionsList.map((t) => Transaction.fromMap(t)).toList();
      });
    }

    final categoriesJson = prefs.getString('categories');
    if (categoriesJson != null) {
      final List<dynamic> categoriesList = json.decode(categoriesJson);
      setState(() {
        categories = categoriesList.map((c) => Category.fromMap(c)).toList();
      });
    }
    
    _updateCategorySpending();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final transactionsJson = json.encode(transactions.map((t) => t.toMap()).toList());
    await prefs.setString('transactions', transactionsJson);
    
    final categoriesJson = json.encode(categories.map((c) => c.toMap()).toList());
    await prefs.setString('categories', categoriesJson);
  }

  void _updateCategorySpending() {
    for (var category in categories) {
      category.spent = 0.0;
    }
    
    for (var transaction in transactions) {
      if (!transaction.isIncome) {
        final category = categories.firstWhere(
          (c) => c.name == transaction.category,
          orElse: () => Category(name: 'Other', limit: 0),
        );
        if (category.name != 'Other') {
          category.spent += transaction.amount;
        }
      }
    }
  }

  void _addTransaction(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
      if (!transaction.isIncome) {
        _updateCategorySpending();
      }
      _saveData();
    });
  }

  void _editTransaction(String id, Transaction updatedTransaction) {
    setState(() {
      final index = transactions.indexWhere((t) => t.id == id);
      if (index != -1) {
        transactions[index] = updatedTransaction;
        _updateCategorySpending();
        _saveData();
      }
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      transactions.removeWhere((t) => t.id == id);
      _updateCategorySpending();
      _saveData();
    });
  }

  void _addCategory(Category category) {
    setState(() {
      categories.add(category);
      _saveData();
    });
  }

  List<Transaction> getFilteredTransactions() {
    return transactions.where((t) {
      final categoryMatch = filterCategory == 'All' || t.category == filterCategory;
      final typeMatch = (t.isIncome && showIncomes) || (!t.isIncome && showExpenses);
      return categoryMatch && typeMatch;
    }).toList();
  }

  void _showAddTransactionDialog() {
    String title = '';
    String amount = '';
    String selectedCategory = categories.isNotEmpty ? categories.first.name : '';
    bool isIncome = false;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Title'),
                      onChanged: (value) => title = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => amount = value,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: [
                        ...categories.map((category) {
                          return DropdownMenuItem(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList(),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    Row(
                      children: [
                        Text('Income'),
                        Switch(
                          value: isIncome,
                          onChanged: (value) {
                            setState(() {
                              isIncome = value;
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text('Select Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
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
                    if (title.isNotEmpty && amount.isNotEmpty) {
                      final newTransaction = Transaction(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        amount: double.parse(amount),
                        category: selectedCategory,
                        date: selectedDate,
                        isIncome: isIncome,
                      );
                      _addTransaction(newTransaction);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTransactionDialog(Transaction transaction) {
    String title = transaction.title;
    String amount = transaction.amount.toString();
    String selectedCategory = transaction.category;
    bool isIncome = transaction.isIncome;
    DateTime selectedDate = transaction.date;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Transaction'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Title'),
                      controller: TextEditingController(text: title),
                      onChanged: (value) => title = value,
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Amount'),
                      controller: TextEditingController(text: amount),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) => amount = value,
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: [
                        ...categories.map((category) {
                          return DropdownMenuItem(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList(),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                    Row(
                      children: [
                        Text('Income'),
                        Switch(
                          value: isIncome,
                          onChanged: (value) {
                            setState(() {
                              isIncome = value;
                            });
                          },
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text('Select Date: ${selectedDate.toLocal().toString().split(' ')[0]}'),
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
                    if (title.isNotEmpty && amount.isNotEmpty) {
                      final updatedTransaction = Transaction(
                        id: transaction.id,
                        title: title,
                        amount: double.parse(amount),
                        category: selectedCategory,
                        date: selectedDate,
                        isIncome: isIncome,
                      );
                      _editTransaction(transaction.id, updatedTransaction);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    String name = '';
    String limit = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Category Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Spending Limit'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) => limit = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && limit.isNotEmpty) {
                  _addCategory(Category(
                    name: name,
                    limit: double.parse(limit),
                  ));
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = getFilteredTransactions();
    final totalIncome = transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpenses;

    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addCategory',
            mini: true,
            onPressed: _showAddCategoryDialog,
            child: Icon(Icons.category),
            tooltip: 'Add Category',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'addTransaction',
            onPressed: _showAddTransactionDialog,
            child: Icon(Icons.add),
            tooltip: 'Add Transaction',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Balance: \$${balance.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('Income',
                                style: TextStyle(color: Colors.green)),
                            Text('\$${totalIncome.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.green)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Expenses',
                                style: TextStyle(color: Colors.red)),
                            Text('\$${totalExpenses.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: filterCategory,
                      items: [
                        DropdownMenuItem(value: 'All', child: Text('All Categories')),
                        ...categories.map((category) {
                          return DropdownMenuItem(
                            value: category.name,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filterCategory = value!;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(showIncomes ? Icons.arrow_upward : Icons.arrow_upward_outlined, color: Colors.green),
                    onPressed: () {
                      setState(() {
                        showIncomes = !showIncomes;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(showExpenses ? Icons.arrow_downward : Icons.arrow_downward_outlined, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        showExpenses = !showExpenses;
                      });
                    },
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return Dismissible(
                  key: Key(transaction.id),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) => _deleteTransaction(transaction.id),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading: Icon(
                        transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                        color: transaction.isIncome ? Colors.green : Colors.red,
                      ),
                      title: Text(transaction.title),
                      subtitle: Text(
                          '${transaction.category} • ${transaction.date.toLocal().toString().split(' ')[0]}'),
                      trailing: Text(
                        '\$${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: transaction.isIncome ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _showEditTransactionDialog(transaction),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('Budget Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ...categories.map((category) {
              final progress = category.limit > 0 ? category.spent / category.limit : 0;
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(category.name, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '\$${category.spent.toStringAsFixed(2)} / \$${category.limit.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (progress > 1 ? 1 : progress).toDouble(),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress > 1 ? Colors.red : Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% of limit',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen();
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Goals', style: TextStyle(fontSize: 24)));
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen();
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Reports', style: TextStyle(fontSize: 24)));
  }
}
