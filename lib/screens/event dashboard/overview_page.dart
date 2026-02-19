import 'dart:io';
import 'package:flutter/material.dart';
import 'package:toibook_app/widgets/infochip_card.dart';
import '../../models/toi_event.dart';

class OverviewPage extends StatelessWidget {
  final ToiEvent event;
  const OverviewPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Mock data aboiut budget
    double spent = 450000;
    double totalBudget = event.budget ?? 1000000;
    double progress = spent / totalBudget;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Header
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image:
                  event.imageUrl != null
                      ? DecorationImage(
                        image:
                            event.imageUrl!.startsWith('http')
                                ? NetworkImage(event.imageUrl!)
                                : FileImage(File(event.imageUrl!))
                                    as ImageProvider,
                        fit: BoxFit.cover,
                      )
                      : null,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child:
                event.imageUrl == null
                    ? const Icon(Icons.celebration, size: 60)
                    : null,
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // General Info
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InfoChip(
                      icon: Icons.location_on_outlined,
                      label: event.location ?? "No location set",
                    ),
                    const SizedBox(width: 10),
                    InfoChip(
                      icon: Icons.people_outline,
                      label: "${event.guestCount ?? 0} guests",
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Budget Dashboard
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Budget Tracking",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${(progress * 100).toInt()}%",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(10),
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _budgetStat("Spent", "₸${spent.toInt()}"),
                          _budgetStat("Total", "₸${totalBudget.toInt()}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _budgetStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
