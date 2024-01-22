import 'dart:convert';
import 'dart:io';

import 'package:merloc/yaml.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as path;

class Locale {
  final String inputFolder;

  Locale({required this.inputFolder});

  List<String> loadLocales() {
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

    return locales;
  }

  List<String>? loadLocalesFile() {
    var file = File(path.join(inputFolder, "localization.yaml"));
    if (file.existsSync()) {
      final localeList =
          (yaml.loadYaml(file.readAsStringSync()) as yaml.YamlMap)
              .toMap()["locales"] as List;
      return localeList.map((e) => (e as String)).toList();
    }

    file = File(path.join(inputFolder, "localization.json"));
    if (file.existsSync()) {
      final localeList =
          json.decode(file.readAsStringSync())["locales"] as List;
      return localeList.map((e) => e as String).toList();
    }

    return null;
  }
}
