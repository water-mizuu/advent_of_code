import "dart:io";

// ignore: comment_references
/// The span should be inclusive at [start], and exclusive at [end].
typedef Span = ({int start, int end});

typedef PointSpan = ({int y, Span x});
typedef Point = ({int y, int x});

typedef Number = ({PointSpan index, int value});
typedef Numbers = List<Number>;

typedef Symbol = Point;
typedef Symbols = Set<Symbol>;

extension PointSpanMethods on PointSpan {
  Iterable<Point> get neighbors sync* {
    for (int y in [y - 1, y, y + 1]) {
      if (y == this.y) {
        yield (y: y, x: x.start - 1);
        yield (y: y, x: x.end);
      } else {
        for (int x_ = x.start - 1; x_ < x.end + 1; ++x_) {
          yield (y: y, x: x_);
        }
      }
    }
  }
}

(Numbers, Symbols) parse(String path) {
  Numbers numbers = [];
  Symbols symbols = {};

  List<String> input = File(path).readAsLinesSync();

  for (var (int y, String line) in input.indexed) {
    List<String> row = line.split("");

    (bool isParsing, int? digits, int? start) isParsingNumber = (false, null, null);
    for (int x = 0; x < row.length; ++x) {
      /// If we are in the process of parsing a number:
      if (isParsingNumber case (true, int digits, int start)) {
        /// We check if the current character is a number.
        if (int.tryParse(row[x]) case int digit) {
          /// If it is, we continue parsing.
          isParsingNumber = (true, digits * 10 + digit, start);
          continue;
        } else {
          /// Else, we stop and push.
          numbers.add((index: (x: (start: start, end: x), y: y), value: digits));
          isParsingNumber = (false, null, null);
        }
      }

      /// If we are not parsing a number, we check if the current character is a number.
      if (int.tryParse(row[x]) case int digit) {
        isParsingNumber = (true, digit, x);
      } else if (row[x] case String char when char != ".") {
        symbols.add((y: y, x: x));
      }
    }

    /// Don't forget to push the last number if there is.
    if (isParsingNumber case (true, int digits, int start)) {
      numbers.add((index: (x: (start: start, end: row.length), y: y), value: digits));
    }
  }

  return (numbers, symbols);
}

void part1() {
  var (Numbers numbers, Symbols symbols) = parse("bin/2023/day_03/assets/main.txt");

  int sum = 0;
  for (var (:PointSpan index, :int value) in numbers) {
    if (index.neighbors.toSet().intersection(symbols).isNotEmpty) {
      sum += value;
    }
  }

  print(sum);
}

void part2() {
  var (Numbers numbers, Symbols symbols) = parse("bin/2023/day_03/assets/main.txt");

  Map<Point, List<int>> adjacency = {for (Point symbol in symbols) symbol: []};
  for (var (:PointSpan index, :int value) in numbers) {
    for (Symbol symbol in index.neighbors.toSet().intersection(symbols)) {
      adjacency[symbol]?.add(value);
    }
  }

  int sum = 0;
  for (List<int> adjacentNumbers in adjacency.values) {
    if (adjacentNumbers.length == 2) {
      sum += adjacentNumbers.reduce((int a, int b) => a * b);
    }
  }

  print(sum);
}

void main() {
  part1();
  part2();
}
