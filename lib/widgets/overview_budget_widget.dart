import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/expense.dart';
import 'package:toibook_app/models/toi_event.dart';
import 'package:toibook_app/providers/toi_provider.dart';

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

  void _showEditBudgetDialog(BuildContext context) {
    final controller = TextEditingController(
      text: event.budget.toInt().toString(),
    );
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Edit Total Budget',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Total budget (₸)',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final val = double.tryParse(controller.text);
                  if (val != null && val > 0) {
                    Provider.of<ToiProvider>(
                      context,
                      listen: false,
                    ).updateBudget(event.id, val);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    ExpenseCategory selectedCategory = ExpenseCategory.other;
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setModalState) => Padding(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Add Expense',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        children:
                            ExpenseCategory.values.map((cat) {
                              final selected = selectedCategory == cat;
                              return ChoiceChip(
                                label: Text(cat.label),
                                selected: selected,
                                selectedColor: _categoryColors[cat]?.withValues(
                                  alpha: 0.2,
                                ),
                                onSelected:
                                    (_) => setModalState(
                                      () => selectedCategory = cat,
                                    ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (₸)',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Note (optional)',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: () {
                            final amount = double.tryParse(
                              amountController.text,
                            );
                            if (amount != null && amount > 0) {
                              Provider.of<ToiProvider>(
                                context,
                                listen: false,
                              ).addExpense(
                                event.id,
                                Expense(
                                  id:
                                      DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                  category: selectedCategory,
                                  amount: amount,
                                  note:
                                      noteController.text.trim().isEmpty
                                          ? null
                                          : noteController.text.trim(),
                                ),
                              );
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('Add Expense'),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
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
                  Text(
                    'Financial Health',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showEditBudgetDialog(context),
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
                  painter: _DonutPainter(
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
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap:
                          () => Provider.of<ToiProvider>(
                            context,
                            listen: false,
                          ).deleteExpense(event.id, exp.id),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Add expense button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => _showAddExpenseSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ),
        ],
      ),
    );
  }
}

// Donut painter
class _DonutPainter extends CustomPainter {
  final List<Expense> expenses;
  final double totalBudget;
  final Map<ExpenseCategory, Color> categoryColors;

  _DonutPainter({
    required this.expenses,
    required this.totalBudget,
    required this.categoryColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    paint.color = Colors.grey[200]!;
    canvas.drawCircle(center, radius - strokeWidth / 2, paint);

    if (totalBudget <= 0) return;

    final Map<ExpenseCategory, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    double startAngle = -pi / 2;
    for (final entry in totals.entries) {
      final sweep = (entry.value / totalBudget) * 2 * pi;
      paint.color = categoryColors[entry.key] ?? Colors.grey;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.expenses != expenses || old.totalBudget != totalBudget;
}
