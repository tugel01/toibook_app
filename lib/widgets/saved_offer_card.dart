import 'package:flutter/material.dart';
import 'package:toibook_app/models/vendors/enums.dart';
import 'package:toibook_app/models/vendors/saved_offer_card.dart';
import 'package:toibook_app/models/vendors/ticket.dart';

class SavedOfferCard extends StatelessWidget {
  final SavedOfferCardResponse offer;
  final TicketCardResponse? ticket;
  final VoidCallback? onDelete;

  const SavedOfferCard({
    super.key,
    required this.offer,
    this.ticket,
    this.onDelete,
  });

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
    final isActive = offer.isActive;

    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: Stack(
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cover image
                  SizedBox(
                    width: 110,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                          child:
                              offer.coverImageUrl != null
                                  ? Image.network(
                                    offer.coverImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, _, _) => Icon(
                                          offer.vendorType == VendorType.venue
                                              ? Icons.location_on_outlined
                                              : Icons.person_outline,
                                          size: 36,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        ),
                                  )
                                  : Icon(
                                    offer.vendorType == VendorType.venue
                                        ? Icons.location_on_outlined
                                        : Icons.person_outline,
                                    size: 36,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                        if (!isActive)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Inactive',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_typeLabel.isNotEmpty)
                            Text(
                              _typeLabel.toUpperCase(),
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            offer.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
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
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                          if (ticket != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  ticket!.status,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusLabel(ticket!.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _statusColor(ticket!.status),
                                ),
                              ),
                            ),
                            if (ticket!.messageToVendor != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                ticket!.messageToVendor!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Chevron
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
        bottom: 5,
        right: 5,
        child: GestureDetector(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.delete_outline,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ),

        ],
      ),
    );
  }

  Color _statusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return Colors.orange;
      case TicketStatus.approved:
        return Colors.green;
      case TicketStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return 'Pending';
      case TicketStatus.approved:
        return 'Approved';
      case TicketStatus.rejected:
        return 'Rejected';
      default:
        return '';
    }
  }
}
