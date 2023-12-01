import "dart:io";
import "dart:math" as math;

typedef Move = (String direction, int count);
typedef Point = (int x, int y);

extension on Point {
  Point operator +(Point other) => ($1 + other.$1, $2 + other.$2);
  Point operator -(Point other) => ($1 - other.$1, $2 - other.$2);
}

List<Move> parseInput() {
  return File("bin/2022/day_09/assets/main.txt")
    .readAsLinesSync()
    .map((l) => l.split(" "))
    .map((v) => (v[0], int.parse(v[1])))
    .toList();
}

Point moveHead(Point head, String direction) {
  /// Move the head according to the direction.
  Point result = head + switch (direction) {
    "U" => (0, 1),
    "D" => (0, -1),
    "L" => (-1, 0),
    "R" => (1, 0),
    _ => throw Error(),
  };

  return result;
}

Point moveTail(Point head, Point tail) {
  // var (int hx, int hy) = head;
  var (int tx, int ty) = tail;
  var (int dx, int dy) = head - tail;

  int distance = math.max(dx.abs(), dy.abs());
  if (distance > 1) {
    if (dy > 0) {
      /// If we need to move down, then move down.
      ++ty;
    } else if (dy < 0) {
      /// If we need to move up, then move up.
      --ty;
    }

    if (dx > 0) {
      /// If we need to move right, then move right.
      ++tx;
    } else if (dx < 0) {
      /// If we need to move left, then move left.
      --tx;
    }
  }

  return (tx, ty);
}

/// A more, primitive, approach.
void part1() {
  List<Move> moves = parseInput();
  Set<Point> visited = {};

  Point head = (2, 2);
  Point tail = (1, 1);

  for (Move move in moves) {
    var (String direction, int count) = move;
    for (int i = 0; i < count; ++i) {
      head = moveHead(head, direction);
      tail = moveTail(head, tail);
      visited.add(tail);
    }
  }

  print(visited.length);
}

// Extend part1 into a linked list. Or a list. Any can work.
void part2() {
  List<Move> moves = parseInput();
  Set<Point> visited = {};
  List<Point> knots = [ for (int i = 0; i < 10; ++i) (0, 0) ];

  for (Move move in moves) {
    var (String direction, int count) = move;
    for (int i = 0; i < count; ++i) {
      /// Move the head according to the moves.
      knots.first = moveHead(knots.first, direction);

      /// Make each of the knots catch up.
      for (int i = 1; i < knots.length; ++i) {
        Point head = knots[i - 1];
        Point tail = knots[i];

        knots[i] = moveTail(head, tail);
      }
      visited.add(knots.last);
    }
  }

  print(visited.length);
}

void main() {
  part1();
  part2();
}
