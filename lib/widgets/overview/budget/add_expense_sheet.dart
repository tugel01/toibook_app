import 'package:flutter/material.dart';
import 'package:toibook_app/models/budget/expense_dto.dart';
import 'package:toibook_app/models/budget/expense_type.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:provider/provider.dart';

class AddExpenseSheet extends StatefulWidget {
  final int eventId;

  const AddExpenseSheet({super.key, required this.eventId});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  static const _categoryColors = {
    ExpenseType.decor: Color(0xFF1B4332),
    ExpenseType.venue: Color(0xFF8B6914),
    ExpenseType.music: Color(0xFFD4A017),
    ExpenseType.food: Color(0xFF8BC34A),
    ExpenseType.other: Color(0xFFB0BEC5),
  };

  ExpenseType _selectedCategory = ExpenseType.other;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _amountError;
  bool _isLoading = false;

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

    setState(() => _isLoading = true);

    try {
      await context.read<ToiProvider>().addExpenseAndRefresh(
        widget.eventId,
        ExpenseDto(
          id: null,
          expenseType: _selectedCategory,
          amount: amount.toInt(),
          description:
              _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          Text(
            'Add Expense',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              onPressed: _isLoading ? null : _submit,
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Add Expense'),
            ),
          ),
        ],
      ),
    );
  }
}
