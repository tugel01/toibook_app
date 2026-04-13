import 'package:flutter/material.dart';
import '../models/event_card_response.dart';

class EventCard extends StatelessWidget {
  final EventCardResponse event;
  const EventCard({super.key, required this.event});

  String get _dateLabel {
    if (event.confirmedDate == null) return 'Date not confirmed yet';
    return event.confirmedDate!;
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? imageProvider = event.coverImageUrl != null
        ? NetworkImage(event.coverImageUrl!)
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.5),
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider, fit: BoxFit.cover)
                    : null,
              ),
              child: imageProvider == null
                  ? Icon(Icons.celebration_outlined,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: event.confirmedDate == null
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _dateLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: event.confirmedDate == null
                                  ? Theme.of(context).colorScheme.error
                                  : null,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}