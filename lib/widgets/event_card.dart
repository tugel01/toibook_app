import 'dart:io';
import 'package:flutter/material.dart';
import '../models/toi_event.dart';

class EventCard extends StatelessWidget {
  final ToiEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final ImageProvider? imageProvider =
        event.imageUrl != null
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
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.5),
                image:
                    imageProvider != null
                        ? DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              // Show icon if no image
              child:
                  imageProvider == null
                      ? Icon(
                        Icons.celebration_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.type
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${event.date.day}.${event.date.month}.${event.date.year}",
                      style: Theme.of(context).textTheme.bodySmall,
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
