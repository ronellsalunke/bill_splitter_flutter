class Endpoints {
  Endpoints._();

  static final baseUrl = 'https://bill-splitter.ksdfg.dev/api/v1';
  static final ocr = '$baseUrl/bills/ocr';
  static final split = '$baseUrl/bills/split';
  static const updateManifest = 'https://raw.githubusercontent.com/ronellsalunke/bill_splitter_flutter/master/update/latest.json';
  static const latestRelease = 'https://github.com/ronellsalunke/bill_splitter_flutter/releases/latest';
}
