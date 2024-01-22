import 'dart:convert';
import 'dart:io';

import 'package:merloc/Locales.dart';
import 'package:merloc/metadata.dart';
import 'package:merloc/yaml.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:path/path.dart' as path;

enum FileType { none, json, yaml }

class Merloc {
  final String input;
  final String output;
  final List<String> locales = [];
  final Map<String, Map> translations = {};

  Merloc({
    required this.input,
    required this.output,
  });

  // Load Locales File
  void loadLocales() {
    final locale = Locale(inputFolder: input);

    locales.addAll(locale.loadLocales());

    for (var item in locales) {
      translations[item] = {};
    }
  }

  // Covert list of directory and file into a Metadata
  void loadTranslations() {
    // Load Metadata
    final meta = Metadata(inputFolder: input, locales: locales);
    final metaItems = meta.loadListMeta();

    // Load File
    for (var item in metaItems) {
      stdout.writeln("Path : " + item.path);

      loadFile(item);
    }
  }

  void writeOutput() {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    for (var locale in locales) {
      final file = File(path.join(output, '$locale.json'));

      file.writeAsString(encoder.convert(translations[locale]));
    }
  }

  void loadFile(MetaItem item) {
    final locale = item.locale;
    final path = item.path;
    final fileType = item.fileType;
    final keys = item.keys;
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

    appendData(temp, data);
  }

  // Key always a string
  // Doesn't need to worry about it
  void appendData(Map temp, Map data) {
    if (data.isEmpty) {
      return;
    }

    if (temp.isEmpty) {
      return temp.addAll(data);
    }

    // Key should be a string
    for (var key in data.keys) {
      // Check if data item is a primitive type
      var item = data[key];
      if (!(item is Map)) {
        temp[key] = item;
        continue;
      }

      // If key is not exist
      if (!temp.containsKey(key)) {
        temp[key] = data;
        continue;
      }

      // Check if temp item is primitype type
      var tempItem = temp[key];
      if (!(tempItem is Map)) {
        temp[key] = data;
        continue;
      }

      appendData(
        tempItem,
        item,
      );
    }
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
