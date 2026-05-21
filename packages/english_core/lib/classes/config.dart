import 'dart:developer' show log;
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:dotenv/dotenv.dart';

class Config {
  // Lazy initialization of .env
  static final DotEnv _env = () {
    final scriptDir = p.dirname(Platform.script.toFilePath());
    // .env file is located in the root of the project
    final envPath = p.normalize(p.join(scriptDir, '..', '..', '.env'));
    log('Env file loaded. Its path: $envPath');
    return DotEnv()..load([envPath]);
  }();

  /// Dictionary path
  /// Returns the dictionary path from the .env file.
  /// If the path is not set or is an empty string, throws an exception.
  static String get dictionaryPath => _env['DICTIONARY_PATH']?.isEmpty ?? true
      ? throw Exception('DICTIONARY_PATH is not set in .env')
      : _env['DICTIONARY_PATH']!;
}
