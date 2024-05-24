import "dart:io";

///
/// Just a wee bit of a hack.
///
class Box {
  const Box(this.value);
  final int value;

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  String toString() => "$value";
}

void part1() {
  List<String> lines = File("bin/2022/day_20/assets/main.txt").readAsLinesSync();
  List<Box> normalized = lines.map(int.parse).map(Box.new).toList();
  int length = normalized.length;

  /// Since we need to run them by order, keep track of the indices
  ///   By keeping a copy.
  for (Box boxed in normalized.toList()) {
    int index = normalized.indexOf(boxed);

    normalized
      ..removeAt(index)
      ..insert((index + boxed.value) % (length - 1), boxed);
  }

  int zeroIndex = normalized.indexWhere((b) => b.value == 0);
  int sum = normalized[(zeroIndex + 1000) % length].value +
      normalized[(zeroIndex + 2000) % length].value +
      normalized[(zeroIndex + 3000) % length].value;

  print(sum);
}

void part2() {
  int decryptionKey = 811589153;
  List<String> lines = File("bin/2022/day_20/assets/main.txt").readAsLinesSync();
  List<Box> normalized = lines.map(int.parse).map((v) => decryptionKey * v).map(Box.new).toList();

  /// Since we need to run them by order, keep track of the indices
  ///   By keeping a copy.
  List<Box> copy = normalized.toList();
  int length = normalized.length;

  for (int i = 0; i < 10; ++i) {
    for (int i = 0; i < copy.length; ++i) {
      int index = normalized.indexOf(copy[i]);

      normalized
        ..removeAt(index)
        ..insert((index + copy[i].value) % (length - 1), copy[i]);
    }
  }

  int zeroIndex = normalized.indexWhere((b) => b.value == 0);
  int sum = normalized[(zeroIndex + 1000) % length].value +
      normalized[(zeroIndex + 2000) % length].value +
      normalized[(zeroIndex + 3000) % length].value;

  print(sum);
}

void main() {
  part1();
  part2();
}
