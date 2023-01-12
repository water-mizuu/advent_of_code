import "dart:io";

int priority(String c) {
  int unit = c.codeUnitAt(0);
  if (64 + 1 <= unit && unit <= 64 + 26) {
    return 26 + unit - 64;
  } else if (96 + 1 <= unit && unit <= 96 + 26) {
    return unit - 96;
  } else {
    return 0;
  }
}

void part1() {
  List<String> lines = File("bin/2022/day_03/assets/main.txt").readAsLinesSync();
  int scores = lines
    // Split the string in half using some cursed regex
    .map((v) => v.split(RegExp("(?<=.{${v.length ~/ 2}})(?=.{${v.length ~/ 2}})")))
    // Put the characters into a tuple of sets (hooray for experimental features!)
    .map((v) => (v[0].split("").toSet(), v[1].split("").toSet()))
    // Get their intersections and combine them.
    .expand((v) => v.$0.intersection(v.$1))
    // Get the priorities, then sum.
    .fold(0, (a, b) => a + priority(b));

  print(scores);
}

void part2() {
  List<String> lines = File("bin/2022/day_03/assets/main.txt").readAsLinesSync();
  int scores = lines
      // Group the lines into three in the most verbose way possible.
      .fold([<String>[]],
            (a, b) => a.last.length == 3
                ? [...a, [b]]
                : [...a.sublist(0, a.length - 1), [...a.last, b]])
      // Get the common letters in each group.
      .expand((g) => g
          .map((v) => v.split("").toSet())
          .reduce((a, b) => a.intersection(b)))
      // Get the priorities, then sum.
      .fold(0, (a, b) => a + priority(b));

  print(scores);
}

void main() {
  part1();
  part2();
}
