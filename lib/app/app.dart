import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
      child: MaterialApp(
        title: 'Flutter Feedback Example',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Feedback Example'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Example of feedback',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          BetterFeedback.of(context).show((UserFeedback feedback) async {
            await _sendFeedbackToSentry(feedback);
          });
        },
        tooltip: 'Feedback',
        child: const Icon(Icons.feedback),
      ),
    );
  }

  Future<void> _sendFeedbackToSentry(UserFeedback feedback) async {
    final feedbackContent = feedback.text ?? 'Empty feedback';
    final id = await Sentry.captureMessage(
      feedbackContent,
      withScope: (scope) {
        scope.addAttachment(
          SentryAttachment.fromUint8List(
            feedback.screenshot,
            'screenshot.png',
            contentType: 'image/png',
          ),
        );

        scope.fingerprint = [const Uuid().v4()];
      },
    );
    await Sentry.captureUserFeedback(SentryUserFeedback(
      eventId: id,
      comments: feedbackContent,
    ));
  }
}
