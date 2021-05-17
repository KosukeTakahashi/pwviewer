extension on RegExp {
  List<String> allMatchesWithSeparators(String input, [int start = 0]) {
    var result = <String>[];

    for (final match in allMatches(input, start)) {
      result.add(input.substring(start, match.start));
      result.add(match[0]!);
      start = match.end;
    }

    result.add(input.substring(start));
    return result;
  }
}

extension StringExtension on String {
  List<String> splitWithDelimiters(RegExp pattern) =>
      pattern.allMatchesWithSeparators(this);
}
