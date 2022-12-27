import "dart:collection";
import "dart:io";

typedef Point = (int x, int y);
typedef Instruction = Object;

const int directionModulus = 4; // 0 -> RIGHT; 1 -> DOWN; 2 -> LEFT; 3 -> UP

extension on Point {
  int get x => $0;
  int get y => $1;

  Point operator +(Point other) => (x + other.x, y + other.y);
}

extension on ((int x, int y) segment, Face face, int fromDirection, Face fromFace) {
  (int x, int y) get segment => $0;
  Face get face => $1;
  int get fromDirection => $2;
  Face get fromFace => $3;
}

const List<Point> directions = [
  (1, 0),
  (0, 1),
  (-1, 0),
  (0, -1),
];

void part1() {
  String input = File("bin/2022/day_22/assets/test.txt").readAsStringSync().replaceAll("\r", "");

  List<String> parts = input.split("\n\n");
  Iterable<RegExpMatch> matches = RegExp(r"(\d+)([RL]?)").allMatches(parts.last);
  Iterable<Instruction> instructions = matches
      .map((x) => (int.parse(x.group(1)!), x.group(2)))
      .expand((p) => [p.$0, if (p.$1 != null) p.$1!]);

  List<String> lines = parts.first.split("\n");
  Point? position;

  int directionIndex = 0;
  Map<Point, bool> map = Map<Point, bool>();
  Map<int, int> minX = Map<int, int>();
  Map<int, int> maxX = Map<int, int>();
  Map<int, int> minY = Map<int, int>();
  Map<int, int> maxY = Map<int, int>();

  for (int y = 1; y <= lines.length; ++y) {
    String line = lines[y - 1];
    for (int x = 1; x <= line.length; ++x) {
      String character = line[x - 1];
      if (character.trim().isEmpty) {
        continue;
      }

      minX[y] ??= x;
      maxX[y] = x;
      minY[x] ??= y;
      maxY[x] = y;

      Point point = (x, y);
      if (character == "#") {
        map[point] = false;
      } else if (character == ".") {
        map[point] = true;

        position ??= point;
      }
    }
  }

  if (position case Point position) {
    for (Instruction instruction in instructions) {
      if (instruction case int steps) {
        for (int i = 0; i < steps; ++i) {
          Point direction = directions[directionIndex];
          Point next = position + direction;

          if (map[next] case bool? valid) {
            if (valid case null) {
              next = direction == (1, 0) ? (minX[position.y]!, position.y)
                   : direction == (0, 1) ? (position.x, minY[position.x]!)
                   : direction == (-1, 0) ? (maxX[position.y]!, position.y)
                   : direction == (0, -1) ? (position.x, maxY[position.x]!)
                   : throw StateError("Unknown direction $direction");
              valid = map[next];
            }

            if (valid case bool valid) {
              if (!valid) {
                break;
              }

              position = next;
            }
          }
        }
      } else if (instruction case String rotate) {
        directionIndex += {"R": 1, "L": -1}[rotate] ?? 0;
        directionIndex %= directionModulus;
      }
    }
    print(position);
    print(1000 * position.y + 4 * position.x + directionIndex);
  }

}

enum Face { front, back, left, right, top, bottom }

