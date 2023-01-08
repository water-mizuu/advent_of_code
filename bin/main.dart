typedef Point = ({int x, int y});

void main() {
  var point = (x: 30, y: 50);
  var (x: int x, y: int y) = point;

  print(x);
}
