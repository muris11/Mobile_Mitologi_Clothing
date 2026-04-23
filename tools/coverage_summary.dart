import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('Coverage file not found');
    return;
  }

  final content = file.readAsStringSync();
  final files = content.split('SF:');

  int totalLines = 0;
  int coveredLines = 0;
  Map<String, Map<String, int>> fileStats = {};

  for (var i = 1; i < files.length; i++) {
    final section = files[i];
    final lines = section.split('\n');
    final fileName = lines[0].trim();

    int fileTotal = 0;
    int fileCovered = 0;

    for (var line in lines) {
      if (line.startsWith('DA:')) {
        fileTotal++;
        final parts = line.split(',');
        final hit = int.tryParse(parts[1]) ?? 0;
        if (hit > 0) fileCovered++;
      }
    }

    totalLines += fileTotal;
    coveredLines += fileCovered;

    if (fileTotal > 0) {
      fileStats[fileName] = {
        'total': fileTotal,
        'covered': fileCovered,
        'percentage': (fileCovered * 100 ~/ fileTotal)
      };
    }
  }

  final overallPercentage = totalLines > 0
      ? (coveredLines / totalLines * 100).toStringAsFixed(1)
      : '0.0';

  print('');
  print('╔════════════════════════════════════════════════════════════╗');
  print('║      MITOLOGI CLOTHING - TEST COVERAGE REPORT              ║');
  print('╚════════════════════════════════════════════════════════════╝');
  print('');
  print('📊 OVERALL COVERAGE: ${overallPercentage}%');
  print('   Lines Covered: ${coveredLines} / ${totalLines}');
  print('   Total Files: ${fileStats.length}');
  print('');
  print('📁 COVERAGE BY MODULE:');
  print('');

  final modules = <String, List<Map<String, dynamic>>>{
    'services': [],
    'providers': [],
    'screens': [],
    'utils': [],
    'models': [],
    'widgets': [],
    'other': []
  };

  fileStats.forEach((file, stats) {
    final normalizedFile = file.replaceAll('\\', '/');
    final category = normalizedFile.contains('/services/')
        ? 'services'
        : normalizedFile.contains('/providers/')
            ? 'providers'
            : normalizedFile.contains('/screens/')
                ? 'screens'
                : normalizedFile.contains('/utils/')
                    ? 'utils'
                    : normalizedFile.contains('/models/')
                        ? 'models'
                        : normalizedFile.contains('/widgets/')
                            ? 'widgets'
                            : 'other';

    modules[category]!.add({
      'file': file.split('/').last,
      'percentage': stats['percentage']
    });
  });

  modules.forEach((module, files) {
    if (files.isEmpty) return;
    final avg = files
            .map((f) => f['percentage'] as int)
            .reduce((a, b) => a + b) ~/
        files.length;
    final icon = avg >= 80
        ? '✅'
        : avg >= 50
            ? '⚠️ '
            : '❌';
    final bar = '█' * (avg ~/ 5) + '░' * (20 - (avg ~/ 5));
    print('  ${icon} ${module.padRight(12)} ${bar} ${avg.toString().padLeft(3)}% (${files.length} files)');
  });

  print('');
  print('🎯 Target: 80% minimum per module');
  print('════════════════════════════════════════════════════════════');
}
