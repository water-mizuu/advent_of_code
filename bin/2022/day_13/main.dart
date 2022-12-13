import "dart:io";

/// The beauty of pattern matching.
/// It literally matches the spec.
bool? compare(Object left, Object right) {
  /// Insert working switch-case here.
  (Object, Object) pair = (left, right);

  if (pair case (int left, int right)) {
    if (left != right) {
      return left < right;
    }
    return null;
  } else if (pair case (List<Object> left, List<Object> right)) {
    for (int i = 0; i < left.length && i < right.length; ++i) {
      /// Compare the smallest.
      if (compare(left[i], right[i]) case bool comparison) {
        return comparison;
      }
    }

    if (left.length == right.length) {
      return null;
    }
    return left.length < right.length;
  } else if (pair case (List<Object> left, int right)) {
    return compare(left, [right]);
  } else if (pair case (int left, List<Object> right)) {
    return compare([left], right);
  } else {
    throw ArgumentError("I do not know how to compare these! (${left.runtimeType}, ${right.runtimeType})");
  }
}
/// I could've just used `jsonDecode`, but meh.
///
/// This is also like a parser-combinator thing but made by hand,
/// which is itself a variant of recursive descent.
(Object parsed, int index)? _parse(String input, [int i = 0]) {
  if (input[i] == "[") {
    if (i + 1 case int i) {
      List<Object> objects = [];

      while (i < input.length - 1 && input[i] != "]") {
        if (_parse(input, i) case (Object element, int index)) {
          objects.add(element);
          i = index;
        } else {
          break;
        }

        if (RegExp(r"\s*,\s*").matchAsPrefix(input, i)?.group(0) case String separator) {
          i += separator.length;
        }
      }

      if (input[i] == "]") {
        return (objects, i + 1);
      }
    }
  } else if (RegExp(r"\d+").matchAsPrefix(input, i)?.group(0) case String span) {
    return (int.parse(span), i + span.length);
  }
}
Object? parse(String input) {
  if (_parse(input) case (Object value, _)) {
    return value;
  }
  return null;
}

void part1() {
  List<String> lines = File("bin/2022/day_13/assets/main.txt").readAsLinesSync();

  List<(Object, Object)> pairs = [];
  List<String> pair = [];
  for (String line in lines) {
    if (line.isNotEmpty) {
      pair.add(line);
    } else if ((parse(pair[0]), parse(pair[1])) case (Object left, Object right)) {
      pairs.add((left, right));
      pair.clear();
    }
  }
  /// This, or rather, the lack of this block, costed me 30 minutes of
  /// wondering why my output was wrong. Because I didn't include the last
  /// pair.
  if ((parse(pair[0]), parse(pair[1])) case (Object left, Object right)) {
    pairs.add((left, right));
    pair.clear();
  }

  int sum = 0;
  for (int i = 0; i < pairs.length; ++i) {
    if (pairs[i] case (Object left, Object right)) {
      /// This might look redundant, but it *is* nullable
      if (compare(left, right) case true) {
        sum += i + 1;
      }
    }
  }

  print(sum);
}

void part2() {
  /// The inputs are supposed to be [[2]] and [[6]],
  /// but it's all the same in the end.
  const int left = 2;
  const int right = 6;

  List<String> lines = File("bin/2022/day_13/assets/main.txt")
      .readAsLinesSync()
      .where((line) => line.isNotEmpty)
      .toList();

  List<Object> packets = [left, right];
  for (String line in lines) {
    if (parse(line) case Object parsed) {
      packets.add(parsed);
    }
  }

  /// There is most likely a more efficient way to do this,
  /// but I like following the script.
  packets.sort((left, right) => compare(left, right) ?? true ? -1 : 1);
  int decoderKey = (packets.indexOf(left) + 1) * (packets.indexOf(right) + 1);

  print(decoderKey);
}

void main() {
  part1();
  part2();
}
