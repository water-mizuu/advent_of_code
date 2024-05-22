// ignore_for_file: unreachable_from_main

import "dart:io";
import "dart:math" as math;

typedef ConversionMap = List<Conversion>;
typedef Conversion = ({UnitRange destination, UnitRange source});

sealed class Range {
  const factory Range.unit(int start, int end) = UnitRange;
  const factory Range.union(List<UnitRange> ranges) = UnionRange;

  static const Range empty = UnionRange([]);

  int get length;

  bool get isEmpty;
  bool get isNotEmpty;

  Set<int> get canonical;

  Iterable<UnitRange> get units;

  bool contains(num value);

  bool intersectsWith(Range other);
  bool covers(Range other);
  Range union(Range other);
  Range intersect(Range other);

  Range difference(Range other);
  Range convertByMap(List<Conversion> conversion);
}

final class UnitRange implements Range {
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

  bool touchesWith(UnitRange other) => this.intersectsWith(other) || this.start == other.end || other.start == this.end;

  @override
  bool intersectsWith(Range other) => switch (other) {
        UnitRange other => !(this.end < other.start || this.start >= other.end),
        UnionRange other => other.units.any(this.intersectsWith),
      };

  @override
  bool covers(Range other) => switch (other) {
        UnitRange other => other.isEmpty || this.start <= other.start && this.end >= other.end,
        UnionRange other => this.covers(other.cell),
      };

  @override
  Range union(Range other) => switch (other) {
        UnitRange other => switch (null) {
            _ when this.intersectsWith(other) || this.touchesWith(other) =>
              Range.unit(math.min(this.start, other.start), math.max(this.end, other.end)),
            _ when this.covers(other) => this,
            _ when other.covers(this) => other,
            null => UnionRange([if (this.isNotEmpty) this, if (other.isNotEmpty) other]),
          },
        UnionRange other => other.units //
            .fold(this, (result, current) => current.isEmpty ? result : result.union(current)),
      };

  @override
  Range intersect(Range other) => switch (other) {
        UnitRange other => switch (null) {
            _ when this.intersectsWith(other) => Range.unit(
                math.max(this.start, other.start),
                math.min(this.end, other.end),
              ),
            null => Range.empty,
          },
        UnionRange other => other.units //
            .map((unit) => this.intersect(unit))
            .union()
      };

  /// Three cases:
  ///   1. A encompasses B:
  ///     A: [        ]
  ///     B:    [   ]
  ///     R: [  ]   [ ]
  ///   2. A intersects with B.
  ///     A: [     ]
  ///     B:    [   ]
  ///     R: [  ]
  ///
  ///     A:       [  ]
  ///     B:    [   ]
  ///     R:       [ ]
  ///   3. A does not intersect with B.

