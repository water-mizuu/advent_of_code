import "dart:io";

typedef List2<T> = List<List<T>>;
typedef Operation = (String operator, Object left, Object right);
typedef ParseResult = (Object operationOrValue, int nextIndex);
typedef Test = bool Function(int);
/// Considering the purpose of records, I might need to
/// turn this into a class.
typedef Monkey = ({
  int id,
  List<int> items,
  Operation operation,
  Test test,
  int modulus,
  int ifTrue,
  int ifFalse,
});

/// An abstract class filled with all the functions needed in the
/// over-engineered parser. Honestly expected more complicated operations
/// in part 2.
abstract class Parser {
  static int? parseMonkeyId(String line) {
    if (RegExp(r"Monkey (\d+)").firstMatch(line)?.group(1) case String idString) {
      if (int.tryParse(idString) case int id) {
        return id;
      }
    }
  }

  static List<int>? parseItems(String line) {
    if (RegExp("Starting items: (.*)").firstMatch(line)?.group(1) case String values) {
      List<String> commaSeparated = values.split(",");

      return commaSeparated.map(int.parse).toList();
    }
  }

  static Iterable<Object> tokenize(String line) sync* {
    int i = 0;

    while (i < line.length) {
      if (line.startsWith(RegExp(r"\s"), i)) {
        i += 1;

        continue;
      } else if (line.startsWith("old", i)) {
        yield "old";

        i += 3;
      } else if (line.startsWith(RegExp("[+-/*=]"), i)) {
        yield line[i];

        i += 1;
      } else if (RegExp(r"\d+").matchAsPrefix(line, i)?.group(0) case String number) {
        yield int.parse(number);

        i += number.length;
      } else {
        print("Unknown what to do at position $i '${line.substring(i)}'");

        // Ensure termination.
        i += 1;
      }
    }
  }

  static ParseResult? parseAtomic(List<Object> tokens, int i) {
    if (tokens[i] case int value) {
      return (value, i + 1);
    }

    if (tokens[i] case "old") {
      return ("old", i + 1);
    }
  }

  static ParseResult? parseMultiplication(List<Object> tokens, int i) {
    if (parseAtomic(tokens, i) case (Object left, int i)) {
      while (i < tokens.length && {"*", "/"}.contains(tokens[i])) {
        if (tokens[i] case String operation) {
          if (parseAtomic(tokens, i + 1) case (Object right, int j)) {
            left = (operation, left, right);

            i = j;
          }
        }
      }

      return (left, i);
    }
  }

  static ParseResult? parseAddition(List<Object> tokens, int i) {
    if (parseMultiplication(tokens, i) case (Object left, int i)) {
      while (i < tokens.length && {"+", "-"}.contains(tokens[i])) {
        if (tokens[i] case String operation) {
          if (parseMultiplication(tokens, i + 1) case (Object right, int j)) {
            left = (operation, left, right);

            i = j;
          }
        }
      }

      return (left, i);
    }
  }

  static int _executeOperation(Object op, {required int old}) {
    if (op case ("+", Object left, Object right)) {
      return _executeOperation(left, old: old) + _executeOperation(right, old: old);
    }
    if (op case ("*", Object left, Object right)) {
      return _executeOperation(left, old: old) * _executeOperation(right, old: old);
    }
    if (op case int value) {
      return value;
    }
    if (op case "old") {
      return old;
    }

    throw UnsupportedError(op.toString());
  }

  static int executeOperation(Operation operation, {required int old}) => _executeOperation(operation, old: old);

  static Operation? parseOperation(String line) {
    if (RegExp("Operation: new = (.*)").firstMatch(line)?.group(1) case String equation) {
      List<Object> tokens = tokenize(equation).toList();

      if (parseAddition(tokens, 0) case (Operation root, _)) {
        return root;
      }
    }
  }

  static int? parseTest(String line) {
    if (RegExp(r"Test: divisible by (\d+)").firstMatch(line)?.group(1) case String number) {
      if (int.tryParse(number) case int divisor) {
        return divisor;
      }
    }
  }

