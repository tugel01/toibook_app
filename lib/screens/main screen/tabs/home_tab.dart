import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/toi_event.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/screens/event%20dashboard/event_dashboard.dart';
import 'package:toibook_app/widgets/add_event_card.dart';
import 'package:toibook_app/widgets/city_picker.dart';
import 'package:toibook_app/widgets/event_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // load once when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ToiProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ToiProvider>();
    final currentCity = provider.currentCity;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationBar(context, currentCity),
            const SizedBox(height: 32),
            Text(
              'My events',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildGrid(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, ToiProvider provider) {
    if (provider.isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.eventsError != null) {
      return Center(
        child: Column(
          children: [
            const Text('Could not load events.'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.read<ToiProvider>().loadEvents(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final events = provider.eventCards;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: events.length + 1,
      itemBuilder: (context, index) {
        if (index == events.length) {
          final provider = context.read<ToiProvider>();
          return AddEventCard(onReturn: () => provider.loadEvents());
        }
        return GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          EventDashboard(event: ToiEvent.mockEvents.first),
                ),
              ),
          child: EventCard(event: events[index]),
        );
      },
    );
  }

  Widget _buildLocationBar(BuildContext context, String currentCity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => CityPicker.show(context),
                borderRadius: BorderRadius.circular(30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 22),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Current Location",
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Text(
                            currentCity,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () => print("Notifications tapped"),
            ),
          ],
        ),
      ),
    );
  }
}
