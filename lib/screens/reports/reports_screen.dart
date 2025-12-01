import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider.transactions;
    
    // Calculate totals by category
    final Map<String, double> categoryTotals = {};
    double totalExpense = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
        totalExpense += tx.amount;
      }
    }

    // Colors for chart segments (Lime, Black, Grey, etc.)
    final List<Color> chartColors = [
      AppColors.primary, // Lime
      AppColors.secondary, // Black
      AppColors.textSecondary, // Grey
      const Color(0xFFE0E0E0), // Light Grey
      const Color(0xFF4CD964), // Green
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Total Expense',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalExpense.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (totalExpense == 0)
                    const SizedBox(
                      height: 200,
                      child: Center(child: Text('No expenses to show')),
                    )
                  else
                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: categoryTotals.entries.toList().asMap().entries.map((entry) {
                            final index = entry.key;
                            final value = entry.value;
                            final percentage = (value.value / totalExpense) * 100;
                            final color = chartColors[index % chartColors.length];
                            
                            return PieChartSectionData(
                              color: color,
                              value: value.value,
                              title: '${percentage.toStringAsFixed(0)}%',
                              radius: 100,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Legend
            ...categoryTotals.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              final color = chartColors[index % chartColors.length];
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      value.key,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Text(
                      '\$${value.value.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
