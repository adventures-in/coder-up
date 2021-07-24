import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _words = [];

  @override
  void initState() {
    super.initState();
    createAndAnalyze().then((_) => print('done'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coder Up'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Hello '),
                      const TextSpan(
                        text: 'bold',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' world!'),
                      for (var word in _words) TextSpan(text: ' $word'),
                    ],
                  ),
                ),
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a search term'),
              onSubmitted: (value) => setState(() {
                _words.add(value);
              }),
            )
          ],
        ),
      ),
    );
  }
}

/// A simple example of using the AnalysisContextCollection API.
Future<void> createAndAnalyze() async {
  final directory = await getApplicationDocumentsDirectory();

  // Create a file in the Documents folder
  final mainFile = File('${directory.path}/main.dart');
  mainFile.writeAsStringSync(codeString);

  final dartToolDir = Directory('${directory.path}/.dart_tool/');
  dartToolDir.createSync();
  final packageConfigFile = File('${dartToolDir.path}/package_config.json');
  packageConfigFile.writeAsStringSync(packageConfig);

  var issueCount = 0;
  final collection = AnalysisContextCollection(
      includedPaths: [directory.absolute.path],
      resourceProvider: PhysicalResourceProvider.INSTANCE);

  // Often one context is returned, but depending on the project structure we
  // can see multiple contexts.
  for (final context in collection.contexts) {
    print('Analyzing ${context.contextRoot.root.path} ...');

    for (final filePath in context.contextRoot.analyzedFiles()) {
      if (!filePath.endsWith('.dart')) {
        continue;
      }

      final errorsResult = await context.currentSession.getErrors2(filePath);
      if (errorsResult is ErrorsResult) {
        for (final error in errorsResult.errors) {
          if (error.errorCode.type != ErrorType.TODO) {
            print(
                '  \u001b[1m${error.source.shortName}\u001b[0m ${error.message}');
            issueCount++;
          }
        }
      }
    }
  }

  print('$issueCount issues found.');
}

const codeString = r'''
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/physical_file_system.dart';

/// A simple example of using the AnalysisContextCollection API.
void main(List<String> args) async {
  FileSystemEntity entity = Directory.current;
  if (args.isNotEmpty) {
    String arg = args.first;
    entity = FileSystemEntity.isDirectorySync(arg) ? Directory(arg) : File(arg);
  }

  var issueCount = 0;
  final collection = AnalysisContextCollection(
      includedPaths: [entity.absolute.path],
      resourceProvider: PhysicalResourceProvider.INSTANCE);

  // Often one context is returned, but depending on the project structure we
  // can see multiple contexts.
  for (final context in collection.contexts) {
    print('Analyzing ${context.contextRoot.root.path} ...');

    for (final filePath in context.contextRoot.analyzedFiles()) {
      if (!filePath.endsWith('.dart')) {
        continue;
      }

      final errorsResult = await context.currentSession.getErrors(filePath);
      if (errorsResult is ErrorsResult) {
        for (final error in errorsResult.errors) {
          if (error.errorCode.type != ErrorType.TODO) {
            print(
                '  \u001b[1m${error.source.shortName}\u001b[0m ${error.message}');
            issueCount++;
          }
        }
      }
    }
  }

  print('$issueCount issues found.');
}
''';

const packageConfig = '''
{
  "configVersion": 2,
  "packages": [],
  "generated": "2021-07-24T12:52:54.278634Z",
  "generator": "pub",
  "generatorVersion": "2.14.0-301.0.dev"
}
''';
