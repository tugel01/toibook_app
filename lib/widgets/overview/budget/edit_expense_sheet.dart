import 'package:flutter/material.dart';
import 'package:toibook_app/models/budget/expense_dto.dart';
import 'package:toibook_app/models/budget/expense_type.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:provider/provider.dart';

class EditExpenseSheet extends StatefulWidget {
  final int eventId;
  final ExpenseDto expense;

  const EditExpenseSheet({
    super.key,
    required this.eventId,
    required this.expense,
  });

  @override
  State<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends State<EditExpenseSheet> {
  static const _categoryColors = {
    ExpenseType.decor: Color(0xFF1B4332),
    ExpenseType.venue: Color(0xFF8B6914),
    ExpenseType.music: Color(0xFFD4A017),
    ExpenseType.food: Color(0xFF8BC34A),
    ExpenseType.other: Color(0xFFB0BEC5),
  };
  late ExpenseType _selectedCategory;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.expense.expenseType;
    _amountController = TextEditingController(
      text: widget.expense.amount.toInt().toString(),
    );
    _noteController = TextEditingController(
      text: widget.expense.description ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Enter a valid number');
      return;
    }

    try {
      await context.read<ToiProvider>().editExpense(
        widget.eventId,
        ExpenseDto(
          id: widget.expense.id,
          expenseType: _selectedCategory,
          amount: amount.toInt(),
          description:
              _noteController.text.trim().isEmpty
                  ? null
                  : _noteController.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _amountError = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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

          // Header with category label
          Row(
            children: [
              Expanded(
                child: Text(
                  'Edit ${widget.expense.expenseType.label} Expense',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                ExpenseType.values.map((cat) {
                  final selected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat.label),
                    selected: selected,
                    selectedColor: _categoryColors[cat]?.withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: (_) {
              if (_amountError != null) {
                setState(() => _amountError = null);
              }
            },
            decoration: InputDecoration(
              labelText: 'Amount (₸)',
              prefixIcon: const Icon(Icons.payments_outlined),
              errorText: _amountError,
            ),
          ),
          const SizedBox(height: 12),

          // Note
          TextField(
            controller: _noteController,
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
              onPressed: _submit,
              child: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }
}
