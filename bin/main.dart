import "dart:math";

void main() {
  int value = Random().nextInt(3);
  String conversion = switch (value) {
    0 => "Zero",
    1 => "One",
    _ => throw Error(),
  };
  print(conversion);
}
