import "dart:io";

// Sliding window problem.
void part1() {
  String input = File("bin/2022/day_6/assets/main.txt").readAsStringSync();

  for (int left = 0, right = 4; right < input.length; ++left, ++right) {
    bool found = true;
    Set<String> seen = {};
    for (int i = left; i < right; ++i) {
      if (!seen.add(input[i])) {
        found = false;
        break;
      }
    }

    if (found) {
      print(right);
      break;
    }
  }
}

// Larger sliding window problem.
void part2() {
  String input = File("bin/2022/day_6/assets/main.txt").readAsStringSync();

  for (int left = 0, right = 14; right < input.length; ++left, ++right) {
    bool found = true;
    Set<String> seen = {};
    for (int i = left; i < right; ++i) {
      if (!seen.add(input[i])) {
        found = false;
        break;
      }
    }

    if (found) {
      print(right);
      break;
    }
  }
}

void main() {
  part1();
  part2();
}
