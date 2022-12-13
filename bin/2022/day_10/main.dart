import "dart:io";

void part1() {
  List<String> commands = File("bin/day_10/assets/main.txt").readAsLinesSync();
  /// One action equals one cycle.
  List<(String, Object?)> actions = [];

  for (String command in commands) {
    /// Since we need to wait for a whole cycle,
    /// Just add a dummy no-op.
    if (command.split(" ") case ["addx", String amount]) {
      int value = int.parse(amount);

      actions
        ..add(("noop", null))
        ..add(("addx", value));
    } else if (command case "noop") {
      actions.add(("noop", null));
    }
  }


  int sum = 0;
  int register = 1;
  for (int c = 0; c < actions.length; ++c) {
    /// During the cycle.
    if ((c + 1) % 40 == 20) {
      sum += register * (c + 1);
    }

    /// After the cycle.
    if (actions[c] case ("addx", int value)) {
      register += value;
    }
  }

  print(sum);
}

void part2() {
  List<String> commands = File("bin/day_10/assets/main.txt").readAsLinesSync();
  /// One action equals one cycle.
  List<(String, Object?)> actions = [];

  for (String command in commands) {
    /// Since we need to wait for a whole cycle,
    /// Just add a dummy no-op.
    if (command.split(" ") case ["addx", String amount]) {
      int value = int.parse(amount);

      actions
        ..add(("noop", null))
        ..add(("addx", value));
    } else if (command case "noop") {
      actions.add(("noop", null));
    }
  }

  int x = 1;
  StringBuffer buffer = StringBuffer();
  for (int c = 0; c < actions.length; ++c) {
    /// During the cycle.

    /// If the current clock is within the window of the register,
    /// Then draw it as lit.

    if (c % 40 case == x - 1 || == x || == x + 1) {
      buffer.write("█");
    } else {
      buffer.write(" ");
    }
    if ((c + 1) % 40 == 0) {
      buffer.writeln();
    }

    // After the cycle.
    if (actions[c] case ("addx", int value)) {
      x += value;
    }
  }

  print(buffer);
}

void main() {
  part1();
  part2();

  ({int x, int y}) point = (x: 3, y: 5);
  print(point.x);
}
