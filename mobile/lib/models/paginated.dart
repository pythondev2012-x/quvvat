import '../utils/parsers.dart';

class Paginated<T> {
  const Paginated({
    required this.count,
    required this.next,
    required this.results,
  });

  final int count;
  final String? next;
  final List<T> results;

  bool get hasMore => next != null && next!.isNotEmpty;

  factory Paginated.fromJson(
    dynamic json,
    T Function(Map<String, dynamic>) parse, {
    String resultsKey = 'results',
  }) {
    if (json is List) {
      final items = asList(json)
          .map((item) => parse(asMap(item)))
          .toList();
      return Paginated(count: items.length, next: null, results: items);
    }
    final map = asMap(json);
    final items = asList(map[resultsKey])
        .map((item) => parse(asMap(item)))
        .toList();
    return Paginated(
      count: asInt(map['count'], items.length),
      next: map['next'] == null ? null : asString(map['next']),
      results: items,
    );
  }
}
