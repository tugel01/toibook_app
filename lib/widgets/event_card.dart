import 'dart:io';
import 'package:flutter/material.dart';
import '../models/toi_event.dart';

class EventCard extends StatelessWidget {
  final ToiEvent event;
  const EventCard({super.key, required this.event});

  String _formatDate() {
    switch (event.dateMode) {
      case DateSelectionMode.single:
        final d = event.singleDate!;
        return '${d.day}.${d.month}.${d.year}';
      case DateSelectionMode.range:
        final s = event.rangeStart!;
        final e = event.rangeEnd!;
        return '${s.day}.${s.month}.${s.year} — ${e.day}.${e.month}.${e.year}';
      case DateSelectionMode.multiple:
        final count = event.multipleDates!.length;
        final first = event.multipleDates!.first;
        return '${first.day}.${first.month}.${first.year} +${count - 1} more';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? imageProvider = event.imageUrl != null
        ? (event.imageUrl!.startsWith('http')
            ? NetworkImage(event.imageUrl!)
            : FileImage(File(event.imageUrl!)) as ImageProvider)
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
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                    : null,
              ),
              child: imageProvider == null
                  ? Icon(Icons.celebration_outlined,
                      size: 40, color: Theme.of(context).colorScheme.primary)
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _formatDate(),
                        style: Theme.of(context).textTheme.bodySmall,
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