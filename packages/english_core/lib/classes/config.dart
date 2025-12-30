import 'dart:io';

import 'package:dotenv/dotenv.dart';

final envFile = File('${Directory.current.parent.path}/english_core/.env');
final env = DotEnv()..load([envFile.path]);

class Config {
  static String get yandexApiKey {
    final apiKey = env['YANDEX_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('\x1b[31mError: YANDEX_API_KEY is not set\x1b[0m');
      print('Set it with: export YANDEX_API_KEY=your_key_here');
      exit(1);
    }
    return apiKey;
  }

  static String get dictionaryPath {
    final path = env['DICTIONARY_PATH'];
    if (path == null || path.isEmpty) {
      print('\x1b[31mError: DICTIONARY_PATH is not set\x1b[0m');
      print('Set it with: export DICTIONARY_PATH=your_path_here');
      exit(1);
    }
    return path;
  }
}
