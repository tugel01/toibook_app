import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/event_card_response.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/screens/event%20dashboard/tabs/overview_page.dart';

class EventDashboard extends StatefulWidget {
  final EventCardResponse event;

  const EventDashboard({super.key, required this.event});

  @override
  State<EventDashboard> createState() => _EventDashboardState();
}

class _EventDashboardState extends State<EventDashboard> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);

    // Trigger the load after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ToiProvider>().loadDashboard(widget.event.id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ToiProvider>();

    // error screen
    if (provider.dashboardError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.event.name),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text('Could not load dashboard.'),
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    () => context.read<ToiProvider>().loadDashboard(
                      widget.event.id,
                    ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // loading screen / Shimmer
    if (provider.isLoadingDashboard || provider.dashboard == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 200),
                Icon(
                  Icons.celebration,
                  size: 67,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 32),
                Text(
                  "Dashboard for ${widget.event.name} is loading...",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // loaded State
    final dashboard = provider.dashboard!;

    return Scaffold(
      appBar: AppBar(
        title: Text(dashboard.name),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          const OverviewPage(),
          const Center(child: Text("Saved Items / Vendors")),
          const Center(child: Text("Chat with Vendors")),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Chat"),
        ],
      ),
    );
  }
}
