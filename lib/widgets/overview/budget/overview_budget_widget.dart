import 'package:flutter/material.dart';
import 'package:toibook_app/models/expense.dart';
import 'package:toibook_app/models/toi_event.dart';
import 'package:toibook_app/widgets/overview/budget/add_expense_sheet.dart';
import 'package:toibook_app/widgets/overview/budget/donut_painter.dart';
import 'package:toibook_app/widgets/overview/budget/edit_budget_sheet.dart';

class OverviewBudgetWidget extends StatelessWidget {
  final ToiEvent event;

  const OverviewBudgetWidget({super.key, required this.event});

  static const _categoryColors = {
    ExpenseCategory.decor: Color(0xFF1B4332),
    ExpenseCategory.venue: Color(0xFF8B6914),
    ExpenseCategory.music: Color(0xFFD4A017),
    ExpenseCategory.food: Color(0xFF8BC34A),
    ExpenseCategory.other: Color(0xFFB0BEC5),
  };

  double _spentFor(ExpenseCategory cat) => event.expenses
      .where((e) => e.category == cat)
      .fold(0.0, (sum, e) => sum + e.amount);

  String _formatAmount(double amount) {
    if (amount >= 1000000) return '₸${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '₸${(amount / 1000).toStringAsFixed(0)}K';
    return '₸${amount.toInt()}';
  }

  void _showEditBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => EditBudgetSheet(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalBudget = event.budget;
    final totalSpent = event.expenses.fold(0.0, (sum, e) => sum + e.amount);
    final remaining = totalBudget - totalSpent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showEditBudgetSheet(context),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Donut chart
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: DonutPainter(
                    expenses: event.expenses,
                    totalBudget: totalBudget,
                    categoryColors: _categoryColors,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TOTAL SPENT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      _formatAmount(totalSpent),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'of ${_formatAmount(totalBudget)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Category breakdown
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                ExpenseCategory.values.map((cat) {
                  final spent = _spentFor(cat);
                  if (spent == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _categoryColors[cat],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat.label.toUpperCase(),
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              _formatAmount(spent),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),

          // Remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                _formatAmount(remaining),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      remaining < 0
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

                    // Add expense button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed:
                  () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (ctx) => AddExpenseSheet(eventId: event.id),
                  ),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ),

          // Expense list
          if (event.expenses.isNotEmpty) ...[
            const Divider(height: 32),
            ...event.expenses.map(
              (exp) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _categoryColors[exp.category]?.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _categoryColors[exp.category],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  exp.category.label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: exp.note != null ? Text(exp.note!) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatAmount(exp.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],


        ],
      ),
    );
  }
}
