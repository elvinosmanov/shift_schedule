class Holidays {
  final String name;
  final DateTime date;

  Holidays({required this.name, required this.date});
  static const _gsDateBase = 2209161600 / 86400;
  static const _gsDateFactor = 86400000;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.millisecondsSinceEpoch,
    };
  }

  factory Holidays.fromList(List<String>? list) {
    final date = double.tryParse(list![1]);
  final millis = (date! - _gsDateBase) * _gsDateFactor;
    return Holidays(name: list[0], date: DateTime.fromMillisecondsSinceEpoch(millis.toInt(), isUtc: true));
  }

  factory Holidays.fromMap(Map<String, dynamic> map) {
    return Holidays(
      name: map['name'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }
}
