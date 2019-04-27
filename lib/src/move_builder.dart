import 'dart:async';

import 'package:build/build.dart';
import 'package:glob_export/src/builder.dart';

/// A [Builder] that moves the output from the [GlobExportBuilder] into the
/// user's source.
class MoveBuilder extends Builder {
  @override
  final buildExtensions = {
    ".glob_export_output": [".g.dart"],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    print("whoof wants to know");
    return buildStep.writeAsBytes(
        buildStep.inputId.changeExtension(".g.dart"),
        buildStep.readAsBytes(
            buildStep.inputId.changeExtension(".glob_export_output")));
  }
}
