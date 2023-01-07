import "dart:collection";
import "dart:io";
import "dart:math" as math;

typedef Point3 = (int x, int y, int z);

extension on Point3 {
  int get x => $0;
  int get y => $1;
  int get z => $2;

  Point3 operator +(Point3 other) => (x + other.x, y + other.y, z + other.z);
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
    /// The visible surfaces are the ones without a direct neighbor.
    /// So we count those.
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
  Queue<Point3> queue = Queue<Point3>()..addLast(start);
  Set<Point3> seen = HashSet()..add(start);

  /// Set of points that represent the direct
  ///   outer layer of the structure.
  Set<Point3> outerLayer = HashSet();

  /// Set of points that represent the direct
  ///   inner layer of the structure.
  Set<Point3> innerLayer = HashSet();

  while (queue.isNotEmpty) {
    Point3 point = queue.removeFirst();

    for (Point3 offset in offsets) {
      if (point + offset case Point3 neighbor && (int x, int y, int z) 
          when {x, y, z}.every((v) => min <= v && v <= max)) {
        /// If we're beyond the bounds of the search,
        ///   ignore this nonexistent "neighbor".

        if (points.contains(neighbor)) {
          /// If neighbor is a magma cube, then we
          ///   add the point to the outer set.
          outerLayer.add(point);
          /// Also, add the neighbor to the
          ///   inner set.
          innerLayer.add(neighbor);
        } else if (seen.add(neighbor)) {
          /// Since it isn't enqueue the cube
          ///   if it isn't seen before.
          queue.addLast(neighbor);
        }
      }
    }
  }

  int sum = 0;
  for (Point3 point in innerLayer) {
    /// The visible surfaces are the ones without a direct neighbor.
    /// So we count those.
    int surface = offsets
        .where((d) => outerLayer.contains(point + d))
        .length;

    sum += surface;
  }

  print(sum);
}

void main() {
  part1();
  part2();
}
