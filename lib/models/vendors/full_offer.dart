import 'package:toibook_app/models/user_model.dart';
import 'package:toibook_app/models/vendors/enums.dart';

class OfferDetailResponse {
  final int id;
  final VendorType vendorType;
  final VenueType? venueType;
  final ServiceType? serviceType;
  final String displayName;
  final String description;
  final City city;
  final List<OfferImage> images;
  final List<DetailsResponse> detailsResponses;

  OfferDetailResponse({
    required this.id,
    required this.vendorType,
    this.venueType,
    this.serviceType,
    required this.displayName,
    required this.description,
    required this.city,
    required this.images,
    required this.detailsResponses,
  });

  OfferImage? get coverImage => images.where((i) => i.isCover).firstOrNull;

  List<OfferImage> get portfolioImages =>
      images.where((i) => !i.isCover).toList();

  List<ContactEntry> get contacts =>
      detailsResponses.expand((d) => d.data).toList();

  factory OfferDetailResponse.fromJson(Map<String, dynamic> json) =>
      OfferDetailResponse(
        id: json['id'],
        vendorType: VendorType.fromString(json['vendorType']),
        venueType:
            json['venueType'] != null
                ? VenueType.fromString(json['venueType'])
                : null,
        serviceType:
            json['serviceType'] != null
                ? ServiceType.fromString(json['serviceType'])
                : null,
        displayName: json['displayName'],
        description: json['description'],
        city: City.fromString(json['city']),
        images:
            (json['images'] as List)
                .map((e) => OfferImage.fromJson(e))
                .toList(),
        detailsResponses:
            (json['detailsResponses'] as List)
                .map((e) => DetailsResponse.fromJson(e))
                .toList(),
      );
}
