import "dart:io";

typedef Range = (int, int);

extension RangeMethods on Range {
  static Range parse(String input) {
    List<int> integers = input.split("-").map(int.parse).toList();

    return (integers.first, integers.last);
  }

  int get low => $0;
  int get high => $1;

  bool includes(Range other) => low <= other.low && high >= other.high;
  bool overlaps(Range other) => !(low > other.high || high < other.low);
}

/// How many pairs are there which one range covers the other?
void part1() {
  List<String> lines = File("bin/2022/day_4/assets/main.txt").readAsLinesSync();

  int count = 0;
  for (String line in lines) {
    var [String left, String right] = line.split(",");
    Range leftRange = RangeMethods.parse(left);
    Range rightRange = RangeMethods.parse(right);

    if (leftRange.includes(rightRange) || rightRange.includes(leftRange)) {
      ++count;
    }
  }
  print(count);
}

void part2() {
  List<String> lines = File("bin/2022/day_4/assets/main.txt").readAsLinesSync();
  int count = 0;
  for (String line in lines) {
    var [String left, String right] = line.split(",");
    Range leftRange = RangeMethods.parse(left);
    Range rightRange = RangeMethods.parse(right);

    if (leftRange.overlaps(rightRange)) {
      ++count;
    }
  }
  print(count);
}

void main() {
  part1();
  part2();
}
