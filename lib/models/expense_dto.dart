import 'package:toibook_app/models/expense_type.dart';

class ExpenseDto {
  final int? id;
  final ExpenseType expenseType;
  final int amount;
  final String? description;

  ExpenseDto({
    required this.id,
    required this.expenseType,
    required this.amount,
    this.description,
  });

  factory ExpenseDto.fromJson(Map<String, dynamic> json) => ExpenseDto(
    id: json['id'],
    expenseType: ExpenseType.fromString(json['expenseType']),
    amount: json['amount'],
    description: json['description'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'expenseType': expenseType.label.toUpperCase(),
    'amount': amount,
    'description': description,
  };
}
