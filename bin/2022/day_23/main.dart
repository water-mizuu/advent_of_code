import "dart:io";

typedef List2<E> = List<List<E>>;
typedef Point = (int x, int y);
typedef Scan = (Point direction, List<Point> checks);

extension on Point {
  int get x => $1;
  int get y => $2;

  Point add(Point other) => this + other;
  Point operator +(Point other) => (this.x + other.x, this.y + other.y);
}

const bool debug = false;

void displayElves(Set<Point> elves) {
  if (!debug) {
    return;
  }

  int leftMost = elves.reduce((a, b) => a.x < b.x ? a : b).x;
  int rightMost = elves.reduce((a, b) => a.x > b.x ? a : b).x;
  int topMost = elves.reduce((a, b) => a.y < b.y ? a : b).y;
  int bottomMost = elves.reduce((a, b) => a.y > b.y ? a : b).y;

  for (int y = topMost; y <= bottomMost; ++y) {
    for (int x = leftMost; x <= rightMost; ++x) {
      if (elves.contains((x, y))) {
        stdout.write("#");
      } else {
        stdout.write(".");
      }
      stdout.write(" ");
    }
    stdout.writeln();
  }
  stdout.writeln();
}

(Set<Point> newElves, int moveCount) move(Set<Point> elves, int round) {
  const Set<Point> neighbors = {
    (-1, -1), // TL
    (0, -1), // TM
    (1, -1), // TR
    (-1, 0), // ML
    (1, 0), // MR
    (-1, 1), // BL
    (0, 1), // BM
    (1, 1), // BR
  };
  const List<Scan> scans = [
    ((0, -1), [(-1, -1), (0, -1), (1, -1)]), /// North
    ((0, 1), [(-1, 1), (0, 1), (1, 1)]), /// South
    ((-1, 0), [(-1, -1), (-1, 0), (-1, 1)]), /// West
    ((1, 0), [(1, -1), (1, 0), (1, 1)]), /// East
  ];

  /// First half
  Map<Point, Point> propositions = {};
  Map<Point, int> counter = {};

  for (Point elf in elves) {
    if (!neighbors.map(elf.add).any(elves.contains)) {
      /// If none of the neighbor
      continue;
    }

    for (int si = round; si < round + scans.length; ++si) {
      var (Point d, List<Point> checks) = scans[si % scans.length];
      if (checks.map(elf.add).any(elves.contains)) {
        /// If there is an elf here, then continue the scan.
        continue;
      }

      /// Since we've found a suitable place,
      ///   set it as my proposition.
      Point proposition = d + elf;

      propositions[elf] = proposition;
      counter[proposition] = (counter[proposition] ??= 0) + 1;

      break;
    }

    /// If we're here, then it means that we're limited by the
    ///   ~~technology of our time~~ neighbors.
  }

  int moved = 0;
  Set<Point> newElves = {};

  /// Second half
  for (Point elf in elves) {
    if (propositions[elf] case Point proposition) {
      if (counter[proposition] == 1) {
        /// If the elf is the only one, then
        ///   just move them there 4head

        newElves.add(proposition);
        ++moved;

        continue;
      }
    }
    /// If the proposition doesn't exist, or if the counter is not `1`,
    ///   then just add them to their originals.
    newElves.add(elf);
  }

  return (newElves, moved);
}

void part1() {
  List2<String> input = File("bin/2022/day_23/assets/main.txt") //
      .readAsLinesSync()
      .map((r) => r.split(""))
      .toList();

  int rounds = 10;
  Set<Point> elves = {};
  for (int y = 0; y < input.length; ++y) {
    for (int x = 0; x < input[y].length; ++x) {
      if (input[y][x] == "#") {
        elves.add((x, y));
      }
    }
  }

  displayElves(elves);
  for (int i = 0; i < rounds; ++i) {
    var (Set<Point> newElves, _) = move(elves, i);

    elves = newElves;
  }
  displayElves(elves);

  int leftMost = elves.reduce((a, b) => a.x < b.x ? a : b).x;
  int rightMost = elves.reduce((a, b) => a.x > b.x ? a : b).x;
  int topMost = elves.reduce((a, b) => a.y < b.y ? a : b).y;
  int bottomMost = elves.reduce((a, b) => a.y > b.y ? a : b).y;
  int sum = (bottomMost - topMost + 1) * (rightMost - leftMost + 1) - elves.length;

  print(sum);
}

void part2() {
  List2<String> input = File("bin/2022/day_23/assets/main.txt") //
      .readAsLinesSync()
      .map((r) => r.split(""))
      .toList();

  Set<Point> elves = {};
  for (int y = 0; y < input.length; ++y) {
    for (int x = 0; x < input[y].length; ++x) {
      if (input[y][x] == "#") {
        elves.add((x, y));
      }
    }
  }

  displayElves(elves);
  for (int i = 0; ; ++i) {
    var (Set<Point> newElves, int moves) = move(elves, i);
    if (moves == 0) {
      print(i + 1);
      break;
    }
    elves = newElves;
  }
  displayElves(elves);
}

void main() {
  part1();
  part2();
}
