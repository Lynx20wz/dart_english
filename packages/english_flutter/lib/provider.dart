import 'package:english_core/english_core.dart' show Word, DictParser;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wordsProvider = Provider<List<Word>>((_) => DictParser().parseAllWords());
