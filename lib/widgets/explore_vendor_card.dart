import 'package:flutter/material.dart';
import 'package:toibook_app/models/vendors/enums.dart';
import 'package:toibook_app/models/vendors/short_offer.dart';

class ExploreVendorCard extends StatelessWidget {
  final OfferResponse offer;

  const ExploreVendorCard({super.key, required this.offer});

  String get _typeLabel {
    if (offer.vendorType == VendorType.venue && offer.venueType != null) {
      return offer.venueType!.label;
    }
    if (offer.vendorType == VendorType.serviceProvider &&
        offer.serviceType != null) {
      return offer.serviceType!.label;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                image:
                    offer.coverImageUrl != null
                        ? DecorationImage(
                          image: NetworkImage(offer.coverImageUrl!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  offer.coverImageUrl == null
                      ? Icon(
                        offer.vendorType == VendorType.venue
                            ? Icons.location_on_outlined
                            : Icons.person_outline,
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
                // Type label
                if (_typeLabel.isNotEmpty)
                  Text(
                    _typeLabel.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                const SizedBox(height: 4),

                // Name
                Text(
                  offer.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),

                // City
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      offer.city.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
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
