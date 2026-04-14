/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/expense_dto.dart';
import 'package:toibook_app/models/expense_type.dart';
import 'package:toibook_app/models/toi_event.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/widgets/overview/budget/edit_expense_sheet.dart';

class EditBudgetSheet extends StatefulWidget {
  final ToiEvent event;

  const EditBudgetSheet({super.key, required this.event});

  @override
  State<EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<EditBudgetSheet> {
  late final TextEditingController _budgetController;
  late List<ExpenseDto> _expenses;
  String? _budgetError;

  static const _categoryColors = {
    ExpenseType.decor: Color(0xFF1B4332),
    ExpenseType.venue: Color(0xFF8B6914),
    ExpenseType.music: Color(0xFFD4A017),
    ExpenseType.food: Color(0xFF8BC34A),
    ExpenseType.other: Color(0xFFB0BEC5),
  };

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: widget.event.budget.toInt().toString(),
    );
    // copy expenses so we can stage changes
    _expenses = List.from(widget.event.expenses);
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) return '₸${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '₸${(amount / 1000).toStringAsFixed(0)}K';
    return '₸${amount.toInt()}';
  }

  Future<void> _openEditExpense(ExpenseDto expense) async {
    final updated = await showModalBottomSheet<ExpenseDto>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => EditExpenseSheet(expense: expense),
    );

    if (updated != null) {
      setState(() {
        final index = _expenses.indexWhere((e) => e.id == updated.id);
        if (index != -1) _expenses[index] = updated;
      });
    }
  }

  void _deleteExpense(int expenseId) {
    setState(() => _expenses.removeWhere((e) => e.id == expenseId));
  }

  void _save() {
    final budget = double.tryParse(_budgetController.text);
    if (budget == null || budget <= 0) {
      setState(() => _budgetError = 'Enter a valid number');
      return;
    }

    Provider.of<ToiProvider>(
      context,
      listen: false,
    ).updateBudgetAndExpenses(widget.event.id, budget, _expenses);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final int totalSpent = _expenses.fold(0, (sum, e) => sum + e.amount);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder:
          (ctx, scrollController) => Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: ListView(
              controller: scrollController,
              children: [
                // Handle
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
                  'Edit Budget',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) {
                    if (_budgetError != null) {
                      setState(() => _budgetError = null);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Total Budget (₸)',
                    prefixIcon: const Icon(Icons.payments_outlined),
                    errorText: _budgetError,
                  ),
                ),
                const SizedBox(height: 24),

                if (_expenses.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expenses',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Total: ${_formatAmount(totalSpent)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._expenses.map(
                    (exp) => Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _categoryColors[exp.expenseType]?.withOpacity(
                                0.15,
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
                          subtitle: exp.description != null ? Text(exp.description!) : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatAmount(exp.amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                onPressed: () => _openEditExpense(exp),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () => _deleteExpense(exp.id),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }
}
*/