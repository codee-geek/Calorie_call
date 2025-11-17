import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/food_log.dart';
import 'add_meal_screen.dart';
import 'summary_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _todayData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  Future<void> _loadTodayData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final data = await apiService.getTodayFood(widget.userId);
      setState(() {
        _todayData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailyCalories = _todayData?['daily_calories'] ?? 0.0;
    final logs = _todayData?['logs'] ?? [];
    final List<FoodLog> foodLogs = (logs as List)
        .map((log) => FoodLog.fromJson(log))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthyFy Me'),
        backgroundColor: Colors.green.shade400,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SummaryScreen(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTodayData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              'Daily Calories',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${dailyCalories.toStringAsFixed(0)} kcal',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Today\'s Meals',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (foodLogs.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No meals logged today',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: foodLogs.length,
                        itemBuilder: (context, index) {
                          final log = foodLogs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Icon(
                                  Icons.restaurant,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              title: Text(
                                log.foodName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${log.quantityGrams.toStringAsFixed(0)}g • ${DateFormat('HH:mm').format(log.timestamp)}',
                              ),
                              trailing: Text(
                                '${log.calories.toStringAsFixed(0)} kcal',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMealScreen(userId: widget.userId),
            ),
          ).then((_) => _loadTodayData());
        },
        backgroundColor: Colors.green.shade400,
        icon: const Icon(Icons.add),
        label: const Text('Add Meal'),
      ),
    );
  }
}

