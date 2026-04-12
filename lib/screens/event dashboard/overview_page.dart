import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/expense.dart';
import 'package:toibook_app/models/toi_event.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/widgets/overview_budget_widget.dart';
import 'package:toibook_app/widgets/overview_countdown_card.dart';
import 'package:toibook_app/widgets/overview_info_card.dart';

class OverviewPage extends StatelessWidget {
  final ToiEvent event;
  const OverviewPage({super.key, required this.event});

  DateTime get _firstDate {
    switch (event.dateMode) {
      case DateSelectionMode.single:
        return event.singleDate!;
      case DateSelectionMode.range:
        return event.rangeStart!;
      case DateSelectionMode.multiple:
        return event.multipleDates!.first;
    }
  }

  String _formatDate(DateTime d) => '${d.day}.${d.month}.${d.year}';

  String _dateLabel() {
    switch (event.dateMode) {
      case DateSelectionMode.single:
        return _formatDate(event.singleDate!);
      case DateSelectionMode.range:
        return '${_formatDate(event.rangeStart!)} — ${_formatDate(event.rangeEnd!)}';
      case DateSelectionMode.multiple:
        return '${event.multipleDates!.length} dates';
    }
  }

  int get _daysLeft {
    final now = DateTime.now();
    final diff = _firstDate.difference(DateTime(now.year, now.month, now.day));
    return diff.inDays;
  }

  @override
  Widget build(BuildContext context) {
    final liveEvent = context.watch<ToiProvider>().events.firstWhere(
      (e) => e.id == event.id,
      orElse: () => event,
    );

    final totalBudget = liveEvent.budget;
    final expenses = liveEvent.expenses;
    final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              image:
                  liveEvent.imageUrl != null
                      ? DecorationImage(
                        image:
                            liveEvent.imageUrl!.startsWith('http')
                                ? NetworkImage(liveEvent.imageUrl!)
                                : FileImage(File(liveEvent.imageUrl!))
                                    as ImageProvider,
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                liveEvent.imageUrl == null
                    ? const Icon(Icons.celebration, size: 60)
                    : null,
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + description
                Text(
                  liveEvent.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  liveEvent.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),

                // Info row: guests + countdown
                Row(
                  children: [
                    Expanded(
                      child: OverviewInfoCard(
                        icon: Icons.people_outline,
                        label: 'Guests',
                        value: '${liveEvent.guestCount}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OverviewCountdownCard(
                        daysLeft: _daysLeft,
                        dateLabel: _dateLabel(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Budget widget
                OverviewBudgetWidget(event: liveEvent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
