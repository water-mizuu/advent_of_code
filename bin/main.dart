typedef Point = ({int x, int y});

void main() {
  var point = (x: 30, y: 50);
  var (:x, :y) = point;

  print((x, y));
}
