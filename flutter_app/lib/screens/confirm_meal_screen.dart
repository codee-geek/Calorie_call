import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/food.dart';
import '../models/food_log.dart';

class ConfirmMealScreen extends StatefulWidget {
  final int userId;
  final String recognizedText;

  const ConfirmMealScreen({
    super.key,
    required this.userId,
    required this.recognizedText,
  });

  @override
  State<ConfirmMealScreen> createState() => _ConfirmMealScreenState();
}

class _ConfirmMealScreenState extends State<ConfirmMealScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Food? _food;
  double _quantityGrams = 100.0;
  double _calories = 0.0;

  @override
  void initState() {
    super.initState();
    _parseFood();
  }

  Future<void> _parseFood() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.parseFood(widget.recognizedText);
      
      setState(() {
        _food = Food(
          id: response['food']['id'],
          name: response['food']['name'],
          defaultQuantityGrams: (response['food']['default_quantity_grams'] ?? 100).toDouble(),
          caloriesPer100g: (response['food']['calories_per_100g'] ?? 0).toDouble(),
        );
        _quantityGrams = (response['quantity_guess'] ?? _food!.defaultQuantityGrams).toDouble();
        _calories = _food!.getCaloriesForQuantity(_quantityGrams);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing food: $e')),
        );
      }
    }
  }

  void _updateQuantity(double newQuantity) {
    setState(() {
      _quantityGrams = newQuantity;
      _calories = _food!.getCaloriesForQuantity(newQuantity);
    });
  }

  Future<void> _confirmMeal() async {
    if (_food == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final foodLog = FoodLog(
        userId: widget.userId,
        foodId: _food!.id!,
        foodName: _food!.name,
        quantityGrams: _quantityGrams,
        calories: _calories,
        timestamp: DateTime.now(),
        source: 'speech',
      );

      await apiService.logFood(foodLog);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal logged successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving meal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Meal'),
        backgroundColor: Colors.green.shade400,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _food == null
              ? const Center(child: Text('Food not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Text(
                                'Detected Food',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _food!.name,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Quantity (grams)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _quantityGrams,
                              min: 10,
                              max: 1000,
                              divisions: 99,
                              label: '${_quantityGrams.toStringAsFixed(0)}g',
                              onChanged: _updateQuantity,
                            ),
                          ),
                          Container(
                            width: 80,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              controller: TextEditingController(
                                text: _quantityGrams.toStringAsFixed(0),
                              )..selection = TextSelection.collapsed(
                                  offset: _quantityGrams.toStringAsFixed(0).length,
                                ),
                              onSubmitted: (value) {
                                final qty = double.tryParse(value) ?? _quantityGrams;
                                _updateQuantity(qty.clamp(10.0, 1000.0));
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('g'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Calories',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_calories.toStringAsFixed(0)} kcal',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _confirmMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Confirm Meal',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