  static int? parseIfTrue(String line) {
    if (RegExp(r"If true: throw to monkey (\d+)").firstMatch(line)?.group(1) case String number) {
      if (int.tryParse(number) case int id) {
        return id;
      }
    }
  }

  static int? parseIfFalse(String line) {
    if (RegExp(r"If false: throw to monkey (\d+)").firstMatch(line)?.group(1) case String number) {
      if (int.tryParse(number) case int id) {
        return id;
      }
    }
  }

  static Monkey? parseMonkey(List<String> monkeyLines) {
    Iterator<String> iterator = monkeyLines.iterator;
    iterator.moveNext();

    if (parseMonkeyId(iterator.current) case int id) {
      iterator.moveNext();
      if (parseItems(iterator.current) case List<int> items) {
        iterator.moveNext();
        if (parseOperation(iterator.current) case Operation operation) {
          iterator.moveNext();
          if (parseTest(iterator.current) case int test) {
            iterator.moveNext();
            if (parseIfTrue(iterator.current) case int ifTrue) {
              iterator.moveNext();
              if (parseIfFalse(iterator.current) case int ifFalse) {
                iterator.moveNext();

                return (
                  id: id,
                  items: items,
                  operation: operation,
                  test: (v) => v % test == 0,
                  modulus: test,
                  ifTrue: ifTrue,
                  ifFalse: ifFalse,
                );
              }
            }
          }
        }
      }
    }
  }

  static List<Monkey> parseMonkeys() {
    List<String> lines = File("bin/2022/day_11/assets/main.txt").readAsLinesSync();
    List2<String> batches = batchInput(lines);
    List<Monkey> monkeys = batches.map(parseMonkey).whereType<Monkey>().toList();

    return monkeys;
  }

  static List2<String> batchInput(List<String> lines) {
    List2<String> batches = [];
    List<String> currentBatch = [];
    for (int i = 0; i < lines.length; ++i) {
      if (lines[i].trim().isEmpty) {
        batches.add(currentBatch);
        currentBatch = [];

        continue;
      }

      currentBatch.add(lines[i].trim());
    }

    if (currentBatch.isNotEmpty) {
      batches.add(currentBatch);
    }

    return batches;
  }
}

void part1() {
  List<Monkey> monkeys = Parser.parseMonkeys();
  List<int> inspects = [for (int i = 0; i < monkeys.length; ++i) 0];
  int rounds = 20;

  for (int i = 0; i < rounds; ++i) {
    for (Monkey monkey in monkeys) {
      while (monkey.items.isNotEmpty) {
        ++inspects[monkey.id];
        int item = monkey.items.removeAt(0);

        int multiplied = Parser.executeOperation(monkey.operation, old: item);
        int bored = multiplied ~/ 3;

        monkeys[monkey.test(bored) ? monkey.ifTrue : monkey.ifFalse].items.add(bored);
      }
    }
  }

  inspects.sort((a, b) => b - a);
  print(inspects[0] * inspects[1]);
}

/// Notes:
///   I have tried modulo-ing every input before processing, but it de-synchronizes
///   after each iteration.
///
///   Each modulus is co-prime.
///   Each modulus is prime.
///   Modular arithmetic rules show how to reduce large numbers.
void part2() {
  List<Monkey> monkeys = Parser.parseMonkeys();
  int lcm = monkeys.map((v) => v.modulus).reduce((a, b) => a * b);

  List<int> inspects = [for (int i = 0; i < monkeys.length; ++i) 0];
  int rounds = 10000;

  for (int i = 0; i < rounds; ++i) {
    for (Monkey monkey in monkeys) {
      while (monkey.items.isNotEmpty) {
        ++inspects[monkey.id];
        int modded = monkey.items.removeAt(0) % lcm;


        int multiplied = Parser.executeOperation(monkey.operation, old: modded);
        int next = monkey.test(multiplied) ? monkey.ifTrue : monkey.ifFalse;

        monkeys[next].items.add(multiplied);
      }
    }
  }

  inspects.sort((a, b) => b - a);
  print(inspects[0] * inspects[1]);
}

void main() {
  part1();
  part2();
}
