import 'dart:convert';

enum ClockRelation { equal, localDominates, remoteDominates, concurrent }

class VectorClock {
  const VectorClock(this.values);

  factory VectorClock.empty() => const VectorClock({});

  factory VectorClock.fromJsonString(String value) {
    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return VectorClock(
        decoded.map((key, value) => MapEntry(key, (value as num).toInt())),
      );
    } catch (_) {
      return VectorClock.empty();
    }
  }

  final Map<String, int> values;

  VectorClock increment(String deviceId) =>
      VectorClock({...values, deviceId: (values[deviceId] ?? 0) + 1});

  VectorClock merged(VectorClock other) {
    final merged = <String, int>{...values};
    for (final entry in other.values.entries) {
      final current = merged[entry.key] ?? 0;
      if (entry.value > current) merged[entry.key] = entry.value;
    }
    return VectorClock(merged);
  }

  ClockRelation compare(VectorClock other) {
    var greater = false;
    var lower = false;
    for (final key in {...values.keys, ...other.values.keys}) {
      final left = values[key] ?? 0;
      final right = other.values[key] ?? 0;
      if (left > right) greater = true;
      if (left < right) lower = true;
    }
    if (!greater && !lower) return ClockRelation.equal;
    if (greater && !lower) return ClockRelation.localDominates;
    if (!greater && lower) return ClockRelation.remoteDominates;
    return ClockRelation.concurrent;
  }

  String toJsonString() => jsonEncode(values);
}
