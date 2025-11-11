import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigService {
  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');
  }

  static String get googleBooksApiKey {
    return dotenv.get('GOOGLE_BOOKS_API_KEY');
  }

  static String get appName => 'BookTracker';
  static const String appVersion = '1.0.0';
}