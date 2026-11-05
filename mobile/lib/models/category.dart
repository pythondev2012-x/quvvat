import '../utils/parsers.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.logo,
    required this.isActive,
  });

  final int id;
  final String name;
  final String displayName;
  final String? logo;
  final bool isActive;

  factory Category.fromJson(Map<String, dynamic> json) {
    final name = asString(json['name']);
    return Category(
      id: asInt(json['id']),
      name: name,
      displayName: asString(json['display_name'], name),
      logo: json['logo'] == null ? null : asString(json['logo']),
      isActive: asBool(json['is_active'], true),
    );
  }

  static List<Category> listFrom(dynamic data) {
    return asList(data)
        .map((item) => Category.fromJson(asMap(item)))
        .where((category) => category.id != 0)
        .toList();
  }
}
