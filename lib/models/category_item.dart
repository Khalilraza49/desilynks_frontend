class CategoryItem {
  final String id;
  final String title;

  const CategoryItem({required this.id, required this.title});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? json['name'] as String? ?? '',
    );
  }

  @override
  String toString() => title;
}
