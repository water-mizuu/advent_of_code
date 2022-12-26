import "dart:io";
import "dart:math";

int convertFromSnafu(String input) {
  Map<String, int> values = {
    "-": -1,
    "=": -2,
  };

  int sum = 0;
  List<String> reversed = input.split("").reversed.toList();
  for (int i = 0; i < reversed.length; ++i) {
    String digit = reversed[i];
    int value = values[digit] ?? int.parse(digit);

    sum += value * pow(5, i).toInt();
  }

  return sum;
}

String convertToSnafu(int input) {
  List<String> chars = [];

  int number = input;
  while (number > 0) {
    int mod = number % 5;

    if (mod case const 0) {
      chars.add("0");
      number ~/= 5;
    } else if (mod case const 1) {
      chars.add("1");
      number ~/= 5;
    } else if (mod case const 2) {
      chars.add("2");
      number ~/= 5;
    } else if (mod case const 3) {
      chars.add("=");
      number ~/= 5;
      number += 1;
    } else if (mod case const 4) {
      chars.add("-");
      number ~/= 5;
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
