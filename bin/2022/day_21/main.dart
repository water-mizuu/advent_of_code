import "dart:collection";
import "dart:io";

/// A kind of hack union type.
///   It's either an operation `((String | num) left, String op, (String | num) right)`
///   or a value `num value`
typedef Definition = ((Object left, String op, Object right)?, num? value);

(String name, Definition definition)? parse(String line) {
  if (RegExp(r"(\S+): (.*)").firstMatch(line)?.groups([1, 2]) case [String name, String rest]) {
    if (RegExp(r"(\S+) (.) (\S+)").firstMatch(rest)?.groups([1, 2, 3]) case [String l, String o, String r]) {
      return (name, ((l, o, r), null));
    } else if (RegExp(r"(\d+)").firstMatch(rest)?.groups([1]) case [String value]) {
      return (name, (null, num.parse(value)));
    }
  }
}

num evaluate(Definition definition, Map<String, Definition> environment) {
  /// Pattern matching?
  if (definition case ((num left, String op, num right), == null)) {
    if (op == "+") {
      return left + right;
    } else if (op == "-") {
      return left - right;
    } else if (op == "*") {
      return left * right;
    } else if (op == "/") {
      return left / right;
    }
  } else if (definition case ((String l, String op, num right), == null)) {
    num left = evaluate(environment[l]!, environment);

    return evaluate(((left, op, right), null), environment);
  } else if (definition case ((num left, String op, String r), == null)) {
    num right = evaluate(environment[r]!, environment);

    return evaluate(((left, op, right), null), environment);
  } else if (definition case ((Object l, String op, Object r), == null)) {
    num left = evaluate(environment[l]!, environment);
    num right = evaluate(environment[r]!, environment);

    return evaluate(((left, op, right), null), environment);
  } else if (definition case (== null, num value)) {
    return value;
  }
  return 0;
}

void part1() {
  List<String> lines = File("bin/2022/day_21/assets/main.txt").readAsLinesSync();
  Map<String, Definition> environment = {
    for ((String, Definition) line in lines.map(parse).whereType<(String, Definition)>())
      line.$1: line.$2
  };

  print(evaluate(environment["root"]!, environment));
}

/// The magical function that returns the inverse.
Map<String, Definition> generateInverse(String root, Map<String, Definition> environment) {
  Map<String, (String, int)> parentConnection = {};
  Queue<String> queue = Queue();
  Queue<(String, Definition)> stack = Queue()..add((root, environment[root]!));

  /// We get the queue... In order?
  while (stack.isNotEmpty) {
    /// We traverse through the tree, adding it to a queue.
    ///   Breadth first search, because we want to start at the roots.
    var (String name, Definition definition) = stack.removeFirst();
    queue.addFirst(name);
    if (definition case ((String l, String _, String r), == null)) {
      if (environment[l] case Definition definition) {
        parentConnection[l] = (name, -1);
        stack.addLast((l, definition));
      }
      if (environment[r] case Definition definition) {
        parentConnection[r] = (name, 1);
        stack.addLast((r, definition));
      }
    }
  }

  /// a = b + 3
  /// b = a - 3

  /// Now, our queue will have the following characteristic:
  ///   The item at [k] is dependent on items exclusively on or before [k - 1].
  ///   Therefore, we can do some mutation while iteration, and we can be sure
  ///   that the environment gets reduced.
  for (String name in queue) {
    if (environment[name] case (== null, num value)) {
      /// Destructure the connection.
      var (String parentName, int location) = parentConnection[name]!;
      if (environment[parentName] case ((Object left, String op, Object right), == null)) {
        /// -1 shows left, 1 shows right.
        if (location == -1) {
          environment[parentName] = ((value, op, right), null);
        } else if (location == 1) {
          environment[parentName] = ((left, op, value), null);
        }
        environment.remove(name);
      }
    } else if (environment[name] case Definition definition && ((num _, String _, num _), == null)) {
      /// Since we have an expression that we can evaluate,
      ///   then evaluate.
      num value = evaluate(definition, environment);
      var (String parentName, int location) = parentConnection[name]!;
      if (environment[parentName] case ((Object left, String op, Object right), == null)) {
        if (location == -1) {
          environment[parentName] = ((value, op, right), null);
        } else if (location == 1) {
          environment[parentName] = ((left, op, value), null);
        }
      }

      environment[name] = (null, value);
    }
  }

  /// Now, we build the inverse environment.
  Map<String, Definition> inverses = {};
  for (MapEntry<String, Definition> entry in environment.entries) {
    String key = entry.key;
    Definition value = entry.value;

    /// We set a special case for root. Basically, set the value
    ///   for its left or right.
    if (key == "root") {
      if (value case ((String left, _, num right), == null)) {
        inverses[left] = (null, right);
      } else if (value case ((num left, _, String right), == null)) {
        inverses[right] = (null, left);
      }
      continue;
    }

    if (value case ((String left, String op, num right), == null)) {
      /// Solving for the left,
      switch (op) {
        /// v = l + r; l = v - r
        case "+": inverses[left] = ((key, "-", right), null); break;
        /// v = l - r; l = v + r
        case "-": inverses[left] = ((key, "+", right), null); break;
        /// v = l * r; l = v / r
        case "*": inverses[left] = ((key, "/", right), null); break;
        /// v = l / r; l = v * r
        case "/": inverses[left] = ((key, "*", right), null); break;
      }
    } else if (value case ((num left, String op, String right), == null)) {
      /// Solving for the right,
      switch (op) {
        /// v = l + r; r = v - l
        case "+": inverses[right] = ((key, "-", left), null); break;
        /// v = l - r; r = l - v
        case "-": inverses[right] = ((left, "-", key), null); break;
        /// v = l * r; r = v / l
        case "*": inverses[right] = ((key, "/", left), null); break;
        /// v = l / r; r = l / v
        case "/": inverses[right] = ((left, "/", key), null); break;
      }
    }
  }

  return inverses;
}

/// Solve for one branch of the root.
///   Inverse all the others.
///   Run evaluate on the inverse environment.
void part2() {
  List<String> lines = File("bin/2022/day_21/assets/main.txt").readAsLinesSync();
  Map<String, Definition> environment = {
    for ((String, Definition) line in lines.map(parse).whereType<(String, Definition)>())
      line.$1: line.$2
  };
  environment.remove("humn");

  Map<String, Definition> inverse = generateInverse("root", environment);
  print(evaluate(inverse["humn"]!, inverse));
}

void main() {
  part1();
  part2();
}
