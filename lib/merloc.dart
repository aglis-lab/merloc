import 'dart:convert';
import 'dart:io';

import 'package:merloc/yaml.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as path;

enum FileType { none, json, yaml }

class Merloc {
  final String input;
  final String output;
  final List<String> locales = [];
  final Map<String, Map> translations = {};

  Merloc({required this.input, required this.output});

  // Covert list of directory and file into a Metadata
  void loadLocalization() {
    final dir = Directory(input);
    final listDir = dir.listSync(recursive: true);

    for (var item in listDir) {
      final filename = path.basename(item.path);
      final fileParts = filename.split('.');
      if (fileParts.length != 2) {
        continue;
      }

      // check if yaml or json
      FileType fileType = FileType.none;
      if (fileParts[1] == 'yaml') {
        fileType = FileType.yaml;
      } else if (fileParts[1] == 'json') {
        fileType = FileType.json;
      }

      if (fileType == FileType.none) {
        continue;
      }

      // already registered on localization
      if (!locales.contains(fileParts[0])) {
        continue;
      }

      // Check if file really exist or it just a directory
      final file = File(item.path);
      if (!file.existsSync()) {
        continue;
      }

      // Get Path File and trim the leading character
      final pathFile =
          item.path.substring(input.length).trimLeading('\\').trimLeading('/');
      final objectKeys = path.split(pathFile)..removeLast();

      // Load File
      loadFile(fileParts[0], item.path, fileType, objectKeys);
    }
  }

  void writeOutput() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    for (var locale in locales) {
      final file = File(path.join(output, '$locale.json'));

      file.writeAsString(encoder.convert(translations[locale]));
    }
  }

  void loadFile(
      String locale, String path, FileType fileType, List<String> keys) {
    final file = File(path);

    var data = <String, dynamic>{};
    if (fileType == FileType.yaml) {
      final parsed =
          (yaml.loadYaml(file.readAsStringSync()) as yaml.YamlMap).toMap();

      data.addAll(parsed);
    } else {
      final parsed = json.decode(file.readAsStringSync());

      data.addAll(parsed);
    }

    var temp = translations[locale]!;
    for (var key in keys) {
      if (temp[key] == null) {
        temp[key] = {};
      }

      temp = temp[key];
    }

    temp.addAll(data);
  }

  void loadLocales() {
    final locales = loadLocalesFile();
    if (locales == null) {
      stderr.writeln(
          "localization.yaml or localization.json not found insize input folder!");
      exit(1);
    }

    if (locales.isEmpty) {
      stderr.writeln("locales should be not empty!");
      exit(1);
    }

    this.locales.addAll(locales);

    for (var item in locales) {
      translations[item] = {};
    }
  }

  List<String>? loadLocalesFile() {
    var file = File(path.join(input, "localization.yaml"));
    if (file.existsSync()) {
      final localeList =
          (yaml.loadYaml(file.readAsStringSync()) as yaml.YamlMap)
              .toMap()["locales"] as List;
      return localeList.map((e) => (e as String)).toList();
    }

    file = File(path.join(input, "localization.json"));
    if (file.existsSync()) {
      final localeList =
          json.decode(file.readAsStringSync())["locales"] as List;
      return localeList.map((e) => e as String).toList();
    }

    return null;
  }
}

extension StringTrailing on String {
  String trimLeading(String pattern) {
    if (pattern.isEmpty) return this;
    var i = 0;
    while (startsWith(pattern, i)) {
      i += pattern.length;
    }

    return substring(i);
  }
}
