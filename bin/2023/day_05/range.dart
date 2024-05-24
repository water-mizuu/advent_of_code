import "dart:math" as math;

typedef Conversion = ({UnitRange destination, UnitRange source});

sealed class IntegerRange {
  const factory IntegerRange.unit(int start, int end) = UnitRange;
  const factory IntegerRange.union(List<UnitRange> ranges) = UnionRange;

  static const IntegerRange empty = UnionRange([]);

  int get length;

  bool get isEmpty;
  bool get isNotEmpty;

  Set<int> get canonical;

  Iterable<UnitRange> get units;

  bool contains(num value);

  bool touchesWith(IntegerRange other);
  bool intersectsWith(IntegerRange other);
  bool covers(IntegerRange other);
  IntegerRange union(IntegerRange other);
  IntegerRange intersect(IntegerRange other);

  IntegerRange difference(IntegerRange other);
  IntegerRange map(List<Conversion> map);
}

final class UnitRange implements IntegerRange {
  const UnitRange(this.start, this.end);

  final int start;
  final int end;

  @override
  bool contains(num value) => this.start <= value && value < this.end;

  @override
  int get length => end - start;

  @override
  bool get isEmpty => length <= 0;

  @override
  bool get isNotEmpty => length > 0;

  @override
  Set<int> get canonical => {for (int i = start; i < end; i++) i};

  @override
  Iterable<UnitRange> get units sync* {
    yield this;
  }

  @override
  bool touchesWith(IntegerRange other) => switch (other) {
        UnitRange other => this.end == other.start || this.start == other.end,
        UnionRange other => other.units.any(this.touchesWith),
      };

  @override
  bool intersectsWith(IntegerRange other) => switch (other) {
        UnitRange other => !(this.end < other.start || this.start >= other.end),
        UnionRange other => other.units.any(this.intersectsWith),
      };

  @override
  bool covers(IntegerRange other) => switch (other) {
        UnitRange other => other.isEmpty || this.start <= other.start && this.end >= other.end,
        UnionRange other => this.covers(other.cell),
      };

  @override
  IntegerRange union(IntegerRange other) => switch (other) {
        UnitRange other => switch (null) {
            _ when this.covers(other) => this,
            _ when other.covers(this) => other,
            _ when this.intersectsWith(other) || this.touchesWith(other) =>
              IntegerRange.unit(math.min(this.start, other.start), math.max(this.end, other.end)),
            _ => UnionRange([if (this.isNotEmpty) this, if (other.isNotEmpty) other]),
          },
        UnionRange other => other.units //
            .fold(this, (result, current) => current.isEmpty ? result : result.union(current)),
      };

  @override
  IntegerRange intersect(IntegerRange other) => switch (other) {
        UnitRange other => switch (null) {
            _ when this.intersectsWith(other) => IntegerRange.unit(
                math.max(this.start, other.start),
                math.min(this.end, other.end),
              ),
            _ => IntegerRange.empty,
          },
        UnionRange other => other.units.map(this.intersect).union()
      };

  @override
  IntegerRange difference(IntegerRange other) => switch (other) {
        UnitRange other => switch (null) {
            _ when this.intersectsWith(other) =>
              IntegerRange.unit(this.start, other.start).union(IntegerRange.unit(other.end, this.end)),
            null => this,
          },
        UnionRange other => other.units.fold(this, (result, current) => result.difference(current)),
      };

  @override
  IntegerRange map(List<Conversion> map) {
    IntegerRange working = this;
    IntegerRange updated = IntegerRange.empty;

    for (Conversion conversion in map) {
      if (working.isEmpty) {
        break;
      }

      if (conversion.source.covers(working)) {
        for (UnitRange unit in working.units) {
          int length = unit.length;
          int startOffset = unit.start - conversion.source.start;

          working -= unit;
          updated |= IntegerRange.unit(
            conversion.destination.start + startOffset,
            conversion.destination.start + startOffset + length,
          );
        }
      }

      if (working.covers(conversion.source)) {
        working -= conversion.source;
        updated |= conversion.destination;
      }

      if (working.intersectsWith(conversion.source)) {
        IntegerRange intersection = working.intersect(conversion.source);
        IntegerRange converted = intersection.map(map);

        working -= intersection;
        updated |= converted;
      }
    }

    return working | updated;
  }

  @override
  String toString() => "[$start, $end)";
}

final class UnionRange implements IntegerRange {
  const UnionRange(this.units);

  @override
  final List<UnitRange> units;

  UnitRange get cell {
    if (units.isEmpty) {
      return const UnitRange(0, 0);
    }

    var UnitRange(start: min, end: max) = units.first;
    for (var UnitRange(:start, :end) in units) {
      min = math.min(start, min);
      max = math.max(end, max);
    }

    return UnitRange(min, max);
  }

  @override
  bool contains(num value) => units.any((unit) => unit.contains(value));

  @override
  int get length => units.map((r) => r.length).fold(0, (a, b) => a + b);

  @override
  bool get isEmpty => length <= 0;

  @override
  bool get isNotEmpty => length > 0;

  @override
  Set<int> get canonical => units.expand((r) => r.canonical).toSet();

  @override
  bool touchesWith(IntegerRange other) => this.units.any((unit) => unit.touchesWith(other));

  @override
  bool intersectsWith(IntegerRange other) => this.units.any((unit) => unit.intersectsWith(other));

  @override
  bool covers(IntegerRange other) => units.fold(other, (other, unit) => other.difference(unit)).isEmpty;

  @override
  IntegerRange union(IntegerRange other) => switch (other) {
        UnitRange other => this.intersectsWith(other) || this.touchesWith(other) //
            ? units.fold(other, (a, b) => a.union(b))
            : IntegerRange.union([...units, if (other.isNotEmpty) other]),
        UnionRange other => units.followedBy(other.units).union(),
      };

  @override
  IntegerRange intersect(IntegerRange other) => other.isEmpty //
      ? IntegerRange.empty
      : units.map((unit) => unit.intersect(other)).union();

  @override
  IntegerRange difference(IntegerRange other) => switch (other) {
        UnitRange other => this.units.map((unit) => unit.difference(other)).union(),
        UnionRange other => other.units.fold(this, (result, current) => result.difference(current)),
      };

  @override
  IntegerRange map(List<Conversion> map) => this
      .units //
      .map((unit) => unit.map(map))
      .fold(IntegerRange.empty, (a, b) => a.union(b));

  @override
  String toString() =>
      switch ((units.toList()..sort((a, b) => a.start - b.start)).map((v) => v.toString()).join(" | ")) {
        "" => "∅",
        String v => v,
      };
}

extension RangeExtension on IntegerRange {
  IntegerRange operator &(IntegerRange other) => this.intersect(other);
  IntegerRange operator |(IntegerRange other) => this.union(other);
  IntegerRange operator -(IntegerRange other) => this.difference(other);
}

extension RangeIterableExtension<R extends IntegerRange> on Iterable<IntegerRange> {
  IntegerRange union() => this.fold(IntegerRange.empty, (a, b) => a.union(b));
}
