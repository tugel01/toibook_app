import 'package:flutter/material.dart';
import 'package:toibook_app/models/expense_dto.dart';

class EditExpenseSheet extends StatefulWidget {
  final ExpenseDto expense;

  const EditExpenseSheet({super.key, required this.expense});

  @override
  State<EditExpenseSheet> createState() => _EditExpenseSheetState();
}

class _EditExpenseSheetState extends State<EditExpenseSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  String? _amountError;

  @override
  void initState() {
    super.initState();
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

  void _submit() {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Enter a valid number');
      return;
    }

    // Return updated expense to edit budget sheet
    Navigator.pop(
      context,
      ExpenseDto(
        id: widget.expense.id,
        expenseType: widget.expense.expenseType,
        amount: amount,
        description: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
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
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

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