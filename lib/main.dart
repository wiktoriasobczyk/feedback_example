import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feedback_example/app/app.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sentryDns = await _receiveSentryDns();

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDns;
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
  runApp(const MyApp());
}

Future<String> _receiveSentryDns() async {
  final String json = await rootBundle.loadString('keys/keys.json');

  final Map<String, dynamic> config = jsonDecode(json);
  return config['sentry_dns'] as String;
}
