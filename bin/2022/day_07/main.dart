import "dart:collection";
import "dart:io";

extension MatchGroupExtension on Match {
  List<String?> get matches => groups([for (int i = 1; i <= groupCount; ++i) i]);
}

enum EntityType { file, directory }

class Entity {

  const Entity({required this.name, required this.children, required this.type, required this.size});
  Entity.directory({required this.name})
      : children = [],
        size = 0,
        type = EntityType.directory;
  Entity.file({required this.name, required this.size})
      : children = [],
        type = EntityType.file;
  final String name;
  final List<Entity> children;
  final EntityType type;
  final int size;

  Iterable<Entity> traverse() sync* {
    Queue<Entity> queue = Queue<Entity>()..add(this);
    Set<Entity> visited = {}..add(this);

    while (queue.isNotEmpty) {
      Entity latest = queue.removeFirst();
      visited.add(latest);
      yield latest;

      for (Entity child in latest.children) {
        queue.add(child);
        visited.add(child);
      }
    }
  }

  int computeSize({Expando<int>? expando}) {
    expando ??= Expando<int>();

    switch (type) {
      case EntityType.file:
        return expando[this] = size;
      case EntityType.directory:
        expando[this] ??= 0;

        return expando[this] = children.map((c) => c.computeSize(expando: expando)).reduce((a, b) => a + b);
    }
  }
}

List<String?>? matchCommand(String line) => RegExp(r"^\$\s*(\S+)(?:\s*(\S+))?").matchAsPrefix(line)?.matches;
List<String?>? matchFile(String line) => RegExp(r"^(?!\$)(\S+)\s+(\S+)").matchAsPrefix(line)?.matches;

void displayEntity(Entity entity, [String indent = ""]) {
  stdout
    ..write(indent)
    ..write(entity.name)
    ..write(entity.type == EntityType.file ? " (file, size=${entity.size})" : " (dir, size=${entity.computeSize()})")
    ..writeln();

  for (Entity child in entity.children.whereType()) {
    displayEntity(child, "  $indent");
  }
}

Entity parseCommands(List<String> lines) {
  Queue<Entity> stack = Queue<Entity>();

  for (int i = 0; i < lines.length; ++i) {
    String line = lines[i];

    if (matchCommand(line) case List<String?> match) {
      if (match case ["cd", ".."]) {
        stack.removeLast();
      } else if (match case ["cd", String args]) {
        if (stack.isNotEmpty) {
          Entity entity =
              stack.last.children.firstWhere((e) => e.name == args, orElse: () => Entity.directory(name: args));

          stack.add(entity);
        } else {
          Entity entity = Entity.directory(name: args);

          stack.add(entity);
        }
      } else if (match case ["ls", _]) {
        ++i;
        while (i < lines.length) {
          String line = lines[i];

          if (matchFile(line) case [String left, String name]) {
            if (int.tryParse(left) case int size) {
              if (!stack.last.children.any((v) => v.name == name)) {
                stack.last.children.add(Entity.file(name: name, size: size));
              }
            } else {
              if (!stack.last.children.any((v) => v.name == name)) {
                stack.last.children.add(Entity.directory(name: name));
              }
            }

            ++i;
          } else {
            --i;
            break;
          }
        }
      }
    }
  }

  return stack.first;
}

/// Problem has multiple easy steps.
/// 1. Generate a tree
/// 2. Traverse the directories.
/// 3. Simple filter & sum.
void part1() {
  List<String> lines = File("bin/2022/day_07/assets/main.txt").readAsLinesSync();
  Entity root = parseCommands(lines);
  displayEntity(root);

  int query = root
      .traverse()
      .where((e) => e.type == EntityType.directory)
      .map((e) => e.computeSize())
      .where((sz) => sz <= 100000)
      .reduce((a, b) => a + b);

  print(query);
}

/// Same as the top, but even easier.
/// Basically find the smallest possible that will satisfy the space requirement.
void part2() {
  List<String> lines = File("bin/2022/day_07/assets/main.txt").readAsLinesSync();
  Entity root = parseCommands(lines);

  int totalSize = root.computeSize();
  int target = totalSize - 40000000;

  int query = root
      .traverse()
      .where((e) => e.type == EntityType.directory)
      .map((e) => e.computeSize())
      .where((sz) => sz >= target)
      .reduce((a, b) => a > b ? b : a);

  print(query);
}

void main() {
  part1();
  part2();
}
