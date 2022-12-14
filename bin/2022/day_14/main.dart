import "dart:io";
import "dart:math" as math;

typedef Point = (int x, int y);

Iterable<Point> generatePath(List<Point> points) sync* {
  for (int i = 0; i < points.length - 1; ++i) {
    if ((points[i], points[i + 1]) case ((int fromX, int fromY), (int toX, int toY))) {
      if ((toX - fromX).sign case int dx && != 0) {
        for (int x = fromX; x != toX + dx; x += dx) {
          yield (x, fromY);
        }
      }
      if ((toY - fromY).sign case int dy && != 0) {
        for (int y = fromY; y != toY + dy; y += dy) {
          yield (fromX, y);
        }
      }
    }
  }
}

void part1() {
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

  int max = particles
      .map((p) => p.$1)
      .reduce(math.max);

  int sand;
  outer:
  for (sand = 0;; ++sand) {
    const List<Point> offset = [(0, 1), (-1, 1), (1, 1)];

    int x = 500;
    int y = 0;
    bool moved = false;
    do {
      moved = false;
      if (y > max) {
        break outer;
      }

      for (Point point in offset) {
        if (point case (int dx, int dy)) {
          if (particles.contains((x + dx, y + dy))) {
            continue;
          }

          moved = true;

          y += dy;
          x += dx;

          break;
        }
      }
    } while (moved);

    particles.add((x, y));

  }
  print(sand);
}

void part2() {
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

  int floor = particles
      .map((p) => p.$1)
      .reduce(math.max) + 2;

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

      for (Point point in offset) {
        if (point case (int dx, int dy)) {
          if (particles.contains((x + dx, y + dy))) {
            continue;
          }

          moved = true;

          y += dy;
          x += dx;

          break;
        }
      }
    } while (moved);

    particles.add((x, y));

  }
  print(sand);
}

void main() {
  part1();
  part2();
}
