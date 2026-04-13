import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/expense.dart';
import 'package:toibook_app/providers/toi_provider.dart';

class AddExpenseSheet extends StatefulWidget {
  final String eventId;

  const AddExpenseSheet({super.key, required this.eventId});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  static const _categoryColors = {
    ExpenseCategory.decor: Color(0xFF1B4332),
    ExpenseCategory.venue: Color(0xFF8B6914),
    ExpenseCategory.music: Color(0xFFD4A017),
    ExpenseCategory.food: Color(0xFF8BC34A),
    ExpenseCategory.other: Color(0xFFB0BEC5),
  };

  ExpenseCategory _selectedCategory = ExpenseCategory.other;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _amountError;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Enter a valid number');
      return;
    }
    Provider.of<ToiProvider>(context, listen: false).addExpense(
      widget.eventId,
      Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory,
        amount: amount,
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
    Navigator.pop(context);
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
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Category chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpenseCategory.values.map((cat) {
              final selected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat.label),
                selected: selected,
                selectedColor: _categoryColors[cat]?.withValues(alpha: 0.3),
                onSelected: (_) =>
                    setState(() => _selectedCategory = cat),
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
              onPressed: _submit,
              child: const Text('Add Expense'),
            ),
          ),
        ],
      ),
    );
  }
}