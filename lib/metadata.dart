import 'dart:io';

import 'package:merloc/merloc.dart';
import 'package:path/path.dart';

class MetaItem {
  final String locale;
  final String path;
  final FileType fileType;
  final List<String> keys;

  MetaItem({
    required this.locale,
    required this.path,
    required this.fileType,
    required this.keys,
  });

  Map<String, dynamic> toJson() {
    return {
      "locale": locale,
      "path": path,
      "fileType": fileType,
      "keys": keys,
    };
  }
}

class Metadata {
  final String inputFolder;
  final List<String> locales;

  Metadata({required this.inputFolder, required this.locales});

  List<MetaItem> loadListMeta() {
    final dir = Directory(inputFolder);
    final listDir = dir.listSync(recursive: true);

    final metas = <MetaItem>[];
    for (var item in listDir) {
      final filename = basename(item.path);
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
      final pathFile = item.path
          .substring(inputFolder.length)
          .trimLeading('\\')
          .trimLeading('/');
      final objectKeys = split(pathFile)..removeLast();

      // Append Meta
      metas.add(MetaItem(
        locale: fileParts[0],
        path: item.path,
        fileType: fileType,
        keys: objectKeys,
      ));
    }

    metas.sort((a, b) {
      return a.keys.length - b.keys.length;
    });

    return metas;
  }
}
