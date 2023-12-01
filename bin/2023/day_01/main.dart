import "dart:io";

void part1() {
  List<String> lines = File("bin/2023/day_01/assets/main.txt").readAsLinesSync();

  int total = 0;
  for (String line in lines) {
    List<int> digits = line.split("").map(int.tryParse).whereType<int>().toList();
    int lineSum = digits.first * 10 + digits.last;

    total += lineSum;
  }

  print("The total is $total");
}

List<int> parse(String line, Map<String, int> lexemes) {
  List<int> tokens = <int>[];
  int i = 0;

  outer:
  while (i < line.length) {
    for (var MapEntry<String, int>(key: String lexeme, :int value) in lexemes.entries) {
      if (line.startsWith(lexeme, i)) {
        tokens.add(value);

        /// Apparently, the tokens can overlap. so, we can't skip to the next match.
        i += 1;

        continue outer;
      }
    }

    i += 1;
  }

  return tokens;
}

void part2() {
  const Map<String, int> lexemes = <String, int>{
    "0": 0,
    "1": 1,
    "2": 2,
    "3": 3,
    "4": 4,
    "5": 5,
    "6": 6,
    "7": 7,
    "8": 8,
    "9": 9,
    "zero": 0,
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
  };

  List<String> lines = File("bin/2023/day_01/assets/main.txt").readAsLinesSync();

  int total = 0;
  for (String line in lines) {
    List<int> digits = parse(line, lexemes);

    int lineSum = digits.first * 10 + digits.last;

    total += lineSum;
  }

  print("The total is $total");
}

void main(List<String> args) {
  part1();
  part2();
}
