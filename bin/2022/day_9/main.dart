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
      bool isAligned = headY == tailY || headX == tailX;
      int threshold = isAligned ? 1 : 0;

      /// Since we're not attached to the head, we need to move *somehow*.
      ///
      /// If we're aligned, we need to move the tail in the direction
      /// where it's at least 2 distance away.
      ///
      /// ┌───┬───┬───┬───┐
      /// │[H]│ 1 │[T]│ 1 │ /// The [T] is aligned and is distance 2 away from [H],
      /// ├───┼───┼───┼───┤ ///   so move it to the direction of the head.
      /// │ 2 │ 1 │ 1 │ 1 │
      /// ├───┼───┼───┼───┤
      /// │ 2 │ 2 │ 2 │ 2 │
      /// ├───┼───┼───┼───┤
      /// │ 3 │ 3 │ 3 │ 3 │
      /// └───┴───┴───┴───┘
      ///         │
      ///         V
      /// ┌───┬───┬───┬───┐
      /// │[H]│[T]│ 1 │ 2 │
      /// ├───┼───┼───┼───┤
      /// │ 1 │ 1 │ 1 │ 2 │
      /// ├───┼───┼───┼───┤
      /// │ 2 │ 2 │ 2 │ 2 │
      /// ├───┼───┼───┼───┤
      /// │ 3 │ 3 │ 3 │ 3 │
      /// └───┴───┴───┴───┘
      ///
      ///
      /// If it's not aligned, then we move both distances.
      /// ┌───┬───┬───┬───┐
      /// │[H]│ 1 │ 1 │ 1 │ /// The [T] is *not* aligned, so we move towards both
      /// ├───┼───┼───┼───┤ ///   directions toward the [H] regardless.
      /// │ 2 │ 1 │[T]│ 1 │
      /// ├───┼───┼───┼───┤
      /// │ 2 │ 1 │ 1 │ 1 │
      /// ├───┼───┼───┼───┤
      /// │ 2 │ 2 │ 2 │ 2 │
      /// └───┴───┴───┴───┘
      ///         │
      ///         V
      /// ┌───┬───┬───┬───┐
      /// │[H]│[T]│ 1 │ 2 │
      /// ├───┼───┼───┼───┤
      /// │ 1 │ 1 │ 1 │ 2 │
      /// ├───┼───┼───┼───┤
      /// │ 2 │ 2 │ 2 │ 2 │
      /// ├───┼───┼───┼───┤
      /// │ 3 │ 3 │ 3 │ 3 │
      /// └───┴───┴───┴───┘
      ///
      /// Coincidentally, this solves the supposed corner case
      /// of part 2.

      if (headY - tailY > threshold) {
        ++tailY;
      } else if (tailY - headY > threshold) {
        --tailY;
      }

      if (headX - tailX > threshold) {
        ++tailX;
      } else if (tailX - headX > threshold) {
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

  int headY = 2;
  int headX = 2;

  int tailY = 1;
  int tailX = 1;

  for (Move move in moves) {
    if (move case (String direction, int count)) {
      for (int i = 0; i < count; ++i) {
        if (moveHead((headX, headY), direction) case (int _headX, int _headY)) {
          headX = _headX;
          headY = _headY;
        }

        /// Make the tail catch up.
        if (moveTail((headX, headY), (tailX, tailY)) case (int _tailX, int _tailY)) {
          visited.add((_tailX, _tailY));

          tailX = _tailX;
          tailY = _tailY;
        }
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
          if ((knots[i - 1], knots[i]) case (Point head, Point tail)) {
            knots[i] = moveTail(head, tail);
          }
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