  @override
  Range difference(Range other) => switch (other) {
        UnitRange other => switch (null) {
            _ when this.intersectsWith(other) => Range.union([
                if (Range.unit(this.start, other.start) case UnitRange left when left.isNotEmpty) left,
                if (Range.unit(other.end, this.end) case UnitRange right when right.isNotEmpty) right,
              ]),
            null => this,
          },
        UnionRange other => other.units.fold(this, (result, current) => result.difference(current)),
      };
  @override
  Range convertByMap(List<Conversion> map) {
    Range working = this;
    Range updated = Range.empty;

    for (var conversion in map) {
      if (working.isEmpty) {
        break;
      }

      if (conversion.source.covers(working)) {
        for (var unit in working.units) {
          int length = unit.length;
          int startOffset = unit.start - conversion.source.start;

          working -= unit;
          updated |= Range.unit(
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
        Range intersection = working.intersect(conversion.source);
        Range converted = intersection.convertByMap(map);

        working -= intersection;
        updated |= converted;
      }
    }

    return working | updated;
  }

  @override
  String toString() => "[$start, $end)";
}

final class UnionRange implements Range {
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
  bool intersectsWith(Range other) => this.units.any((unit) => unit.intersectsWith(other));

  @override
  bool covers(Range other) => units.fold(other, (target, unit) => target.difference(unit)).isEmpty;

  @override
  Range union(Range other) => switch (other) {
        UnitRange other => this.intersectsWith(other) //
            ? units.fold(other, (a, b) => a.union(b))
            : UnionRange([...units, if (other.isNotEmpty) other]),
        UnionRange other => units.followedBy(other.units).union(),
      };

  @override
  Range intersect(Range other) => other.isEmpty //
      ? Range.empty
      : units.map((unit) => unit.intersect(other)).union();

  @override
  Range difference(Range other) => switch (other) {
        UnitRange other => this.units.map((unit) => unit.difference(other)).union(),
        UnionRange other => other.units.fold(this, (result, current) => result.difference(current)),
      };

  @override
  Range convertByMap(List<Conversion> map) => this
      .units //
      .map((unit) => unit.convertByMap(map))
      .fold(Range.empty, (a, b) => a.union(b));

  @override
  String toString() =>
      switch ((units.toList()..sort((a, b) => a.start - b.start)).map((v) => v.toString()).join(" | ")) {
        "" => "∅",
        String v => v,
      };
}

extension RangeExtension on Range {
  Range operator &(Range other) => this.intersect(other);
  Range operator |(Range other) => this.union(other);
  Range operator -(Range other) => this.difference(other);
}

extension<R extends Range> on Iterable<Range> {
  Range union() => this.fold(Range.empty, (a, b) => a.union(b));
}

(List<int> seeds, List<ConversionMap> maps) parse(String path) {
  var input = File(path).readAsStringSync().replaceAll("\r", "");
  var [rawSeeds, ...rawMaps] = input.split("\n\n");

  var seeds = rawSeeds.split(":").last.split(" ").map(int.tryParse).whereType<int>().toList();
  var maps = [
    for (var rawMap in rawMaps)
      [
        for (var line in rawMap.split("\n").skip(1))
          if (line.split(" ").map(int.parse).toList()
              case [
                var destinationStart,
                var sourceStart,
                var length,
              ])
            (
              destination: UnitRange(destinationStart, destinationStart + length),
              source: UnitRange(sourceStart, sourceStart + length),
            ),
      ],
  ];

  return (seeds, maps);
}

int? convertValueByConversion(int from, Conversion conversion) {
  var (
    destination: UnitRange(start: int destinationStart),
    source: UnitRange(start: int sourceStart, end: int sourceEnd)
  ) = conversion;

  if (conversion.source.contains(from)) {
    return from - sourceStart + destinationStart;
  }

  return null;
}

int convertValue(int from, ConversionMap map) {
  for (Conversion conversion in map) {
    if (convertValueByConversion(from, conversion) case int converted) {
      return converted;
    }
  }

  return from;
}

int convertThorough(int value, List<ConversionMap> maps) {
  int converted = value;
  for (ConversionMap map in maps) {
    converted = convertValue(converted, map);
  }

  return converted;
}

void part1() {
  var (List<int> seeds, List<ConversionMap> maps) = parse("bin/2023/day_05/assets/main.txt");

  int? lowest;
  for (int seed in seeds) {
    int converted = convertThorough(seed, maps);

    lowest = math.min(lowest ??= converted, converted);
  }

  print(lowest);
}

void part2() {
  var (List<int> seeds, List<ConversionMap> maps) = parse("bin/2023/day_05/assets/main.txt");
  Range given = [for (int i = 0; i < seeds.length; i += 2) Range.unit(seeds[i], seeds[i] + seeds[i + 1])].union();

  for (var map in maps) {
    given = given.convertByMap(map);
  }

  switch (given) {
    case UnitRange(:var start) || UnionRange(cell: UnitRange(:var start)):
      print(start);
  }
}

void main() {
  part1();
  part2();
}
