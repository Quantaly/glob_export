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
    ".glex": [".g.dart"]
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    var fileContents = await buildStep.readAsString(buildStep.inputId);
    //var allAssets = await buildStep.findAssets(Glob("**")).toSet();
    var exportIds = Set<AssetId>();
    for (var line in fileContents.split(_newline)) {
      String glob = _path.joinAll(List.from(buildStep.inputId.pathSegments)..removeLast()..add(line));
      print("the glob is $glob");
      exportIds.addAll(await buildStep
          .findAssets(Glob(glob))
          .toSet());
    }

    var exports = exportIds.map((id) => Directive.export(_exportUri(id.uri, buildStep.inputId.uri)));
    var library = Library((b) => b..directives.addAll(exports));

    var outputId = buildStep.inputId.changeExtension(".g.dart");
    var emitter = DartEmitter(Allocator.none, true);
    await buildStep.writeAsString(
        outputId,
        DartFormatter(fixes: StyleFix.all)
            .format(emitter.visitLibrary(library).toString()));
  }
}

String _exportUri(Uri uri, Uri baseUri) {
  if (uri.isScheme("package")) return uri.toString();
  var ret = _path.relative(uri.toString(), from: _path.dirname(baseUri.toString()));
  print(ret);
  return ret;
}