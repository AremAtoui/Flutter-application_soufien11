import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'api_service.dart'; // Assuming you have this file
import 'models.dart'; // Assuming you have this file
import 'total_display.dart'; // Assuming you have this file
import 'task_provider.dart'; // TaskProvider
import 'weather_widget.dart'; // Assuming you have this file
import 'taskform.dart'; // Assurez-vous que le chemin est correct

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: ExpenseTrackerScreen(onThemeChanged: _onThemeChanged),
    );
  }

  void _onThemeChanged(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}

class ExpenseTrackerScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  ExpenseTrackerScreen({required this.onThemeChanged});

  @override
  _ExpenseTrackerScreenState createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  List<Expense> expenses = [];
  String _baseCurrency = 'USD';
  Map<String, double> exchangeRates = {};
  List<String> categories = ['Food', 'Transport', 'Entertainment', 'Other'];
  late SharedPreferences prefs;
  late ApiService apiService;
  bool isLoading = true;
  String? errorMessage;
  bool showChart = false;
  bool showWelcome = true;

  List<DateTime> holidays = [
    DateTime.utc(2025, 1, 1),
    DateTime.utc(2025, 5, 1),
    DateTime.utc(2025, 12, 25),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    prefs = await SharedPreferences.getInstance();
    _baseCurrency = prefs.getString('baseCurrency') ?? 'USD';
    apiService = ApiService(_baseCurrency);

    final savedExpenses = prefs.getString('expenses');
    if (savedExpenses != null) {
      expenses = (jsonDecode(savedExpenses) as List)
          .map((e) => Expense.fromJson(e))
          .toList();
    }

    await _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final rates = await apiService.fetchExchangeRates();
      setState(() {
        exchangeRates = rates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  double _convertToBaseCurrency(double amount, String currency) {
    if (exchangeRates.containsKey(currency)) {
      return amount / exchangeRates[currency]!;
    }
    return amount;
  }

  double get totalInBaseCurrency {
    return expenses.fold(0, (sum, expense) {
      return sum + _convertToBaseCurrency(expense.amount, expense.currency);
    });
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      final baseAmount = _convertToBaseCurrency(expense.amount, expense.currency);
      totals[expense.category] = (totals[expense.category] ?? 0) + baseAmount;
    }
    return totals;
  }

  void _addExpense(String title, double amount, String category) async {
    setState(() {
      expenses.add(Expense(
        title: title,
        amount: amount,
        category: category,
        currency: _baseCurrency,
        date: DateTime.now(),
      ));
      prefs.setString('expenses', jsonEncode(expenses));
      showWelcome = false;
    });
  }

  void _showHome() {
    setState(() {
      showChart = true;
      showWelcome = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Expense Tracker'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/profile.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'soufien jerou',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _showHome();
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Expense'),
              onTap: () {
                Navigator.pop(context);
                _showAddExpenseDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.money),
              title: Text('Change Currency'),
              onTap: () {
                Navigator.pop(context);
                _showChangeCurrencyDialog();
              },
            ),
            ListTile(
              leading: Icon(Icons.nights_stay),
              title: Text('Change Mode'),
              trailing: Switch(
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (value) {
                  widget.onThemeChanged(value ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.check),
              title: Text('Task'),
              onTap: () {
                Navigator.pop(context);
                _showTaskPage(context);
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text('Error: $errorMessage'))
              : showWelcome
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/fond.png',
                            width: 200,
                            height: 200,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Welcome to Expense Tracker!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : showChart
                      ? Column(
                          children: [
                            TotalDisplay(
                              baseCurrency: _baseCurrency,
                              total: totalInBaseCurrency,
                            ),
                            Expanded(
                              child: isLargeScreen
                                  ? Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: PieChart(
                                            PieChartData(
                                              sections: expensesByCategory.entries.map((entry) {
                                                return PieChartSectionData(
                                                  value: entry.value,
                                                  title: '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                                                  color: Colors.primaries[expensesByCategory.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              WeatherWidget(apiService: apiService),
                                              TableCalendar(
                                                focusedDay: DateTime.now(),
                                                firstDay: DateTime.utc(2020, 01, 01),
                                                lastDay: DateTime.utc(2025, 12, 31),
                                                calendarFormat: CalendarFormat.month,
                                                eventLoader: (day) {
                                                  return holidays.where((holiday) =>
                                                      holiday.year == day.year &&
                                                      holiday.month == day.month &&
                                                      holiday.day == day.day).toList();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        WeatherWidget(apiService: apiService),
                                        TableCalendar(
                                          focusedDay: DateTime.now(),
                                          firstDay: DateTime.utc(2020, 01, 01),
                                          lastDay: DateTime.utc(2025, 12, 31),
                                          calendarFormat: CalendarFormat.month,
                                          eventLoader: (day) {
                                            return holidays.where((holiday) =>
                                                holiday.year == day.year &&
                                                holiday.month == day.month &&
                                                holiday.day == day.day).toList();
                                          },
                                        ),
                                        Expanded(
                                          child: PieChart(
                                            PieChartData(
                                              sections: expensesByCategory.entries.map((entry) {
                                                return PieChartSectionData(
                                                  value: entry.value,
                                                  title: '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                                                  color: Colors.primaries[expensesByCategory.keys.toList().indexOf(entry.key) % Colors.primaries.length],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        )
                      : Container(),
    );
  }

  void _showTaskPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (context) => TaskProvider(),
          child: TaskPage(),
        ),
      ),
    );
  }

  void _showChangeCurrencyDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Currency'),
        content: DropdownButton<String>(
          value: _baseCurrency,
          items: exchangeRates.keys.map((key) {
            return DropdownMenuItem(
              value: key,
              child: Text(key),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _baseCurrency = value;
                prefs.setString('baseCurrency', _baseCurrency);
                apiService = ApiService(_baseCurrency);
                _fetchExchangeRates();
              });
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  void _showAddExpenseDialog() {
    String title = '';
    double amount = 0.0;
    String category = categories[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) => title = value,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              onChanged: (value) => amount = double.tryParse(value) ?? 0.0,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: category,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => category = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (title.isNotEmpty && amount > 0) {
                _addExpense(title, amount, category);
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}