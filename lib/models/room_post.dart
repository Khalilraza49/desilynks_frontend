class RoomPost {
  final String title;
  final String location;
  final String price;
  final String status; // 'Active', 'Pending', 'Expired'
  final String date;
  final String propertyType; // 'Room', 'Apartment', 'House', 'Studio'
  final List<String> amenities;
  final String imageUrl;

  RoomPost({
    required this.title,
    required this.location,
    required this.price,
    required this.status,
    required this.date,
    required this.propertyType,
    required this.amenities,
    required this.imageUrl,
  });
}
