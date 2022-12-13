import "dart:io";
import "dart:math" as math;

typedef Move = (String direction, int count);
typedef Point = (int x, int y);

List<Move> parseInput() {
  return File("bin/2022/day_9/assets/main.txt")
    .readAsLinesSync()
    .map((l) => l.split(" "))
    .map((v) => (v[0], int.parse(v[1])))
    .toList();
}

Point moveHead(Point head, String direction) {
  /// Move the head according to the direction.
  if (head case (int x, int y)) {
    /// (Normal == can work, but I like the case. It feels satisfying.)
    if (direction case "U") {
      ++y;
    } else if (direction case "D") {
      --y;
    } else if (direction case "L") {
      --x;
    } else if (direction case "R") {
      ++x;
    }

    return (x, y);
  }
  return head;
}

Point moveTail(Point head, Point tail) {
  if ((head, tail) case ((int headX, int headY), (int tailX, int tailY))) {
    int distance = math.max(
      (headX - tailX).abs(),
      (headY - tailY).abs(),
    );
    if (distance > 1) {
      if (headY - tailY > 0) {
        /// If we need to move down, then move down.
        ++tailY;
      } else if (tailY - headY > 0) {
        /// If we need to move up, then move up.
        --tailY;
      }

      if (headX - tailX > 0) {
        /// If we need to move right, then move right.
        ++tailX;
      } else if (tailX - headX > 0) {
        /// If we need to move left, then move left.
        --tailX;
      }
    }

    return (tailX, tailY);
  }
  return tail;
}

/// A more, primitive, approach.
void part1() {
  List<Move> moves = parseInput();
  Set<Point> visited = {};

  Point head = (2, 2);
  Point tail = (1, 1);

  for (Move move in moves) {
    if (move case (String direction, int count)) {
      for (int i = 0; i < count; ++i) {
        head = moveHead(head, direction);
        tail = moveTail(head, tail);
        visited.add(tail);
      }
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
    if (move case (String direction, int count)) {
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
  }

  print(visited.length);
}

void main() {
  part1();
  part2();
}
