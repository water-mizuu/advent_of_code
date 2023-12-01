import "dart:collection";
import "dart:io";
import "dart:math" as math;

typedef List2<E> = List<List<E>>;
typedef List3<E> = List<List2<E>>;
typedef Point = (int x, int y);
typedef Key = (int rockPointer, int actionPointer, String highestProfile);

extension<E> on Iterable<E> {
  Iterable<E> loop() sync* {
    yield* this;
    yield* loop();
  }
}

extension on int {
  (int, int) divmod(int right) => (this ~/ right, this % right);
}

const List3<String> blocks = [
  [
    ["#", "#", "#", "#"],
  ],
  [
    [" ", "#", " "],
    ["#", "#", "#"],
    [" ", "#", " "],
  ],
  [
    [" ", " ", "#"],
    [" ", " ", "#"],
    ["#", "#", "#"],
  ],
  [
    ["#"],
    ["#"],
    ["#"],
    ["#"],
  ],
  [
    ["#", "#"],
    ["#", "#"],
  ],
];

///
/// Helper function that extends the grid whenever needed.
/// This is so we only allocate what we really need.
///
void expandGrid(List2<String> grid, int y) {
  int expandCount = y - grid.length + 1;

  for (int i = 0; i < expandCount; ++i) {
    grid.add(["|", " ", " ", " ", " ", " ", " ", " ", "|"]);
  }
}

///
/// Collision detection, although it seems that this is slow.
/// I have no idea how to improve this.
///
bool collides(List2<String> grid, List2<String> rock, Point location, Point direction) {
  int x = location.$1 + direction.$1;
  int y = location.$2 + direction.$2;

  if (x < 0 || x >= grid[0].length || y < 0 || y >= grid.length) {
    return true;
  }


  for (int gy = y; gy >= y - (rock.length - 1); --gy) {
    for (int gx = x; gx < x + rock[0].length; ++gx) {
      /// Converting between y-inversed grid and y-normal rock
      /// was a struggle. It turned out to be clean in the end though.
      int ry = y - gy; /// The [r]ock [y]
      int rx = gx - x; /// The [r]ock [x]

      if (rock[ry][rx] != " " && grid[gy][gx] != " ") {
        /// Check if the grid is writable.
        return true;
      }
    }
  }

  return false;
}

///
/// Part 1! It's actually just tetris.
///   Good news is I have made an entire tetris game before,
///   so this isn't a struggle.
///
/// (It was.)
///
void part1() {
  Iterable<String> input = File("bin/2022/day_17/assets/main.txt") //
      .readAsStringSync()
      .trim()
      .split("");

  Iterator<List2<String>> rocks = blocks.loop().iterator;
  Iterator<String> actions = input.loop().iterator;

  int rockCount = 2022;
  int highest = 1;

  List2<String> grid = [["+", "-", "-", "-", "-", "-", "-", "-", "+"]];

  for (int i = 0; i < rockCount; ++i) {
    rocks.moveNext();
    List2<String> rock = rocks.current;

    int x = 3;
    int y = highest + rock.length + 2;

    expandGrid(grid, y);

    /// Move left or right
    while (actions.moveNext()) {
      switch (actions.current) {
        case "<":
          /// Move left
          if (!collides(grid, rock, (x, y), (-1, 0))) {
            /// If the move doesn't collide, then move left.
            x -= 1;
          }
          break;
        case ">":
          /// Move right
          if (!collides(grid, rock, (x, y), (1, 0))) {
            /// If the move doesn't collide, then move right.
            x += 1;
          }
          break;
      }

      /// Move down
      if (!collides(grid, rock, (x, y), (0, -1))) {
        y -= 1;
      } else {
        break;
      }
    }

    highest = math.max(highest, y + 1);

    for (int gy = y; gy >= y - (rock.length - 1); --gy) {
      for (int gx = x; gx < x + rock[0].length; ++gx) {
        int ry = y - gy; /// The [r]ock [y]
        int rx = gx - x; /// The [r]ock [x]

        if (rock[ry][rx] != " " && grid[gy][gx] == " ") {
          /// Check if the grid is writable.
          grid[gy][gx] = rock[ry][rx];
        }
      }
    }
  }

  print(highest - 1);
}

