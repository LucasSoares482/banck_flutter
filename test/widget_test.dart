// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic app test', (WidgetTester tester) async {
    // Build a simple MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: Text('Test')),
          body: Center(child: Text('Test App')),
        ),
      ),
    );

    // Verify that the test app loads
    expect(find.text('Test App'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('Widget creation test', (WidgetTester tester) async {
    // Test basic widget creation
    await tester.pumpWidget(
      MaterialApp(
        home: Container(
          child: Text('Hello World'),
        ),
      ),
    );

    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('Button tap test', (WidgetTester tester) async {
    int counter = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Column(
                children: [
                  Text('Count: $counter'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        counter++;
                      });
                    },
                    child: Text('Increment'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Initial state
    expect(find.text('Count: 0'), findsOneWidget);

    // Tap button
    await tester.tap(find.text('Increment'));
    await tester.pump();

    // Check updated state
    expect(find.text('Count: 1'), findsOneWidget);
  });
}