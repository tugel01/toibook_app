enum VendorType {
  venue,
  serviceProvider;

  static VendorType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'VENUE':
        return VendorType.venue;
      case 'SERVICE_PROVIDER':
        return VendorType.serviceProvider;
      default:
        throw Exception('Unknown vendor type: $value');
    }
  }

  String toQueryString() {
    switch (this) {
      case VendorType.venue:
        return 'VENUE';
      case VendorType.serviceProvider:
        return 'SERVICE_PROVIDER';
    }
  }
}

enum VenueType {
  restaurant,
  bar,
  loft;

  static VenueType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'RESTAURANT':
        return VenueType.restaurant;
      case 'BAR':
        return VenueType.bar;
      case 'LOFT':
        return VenueType.loft;
      default:
        throw Exception('Unknown venue type: $value');
    }
  }

  String get label {
    switch (this) {
      case VenueType.restaurant:
        return 'Restaurant';
      case VenueType.bar:
        return 'Bar';
      case VenueType.loft:
        return 'Loft';
    }
  }

  String toQueryString() {
    switch (this) {
      case VenueType.restaurant:
        return 'RESTAURANT';
      case VenueType.bar:
        return 'BAR';
      case VenueType.loft:
        return 'LOFT';
    }
  }
}

enum ServiceType {
  photographer,
  florisit,
  dj,
  host;

  String get label {
    switch (this) {
      case ServiceType.photographer:
        return 'Photographer';
      case ServiceType.florisit:
        return 'Florist';
      case ServiceType.dj:
        return 'DJ';
      case ServiceType.host:
        return 'Host';
    }
  }

  static ServiceType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PHOTOGRAPHER':
        return ServiceType.photographer;
      case 'FLORIST':
        return ServiceType.florisit;
      case 'DJ':
        return ServiceType.dj;
      case 'HOST':
        return ServiceType.host;
      default:
        throw Exception('Unknown service type: $value');
    }
  }

  String toQueryString() {
    switch (this) {
      case ServiceType.photographer:
        return 'PHOTOGRAPHER';
      case ServiceType.florisit:
        return 'FLORIST';
      case ServiceType.dj:
        return 'DJ';
      case ServiceType.host:
        return 'HOST';
    }
  }
}

class OfferImage {
  final String imageUrl;
  final bool isCover;

  OfferImage({required this.imageUrl, required this.isCover});

  factory OfferImage.fromJson(Map<String, dynamic> json) =>
      OfferImage(imageUrl: json['imageUrl'], isCover: json['isCover']);
}

enum ContactType {
  phone,
  instagram,
  telegram;

  static ContactType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PHONE':
        return ContactType.phone;
      case 'INSTAGRAM':
        return ContactType.instagram;
      case 'TELEGRAM':
        return ContactType.telegram;
      default:
        throw Exception('Unknown contact type: $value');
    }
  }
}

class ContactEntry {
  final ContactType contactType;
  final String contactInfo;

  ContactEntry({required this.contactType, required this.contactInfo});

  factory ContactEntry.fromJson(Map<String, dynamic> json) => ContactEntry(
    contactType: ContactType.fromString(json['contactType']),
    contactInfo: json['contactInfo'],
  );
}

class DetailsResponse {
  final int id;
  final String detailsType;
  final List<ContactEntry> data;

  DetailsResponse({
    required this.id,
    required this.detailsType,
    required this.data,
  });

  factory DetailsResponse.fromJson(
    Map<String, dynamic> json,
  ) => DetailsResponse(
    id: json['id'],
    detailsType: json['detailsType'],
    data: (json['data'] as List).map((e) => ContactEntry.fromJson(e)).toList(),
  );
}

enum OfferStatus {
  created,
  pending,
  active,
  disabled;

  String get label {
    switch (this) {
      case OfferStatus.created:
        return 'Created';
      case OfferStatus.pending:
        return 'Pending';
      case OfferStatus.active:
        return 'Active';
      case OfferStatus.disabled:
        return 'Disabled';
    }
  }

  static OfferStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CREATED':
        return OfferStatus.created;
      case 'PENDING':
        return OfferStatus.pending;
      case 'ACTIVE':
        return OfferStatus.active;
      case 'DISABLED':
        return OfferStatus.disabled;
      default:
        throw Exception('Unknown offer status: $value');
    }
  }

  String toQueryString() {
    switch (this) {
      case OfferStatus.created:
        return 'CREATED';
      case OfferStatus.pending:
        return 'PENDING';
      case OfferStatus.active:
        return 'ACTIVE';
      case OfferStatus.disabled:
        return 'DISABLED';
    }
  }
}
