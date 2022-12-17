import "dart:io";

typedef Result<R> = (R? value, String? error);

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

    return compare(left.length, right.length);
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
Result<(Object parsed, int index)> _parse(String input, [int i = 0]) {
  if (input[i] == "[") {
    if (i + 1 case int i) {
      List<Object> objects = [];

      while (i < input.length - 1 && input[i] != "]") {
        if (_parse(input, i) case ((Object element, int _i), null)) {
          objects.add(element);
          i = _i;
        } else {
          break;
        }

        if (RegExp(r"\s*,\s*").matchAsPrefix(input, i)?.group(0) case String separator) {
          i += separator.length;
        }
      }

      if (input[i] == "]") {
        return ((objects, i + 1), null);
      }
      return (null, "Expected a closing delimiter at $i");
    }
  } else if (RegExp(r"\d+").matchAsPrefix(input, i)?.group(0) case String span) {
    return ((int.parse(span), i + span.length), null);
  } else {
    return (null, "Unexpected token ${input[i]}");
  }
}
Result<Object> parse(String input) {
  Result<(Object parsed, int index)> parsed = _parse(input);

  if (parsed case (null, String error)) {
    return parsed;
  }

  if (parsed case ((Object value, _), null)) {
    return (value, null);
  }

  return (null, "Unexpected result");
}

void part1() {
  List<String> lines = File("bin/2022/day_13/assets/main.txt").readAsLinesSync();

  List<(Object, Object)> pairs = [];
  List<String> pair = [];
  for (String line in lines) {
    if (line.isNotEmpty) {
      pair.add(line);
    } else {
      if (parse(pair[0]) case (Object left, null)) {
        if (parse(pair[1]) case (Object right, null)) {
          pairs.add((left, right));
          pair.clear();
        }
      }
    }
  }
  /// This, or rather, the lack of this block, costed me 30 minutes of
  /// wondering why my output was wrong. Because I didn't include the last
  /// pair.
  if (parse(pair[0]) case (Object left, null)) {
    if (parse(pair[1]) case (Object right, null)) {
      pairs.add((left, right));
      pair.clear();
    }
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
  const List<List<int>> left = [[2]];
  const List<List<int>> right = [[6]];

  List<String> lines = File("bin/2022/day_13/assets/main.txt")
      .readAsLinesSync()
      .where((line) => line.isNotEmpty)
      .toList();

  List<Object> packets = [left, right];
  for (String line in lines) {
    if (parse(line) case (Object parsed, null)) {
      packets.add(parsed);
    }
  }

  int leftIndex = 1;
  int rightIndex = 1;
  for (int i = 0; i < packets.length; ++i) {
    if (compare(left, packets[i]) case false) {
      ++leftIndex;
    }
    if (compare(right, packets[i]) case false) {
      ++rightIndex;
    }
  }

  int decoderKey = leftIndex*rightIndex;

  print(decoderKey);
}

void main() {
  part1();
  part2();

  (String? v1, int? v2) values = (null, 3);
  switch (values) {
    case (String v, null):
      print(v);
      break;
    case (null, int v):
      print(v);
      break;
  }
}
