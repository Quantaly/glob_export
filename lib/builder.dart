import 'package:build/build.dart';

import 'src/builder.dart';
import 'src/move_builder.dart';

/// Factory for [GlobExportBuilder].
GlobExportBuilder makeBuilder(BuilderOptions options) => GlobExportBuilder();

/// Factory for [MoveBuilder].
MoveBuilder makeMoveBuilder(BuilderOptions options) => MoveBuilder();

/// Factory for my [FileDeletingBuilder].
///
/// It... doesn't seem to actually work, though.
///
/// Whatever.
FileDeletingBuilder makeFileDeletingBuilder(BuilderOptions options) =>
    FileDeletingBuilder([".glob_export_output"]);
