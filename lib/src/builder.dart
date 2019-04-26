import 'dart:async';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

final _newline = RegExp("\\r\\n|\\r|\\n");
final _path = path.Context(style: path.Style.url);

/// The main [Builder] used by this package.
class GlobExportBuilder extends Builder {
  @override
  final buildExtensions = {
    ".glex": [".glob_export_output"],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    var fileContents = await buildStep.readAsString(buildStep.inputId);
    var includes = <AssetId>{};
    var excludes = <AssetId>{};

    for (var line in fileContents.split(_newline)) {
      if (line.startsWith("#") || line.isEmpty) {
        continue;
      } else if (line.startsWith("!")) {
        String glob = _path.joinAll(List.from(buildStep.inputId.pathSegments)
          ..removeLast()
          ..add(line.substring(1)));
        excludes.addAll(await buildStep.findAssets(Glob(glob)).toSet());
      } else {
        String glob = _path.joinAll(List.from(buildStep.inputId.pathSegments)
          ..removeLast()
          ..add(line));
        includes.addAll(await buildStep.findAssets(Glob(glob)).toSet());
      }
    }

    var exports = includes.difference(excludes).map(
        (id) => Directive.export(_exportUri(id.uri, buildStep.inputId.uri)));
    var library = Library((b) => b..directives.addAll(exports));

    var outputId = buildStep.inputId.changeExtension(".glob_export_output");
    var emitter = DartEmitter(Allocator.none, true);
    return buildStep.writeAsString(
        outputId,
        DartFormatter(fixes: StyleFix.all)
            .format(emitter.visitLibrary(library).toString()));
  }
}

String _exportUri(Uri uri, Uri baseUri) {
  if (uri.isScheme("package")) return uri.toString();
  return _path.relative(uri.toString(),
      from: _path.dirname(baseUri.toString()));
}