void part2() {
  String input = File("bin/2022/day_22/assets/main.txt").readAsStringSync().replaceAll("\r", "");

  List<String> parts = input.split("\n\n");
  Iterable<RegExpMatch> matches = RegExp(r"(\d+)([RL]?)").allMatches(parts.last);
  Iterable<Instruction> instructions = matches
      .map((x) => (int.parse(x.group(1)!), x.group(2)))
      .expand((p) => [p.$0, if (p.$1 != null) p.$1!]);

  int length = 50;

  List<String> lines = parts.first.split("\n");
  Map<Face, List<Face>> faceNeighbors = {
    Face.front: [Face.right, Face.bottom, Face.left, Face.top],
    Face.back: [Face.left, Face.bottom, Face.right, Face.top],
    Face.left: [Face.front, Face.bottom, Face.back, Face.top],
    Face.right: [Face.back, Face.bottom, Face.front, Face.top],
    Face.top: [Face.right, Face.front, Face.left, Face.back],
    Face.bottom: [Face.right, Face.back, Face.left, Face.front],
  };
  Map<Face, int> faceRotations = {};
  Map<Face, Point> faceSegment = {};
  Map<Point, Map<Point, bool>> segments = {};

  Face face = Face.front;
  Point? position;

  int directionIndex = 0;
  for (int j = 0; j < lines.length ~/ length; ++j) {
    int jFactor = j * length;
    for (int i = 0; i < lines[jFactor].length ~/ length; ++i) {
      int iFactor = i * length;
      Point segment = (i, j);
      Map<Point, bool> segmentContainer = {};

      for (int y = 0; y < length; ++y) {
        String line = lines[jFactor + y];
        for (int x = 0; x < length; ++x) {
          String character = line[iFactor + x];
          if (character.trim().isEmpty) {
            continue;
          }

          Point point = (x, y);
          if (character == "#") {
            segmentContainer[point] = false;
          } else if (character == ".") {
            segmentContainer[point] = true;

            position ??= point;
          }
        }
      }
      if (segmentContainer.isNotEmpty) {
        segments[segment] = segmentContainer;
      }
    }
  }

  if (position case Point position) {
    Queue<(Point, Face, int, Face)> queue = Queue<(Point, Face, int, Face)>()
      ..addLast((segments.keys.first, Face.front, 1, Face.top));
    HashSet<Point> visited = HashSet<Point>()
      ..add(segments.keys.first);

    while (queue.isNotEmpty) {
      (Point, Face, int, Face) current = queue.removeFirst();

      int relativeFrom = current.fromDirection + 2 % 4;
      int offset = (relativeFrom - faceNeighbors[current.face]!.indexOf(current.fromFace)) % 4;

      faceSegment[current.face] = current.segment;
      faceRotations[current.face] = offset;

      for (int i = 0; i < 4; ++i) {
        Point newSegment = current.segment + directions[i];

        if (segments.containsKey(newSegment) && visited.add(newSegment)) {
          queue.addLast((newSegment, faceNeighbors[current.face]![(i - offset) % 4], i, current.face));
        }
      }
    }

    for (Instruction instruction in instructions) {
      if (instruction case int steps) {
        for (int i = 0; i < steps; ++i) {
          Point direction = directions[directionIndex];
          Point newPosition = position + direction;
          int newDirectionIndex = directionIndex;
          Face newFace = face;

          bool? valid = segments[faceSegment[face]!]![newPosition];
          if (valid case null) {
            newFace = faceNeighbors[face]![(directionIndex - faceRotations[face]!) % 4];
            newPosition = position;

            int relativeFrom = (directionIndex + 2) % 4;
            int positionOffset = (faceNeighbors[newFace]!.indexOf(face) - relativeFrom) % 4;
            int offset = faceRotations[newFace]!;
            int rotations = (positionOffset + offset) % 4;

            for (int i = 0; i < rotations; ++i) {
              newDirectionIndex += 1;
              newDirectionIndex %= directionModulus;

              newPosition = (length - 1 - newPosition.y, newPosition.x);
            }

            newPosition = newDirectionIndex == 0 ? (0, newPosition.y)
                        : newDirectionIndex == 1 ? (newPosition.x, 0)
                        : newDirectionIndex == 2 ? (length - 1, newPosition.y)
                        : newDirectionIndex == 3 ? (newPosition.x, length - 1)
                        : throw Exception();
            valid = segments[faceSegment[newFace]]![newPosition];
          }

          if (valid case bool valid) {
            if (!valid) {
              break;
            }

            position = newPosition;
            face = newFace;
            directionIndex = newDirectionIndex;
          }
        }
      } else if (instruction case String rotate) {
        directionIndex += {"R": 1, "L": -1}[rotate] ?? 0;
        directionIndex %= directionModulus;
      }
    }

    if (faceSegment[face] case (int x, int y)) {
      int column = x * length + position.x + 1;
      int row = y * length + position.y + 1;

      print(1000 * row + 4 * column + directionIndex);
    }
  }
}

void main() {
  part1();
  part2();
}
