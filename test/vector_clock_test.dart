import 'package:flutter_application_1/core/sync/vector_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('compares dominant and concurrent vector clocks', () {
    const base = VectorClock({'a': 1});
    expect(
      base.compare(const VectorClock({'a': 2})),
      ClockRelation.remoteDominates,
    );
    expect(
      const VectorClock({'a': 2}).compare(base),
      ClockRelation.localDominates,
    );
    expect(
      const VectorClock({'a': 2}).compare(const VectorClock({'a': 1, 'b': 1})),
      ClockRelation.concurrent,
    );
  });

  test('round-trips and merges clocks', () {
    final merged = const VectorClock({'android': 3})
        .merged(const VectorClock({'windows': 4, 'android': 2}));
    expect(VectorClock.fromJsonString(merged.toJsonString()).values, {
      'android': 3,
      'windows': 4,
    });
  });
}
