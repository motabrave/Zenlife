import 'dart:convert';

class WellnessEntry {
  final DateTime date;         // ngày ghi
  final int sweetUnits;        // 0..10
  final int stressLevel;       // 0..10
  final int sleepMinutes;      // phút từ 0..1439 (giờ ngủ)
  final int wakeMinutes;       // phút từ 0..1439 (giờ dậy)
  final double hoursSlept;     // số giờ ngủ (xử lý qua ngày)
  final int score;             // 0..100
  final String? notes;

  WellnessEntry({
    required this.date,
    required this.sweetUnits,
    required this.stressLevel,
    required this.sleepMinutes,
    required this.wakeMinutes,
    required this.hoursSlept,
    required this.score,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'sweetUnits': sweetUnits,
        'stressLevel': stressLevel,
        'sleepMinutes': sleepMinutes,
        'wakeMinutes': wakeMinutes,
        'hoursSlept': hoursSlept,
        'score': score,
        'notes': notes,
      };

  factory WellnessEntry.fromMap(Map<String, dynamic> map) => WellnessEntry(
        date: DateTime.parse(map['date'] as String),
        sweetUnits: map['sweetUnits'] as int,
        stressLevel: map['stressLevel'] as int,
        sleepMinutes: map['sleepMinutes'] as int,
        wakeMinutes: map['wakeMinutes'] as int,
        hoursSlept: (map['hoursSlept'] as num).toDouble(),
        score: map['score'] as int,
        notes: map['notes'] as String?,
      );

  String toJson() => json.encode(toMap());
  factory WellnessEntry.fromJson(String src) => WellnessEntry.fromMap(json.decode(src));

  String get readableDate =>
      "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
}
