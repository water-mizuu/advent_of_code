import "dart:collection";
import "dart:io";
import "dart:math" as math;

typedef Point3 = (int x, int y, int z);

extension on Point3 {
  int get x => $0;
  int get y => $1;
  int get z => $2;

  Point3 operator +(Point3 other) => (x + other.x, y + other.y, z + other.z);
  // Point3 operator -(Point3 other) => (x - other.x, y - other.y, z - other.z);
}

void part1() {
  const Set<Point3> offsets = {
    (1, 0, 0),
    (-1, 0, 0),
    (0, 1, 0),
    (0, -1, 0),
    (0, 0, 1),
    (0, 0, -1),
  };

  Set<Point3> points = File("bin/2022/day_18/assets/main.txt")
    .readAsLinesSync()
    .map((l) => l.split(",").map(int.parse).toList())
    .map((v) => (v[0], v[1], v[2]))
    .toSet();

  int sum = 0;
  for (Point3 point in points) {
    int surface = offsets
        .where((d) => !points.contains(point + d))
        .length;

    sum += surface;
  }

  print(sum);
}

void part2() {
  const Set<Point3> offsets = {
    (1, 0, 0),
    (-1, 0, 0),
    (0, 1, 0),
    (0, -1, 0),
    (0, 0, 1),
    (0, 0, -1),
  };

  Set<Point3> points = File("bin/2022/day_18/assets/main.txt")
    .readAsLinesSync()
    .map((l) => l.split(",").map(int.parse).toList())
    .map((v) => (v[0], v[1], v[2]))
    .toSet();

  /// Find the leftmost possible surface.
  int min = points
      .map((v) => [v.$0, v.$1, v.$2].reduce(math.min))
      .reduce(math.min) - 1;

  /// Find the rightmost possible surface.
  int max = points
      .map((v) => [v.$0, v.$1, v.$2].reduce(math.max))
      .reduce(math.max) + 1;

  Point3 start = (min, min, min);

  /// Prepping a breadth first search.
  Queue<Point3> queue = Queue<Point3>()
    ..addLast(start);

  /// We only save points that we've seen coming from
  ///   a specific direction.
  ///
  /// This is important as we may see a cube twice,
  ///   but from a different direction.
  //    □ 🡓
  ///   □ □ ← (Seeing this block from three directions is okay.)
  ///   □ 🡑
  Set<(Point3, Point3)> seen = HashSet()
    ..add(((0, 0, 0), start));

  int sum = 0;
  while (queue.isNotEmpty) {
    Point3 point = queue.removeFirst();

    for (Point3 offset in offsets) {
      if (point + offset case Point3 neighbor && (int x, int y, int z)) {
        /// If we're beyond the bounds of the search,
        ///   ignore this nonexistent "neighbor".
        if (x < min || x > max || y < min || y > max || z < min || z > max) {
          continue;
        }

        if (seen.add((offset, neighbor))) {
          /// If we haven't seen this cube from
          ///   this direction yet, then process.
          if (points.contains(neighbor)) {
            /// If this is a cube in the given set,
            ///   then add its surface.
            sum += 1;
          } else {
            /// Enqueue the three-dimensional neighbor.
            queue.addLast(neighbor);
          }
        }
      }
    }
  }
  print(sum);
}

void main() {
  part1();
  part2();
}
