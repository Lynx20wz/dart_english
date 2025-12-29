import 'dart:io';

import 'package:dotenv/dotenv.dart';

final env = DotEnv();

class Config {
  static late final String dictionaryPath;
  static late final String yandexApiKey;

  static void init() {
    dictionaryPath = env.getOrElse('DICTIONARY_PATH', () => '.');

    final apiKey = env['YANDEX_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      print('\x1b[31mError: YANDEX_API_KEY is not set\x1b[0m');
      print('Set it with: export YANDEX_API_KEY=your_key_here');
      exit(1);
    }

    yandexApiKey = apiKey;
  }
}
