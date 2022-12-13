import "dart:collection";
import "dart:io";
import "dart:math" as math;

typedef List2<T> = List<List<T>>;
typedef Point = (int x, int y);
typedef Table = Map<Point, List<Point>>;

/// Compute all the valid moves for each cell.
Table validTransitions(List2<int> grid) {
  // A little trick.
  const List<Point> offsets = [
    (1, 0),
    (0, 1),
    (-1, 0),
    (0, -1),
  ];

  Table table = {};
  for (int y = 0; y < grid.length; ++y) {
    for (int x = 0; x < grid[y].length; ++x) {
      List<Point> next = table[(x, y)] = [];

      for (Point offset in offsets) {
        /// I wonder when functional destructuring will come?
        if (offset case (int dx, int dy)) {
          /// Coordinates of the neighbor.
          int nx = x + dx;
          int ny = y + dy;

          /// If the coordinates are outside the grid,
          if (nx case < 0 || >= grid[y].length) {
            continue;
          }
          if (ny case < 0 || >= grid.length) {
            continue;
          }
          /// or if it's too high up, then ignore it.
          if (grid[ny][nx] - grid[y][x] > 1) {
            continue;
          }

          next.add((nx, ny));
        }
      }
    }
  }

  return table;
}

/// A simple breadth-first search.
/// I didn't bother computing the actual paths, because why.
Iterable<int> solve(List<Point> start, Point target, Table transitions) sync* {
  Queue<(Point point, int length)> queue = Queue();
  Set<Point> seen = {};

  for (Point p in start) {
    queue.addLast((p, 1));
  }

  while (queue.isNotEmpty) {
    if (queue.removeFirst() case (Point point, int length)) {
      if (!seen.add(point)) {
        continue;
      }

      /// If one wonders why this is in an if-statement,
      /// it's because `transition[point]` is nullable.
      if (transitions[point] case List<Point> next) {
        for (Point transition in next) {
          /// If we've found a path to the target, then yield.
          /// But continue.
          if (transition == target) {
            yield length;
          } else {
            queue.add((transition, length + 1));
          }
        }
      }
    }
  }
  /// So much brackets. I hope working irrefutable patterns come soon
}

// Basically a maze.
void part1() {
  List2<String> input = File("bin/2022/day_12/assets/main.txt") //
      .readAsLinesSync()
      .map((v) => v.split(""))
      .toList();
  List2<int> grid = input
      .map((v) => v
          .map((c) => c == "S" ? "a" : c == "E" ? "z" : c)
          .map((c) => c.codeUnits.first)
          .toList())
      .toList();

  /// If anyone has tips how to do this better, maybe
  /// in a more concise way, teach me.
  Point start = [
    for (int y = 0; y < input.length; ++y)
      for (int x = 0; x < input[y].length; ++x)
        if (input[y][x] == "S") (x, y)
  ].single;
  Point target = [
    for (int y = 0; y < input.length; ++y)
      for (int x = 0; x < input[y].length; ++x)
        if (input[y][x] == "E") (x, y)
  ].single;

  Table transitions = validTransitions(grid);
  int minimum = solve([start], target, transitions).reduce(math.min);

  print(minimum);
}

// Basically a multiple start.
void part2() {
  List2<String> input = File("bin/2022/day_12/assets/main.txt") //
      .readAsLinesSync()
      .map((v) => v.split(""))
      .toList();
  List2<int> grid = input
      .map((v) => v
          .map((c) => c == "S" ? "a" : c == "E" ? "z" : c)
          .map((c) => c.codeUnits.first)
          .toList())
      .toList();

  /// The only difference from the first part. Huh.
  List<Point> start = [
    for (int y = 0; y < grid.length; ++y)
      for (int x = 0; x < grid[y].length; ++x)
        if (grid[y][x] == "a".codeUnits.first) (x, y)
  ];
  Point target = [
    for (int y = 0; y < input.length; ++y)
      for (int x = 0; x < input[y].length; ++x)
        if (input[y][x] == "E") (x, y)
  ].single;

  Table transitions = validTransitions(grid);
  int minimum = solve(start, target, transitions).reduce(math.min);

  print(minimum);
}

void main() {
  part1();
  part2();
}
