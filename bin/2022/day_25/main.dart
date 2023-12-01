import "dart:io";
import "dart:math";

extension on int {
  (int, int) divMod(int right) => (this ~/ right, this % right);
}

int convertFromSnafu(String input) {
  int sum = 0;
  List<String> reversed = input.split("").reversed.toList();
  for (int i = 0; i < reversed.length; ++i) {
    String digit = reversed[i];
    int value = switch (digit) {
      "-" => -1,
      "=" => -2,
      _ => int.parse(digit),
    };

    sum += value * pow(5, i).toInt();
  }

  return sum;
}

String convertToSnafu(int input) {
  List<String> chars = [];

  int number = input;
  while (number > 0) {
    var (int _number, int mod) = number.divMod(5);
    number = _number;

    String character = switch (mod) {
      (>= 0) && (< 3) => "$mod",
      3 => "=",
      4 || _ => "-",
    };
    chars.add(character);

    int increment = switch (mod) {
      (>= 0) && (< 3) => 0,
      _ => 1,
    };
    number += increment;
  }

  return chars.reversed.join();
}

void part1() {
  int sum = File("bin/2022/day_25/assets/main.txt").readAsLinesSync().map(convertFromSnafu).reduce((a, b) => a + b);

  print(convertToSnafu(sum));
}

void main() {
  part1();
}
