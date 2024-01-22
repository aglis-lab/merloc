import 'dart:io';

import 'package:merloc/merloc.dart';

void main(List<String> arguments) {
  if (arguments.length == 0) {
    stderr.writeln('Arguments should follow package format!\n');
    helpMessage();
    exit(1);
  }

  var inputFolder = "";
  var outputFolder = "";
  if (arguments.length == 1) {
    inputFolder = arguments[0];
    outputFolder = arguments[0];
  } else {
    inputFolder = arguments[0];
    outputFolder = arguments[1];
  }

  final merloc = Merloc(
    input: inputFolder,
    output: outputFolder,
  );
  try {
    stdout.writeln("load localization config file...");
    merloc.loadLocales();

    stdout.writeln("load all translations...");
    merloc.loadTranslations();

    stdout.writeln("merge and create ourput...");
    merloc.writeOutput();

    stdout.writeln("finish merge localization...");
  } catch (e) {
    stderr.writeln("Error Occured!");
    stderr.writeln(e.toString());
  }
}

void helpMessage() {
  stdout.writeln("Command Line Format:");
  stdout.writeln(
      "Generate New Localization: merloc [input folder localization] [output folder localization]\n");
  stdout.writeln(
      "Append Output Localization: merloc -a [input folder localization] [output folder localization]\n");
  stdout.writeln(
      "Append Input Localization: merloc -ap [input folder localization]\n");
  stdout.writeln("Note:");
  stdout.writeln("- Input Support both json and yaml");
  stdout.writeln("- Output only emit json for now");
}
