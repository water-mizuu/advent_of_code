import "dart:io";

typedef Point = (int x, int y);
typedef Blizzard = (Point position, String direction);

extension PointMethods on Point {
  int get x => $0;
  int get y => $1;

  Point operator +(Point other) => (x + other.x, y + other.y);
  Point operator -(Point other) => (x - other.x, y - other.y);
}

extension BlizzardMethods on Blizzard {
  Point get position => $0;
  String get direction => $1;
}

Set<Blizzard> iterate(Set<Blizzard> blizzards, Set<Point> walls) {
  Set<Blizzard> newBlizzards = Set();

  for (Blizzard blizzard in blizzards) {
    if (blizzard case (Point position, ("^" || "v") && String direction)) {
      Point change = switch(direction) {
        "^" => (0, -1),
        "v" => (0, 1),
      };
      Point newPosition = position + change;

      if (walls.contains(newPosition)) {
        Point wrappedPosition = walls
              .where((p) => newPosition.x == p.x && newPosition.y != p.y)
              .single
          + change;
        newPosition = wrappedPosition;
      }
      newBlizzards.add((newPosition, direction));
    } else if (blizzard case (Point position, (">" || "<") && String direction)) {
      Point change = switch(direction) {
        ">" => (1, 0),
        "<" => (-1, 0),
      };
      Point newPosition = position + change;

      if (walls.contains(newPosition)) {
        Point wrappedPosition = walls
              .where((p) => newPosition.x != p.x && newPosition.y == p.y)
              .single
          + change;
        newPosition = wrappedPosition;
      }
      newBlizzards.add((newPosition, direction));
    }
  }

  return newBlizzards;
}

((Point start, Point end), Set<Point> board, Set<Blizzard> blizzards, Set<Point> walls) parse(List<String> lines) {
  Set<Point> board = {};
  Set<Blizzard> blizzards = {};
  Set<Point> walls = {};

  Point? start;
  Point? end;
  for (int y = 0; y < lines.length; ++y) {
    for (int x = 0; x < lines[y].length; ++x) {
      Point point = (x, y);

      if (lines[y][x] == "#") {
        walls.add(point);
      }

      if (lines[y][x] == ".") {
        start ??= point;
        end = point;
      }

      if (lines[y][x] case ("^" || "v" || "<" || ">") && String direction) {
        blizzards.add((point, direction));
      }

      if (lines[y][x].trim().isNotEmpty) {
        board.add(point);
      }
    }
  }

  if (start == null || end == null) {
    throw StateError("Empty lines!");
  }

  return ((start, end), board, blizzards, walls);
}

void displayBoard(Set<Blizzard> blizzards, Set<Point> walls, [Point? person]) {
  Map<Point, String> blizzardDisplays = {};
  for (Blizzard blizzard in blizzards) {
    if (blizzard case (Point point, String direction)) {
      if (blizzardDisplays[point] case String saved) {
        if (int.tryParse(saved) case int acc) {
          blizzardDisplays[point] = "${acc + 1}";
        } else {
          blizzardDisplays[point] = "2";
        }
      } else {
        blizzardDisplays[point] = direction;
      }
    }
  }

  Point topLeft = walls.reduce((a, b) => a.x <= b.x && a.y <= b.y ? a : b);
  Point bottomRight = walls.reduce((a, b) => a.x >= b.x && a.y >= b.y ? a : b);

  if (bottomRight - topLeft + (1, 1) case (int width, int height)) {
    for (int y = 0; y < height; ++y) {
      for (int x = 0; x < width; ++x) {
        Point point = (x, y);

        if (person == point) {
          stdout.write("E");
        } else if (blizzardDisplays[point] case String v) {
          stdout.write(v);
        } else if (walls.contains(point)) {
          stdout.write("#");
        } else {
          stdout.write(".");
        }
      }
      stdout.writeln();
    }
  }

}

void part1() {
  const Set<Point> moves = { (0, 1), (-1, 0), (0, 0), (1, 0), (0, -1) };

  List<String> lines = File("bin/2022/day_24/assets/main.txt").readAsLinesSync();
  var ((Point start, Point end), Set<Point> board, Set<Blizzard> blizzards, Set<Point> walls) = parse(lines);

  Set<Point> possible = { start };

  for (int minute = 1; ; ++minute) {
    blizzards = iterate(blizzards, walls);
    /// Get all the points of each blizzard.
    Set<Point> blizzardPoints = blizzards.map((p) => p.$0).toSet();
    /// Set operations instead of explicit structures! Hooray!
    ///   `allowed` is the set of points in the board that are not walls or blizzards
    ///   `nextPossible` is the set of all neighbors & self of each node in `possible` that coincides with allowed.
    Set<Point> allowed = board.difference(walls.union(blizzardPoints));
    Set<Point> nextPossible = possible.expand((c) => moves.map((n) => n + c)).toSet().intersection(allowed);

    if (nextPossible.contains(end)) {
      nextPossible = {end};
      print(minute);
      break;
    }
    possible = nextPossible;
  }
}

void part2() {
  const Set<Point> moves = { (0, 1), (-1, 0), (0, 0), (1, 0), (0, -1) };

  List<String> lines = File("bin/2022/day_24/assets/main.txt").readAsLinesSync();
  var ((Point start, Point end), Set<Point> board, Set<Blizzard> blizzards, Set<Point> walls) = parse(lines);
  Set<Point> possibles = { start };

  int segment = 0;
  for (int minute = 1; ; ++minute) {
    blizzards = iterate(blizzards, walls);
    Set<Point> blizzardPoints = blizzards.map((p) => p.$0).toSet();
    Set<Point> allowed = board.difference(walls.union(blizzardPoints));
    Set<Point> nextPossible = possibles.expand((c) => moves.map((n) => n + c)).toSet().intersection(allowed);

    if (segment == 0) {
      if (nextPossible.contains(end)) {
        nextPossible = {end};
        segment = 1;
      }
    } else if (segment == 1) {
      if (nextPossible.contains(start)) {
        nextPossible = {start};
        segment = 2;
      }
    } else if (segment == 2) {
      if (nextPossible.contains(end)) {
        nextPossible = {end};
        print(minute);
        break;
      }
    }
    possibles = nextPossible;
  }
}

void main() {
  part1();
  part2();
}
