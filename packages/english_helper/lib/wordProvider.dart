import 'package:english_core/classes/word.dart';
import 'package:sqflite/sqflite.dart';

final class WordProvider {
  final Database db;

  WordProvider(this.db);

  static const _selectWordWithTranslations = '''
    SELECT w.*, GROUP_CONCAT(t.translation, ', ') as translation
    FROM words w
    LEFT JOIN translations t ON w.id = t.word_id
  ''';

  Future<List<Word>> getWords([String? search]) async {
    final res = await db.rawQuery(
      '$_selectWordWithTranslations WHERE w.original LIKE ? GROUP BY w.id ORDER BY w.original',
      ['%$search%'],
    );
    return res.map((row) => Word.fromMap(row)).toList();
  }

  Future<Word?> getWord(String original, [Transaction? t]) async {
    final res = await (t ?? db).rawQuery(
      '$_selectWordWithTranslations WHERE w.original = ? GROUP BY w.id',
      [original],
    );
    if (res.isEmpty) return null;
    return Word.fromMap(res.first);
  }

  Future<bool> updateWord(Word word, [Transaction? t]) async {
    final existingWord = await getWord(word.mainPair.original, t);
    if (existingWord == null || existingWord == word) return false;

    final txn = t ?? db;

    await txn.rawUpdate(
      '''
      UPDATE words SET
      transcription = ?,
      original_example = ?,
      translation_example = ?,
      part_of_speech = ?
      WHERE original = ?
    ''',
      [
        word.transcription,
        word.originalExample,
        word.translationExample,
        word.partOfSpeech?.name,
        word.mainPair.original,
      ],
    );

    final wordId = await txn.rawQuery(
      'SELECT id FROM words WHERE original = ?',
      [word.mainPair.original],
    );

    if (wordId.isNotEmpty) {
      final id = wordId.first['id'] as int;
      await txn.delete('translations', where: 'word_id = ?', whereArgs: [id]);

      final translations = word.mainPair.translation?.split(', ') ?? [];
      for (final translation in translations) {
        await txn.insert('translations', {
          'word_id': id,
          'translation': translation,
        });
      }
    }
    return true;
  }

  Future<int> addWord(Word word, [Transaction? t]) async {
    if (word.mainPair.original.isEmpty) {
      throw ArgumentError('Word original cannot be empty');
    }

    final txn = t ?? db;

    final id = await txn.insert('words', {
      'original': word.mainPair.original,
      'transcription': word.transcription,
      'original_example': word.originalExample,
      'translation_example': word.translationExample,
      'part_of_speech': word.partOfSpeech?.name,
    });

    final translations = word.mainPair.translation?.split(', ') ?? [];
    for (final translation in translations) {
      await txn.insert('translations', {
        'word_id': id,
        'translation': translation,
      });
    }

    return id;
  }

  Future<FillResult> fillDatabase(List<Word> words) async {
    int addedCount = 0;
    int updatedCount = 0;
    int skippedCount = 0;

    await db.transaction((txn) async {
      for (final word in words) {
        if (await getWord(word.mainPair.original, txn) != null) {
          (await updateWord(word, txn)) ? updatedCount++ : skippedCount++;
        } else {
          await addWord(word, txn);
          addedCount++;
        }
      }
    });
    return FillResult(words.length, addedCount, updatedCount, skippedCount);
  }
}

class FillResult {
  final int totalCount;
  final int addedCount;
  final int updatedCount;
  final int skippedCount;

  FillResult(
    this.totalCount,
    this.addedCount,
    this.updatedCount,
    this.skippedCount,
  );

  @override
  String toString() {
    return 'FillResult(totalCount: $totalCount, addedCount: $addedCount, updatedCount: $updatedCount, skippedCount: $skippedCount)';
  }
}
