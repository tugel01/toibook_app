import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toibook_app/models/vendors/enums.dart';
import 'package:toibook_app/models/vendors/full_offer.dart';
import 'package:toibook_app/models/vendors/short_offer.dart';

import 'package:toibook_app/providers/toi_provider.dart';
import 'package:toibook_app/services/vendor_service.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorProfileScreen extends StatefulWidget {
  final OfferResponse offer;

  const VendorProfileScreen({super.key, required this.offer});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  OfferDetailResponse? _offer;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;
  bool _isFavoriteLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOffer();
  }

  Future<void> _loadOffer() async {
    try {
      final results = await Future.wait([
        VendorService().getOffer(widget.offer.id),
        VendorService().getFavorites(),
      ]);

      if (!mounted) return;
      final offer = results[0] as OfferDetailResponse;
      final favorites = results[1] as List<OfferResponse>;

      setState(() {
        _offer = offer;
        _isFavorite = favorites.any((f) => f.id == widget.offer.id);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchContact(String info, ContactType type) async {
    String url;
    switch (type) {
      case ContactType.phone:
        url = 'tel:${info.replaceAll(' ', '')}';
        break;
      case ContactType.instagram:
        final handle = info.replaceAll('@', '');
        url = 'https://instagram.com/$handle';
        break;
      case ContactType.telegram:
        final handle = info.replaceAll('@', '');
        url = 'https://t.me/$handle';
        break;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showAddToEvent(BuildContext context) {
    final events = context.read<ToiProvider>().eventCards;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.7,
            expand: false,
            builder:
                (_, scrollController) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Add to my event',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            events.isEmpty
                                ? const Center(
                                  child: Text(
                                    'No events yet. Create one first.',
                                  ),
                                )
                                : ListView.builder(
                                  controller: scrollController,
                                  itemCount: events.length,
                                  itemBuilder: (context, index) {
                                    final event = events[index];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                        Icons.celebration_outlined,
                                      ),
                                      title: Text(event.name),
                                      trailing: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onTap: () {
                                        VendorService().addToEvent(
                                          widget.offer.id,
                                          event.id,
                                        );
                                        Navigator.pop(ctx);
                                      },
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  IconData _contactIcon(ContactType type) {
    switch (type) {
      case ContactType.phone:
        return Icons.phone_outlined;
      case ContactType.instagram:
        return Icons.camera_alt_outlined;
      case ContactType.telegram:
        return Icons.send_outlined;
    }
  }

  String _contactLabel(ContactType type) {
    switch (type) {
      case ContactType.phone:
        return 'Phone';
      case ContactType.instagram:
        return 'Instagram';
      case ContactType.telegram:
        return 'Telegram';
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavoriteLoading = true);
    try {
      await VendorService().addOrRemoveFromFavorites(widget.offer.id);
      if (!mounted) return;
      setState(() => _isFavorite = !_isFavorite);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update favorites')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isFavoriteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon:
                _isFavoriteLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : null,
                    ),
            onPressed: _isFavoriteLoading ? null : _toggleFavorite,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load vendor.'),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loadOffer,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _buildContent(),
      bottomNavigationBar:
          _offer == null
              ? null
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => _showAddToEvent(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add to my event'),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildContent() {
    final offer = _offer!;
    final typeLabel =
        offer.vendorType == VendorType.venue
            ? offer.venueType?.label ?? ''
            : offer.serviceType?.label ?? '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          Container(
            height: 260,
            width: double.infinity,
            color: Theme.of(context).colorScheme.primaryContainer,
            child:
                offer.coverImage != null
                    ? Image.network(
                      offer.coverImage!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, _, _) => Icon(
                            Icons.image_outlined,
                            size: 60,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                    )
                    : Icon(
                      Icons.image_outlined,
                      size: 60,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type label
                if (typeLabel.isNotEmpty)
                  Text(
                    typeLabel.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                const SizedBox(height: 4),

                // Name
                Text(
                  offer.displayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // City
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      offer.city.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  offer.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Portfolio photos
                if (offer.portfolioImages.isNotEmpty) ...[
                  Text(
                    'Portfolio',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: offer.portfolioImages.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final img = offer.portfolioImages[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            img.imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, _, _) => Container(
                                  width: 120,
                                  height: 120,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.image_outlined),
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Contacts
                if (offer.contacts.isNotEmpty) ...[
                  Text(
                    'Contacts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...offer.contacts.map(
                    (contact) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _contactIcon(contact.contactType),
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        _contactLabel(contact.contactType),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(contact.contactInfo),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap:
                          () => _launchContact(
                            contact.contactInfo,
                            contact.contactType,
                          ),
                    ),
                  ),
                ],

                // Bottom padding for FAB
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
