import 'dart:io';

import 'package:merloc/merloc.dart';

// first argument is input folder and second is output folder
void main(List<String> arguments) {
  if (arguments.length < 2 || arguments.length > 2) {
    stderr.writeln('Arguments should follow package format!\n');
    helpMessage();
    exit(1);
  }

  final inputFolder = arguments[0];
  final outputFolder = arguments[1];
  final merloc = Merloc(input: inputFolder, output: outputFolder);
  try {
    merloc.loadLocales();
    merloc.loadLocalization();
    merloc.writeOutput();
  } catch (e) {
    stderr.writeln("Error Occured!");
    stderr.writeln(e.toString());
  }
}

void helpMessage() {
  stdout.writeln("Command Line Format:");
  stdout.writeln(
      "merloc [input folder localization] [output folder localization]\n");
  stdout.writeln("Note:");
  stdout.writeln("- Input Support both json and yaml");
  stdout.writeln("- Output only emit json for now");
}
