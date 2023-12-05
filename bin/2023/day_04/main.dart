import "dart:io";
import "dart:math";

Iterable<(Set<int> winning, Set<int> given)> parse(String path) sync* {
  List<String> lines = File(path).readAsLinesSync();
  RegExp regex = RegExp(r"Card\s+(\d+):\s+([^\n]+)\s*\|\s*([^\n]+)");

  for (String line in lines) {
    if (regex.matchAsPrefix(line) case RegExpMatch match) {
      var [String _, String winningRaw, String givenRaw] = match.groups([1, 2, 3]).whereType<String>().map((v) => v.trim()).toList();

      Set<int> winning = winningRaw.split(" ").map(int.tryParse).whereType<int>().toSet();
      Set<int> given = givenRaw.split(" ").map(int.tryParse).whereType<int>().toSet();

      yield (winning, given);
    }
  }
}

void part1() {
  int sum = 0;

  for (var (Set<int> winning, Set<int> given) in parse("bin/2023/day_04/assets/main.txt")) {
    sum += pow(2, winning.intersection(given).length - 1).floor();
  }

  print(sum);
}

void part2() {
  List<(Set<int>, Set<int>)> parsed = parse("bin/2023/day_04/assets/main.txt").toList();
  Map<int, int> copies = {
    for (int i = 0; i < parsed.length; ++i) i: 1,
  };
  for (var (int i, (Set<int> winning, Set<int> given)) in parsed.indexed) {
    int wins = winning.intersection(given).length;

    for (int j = 1; j <= wins; ++j) {
      copies[i + j] = copies[i + j]! + copies[i]!;
    }
  }

  int sum = copies.values.reduce((int a, int b) => a + b);

  print("The sum is $sum");
}

void main() {
  part1();
  part2();
}
