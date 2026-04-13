import 'dart:math';
import 'package:flutter/material.dart';
import 'package:toibook_app/models/expense.dart';

class DonutPainter extends CustomPainter {
  final List<Expense> expenses;
  final double totalBudget;
  final Map<ExpenseCategory, Color> categoryColors;

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

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt;

    // Background ring
    paint.color = Colors.grey[200]!;
    canvas.drawCircle(center, radius - strokeWidth / 2, paint);

    if (totalBudget <= 0 || expenses.isEmpty) return;

    // Group by category
    final Map<ExpenseCategory, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }


    const gapAngle = 0.01;
    double startAngle = -pi / 2;

    for (final entry in totals.entries) {
      final fraction = (entry.value / totalBudget).clamp(0.0, 1.0);
      final sweep = fraction * 2 * pi;


      paint.color = categoryColors[entry.key] ?? Colors.grey;
      canvas.drawArc(rect, startAngle, sweep - gapAngle, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) =>
      old.expenses != expenses || old.totalBudget != totalBudget;
}
