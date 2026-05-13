import 'dart:io';

Future<String> exportCsvFile({
  required String fileName,
  required String content,
}) async {
  final sanitizedName = fileName.trim().isEmpty ? 'export.csv' : fileName.trim();
  final homePath = Platform.environment['HOME'];
  final downloadsDirectory =
      homePath == null ? null : Directory('$homePath/Downloads');

  Directory targetDirectory;
  if (downloadsDirectory != null && await downloadsDirectory.exists()) {
    targetDirectory = downloadsDirectory;
  } else {
    targetDirectory = Directory.systemTemp;
  }

  final file = File('${targetDirectory.path}/$sanitizedName');
  await file.writeAsString(content);
  return file.path;
}