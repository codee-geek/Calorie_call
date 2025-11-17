import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class SummaryScreen extends StatefulWidget {
  final int userId;

  const SummaryScreen({super.key, required this.userId});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, dynamic>? _summaryData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final todayData = await apiService.getTodayFood(widget.userId);
      
      // Calculate weekly data (simplified - in real app, fetch from backend)
      setState(() {
        _summaryData = {
          'daily_calories': todayData['daily_calories'] ?? 0.0,
          'weekly_calories': (todayData['daily_calories'] ?? 0.0) * 7, // Placeholder
          'top_foods': todayData['logs'] ?? [],
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading summary: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: Colors.green.shade400,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.green.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Daily Calories',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(_summaryData?['daily_calories'] ?? 0.0).toStringAsFixed(0)} kcal',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Weekly Calories',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${(_summaryData?['weekly_calories'] ?? 0.0).toStringAsFixed(0)} kcal',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Top Foods',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_summaryData?['top_foods'] == null ||
                      (_summaryData!['top_foods'] as List).isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No food data available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ...((_summaryData!['top_foods'] as List).take(5).map((food) {
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
                            food['food_name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            '${(food['calories'] ?? 0).toStringAsFixed(0)} kcal',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList()),
                ],
              ),
            ),
    );
  }
}

