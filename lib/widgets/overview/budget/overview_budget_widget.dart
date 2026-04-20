import 'package:flutter/material.dart';
import 'package:toibook_app/models/budget/budget_response.dart';
import 'package:toibook_app/models/budget/expense_dto.dart';
import 'package:toibook_app/models/budget/expense_type.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/widgets/overview/budget/add_expense_sheet.dart';
import 'package:toibook_app/widgets/overview/budget/donut_painter.dart';
import 'package:toibook_app/widgets/overview/budget/edit_expense_sheet.dart';
import 'package:provider/provider.dart';

class OverviewBudgetWidget extends StatelessWidget {
  final int eventId;
  final BudgetResponse budgetResponse;

  const OverviewBudgetWidget({
    super.key,
    required this.eventId,
    required this.budgetResponse,
  });

  static const _categoryColors = {
    ExpenseType.decor: Color.fromARGB(255, 70, 128, 157),
    ExpenseType.venue: Color.fromARGB(255, 232, 109, 52),
    ExpenseType.music: Color.fromARGB(255, 219, 172, 54),
    ExpenseType.food: Color(0xFF8BC34A),
    ExpenseType.other: Color(0xFFB0BEC5),
  };

  int _spentFor(ExpenseType cat) => budgetResponse.expenses
      .where((e) => e.expenseType == cat)
      .fold(0, (sum, e) => sum + e.amount);

  String _formatAmount(int amount) {
    if (amount >= 1000000) return '₸${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '₸${(amount / 1000).toStringAsFixed(0)}K';
    return '₸${amount.toInt()}';
  }

  void _showEditBudgetSheet(BuildContext context) {
    print("WAIT");
    /*
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (ctx) =>
              EditBudgetSheet(eventId: eventId, budgetResponse: budgetResponse),
    );*/
  }

  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddExpenseSheet(eventId: eventId),
    );
  }

  void _showEditExpenseSheet(BuildContext context, ExpenseDto expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EditExpenseSheet(eventId: eventId, expense: expense),
    );
  }

  void _showDeleteExpenseDialog(BuildContext context, ExpenseDto exp) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Expense'),
            content: const Text(
              'Are you sure you want to delete this expense?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed:
                    () => {
                      context.read<ToiProvider>().deleteExpense(eventId, exp),
                      Navigator.of(context).pop(),
                    },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = budgetResponse.expenses;
    final totalSpent = expenses.fold(0, (sum, e) => sum + e.amount);

    final totalBudget = budgetResponse.budgetAmount;
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
              Text(
                'Budget Overview',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                    expenses:
                        expenses
                            .map(
                              (e) => DonutExpense(
                                category: e.expenseType,
                                amount: e.amount.toDouble(),
                              ),
                            )
                            .toList(),

                    totalBudget: totalBudget,
                    categoryColors: _categoryColors,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
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
                ExpenseType.values.map((cat) {
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
              onPressed: () => _showAddExpenseSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
          ),
          const SizedBox(height: 12),

          // Expense list
          if (expenses.isNotEmpty) ...[
            const Divider(height: 32),
            ...expenses.map(
              (exp) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  _showEditExpenseSheet(context, exp);
                },
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _categoryColors[exp.expenseType]?.withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _categoryColors[exp.expenseType],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  exp.expenseType.label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle:
                    exp.description != null ? Text(exp.description!) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatAmount(exp.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Color.fromARGB(255, 198, 92, 85),
                      ),
                      onPressed: () {
                        _showDeleteExpenseDialog(context, exp);
                      },
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
