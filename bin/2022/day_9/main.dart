import "dart:io";
import "dart:math" as math;

const int gridSize = 6;

typedef Move = (String direction, int count);
typedef Point = (int x, int y);

// A more, primitive, approach.
void part1() {
  List<Move> moves = File("bin/day_9/assets/main.txt")
      .readAsLinesSync()
      .map((l) => l.split(" "))
      .map((v) => (v[0], int.parse(v[1])))
      .toList();
  Set<Point> visited = {};

  int headY = 2;
  int headX = 2;

  int tailY = 1;
  int tailX = 1;

  for (Move move in moves) {
    if (move case (String direction, int count)) {
      for (int i = 0; i < count; ++i) {
        if (direction case "U") {
          ++headY;
        } else if (direction case "D") {
          --headY;
        } else if (direction case "L") {
          --headX;
        } else if (direction case "R") {
          ++headX;
        }

        /// Make the tail catch up.
        int distance = math.max((headX - tailX).abs(), (headY - tailY).abs());
        bool aligned = headY == tailY || headX == tailX;
        if (distance > 1) {
          int thresh = aligned ? 1 : 0;

          if (headY - tailY > thresh) {
            ++tailY;
          } else if (tailY - headY > thresh) {
            --tailY;
          }

          if (headX - tailX > thresh) {
            ++tailX;
          } else if (tailX - headX > thresh) {
            --tailX;
          }
        }

        visited.add((tailX, tailY));
      }
    }

  }

  print(visited.length);
}

// Extend part1 into a linked list. Or a list. Any can work.
void part2() {
  List<Move> moves = File("bin/day_9/assets/main.txt")
      .readAsLinesSync()
      .map((l) => l.split(" "))
      .map((v) => (v[0], int.parse(v[1])))
      .toList();
  Set<Point> visited = {};

  List<Point> knots = [
    for (int i = 0; i < 10; ++i) (0, 0)
  ];

  for (Move move in moves) {
    if (move case (String direction, int count)) {
      for (int i = 0; i < count; ++i) {

        /// Move the head according to the moves.
        if (knots.first case (int x, int y)) {
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
          /// Replacing the element in the list, because records
          /// are immutable and object if-case still doesn't work.
          ///
          /// Can't wait though.
          knots[0] = (x, y);
        }

        /// Make each of the knots catch up.
        for (int i = 1; i < knots.length; ++i) {

          /// I think this is a little too... packed?
          /// But it works!
          if ((knots[i - 1], knots[i]) case ((int headX, int headY), (int tailX, int tailY))) {
            /// Chebyshev distance.
            int distance = math.max(
              (headX - tailX).abs(),
              (headY - tailY).abs(),
            );

            /// If we are not adjacent, then we adjust the rope.
            if (distance > 1) {
              bool isAligned = headY == tailY || headX == tailX;
              int threshold = isAligned ? 1 : 0;

              /// I can probably use the direction from the move,
              /// but nah.
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

            /// *sigh* Same thing as above. This physically hurts me.
            knots[i] = (tailX, tailY);
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
