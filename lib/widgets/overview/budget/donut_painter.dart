import 'dart:math';
import 'package:flutter/material.dart';
import 'package:toibook_app/models/expense_type.dart';

class DonutExpense {
  final ExpenseType category;
  final double amount;

  DonutExpense({required this.category, required this.amount});
}

class DonutPainter extends CustomPainter {
  final List<DonutExpense> expenses;
  final int totalBudget;
  final Map<ExpenseType, Color> categoryColors;

  DonutPainter({
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

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Background ring
    paint.color = Colors.grey[200]!;
    canvas.drawCircle(center, radius - strokeWidth / 2, paint);

    if (totalBudget <= 0 || expenses.isEmpty) return;

    // Group by category
    final Map<ExpenseType, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    const gapAngle = 0.015;
    double startAngle = -pi / 2;

    for (final entry in totals.entries) {
      final fraction = (entry.value / totalBudget).clamp(0.0, 1.0);
      final sweep = fraction * 2 * pi;

      if (sweep < 0.01) continue;

      paint.color = categoryColors[entry.key] ?? Colors.grey;
      canvas.drawArc(rect, startAngle, sweep - gapAngle, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) =>
      old.expenses != expenses || old.totalBudget != totalBudget;
}