List<int> relativePositions(List2<String> grid, int highest) {
  int rowLength = grid[0].length;
  Set<int> xs = { for (int x = 0; x < rowLength; ++x) x };
  List<int> distances = [ for (int x = 0; x < rowLength; ++x) 0 ];

  for (int y = highest - 1; y >= 0; --y) {
    for (int x in {...xs}) {
      if (grid[y][x] != " ") {
        xs.remove(x);
        distances[x] = highest - 1 - y;
      }
    }
  }

  return distances;
}

///
/// Obviously we're not going to run the algorithm for
///   a trillion iterations. So we have to find something.
///   Perhaps a cycle exists?
///
/// (It does!)
///
void part2() {
  List<String> input = File("bin/2022/day_17/assets/main.txt") //
      .readAsStringSync()
      .trim()
      .split("");

  /// For the cache, we cannot use iterators.
  ///   So we have to use indices.
  List3<String> rocks = blocks;
  List<String> actions = input;

  int rockCount = 1000000000000;
  int highest = 1;

  List2<String> grid = [["+", "-", "-", "-", "-", "-", "-", "-", "+"]];

  /// Initialize this to invalid indices for
  ///   logic consistency.
  int pr = -1; /// [p]ointer to [r]ock
  int pa = -1; /// [p]ointer to [a]ction

  /// Keeps track of the first keys that show up.
  ///   Preserves order (important).
  Map<Key, int> cache = LinkedHashMap<Key, int>();
  for (int i = 0; i < rockCount; ++i) {
    /// We're basically simulating Iterator<?>.
    pr = (pr + 1) % rocks.length;
    List2<String> rock = rocks[pr];

    Key key = (pr, pa, relativePositions(grid, highest).join(","));
    if (cache[key] case int first) {
      /// Since it's in the cache already, it means that
      ///   we've seen this state before. (Hooray!)
      int cacheLength = cache.length;

      /// Get the index of the key, which means that the cycle
      ///   starts here.
      int cycleStart = cache.entries.takeWhile((v) => v.key != key).length;
      int cycleSize = cacheLength - cycleStart;

      /// Technically, [highest] is the last height before the cycle began.
      ///   So we can find the height of each cycle by subtracting the
      ///   first saved value.
      int cycleHeight = highest - first;

      /// The excess is like the reverse tail of the cycle, but not the head.
      ///   Imagine the cycle like this:
      ///       [excess] - [cycle] - [remaining]
      ///   this illustration is the key to this. Basically, we're saying that
      ///   the cycle does not start immediately, so we have to account for that.
      int excess = cacheLength - cycleSize;

      var (int quo, int rem) = (rockCount - excess).divmod(cycleSize);
      /// This is the tail part. If we removed the excess and a
      ///   whole number multiple of the cycle, we're left with
      ///   a part of the cycle that ends somewhere in the middle.
      int remaining = cache.values.elementAt(excess + rem) - first;

      /// And finally, put it all together.
      int calculated  = cycleHeight * quo + first + remaining - 1;

      highest = calculated;

      break;
    } else {
      cache[key] = highest;

      /// Position of the current block.
      int x = 3;
      int y = highest + rock.length + 2;

      expandGrid(grid, y);

      /// Move left or right
      for (;;) {
        /// Same thing with [pr]
        pa = (pa + 1) % actions.length;
        switch (actions[pa]) {
          case "<":
            /// Move left

            if (!collides(grid, rock, (x, y), (-1, 0))) {
              /// If the move doesn't collide, then move left.
              x -= 1;
            }
            break;
          case ">":
            /// Move right

            if (!collides(grid, rock, (x, y), (1, 0))) {
              /// If the move doesn't collide, then move right.
              x += 1;
            }
            break;
        }

        /// Move down
        if (!collides(grid, rock, (x, y), (0, -1))) {
          y -= 1;
        } else {
          break;
        }
      }

      highest = math.max(highest, y + 1);

      for (int gy = y; gy >= y - (rock.length - 1); --gy) {
        for (int gx = x; gx < x + rock[0].length; ++gx) {
          int ry = y - gy; /// The [r]ock [y]
          int rx = gx - x; /// The [r]ock [x]

          if (rock[ry][rx] != " " && grid[gy][gx] == " ") {
            /// Check if the grid is writable.
            grid[gy][gx] = rock[ry][rx];
          }
        }
      }
    }
  }

  print(highest);
}

void main() {
  part1();
  part2();
}
