import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/widgets/overview/budget/overview_budget_widget.dart';
import 'package:toibook_app/widgets/overview/overview_countdown_card.dart';
import 'package:toibook_app/widgets/overview/overview_info_card.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});


  int _daysLeft(String dateString) {
    try {
      final parts = dateString.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final now = DateTime.now();
      return date.difference(DateTime(now.year, now.month, now.day)).inDays;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ToiProvider>();
    final dashboard = provider.dashboard;

    if (dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final guestWidget = dashboard.guestCountWidget;
    final countdownWidget = dashboard.countdownWidget;
    final budgetWidget = dashboard.budgetWidget;

    final guestCount = guestWidget?.guestCount;
    final countdownDate = countdownWidget?.countdown;
    final budgetData = budgetWidget?.budget;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          Container(
            height: 220,
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.celebration, size: 60),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  dashboard.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // Description
                Text(
                  dashboard.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),

                // Info row
                Row(
                  children: [
                    if (guestCount != null)
                      Expanded(
                        child: OverviewInfoCard(
                          icon: Icons.people_outline,
                          label: 'Guests',
                          value: '$guestCount',
                        ),
                      ),
                    const SizedBox(width: 12),
                    if (countdownDate != null)
                      Expanded(
                        child: OverviewCountdownCard(
                          daysLeft: _daysLeft(countdownDate),
                          dateLabel: countdownDate,
                        ),
                      ),
                    if (countdownDate == null)
                      Expanded(
                        child: OverviewInfoCard(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          value: 'Not confirmed yet',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Budget widget
                if (budgetData != null)
                  OverviewBudgetWidget(
                    eventId: dashboard.eventId,
                    budgetResponse: budgetData,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
