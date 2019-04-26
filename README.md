# glob_export

A builder package for automatically exporting Dart files in a project based on globs.

## Usage

The builder looks for files with the `.glex` extension and processes them similarly to gitignore files, except backwards:

- Globs directly listed in the file are included.
- Globs preceded with ! are excluded.
  - Exclusions take precedence over inclusions.
- Lines preceded with # are treated as comments and ignored.

Make sure you have this package and [`build_runner`](https://pub.dartlang.org/packages/build_runner) as dev dependencies, then run

- `pub run build_runner build` or `pub run build_runner watch` for a standalone package or command-line application
- `flutter packages pub run build_runner build` or `flutter packages pub run build_runner watch` for a Flutter project
- `webdev build` or `webdev serve` for a web project

The output file has the extension `.g.dart` and simply exports all included files.

## Example

A common use case would be an `everything.glex` file in the `lib` folder of an application package:

```
**.dart
```

And if you want to exclude generated files:

```
!**.g.dart
```

Then, from a Dart file in `lib`:

```dart
import 'everything.g.dart';

// Some code that uses other code from elsewhere in your package
```

## Known issues

- There are no tests. No unit tests. No integration tests. No tests, whatsoever. Where would one even begin writing tests for a builder? (That was a serious question. I have no idea how to automatically test this.)
- Currently, the package will happily export Dart files with `part of` directives, which is not allowed because they aren't standalone libraries. Unfortunately, the method on `BuildStep` for determining whether or not a file is a library is broken and always returns false. Or more technically a `Future` that completes with false. Whatever. The point is, it doesn't work and it's dumb.