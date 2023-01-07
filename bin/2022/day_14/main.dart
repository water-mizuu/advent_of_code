import "dart:io";
import "dart:math" as math;

typedef Point = (int x, int y);

Iterable<Point> generatePath(List<Point> points) sync* {
  for (int i = 0; i < points.length - 1; ++i) {
    /// Destructure the current point `point[i]`
    ///   and the subsequent next point `point[i + 1]`
    var (int fx, int fy) = points[i];
    var (int tx, int ty) = points[i + 1];
    /// Declare `dx` as the constrained difference of `fx` and `tx`,
    ///   and only execute the loop if it is not 0.
    if ((tx - fx).sign case int dx && != 0) {
      /// Start from `fx`, up to one above `tx`
      for (int x = fx; x != tx + dx; x += dx) {
        yield (x, fy);
      }
    }
    /// Same logic as `dx`, but this time in `dy`.
    if ((ty - fy).sign case int dy && != 0) {
      for (int y = fy; y != ty + dy; y += dy) {
        yield (fx, y);
      }
    }
  }
}

void part1() {
  /// Kind of convoluted way to parse lines with the regular grammar
  /// ```
  ///  line = pair ("->" pair)*
  ///  pair = number "," number
  ///  number = /\d+/
  /// ```
  /// collecting them into a set of tuples.
  Set<Point> particles = File("bin/2022/day_14/assets/main.txt")
      .readAsLinesSync()
      .map((l) => l
          .split("->")
          .map((v) => v
              .split(",")
              .map(int.parse))
          .map((v) => (v.first, v.last))
          .toList())
      .expand((p) => generatePath(p))
      .toSet();

  /// Save the maximum y-coordinate for comparison.
  int max = particles
      .map((p) => p.$1)
      .reduce(math.max);

  /// Without making this more convoluted,
  /// the stop condition had to be put inside the loop.
  int sand;
  outer:
  for (sand = 0;; ++sand) {
    const List<Point> offset = [(0, 1), (-1, 1), (1, 1)];

    int x = 500;
    int y = 0;
    bool moved = false;
    do {
      moved = false;
      /// If we fall into the abyss, then
      /// break the outer loop.
      if (y > max) {
        break outer;
      }

      /// Iterate through each offset, [-1, 1] × [1, 1]
      for (Point point in offset) {
        var (int dx, int dy) = point;
        /// If the potential move is already stored,
        /// then ignore it and move to the next.
        if (particles.contains((x + dx, y + dy))) {
          continue;
        }

        moved = true;

        y += dy;
        x += dx;

        /// Since we finally found a valid move,
        /// break out of the loop.
        break;
      }
    } while (moved);

    /// Solidify the particle by adding it to the
    /// set of collision points.
    particles.add((x, y));

  }
  print(sand);
}

void part2() {
  /// Kind of convoluted way to parse lines with the regular grammar
  /// ```
  ///  line = pair ("->" pair)*
  ///  pair = number "," number
  ///  number = /\d+/
  /// ```
  /// collecting them into a set of tuples.
  Set<Point> particles = File("bin/2022/day_14/assets/main.txt")
      .readAsLinesSync()
      .map((l) => l
          .split("->")
          .map((v) => v
              .split(",")
              .map(int.parse))
          .map((v) => (v.first, v.last))
          .toList())
      .expand((p) => generatePath(p))
      .toSet();

  /// The floor is two units lower than the lowest block.
  int floor = particles
      .map((p) => p.$1)
      .reduce(math.max) + 2;

  /// Keep looping until there's a solid particle at (x=500, y=0).
  int sand;
  for (sand = 0; !particles.contains((500, 0)); ++sand) {
    const List<Point> offset = [(0, 1), (-1, 1), (1, 1)];

    int x = 500;
    int y = 0;
    bool moved = false;
    do {
      moved = false;
      /// If the next is the floor, then don't bother.
      if (y + 1 >= floor) {
        break;
      }

      /// Iterate through each offset, [-1, 1] × [1, 1]
      for (Point point in offset) {
        var (int dx, int dy) = point;
        /// If the potential move is already stored,
        /// then ignore it and move to the next.
        if (particles.contains((x + dx, y + dy))) {
          continue;
        }

        moved = true;

        y += dy;
        x += dx;

        /// Since we finally found a valid move,
        /// break out of the loop.
        break;
      }
    } while (moved);

    /// Solidify the particle by adding it to the
    /// set of collision points.
    particles.add((x, y));

  }
  print(sand);
}

void main() {
  part1();
  part2();
}
