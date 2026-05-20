import 'dart:io' show Directory, File;

import 'package:test/test.dart';
import 'package:english_core/english_core.dart';

void main() {
  const dictPath = 'test/test_files';

  setUpAll(() async {
    final src = Directory('$dictPath/source');
    final dest = Directory(dictPath);
    await dest.create(recursive: true);
    await for (final entity in src.list()) {
      if (entity is File) {
        await entity.copy('${dest.path}/${entity.uri.pathSegments.last}');
      }
    }
  });

  test('formatAllFiles with web info', () async {
    final parser = DictParser(dictPath);

    await for (final p in parser.formatAllFiles(loadWebInfo: true)) {
      print('${p.$1 + 1}, ${p.$2.word.mainPair.original}');
    }

    for (final file in parser.parseAllFiles()) {
      final target = File(
        '$dictPath/target/${file.file.uri.pathSegments.last}',
      );
      expect(
        file.file.readAsStringSync(),
        target.readAsStringSync(),
        reason: 'Mismatch: ${file.file.path}',
      );
    }
  });
}
