import "dart:io";
import "dart:math";

typedef List2<T> = List<List<T>>;

List2<int> readInput() {
  List2<int> list = [
    for (String line in File("bin/2022/day_08/assets/main.txt").readAsLinesSync())
      [for (String c in line.split("")) int.parse(c)]
  ];

  return list;
}


void part1() {
  List2<int> grid = readInput();
  Set<(int, int)> visible = {};

  for (int y = 0; y < grid.length; ++y) {
    for (int x = 0; x < grid.length; ++x) {
      List<bool> blockedDirections = [false, false, false, false];

      /// Check above visibility
      for (int y_ = y - 1; y_ >= 0; --y_) {
        if (grid[y_][x] >= grid[y][x]) {
          blockedDirections[0] = true;
          break;
        }
      }

      /// Check below visibility
      for (int y_ = y + 1; y_ < grid.length; ++y_) {
        if (grid[y_][x] >= grid[y][x]) {
          blockedDirections[1] = true;
          break;
        }
      }

      /// Check left visibility
      for (int x_ = x - 1; x_ >= 0; --x_) {
        if (grid[y][x_] >= grid[y][x]) {
          blockedDirections[2] = true;
          break;
        }
      }

      /// Check right visibility
      for (int x_ = x + 1; x_ < grid[y].length; ++x_) {
        if (grid[y][x_] >= grid[y][x]) {
          blockedDirections[3] = true;
          break;
        }
      }

      if (blockedDirections.any((b) => !b)) {
        visible.add((y, x));
      }
    }
  }

  print(visible.length);
}

void part2() {
  List2<int> grid = readInput();
  List2<int> scores = [for (List<int> row in grid) [for (int _ in row) 0]];

  for (int y = 0; y < grid.length; ++y) {
    for (int x = 0; x < grid.length; ++x) {
      List<int> directionalSum = [0, 0, 0, 0];

      /// Check above visibility
      for (int y_ = y - 1; y_ >= 0; --y_) {
        directionalSum[0]++;
        if (grid[y_][x] >= grid[y][x]) {
          break;
        }
      }

      /// Check below visibility
      for (int y_ = y + 1; y_ < grid.length; ++y_) {
        directionalSum[1]++;
        if (grid[y_][x] >= grid[y][x]) {
          break;
        }
      }

      /// Check left visibility
      for (int x_ = x - 1; x_ >= 0; --x_) {
        directionalSum[2]++;
        if (grid[y][x_] >= grid[y][x]) {
          break;
        }
      }

      /// Check right visibility
      for (int x_ = x + 1; x_ < grid[y].length; ++x_) {
        directionalSum[3]++;
        if (grid[y][x_] >= grid[y][x]) {
          break;
        }
      }

      scores[y][x] = directionalSum.reduce((a, b) => a * b);
    }
  }

  print(scores.expand((v) => v).reduce(max));
}

void main() {
  part1();
  part2();
}
