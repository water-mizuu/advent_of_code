import "dart:io";

void part1() {
  const Map<String, int> scores = {
    "A": 1, "X": 1,
    "B": 2, "Y": 2,
    "C": 3, "Z": 3,
  };
  List<String> lines = File("bin/day_2/assets/main.txt").readAsLinesSync();

  int totalScore = 0;
  for (String line in lines) {
    if (line.split(" ") case [String left, String right]) {
      int scoreLeft = scores[left] ?? 0;
      int scoreRight = scores[right] ?? 0;

      int result = (scoreLeft - scoreRight) % 3;
      bool win = result == 2;
      bool draw = result == 0;

      int resultingScore = win ? 6 : draw ? 3 : 0;
      totalScore += resultingScore + scoreRight;
    }
  }
  print(totalScore);
}

void part2() {
  const Map<String, int> scores = {
    "A": 1,
    "B": 2,
    "C": 3,
  };
  const Map<String, int> shifts = {
    "X": -1,
    "Y": 0,
    "Z": 1,
  };
  List<String> lines = File("bin/day_2/assets/main.txt").readAsLinesSync();

  int totalScore = 0;
  for (String line in lines) {
    if (line.split(" ") case [String left, String right]) {
      int shift = shifts[right] ?? 0;
      int decidedScore = (shift + 1) * 3; // X = 0, Y = 3, Z = 6

      int scoreLeft = scores[left] ?? 0;
      int scoreRight = (scoreLeft + shift - 1) % 3 + 1;

      totalScore += decidedScore + scoreRight;
    }
  }

  print(totalScore);
}

void main() {
  part1();
  part2();
}
