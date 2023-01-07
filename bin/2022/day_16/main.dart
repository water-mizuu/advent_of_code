import "dart:io";
import "dart:math" as math;

typedef List2<E> = List<List<E>>;

typedef Ids = Map<String, int>;
typedef Names = Map<int, String>;
typedef Row = (String name, int id, int rate, Set<String> connections);
typedef ParseResult = (List<Row> rows, Map<String, int> ids, Map<int, String> names);
typedef Graph = Map<int, (int flow, Set<int> connections)>;
typedef Cons<E> = (E car, List<E> cdr);

extension<E> on List<E> {
  Iterable<Cons<E>> chooseOne() sync* {
    for (int i = 0; i < length; ++i) {
      yield (this[i], sublist(0, i) + sublist(i + 1));
    }
  }
}

(List<Row> rows, Ids ids, Names names) parseInput() {
  List<String> lines = File("bin/2022/day_16/assets/main.txt").readAsLinesSync();
  RegExp regexp = RegExp(
    r"Valve (\S+) has flow rate=(\d+); "
    "(?:(?:tunnels lead to valves)|(?:tunnel leads to valve))"
    "(.*)");

  int counter = 0;
  Ids ids = {};
  Names names = {};
  List<Row> data = [];

  for (String line in lines) {
    if (regexp.firstMatch(line)?.groups([1, 2, 3]) case [String name, String rateString, String routes]) {
      int id = ids.putIfAbsent(name, () => counter++);
      ids[name] = id;
      names[id] = name;

      Set<String> connections = routes
          .split(",")
          .map((v) => v.trim())
          .toSet();

      int rate = int.parse(rateString);

      data.add((name, id, rate, connections));
    }
  }

  return (data, ids, names);
}

(Graph graph, Ids ids, Names names) parseData() {
  if (parseInput() case (List<Row> rows, Ids ids, Map<int, String> names)) {
    Graph graph = {};

    for (Row row in rows) {
      if (row case (String name, int id, int rate, Set<String> transitions)) {
        graph[id] = (rate, {for (String n in transitions) ids[n]!});
      }
    }

    return (graph, ids, names);
  }
}

Map<(int, String, int), int> savedDfs1 = {};
int dfs(Graph graph, List2<int> distances, int current, List<int> remaining, int timeLimit) {
  (int, String, int) key = (current, remaining.join("-"), timeLimit);

  if (savedDfs1[key] case int computed) {
    return computed;
  }

  int result = 0;
  for (Cons<int> selected in remaining.chooseOne()) {
    if (selected case (int pipe, List<int> otherPipes)) {
      if (distances[current][pipe] case int distance when distance <= timeLimit) {
        if (graph[pipe] case (int rate, _)) {
          int limit = (timeLimit - distance) - 1;
          int flow = rate * limit + dfs(graph, distances, pipe, otherPipes, limit);

          result = math.max(result, flow);
        }
      }
    }
  }

  return savedDfs1[key] = result;
}

void part1() {
  if (parseData() case (Graph graph, Ids ids, Names names)) {
    List2<int> distances = [
      for (int i = 0; i < names.length; ++i)
        [for (int j = 0; j < names.length; ++j) 100]
    ];

    /// Set the distances between connected pipes to 1:
    for (MapEntry<int, (int flow, Set<int> connections)> entry in graph.entries) {
      if ((entry.key, entry.value) case (int id, (int rate, Set<int> connections))) {
        for (int j in connections) {
          distances[id][j] = 1;
        }
      }
    }

    /// Floyd-Warshall algorithm.
    /// O(n^3) algorithm that determines the distance of any node to any node.
    for (int z = 0; z < names.length; ++z) {
      for (int y = 0; y < names.length; ++y) {
        for (int x = 0; x < names.length; ++x) {
          distances[y][x] = math.min(distances[y][x], distances[y][z] + distances[z][x]);
        }
      }
    }

    int start = ids["AA"]!;
    List<int> nonzero = [
      for (int i = 0; i < names.length; ++i)
        if ((graph[i]?.$0 ?? 0) > 0) i
    ];

    print(dfs(graph, distances, start, nonzero, 30));
  }
}

Map<(int, String, int), int> savedDfs2 = {};
int dfs2(Graph graph, List2<int> distances, int start, int current, List<int> remaining, int timeLimit) {
  (int, String, int) key = (current, remaining.join("-"), timeLimit);
  if (savedDfs2[key] case int computed) {
    return computed;
  }

  int result = dfs(graph, distances, start, remaining, 26);

  for (Cons<int> pair in remaining.chooseOne()) {
    if (pair case (int r, List<int> rr)) {
      if (distances[current][r] case int distance when distance <= timeLimit) {
        if (graph[r] case (int rate, _)) {
          int limit = (timeLimit - distance) - 1;
          int flow = rate * limit + dfs2(graph, distances, start, r, rr, limit);

          result = math.max(result, flow);
        }
      }
    }
  }

  return savedDfs2[key] = result;
}

void part2() {
  if (parseData() case (Graph graph, Ids ids, Names names)) {
    List2<int> distances = [
      for (int i = 0; i < names.length; ++i)
        [for (int j = 0; j < names.length; ++j) 100]
    ];

    /// Set the distances between connected pipes to 1:
    for (MapEntry<int, (int flow, Set<int> connections)> entry in graph.entries) {
      if ((entry.key, entry.value) case (int id, (int rate, Set<int> connections))) {
        for (int j in connections) {
          distances[id][j] = 1;
        }
      }
    }

    /// Floyd-Warshall algorithm.
    /// O(n^3) algorithm that determines the distance of any node to any node.
    for (int z = 0; z < names.length; ++z) {
      for (int y = 0; y < names.length; ++y) {
        for (int x = 0; x < names.length; ++x) {
          distances[y][x] = math.min(distances[y][x], distances[y][z] + distances[z][x]);
        }
      }
    }

    int start = ids["AA"]!;
    List<int> nonzero = [
      for (int i = 0; i < names.length; ++i)
        if ((graph[i]?.$0 ?? 0) > 0) i
    ];

    print(dfs2(graph, distances, start, start, nonzero, 26));
  }
}

void main() {
  part1();
  part2();
}
