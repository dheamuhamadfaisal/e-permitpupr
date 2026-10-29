import 'package:flutter_test/flutter_test.dart';

String normalizeUrl(String input) {
  var trimmed = input.trim();
  if (trimmed.isEmpty) return trimmed;
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    trimmed = 'https://$trimmed';
  }
  return trimmed;
}

bool isLikelyFilename(String text) {
  final lower = text.toLowerCase().trim();
  if (!lower.contains('/')) {
    return lower.endsWith('.pdf') ||
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.dwg') ||
        lower.endsWith('.shp') ||
        lower.endsWith('.zip') ||
        lower.endsWith('.rar') ||
        lower.endsWith('.kml') ||
        lower.endsWith('.kmz');
  }
  return false;
}

bool isValidUrl(String? input) {
  if (input == null || input.trim().isEmpty) return false;
  final trimmed = input.trim();

  if (isLikelyFilename(trimmed) &&
      !trimmed.startsWith('http://') &&
      !trimmed.startsWith('https://')) {
    return false;
  }

  final normalized = normalizeUrl(trimmed);
  final uri = Uri.tryParse(normalized);
  if (uri == null) return false;
  if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) return false;
  if (uri.host.isEmpty || !uri.host.contains('.')) return false;
  if (uri.host.contains(' ')) return false;

  final parts = uri.host.split('.');
  if (parts.last.length < 2) return false;

  return true;
}

void main() {
  group('Link URL Validation for KRK and Siteplan Form', () {
    test('Valid Google Drive URLs should pass', () {
      expect(isValidUrl('https://drive.google.com/drive/folders/1a2b3c4d5e'), isTrue);
      expect(isValidUrl('http://drive.google.com/file/d/123/view'), isTrue);
      expect(isValidUrl('drive.google.com/file/d/123'), isTrue);
      expect(isValidUrl('https://docs.google.com/spreadsheets/d/abc/edit'), isTrue);
    });

    test('Valid cloud storage URLs should pass', () {
      expect(isValidUrl('https://www.dropbox.com/s/abcdef/polygon.kml'), isTrue);
      expect(isValidUrl('dropbox.com/s/abcdef/siteplan.dwg'), isTrue);
      expect(isValidUrl('https://onedrive.live.com/?id=123'), isTrue);
    });

    test('Plain text, non-links, or invalid formats should fail', () {
      expect(isValidUrl(''), isFalse);
      expect(isValidUrl('   '), isFalse);
      expect(isValidUrl(null), isFalse);
      expect(isValidUrl('coba'), isFalse);
      expect(isValidUrl('sudah dikirim di wa'), isFalse);
      expect(isValidUrl('tidak memakai link'), isFalse);
      expect(isValidUrl('google drive'), isFalse);
    });

    test('Filename alone without web URL should fail', () {
      expect(isValidUrl('dokumen.pdf'), isFalse);
      expect(isValidUrl('siteplan.dwg'), isFalse);
      expect(isValidUrl('polygon.kml'), isFalse);
      expect(isValidUrl('berkas.shp'), isFalse);
      expect(isValidUrl('arsip.zip'), isFalse);
    });

    test('Full URL containing filename path should still pass', () {
      expect(isValidUrl('https://example.com/files/polygon.kml'), isTrue);
      expect(isValidUrl('https://storage.garutkab.go.id/dwg/siteplan.dwg'), isTrue);
    });
  });
}
