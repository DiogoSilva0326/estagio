import 'csv_exporter_stub.dart'
    if (dart.library.io) 'csv_exporter_io.dart'
    if (dart.library.html) 'csv_exporter_web.dart' as impl;

Future<String> exportCsvFile({
  required String fileName,
  required String content,
}) {
  return impl.exportCsvFile(fileName: fileName, content: content);
}