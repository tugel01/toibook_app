import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/user_model.dart';
import 'package:toibook_app/models/vendors/enums.dart';
import 'package:toibook_app/models/vendors/short_offer.dart';
import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/screens/vendor_profile_screen.dart';
import 'package:toibook_app/services/vendor_service.dart';
import 'package:toibook_app/widgets/explore_vendor_card.dart';
import 'package:toibook_app/widgets/location_bar.dart';

enum _ExploreTab { top, places, people }

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  City? _lastCity;
  final _searchController = TextEditingController();
  Timer? _debounce;

  _ExploreTab _activeTab = _ExploreTab.top;
  VenueType? _selectedVenueType;
  ServiceType? _selectedServiceType;

  List<OfferResponse> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _fetchFeed);
  }

  City? _currentCity() {
    final profile = context.read<ToiProvider>().userProfile;
    final cityLabel = profile?.city?.label;
    if (cityLabel == null) return null;
    try {
      return City.fromString(cityLabel);
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchFeed() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      VendorType? vendorType;
      if (_activeTab == _ExploreTab.places) vendorType = VendorType.venue;
      if (_activeTab == _ExploreTab.people) {
        vendorType = VendorType.serviceProvider;
      }

      final results = await VendorService().getFeed(
        vendorType: vendorType,
        venueType: _activeTab == _ExploreTab.places ? _selectedVenueType : null,
        serviceType:
            _activeTab == _ExploreTab.people ? _selectedServiceType : null,
        city: _currentCity(),
        query:
            _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _results = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _onTabChanged(_ExploreTab tab) {
    setState(() {
      _activeTab = tab;
      _selectedVenueType = null;
      _selectedServiceType = null;
    });
    _fetchFeed();
  }

  void _onVenueTypeSelected(VenueType type) {
    setState(() {
      _selectedVenueType = _selectedVenueType == type ? null : type;
    });
    _fetchFeed();
  }

  void _onServiceTypeSelected(ServiceType type) {
    setState(() {
      _selectedServiceType = _selectedServiceType == type ? null : type;
    });
    _fetchFeed();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ToiProvider>();
    final currentCity = provider.userProfile?.city;

    if (currentCity != _lastCity) {
      _lastCity = currentCity;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchFeed();
      });
    }
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocationBar(location: currentCity?.label ?? 'Select City'),
                const SizedBox(height: 32),
                Text(
                  'Explore Vendors',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Search bar
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _fetchFeed(),
                  decoration: InputDecoration(
                    hintText: 'Search vendors, venues...',
                    prefixIcon: const Icon(Icons.search_outlined),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                _fetchFeed();
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tab selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      _ExploreTab.values.map((tab) {
                        final isActive = _activeTab == tab;
                        final label = switch (tab) {
                          _ExploreTab.top => 'Top',
                          _ExploreTab.places => 'Places',
                          _ExploreTab.people => 'People',
                        };
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _onTabChanged(tab),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isActive
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Filter chips
                if (_activeTab == _ExploreTab.places)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          VenueType.values.map((type) {
                            final selected = _selectedVenueType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(type.label),
                                selected: selected,
                                onSelected: (_) => _onVenueTypeSelected(type),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                if (_activeTab == _ExploreTab.people)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          ServiceType.values.map((type) {
                            final selected = _selectedServiceType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(type.label),
                                selected: selected,
                                onSelected: (_) => _onServiceTypeSelected(type),
                              ),
                            );
                          }).toList(),
                    ),
                  ),


                const SizedBox(height: 16),
              ],
            ),
          ),

          // Results
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Could not load vendors.'),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _fetchFeed,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                    : _results.isEmpty
                    ? const Center(child: Text('No vendors found.'))
                    : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => VendorProfileScreen(
                                        offer: _results[index],
                                      ),
                                ),
                              ),
                          child: ExploreVendorCard(offer: _results[index]),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
