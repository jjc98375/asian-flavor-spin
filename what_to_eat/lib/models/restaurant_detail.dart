import 'restaurant.dart';

class DailyHours {
  final String day;
  final String start;
  final String end;
  final bool isClosed;

  const DailyHours({
    required this.day,
    required this.start,
    required this.end,
    required this.isClosed,
  });

  String get dayName {
    return switch (day) {
      '0' => 'Monday',
      '1' => 'Tuesday',
      '2' => 'Wednesday',
      '3' => 'Thursday',
      '4' => 'Friday',
      '5' => 'Saturday',
      '6' => 'Sunday',
      _ => day,
    };
  }

  String get timeRange {
    if (isClosed) return 'Closed';
    return '${_formatTime(start)} – ${_formatTime(end)}';
  }

  static String _formatTime(String t) {
    if (t.length != 4) return t;
    final hour = int.tryParse(t.substring(0, 2)) ?? 0;
    final minute = t.substring(2);
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }
}

class RestaurantDetail {
  final Restaurant restaurant;
  final List<String> photos;
  final List<DailyHours> hours;
  final bool isOpenNow;
  final List<String> transactions;

  const RestaurantDetail({
    required this.restaurant,
    required this.photos,
    required this.hours,
    required this.isOpenNow,
    required this.transactions,
  });

  factory RestaurantDetail.fromYelpDetailJson(Map<String, dynamic> json) {
    final base = Restaurant.fromYelpJson(json);

    final photos = (json['photos'] as List<dynamic>? ?? [])
        .map((p) => p as String)
        .toList();

    final hoursList = json['hours'] as List<dynamic>?;
    final hoursData =
        hoursList?.isNotEmpty == true ? hoursList!.first as Map<String, dynamic> : null;

    final isOpenNow =
        (hoursData?['is_open_now'] as bool?) ?? false;

    final openList = (hoursData?['open'] as List<dynamic>? ?? []);
    // Build a map: day -> list of open periods
    final Map<String, List<Map<String, dynamic>>> dayMap = {};
    for (final entry in openList) {
      final e = entry as Map<String, dynamic>;
      final day = e['day'].toString();
      dayMap.putIfAbsent(day, () => []).add(e);
    }

    final List<DailyHours> dailyHours = [];
    for (var d = 0; d < 7; d++) {
      final key = d.toString();
      final periods = dayMap[key];
      if (periods == null || periods.isEmpty) {
        dailyHours.add(DailyHours(day: key, start: '', end: '', isClosed: true));
      } else {
        // Use first period per day
        final p = periods.first;
        dailyHours.add(DailyHours(
          day: key,
          start: p['start'] as String? ?? '',
          end: p['end'] as String? ?? '',
          isClosed: false,
        ));
      }
    }

    final transactions = (json['transactions'] as List<dynamic>? ?? [])
        .map((t) => t as String)
        .toList();

    return RestaurantDetail(
      restaurant: base,
      photos: photos,
      hours: dailyHours,
      isOpenNow: isOpenNow,
      transactions: transactions,
    );
  }
}
