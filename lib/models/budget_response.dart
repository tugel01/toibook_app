import 'package:toibook_app/models/expense_dto.dart';

class BudgetResponse {
  final int eventId;
  final int budgetId;
  final int budgetAmount;
  final List<ExpenseDto> expenses;

  BudgetResponse({
    required this.eventId,
    required this.budgetId,
    required this.budgetAmount,
    required this.expenses,
  });

  factory BudgetResponse.fromJson(Map<String, dynamic> json) => BudgetResponse(
        eventId: json['eventId'],
        budgetId: json['budgetId'],
        budgetAmount: json['budgetAmount'],
        expenses: (json['expenses'] as List)
            .map((e) => ExpenseDto.fromJson(e))
            .toList(),
      );
}