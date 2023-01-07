// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import "dart:collection";
import "dart:io";
import "dart:math" as math;

typedef BitField = int;
typedef Resources = ({int ore, int clay, int obsidian, int geode});
typedef Entry = (int time, Resources goods, Resources robots);

class Blueprint {
  final int id;
  final int oreRobotCost;
  final int clayRobotCost;
  final ({int ore, int clay}) obsidianRobotCost;
  final ({int ore, int obsidian}) geodeRobotCost;
  final int maxOreCost;
  final int maxClayCost;
  final int maxObsidianCost;

  Blueprint({
    required this.id,
    required this.oreRobotCost,
    required this.clayRobotCost,
    required this.obsidianRobotCost,
    required this.geodeRobotCost,
  }) : maxOreCost = [oreRobotCost, clayRobotCost, obsidianRobotCost.ore, geodeRobotCost.ore].reduce(math.max),
       maxClayCost = obsidianRobotCost.clay,
       maxObsidianCost = geodeRobotCost.obsidian;
}

int tryBlueprint(Blueprint bp, int time) {
  StringBuffer buffer = StringBuffer();

  HashSet<Entry> seen = HashSet<Entry>();
  Queue<Entry> queue = Queue<Entry>();

  Entry start = (time, (ore: 0, clay: 0, obsidian: 0, geode: 0), (ore: 1, clay: 0, obsidian: 0, geode: 0));
  queue.addLast(start);

  int max = 0;
  while (queue.isNotEmpty) {
    var (int time, Resources goods, Resources robots) = queue.removeFirst();
    max = math.max(max, goods.geode);

    if (time <= 0) {
      continue;
    }

    Resources nextGoods = (
      ore: math.min(goods.ore, (time * bp.maxOreCost) - (robots.ore * (time - 1))),
      clay: math.min(goods.clay, (time * bp.obsidianRobotCost.clay) - (robots.clay * (time - 1))),
      obsidian: math.min(goods.obsidian, (time * bp.geodeRobotCost.obsidian) - (robots.obsidian * (time - 1))),
      geode: goods.geode,
    );
    Resources nextRobots = (
      ore: math.min(robots.ore, bp.maxOreCost),
      clay: math.min(robots.clay, bp.maxClayCost),
      obsidian: math.min(robots.obsidian, bp.maxObsidianCost),
      geode: robots.geode,
    );

    /// Shadow them.
    if ((nextGoods, nextRobots) case (Resources goods, Resources robots)) {
      Entry entry = (time, goods, robots);
      buffer.writeln(entry);

      if (seen.add(entry)) {
        queue.add((
          time - 1,
          (
            ore: goods.ore + robots.ore,
            clay: goods.clay + robots.clay,
            obsidian: goods.obsidian + robots.obsidian,
            geode: goods.geode + robots.geode,
          ),
          robots,
        ));

        /// Try buying one ore robot.
        if (robots.ore < bp.maxOreCost && goods.ore >= bp.oreRobotCost) {
          queue.add((
            time - 1,
            (
              ore: goods.ore + robots.ore - bp.oreRobotCost,
              clay: goods.clay + robots.clay,
              obsidian: goods.obsidian + robots.obsidian,
              geode: goods.geode + robots.geode,
            ),
            (
              ore: robots.ore + 1,
              clay: robots.clay,
              obsidian: robots.obsidian,
              geode: robots.geode,
            ),
          ));
        }

        /// Try buying one ore robot.
        if (robots.clay < bp.maxClayCost && goods.ore >= bp.clayRobotCost) {
          queue.add((
            time - 1,
            (
              ore: goods.ore + robots.ore - bp.clayRobotCost,
              clay: goods.clay + robots.clay,
              obsidian: goods.obsidian + robots.obsidian,
              geode: goods.geode + robots.geode,
            ),
            (
              ore: robots.ore,
              clay: robots.clay + 1,
              obsidian: robots.obsidian,
              geode: robots.geode,
            ),
          ));
        }

        /// Try buying one obsidian robot.
        if (robots.obsidian < bp.maxObsidianCost &&
            goods.ore >= bp.obsidianRobotCost.ore &&
            goods.clay >= bp.obsidianRobotCost.clay) {
          queue.add((
            time - 1,
            (
              ore: goods.ore + robots.ore - bp.obsidianRobotCost.ore,
              clay: goods.clay + robots.clay - bp.obsidianRobotCost.clay,
              obsidian: goods.obsidian + robots.obsidian,
              geode: goods.geode + robots.geode,
            ),
            (
              ore: robots.ore,
              clay: robots.clay,
              obsidian: robots.obsidian + 1,
              geode: robots.geode,
            ),
          ));
        }

        /// Try buying one geode robot.
        if (goods.ore >= bp.geodeRobotCost.ore &&
            goods.obsidian >= bp.geodeRobotCost.obsidian) {
          queue.add((
            time - 1,
            (
              ore: goods.ore + robots.ore - bp.geodeRobotCost.ore,
              clay: goods.clay + robots.clay,
              obsidian: goods.obsidian + robots.obsidian - bp.geodeRobotCost.obsidian,
              geode: goods.geode + robots.geode,
            ),
            (
              ore: robots.ore,
              clay: robots.clay,
              obsidian: robots.obsidian,
              geode: robots.geode + 1,
            ),
          ));
        }
      }
    }
  }

  File("bin/2022/day_19/assets/out.txt")
    ..createSync(recursive: true)
    ..writeAsStringSync(buffer.toString());

  return max;
}

Blueprint parseLine(String line) {
  RegExp regex = RegExp(r"Blueprint (\d+): "
      r"Each ore robot costs (\d+) ore. "
      r"Each clay robot costs (\d+) ore. "
      r"Each obsidian robot costs (\d+) ore and (\d+) clay. "
      r"Each geode robot costs (\d+) ore and (\d+) obsidian.");

  if (regex.firstMatch(line) case RegExpMatch match) {
    if (match.groups([1, 2, 3, 4, 5, 6, 7]).whereType<String>().map(int.parse).toList() case [
          int id,
          int oreRobotCost,
          int clayRobotCost,
          int obsidianRobotOreCost,
          int obsidianRobotClayCost,
          int geodeRobotOreCost,
          int geodeRobotObsidianCost,
        ]) {
      return Blueprint(
        id: id,
        oreRobotCost: oreRobotCost,
        clayRobotCost: clayRobotCost,
        obsidianRobotCost: (ore: obsidianRobotOreCost, clay: obsidianRobotClayCost),
        geodeRobotCost: (ore: geodeRobotOreCost, obsidian: geodeRobotObsidianCost),
      );
    }
  }

  throw Error();
}

/// NOTES:
///   So, it's just day 16 again.
void part1() {
  List<Blueprint> blueprints = File("bin/2022/day_19/assets/main.txt")
      .readAsLinesSync()
      .map(parseLine)
      .toList();

  int sum = 0;
  for (Blueprint bp in blueprints) {
    int geodes = tryBlueprint(bp, 24);
    print("${bp.id} = $geodes");

    sum += bp.id * geodes;
  }

  print(sum);
}
/// NOTES:
///   Reusable solution? Huh.
void part2() {
  List<Blueprint> blueprints = File("bin/2022/day_19/assets/main.txt")
      .readAsLinesSync()
      .map(parseLine)
      .take(3)
      .toList();

  int sum = 1;
  for (Blueprint bp in blueprints) {
    int geodes = tryBlueprint(bp, 32);
    print("${bp.id} = $geodes");

    sum *= geodes;
  }

  print(sum);
}

void main() {
  part1();
  part2();
}
