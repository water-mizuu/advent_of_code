import "dart:collection";
import "dart:io";
import "dart:math" as math;

typedef Stacks = Map<String, Queue<String>>;
typedef Commands = List<Command>;
typedef Command = (int count, String from, String to);
typedef Span = (int, int);

enum Mode { ones, multiple }

/// Experimental features galore.
(Stacks, Commands) parse(String input) {
  Stacks stacks;
  Commands commands;

  /// We can't use destructuring yet, so this is
  /// what we're gonna have to use.
  var [String stacksString, String commandString] = input.split("\n\n");

  /// Stack parsing
  {
    List<String> lines = stacksString.split("\n");
    int width = lines.map((l) => l.length).reduce(math.max);

    List<String> paddedLines = lines.map((l) => l.padRight(width)).toList();
    String lastLine = paddedLines.last;

    /// Basically, we grab all the indices which is spanned by
    /// the numbers at the bottom.
    Iterable<Span> indices = RegExp(r"\d+")
        .allMatches(lastLine)
        .map((v) => (v.start, v.end));

    Stacks _stacks = {};
    for (Span span in indices) {
      /// We assume that:
      ///   1. The keys are always at the bottom.
      ///   2. The span of each key aligns with the items.
      ///     This means that in:
      ///      [│d│] [│e │]
      ///      [│a│] [│b │]
      ///       │1│   │2 │ 
      ///     the bars always align.
      var (int start, int end) = span;
      String key = lastLine.substring(start, end);
      Queue<String> stack = _stacks[key] ??= Queue<String>();

      /// Iterate from the bottom of the stack of the string,
      /// appending to the "stack" queue as we go.
      for (int y = (paddedLines.length - 1) - 1; y >= 0; --y) {
        String element = paddedLines[y].substring(start, end).trim();

        if (element.isNotEmpty) {
          stack.addLast(element);
        }
      }
    }

    stacks = _stacks;
  }

  /// Command parsing
  {
    List<String> lines = commandString.split("\n");
    RegExp commandRegExp = RegExp(r"move (\d+) from (\d+) to (\d+)");

    List<Command> _commands = [];
    for (String line in lines) {
      List<String?>? groups = commandRegExp.firstMatch(line)?.groups([1, 2, 3]);

      if (groups case [String count, String from, String to]) {
        _commands.add((int.parse(count), from, to));
      }
    }

    commands = _commands;
  }

  return (stacks, commands);
}

void applyCommand(Stacks stacks, Command command, Mode mode) {
  var (int count, String from, String to) = command;
  switch (mode) {
    /// While I can replicate the [Mode.multiple] implementation,
    /// I think that this should be more representative of part-1.
    case Mode.ones:
      for (int i = 0; i < count; ++i) {
        String value = stacks[from]!.removeLast();

        stacks[to]!.addLast(value);
      }
      break;

    /// If it is multiple, take the [count]-last elements
    /// and reverse it, because that's how [.addAll] works.
    case Mode.multiple:
      stacks[to]!.addAll([
        for (int i = 0; i < count; ++i)
          stacks[from]!.removeLast()
      ].reversed);

      break;
  }
}

void part1() {
  String input = File("bin/2022/day_5/assets/main.txt")
      .readAsStringSync()
      .replaceAll("\r", "");

  var (Stacks stacks, Commands commands) = parse(input);
  for (Command command in commands) {
    applyCommand(stacks, command, Mode.ones);
  }

  StringBuffer buffer = StringBuffer();
  for (Queue<String> stack in stacks.values) {
    String last = stack.last;

    buffer.write(last);
  }
  print(buffer);
}

void part2() {
  String input = File("bin/2022/day_5/assets/main.txt")
      .readAsStringSync()
      .replaceAll("\r", "");

  var (Stacks stacks, Commands commands) = parse(input);
  for (Command command in commands) {
    applyCommand(stacks, command, Mode.multiple);
  }

  StringBuffer buffer = StringBuffer();
  for (Queue<String> stack in stacks.values) {
    String last = stack.last;

    buffer.write(last);
  }
  print(buffer);
}

void main() {
  part1();
  part2();
}
