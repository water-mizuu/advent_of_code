// ignore_for_file: unreachable_from_main

import "dart:io";
import "dart:math" as math;

import "range.dart";

typedef ConversionMap = List<Conversion>;

(List<int> seeds, List<ConversionMap> maps) parse(String path) {
  var input = File(path).readAsStringSync().replaceAll("\r", "");
  var [rawSeeds, ...rawMaps] = input.split("\n\n");

  var seeds = rawSeeds.split(":").last.split(" ").map(int.tryParse).whereType<int>().toList();
  var maps = [
    for (var rawMap in rawMaps)
      [
        for (var line in rawMap.split("\n").skip(1))
          if (line.split(" ").map(int.parse).toList() case [var destinationStart, var sourceStart, var length])
            (
              destination: UnitRange(destinationStart, destinationStart + length),
              source: UnitRange(sourceStart, sourceStart + length),
            ),
      ],
  ];

  return (seeds, maps);
}

int? convertValueByConversion(int from, Conversion conversion) {
  var (
    destination: UnitRange(start: int destinationStart),
    source: UnitRange(start: int sourceStart, end: int sourceEnd)
  ) = conversion;

  if (conversion.source.contains(from)) {
    return from - sourceStart + destinationStart;
  }

  return null;
}

int convertValue(int from, ConversionMap map) {
  for (Conversion conversion in map) {
    if (convertValueByConversion(from, conversion) case int converted) {
      return converted;
    }
  }

  return from;
}

int convertThorough(int value, List<ConversionMap> maps) {
  int converted = value;
  for (ConversionMap map in maps) {
    converted = convertValue(converted, map);
  }

  return converted;
}

void part1() {
  var (List<int> seeds, List<ConversionMap> maps) = parse("bin/2023/day_05/assets/main.txt");

  int? lowest;
  for (int seed in seeds) {
    int converted = convertThorough(seed, maps);

    lowest = math.min(lowest ??= converted, converted);
  }

  print(lowest);
}

void part2() {
  var (List<int> seeds, List<ConversionMap> maps) = parse("bin/2023/day_05/assets/main.txt");
  IntegerRange given = maps.fold(
    [
      for (int i = 0; i < seeds.length; i += 2) //
        IntegerRange.unit(seeds[i], seeds[i] + seeds[i + 1]),
    ].union(),
    (given, map) => given.map(map),
  );

  switch (given) {
    case UnitRange(:var start) || UnionRange(cell: UnitRange(:var start)):
      print(given);
      print(start);
  }
}

void main() {
  part1();
  part2();
}
