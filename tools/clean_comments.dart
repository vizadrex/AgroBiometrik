import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    print('lib folder not found');
    return;
  }

  int count = 0;
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = entity.readAsStringSync();
      final lines = content.split('\n');
      final newLines = <String>[];

      for (var line in lines) {
        String l = line;
        
        if (l.contains('///')) {
          newLines.add(line);
          continue;
        }

        var idx = l.indexOf('//');
        
        while (idx != -1) {
          if (idx > 0 && l[idx - 1] == ':') {
             idx = l.indexOf('//', idx + 2);
          } else {
             break;
          }
        }

        if (idx != -1) {
          final prefix = l.substring(0, idx).trimRight();
          if (prefix.trim().isNotEmpty) {
            newLines.add(prefix);
          }
        } else {
          newLines.add(line);
        }
      }

      final newContent = newLines.join('\n');
      if (newContent != content) {
        entity.writeAsStringSync(newContent);
        count++;
        print('Cleaned: ${entity.path}');
      }
    }
  }
  print('Total cleaned files: $count');
}
