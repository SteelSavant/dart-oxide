import 'dart:io';

// ignore_for_file: avoid_print

void main() {
  // Copilot: read each lconv.info file in all subdirectories of the current directory into a string

  final topLevel = Directory('.');
  final outputFile = File('./coverage/lcov.info');

  print('Combining coverage files in  ${topLevel.absolute.path}');

  final lconvFiles = topLevel
      .listSync(recursive: true)
      .where(
        (final e) =>
            e.path.endsWith('lcov.info') &&
            e.uri.pathSegments.length >
                2, // dart file path comparisons are jank as hell, so we cheat a little instead
      )
      .map((final e) => File(e.path));

  for (final file in lconvFiles) {
    print('Found ${file.path}');
  }

  final lconvContents = Lcov.parse(
    lconvFiles
        .map(
          (final e) => (
            e.path.replaceAll('coverage\\lcov.info', ''),
            e.readAsStringSync()
          ),
        )
        .map((final e) => e.$2.replaceAll('SF:', 'SF:${e.$1}'))
        .join('\n'),
  )
    ..removeSourceWhere((final e) => e.endsWith('_test.dart'))
    ..removeSourceWhere((final p0) => p0.endsWith('.g.dart'))
    ..removeSourceWhere((final p0) => p0.endsWith('.freezed.dart'));

  print('Writing to ${outputFile.absolute.path}');

  outputFile
    ..createSync(recursive: true)
    ..writeAsStringSync(lconvContents.toString());

  if (Platform.isWindows) {
    try {
      print('Generating HTML report');
      Directory('coverage/html').createSync(recursive: true);
      final result = Process.runSync(
        'perl',
        [
          'C:\\ProgramData\\chocolatey\\lib\\lcov\\tools\\bin\\genhtml',
          'coverage/lcov.info',
          '-o',
          'coverage/html',
          '--branch-coverage',
        ],
      );

      print(result.stdout);
    } on Exception catch (e) {
      print(e);
    }
  }

  // TODO::genhtml for mac/linux
}

class Lcov {
  final List<LcovRecord> records;

  Lcov(this.records);

  factory Lcov.parse(final String source) {
    final lines = source.split('\n');
    final records = <LcovRecord>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.startsWith('SF:')) {
        final sourceFile = line.substring(3);
        final recordLines = <String>[];

        for (var j = i + 1; j < lines.length; j++) {
          final line = lines[j];

          if (line.startsWith('end_of_record')) {
            records.add(LcovRecord(sourceFile, recordLines));
            i = j;
            break;
          } else {
            recordLines.add(line);
          }
        }
      }
    }

    print('Lcov parsed ${records.length} records');

    return Lcov(records);
  }

  void removeSourceWhere(final bool Function(String) predicate) {
    records.removeWhere((final e) => predicate(e.sourceFile));
  }

  void write(final StringBuffer buffer) => buffer.writeAll(records, '\n');

  @override
  String toString() {
    final buffer = StringBuffer();
    write(buffer);
    return buffer.toString();
  }
}

class LcovRecord {
  final String sourceFile;
  final List<String> lines;

  LcovRecord(this.sourceFile, this.lines);

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('SF:$sourceFile\n')
      ..writeAll(lines, '\n')
      ..write('\nend_of_record');
    return buffer.toString();
  }
}
