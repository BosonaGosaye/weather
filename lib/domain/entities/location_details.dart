class LocationDetails {
  final String street;
  final String city;
  final String region;
  final String country;
  final String postalCode;

  const LocationDetails({
    this.street = '',
    this.city = '',
    this.region = '',
    this.country = '',
    this.postalCode = '',
  });

  @override
  String toString() {
    return [city, region, country].where((e) => e.isNotEmpty).join(', ');
  }
}
