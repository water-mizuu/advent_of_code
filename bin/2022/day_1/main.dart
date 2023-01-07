import "dart:io";
import "dart:math" as math;

void part1() {
  List<String> lines = File("bin/2022/day_1/assets/input.txt").readAsLinesSync();
  List<int> collected = [];
  int buffer = 0;
  for (String line in lines) {
    if (line.trim() case "") {
      collected.add(buffer);
      buffer = 0;
    }

    if (int.tryParse(line) case int parsed) {
      buffer += parsed;
    }
  }
  if (buffer != 0) {
    collected.add(buffer);
    buffer = 0;
  }

  int max = collected.reduce(math.max);

  print(max);
}

void part2() {
  List<String> lines = File("bin/2022/day_1/assets/input.txt").readAsLinesSync();
  List<int> collected = [];
  int buffer = 0;
  for (String line in lines) {
    if (line.trim() case "") {
      collected.add(buffer);
      buffer = 0;
    }

    if (int.tryParse(line) case int parsed) {
      buffer += parsed;
    }
  }
  if (buffer != 0) {
    collected.add(buffer);
    buffer = 0;
  }

  collected.sort();
  int sum = collected.reversed.take(3).reduce((a, b) => a + b);

  print(sum);
}

void main() {
  part1();
  part2();

}
