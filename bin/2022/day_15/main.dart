import "dart:io";
import "dart:math" as math;

typedef Data = (Point sensor, Point beacon);
typedef Point = (int x, int y);
typedef Range = (int low, int high);
typedef Range2d = (Point low, Point high, Point increment);

extension ArithmeticPoint on Point {
  int get x => $0;
  int get y => $1;

  Point operator +(Point other) => (x + other.x, y + other.y);
  Point operator -(Point other) => (x - other.x, y - other.y);
}

extension PointMethods on Point {
  (Point, Point)? extrema(int distance, int level) {
    if (this case (int x, int y)) {
      if ((level - y).abs() case int ry && <= distance) {
        int dx = distance - ry;

        return ((x - dx, level), (x + dx, level));
      }
    }
  }
}

extension MatchGroupExtension on Match {
  List<String> get matches => groups([for (int i = 1; i <= groupCount; ++i) i])
      .whereType<String>()
      .toList();
}

extension RangeMethods on Range {
  int get high => $1;
  int get low => $0;

  int get length => high - low + 1;

  bool includes(Range other) => low <= other.low && high >= other.high;
  bool overlaps(Range other) => !(low > other.high || high < other.low);

  Range clamp(int low, int high) => (this.low.clamp(low, high), this.high.clamp(low, high));
  Range combine(Range other) => (math.min(low, other.low), math.max(high, other.high));

  Set<Range> subtract(Range other) {
    if (!overlaps(other)) {
      return {this};
    }

    Range left = (math.min(low, other.low), other.low - 1);
    Range right = (other.high + 1, math.max(other.high, high));

    return {
      if (left.length > 0) left,
      if (right.length > 0) right,
    };
  }

  Iterable<int> iterable() sync* {
    for (int i = low; i <= high; ++i) {
      yield i;
    }
  }
}

extension IterableExtension on Iterable<Range> {
  Set<Range> subtract(Set<Range> right) => right
      .fold(this, (acc, now) => acc.expand((v) => v.subtract(now)))
      .toSet();

  Set<Range> flatten([num max = double.infinity]) {
    List<Range> combinedRanges = toList();

    bool hasChanged = false;
    do {
      List<Range> cache = [];
      hasChanged = false;

      for (Range range in combinedRanges) {
        bool hasMerged = false;
        for (int i = 0; i < cache.length; ++i) {
          Range combined = cache[i];

          if (combined.includes(range)) {
            hasMerged = true;
          } else if (combined.overlaps(range)) {
            hasMerged = true;

            cache[i] = range.combine(combined);
          }
        }
        if (!hasMerged) {
          cache.add(range);
        } else {
          hasChanged = true;
        }
      }
      combinedRanges = cache;
    } while (hasChanged);

    return combinedRanges.toSet();
  }

  Set<Range> operator -(Set<Range> right) => subtract(right);
}

List<Data> parseData(String name) {
  RegExp parser = RegExp(r"Sensor at x=([-]?\d+), y=([-]?\d+): closest beacon is at x=([-]?\d+), y=([-]?\d+)");

  List<String> lines = File("bin/2022/day_15/assets/$name.txt").readAsLinesSync();
  List<Data> data = [];

  for (String line in lines) {
    if (parser.firstMatch(line)?.matches case List<String> results) {
      if (results.map(int.tryParse).toList() case [int sx, int sy, int bx, int by])  {
        data.add(((sx, sy), (bx, by)));
      }
    }
  }

  return data;
}

int manhattanDistance(Point a, Point b) {
  if ((a, b) case ((int ax, int ay), (int bx, int by))) {
    return (ax - bx).abs() + (ay - by).abs();
  }
}

/// NOTES:
///   With Y as target y,
///   Manhattan distance `dist` = |dx| + |dy|.
///   We can filter out unused beacons.
///   This includes day 4.
void part1() {
  List<Data> data = parseData("main");

  Set<Range> ranges = {};
  Set<Point> beacons = {};

  int yLevel = 2000000;
  for (Data datum in data) {
    if (datum case (Point sensor, Point beacon)) {
      int distance = manhattanDistance(sensor, beacon);

      if (sensor.extrema(distance, yLevel) case ((int lx, _), (int rx, _))) {
        ranges.add((lx, rx));

        if (beacon.y == yLevel) {
          beacons.add(beacon);
        }
      }
    }
  }

  int sum = ranges
          .flatten() //
          .map((v) => v.length)
          .fold(0, (a, b) => a + b) -
      beacons.length;

  print(sum);
}

/// This runs really slow.
/// Like, ***really*** slow.
void part2() {
  List<Data> data = parseData("main");

  int limit = 4000000;
  for (int y = 0; y <= limit; ++y){
    Set<Range> ranges = {};

    for (Data datum in data) {
      if (datum case (Point sensor, Point beacon)) {
        int distance = manhattanDistance(sensor, beacon);
        if (sensor.extrema(distance, y) case ((int lx, _), (int rx, _))) {
          ranges.add((lx, rx).clamp(0, limit));
        }
      }
    }

    Set<Range> union = {(0, limit)}.subtract(ranges);
    if (union.isNotEmpty) {
      int x = union.first.x;

      print(x * 4000000 + y);
      break;
    }
  }
}

void main() {
  part1();
  part2();
}
