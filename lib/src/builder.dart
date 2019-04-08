import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

final _newline = RegExp("\\r?\\n?");

/// The main [Builder] used by this package.
class GlobExportBuilder extends Builder {
  @override
  final buildExtensions = {
    ".glex": [".g.dart"]
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    var fileContents = await buildStep.readAsString(buildStep.inputId);
    var exportIds = Set<AssetId>();
    for (var line in fileContents.split(_newline)) {
      exportIds.addAll(await buildStep.findAssets(Glob(line)).toSet());
    }

    var exports = Set<Directive>();
    for (var id in exportIds) {
      exports.add(Directive.export(id.uri.toString()));
    }

    var library = Library((b) => b..directives.addAll(exports));

    var outputId = buildStep.inputId.changeExtension(".g.dart");
    var emitter = DartEmitter(Allocator.none, true);
    await buildStep.writeAsString(
        outputId,
        DartFormatter(fixes: StyleFix.all)
            .format(emitter.visitLibrary(library).toString()));
  }
}
