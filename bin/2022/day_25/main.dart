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
    int value = switch(digit) {
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

    if (mod == 0) {
      chars.add("0");
    } else if (mod == 1) {
      chars.add("1");
    } else if (mod == 2) {
      chars.add("2");
    } else if (mod == 3) {
      chars.add("=");
      number += 1;
    } else if (mod == 4) {
      chars.add("-");
      number += 1;
    }
  }

  return chars.reversed.join();
}

void part1() {
  int sum = File("bin/2022/day_25/assets/main.txt")
      .readAsLinesSync()
      .map(convertFromSnafu)
      .reduce((a, b) => a + b);

  print(convertToSnafu(sum));
}

void main() {
  part1();
}
