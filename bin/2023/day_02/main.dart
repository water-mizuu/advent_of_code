import "dart:io";
import "dart:math";

enum Color { red, green, blue }

typedef CubePick = ({int count, Color color});
typedef PickGroup = List<CubePick>;
typedef Game = ({int id, List<PickGroup> picks});

List<PickGroup> parseCubes(String input) => [
      for (var group in input.split(";").map((g) => g.trim()))
        [
          for (var pick in group.split(",").map((p) => p.trim()))
            if (pick.split(" ") case [String countRaw, String colorRaw])
              (count: int.parse(countRaw), color: Color.values.firstWhere((Color color) => color.name == colorRaw)),
        ],
    ];

Iterable<Game> parseInput(String path) sync* {
  List<String> rawLines = File(path).readAsLinesSync();
  for (String line in rawLines) {
    /// We match first this schema:
    ///
    /// Game \d+: [^\n]+

    RegExp regex = RegExp(r"Game (\d+): ([^\n]+)");
    if (regex.matchAsPrefix(line) case RegExpMatch match) {
      var [String idRaw, String cubesRaw] = match.groups([1, 2]).whereType<String>().toList();
      int id = int.parse(idRaw);
      List<PickGroup> cubes = parseCubes(cubesRaw);

      yield (id: id, picks: cubes);
    }
  }
}

void part1() {
  const Map<Color, int> limits = {
    Color.red: 12,
    Color.green: 13,
    Color.blue: 14,
  };

  int sum = 0;
  for (var (:int id, :List<PickGroup> picks) in parseInput("bin/2023/day_02/assets/main.txt")) {
    bool isPossible = true;

    for (PickGroup group in picks) {
      for (var (:int count, :Color color) in group) {
        if (count > limits[color]!) {
          isPossible = false;
          break;
        }
      }
    }

    if (isPossible) {
      sum += id;
    }
  }

  print(sum);
}

void part2() {
  int sum = 0;
  for (var (id: _, :List<PickGroup> picks) in parseInput("bin/2023/day_02/assets/main.txt")) {
    Map<Color, int> counts = {
      Color.red: 0,
      Color.green: 0,
      Color.blue: 0,
    };

    for (PickGroup group in picks) {
      for (var (:int count, :Color color) in group) {
        counts[color] = switch (counts[color]) {
          null => count,
          int value => max(value, count),
        };
      }
    }

    int power = counts.values.reduce((int a, int b) => a * b);

    sum += power;
  }

  print(sum);
}

void main() {
  part1();
  part2();
}
