import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

Future<void> _ensureServerRunning() async {
  if (kIsWeb) return;
  if (!Platform.isWindows) return;

  try {
    final socket = await Socket.connect('127.0.0.1', 8000,
        timeout: const Duration(milliseconds: 600));
    socket.destroy();
    return; // Port 8000 is already active
  } catch (_) {
    // Port 8000 is not reachable; launch backend server
    try {
      final currentDir = Directory.current.path;
      final pythonCandidates = [
        'backend\\venv\\Scripts\\python.exe',
        '$currentDir\\backend\\venv\\Scripts\\python.exe',
        '..\\backend\\venv\\Scripts\\python.exe',
      ];

      for (final p in pythonCandidates) {
        final f = File(p);
        if (f.existsSync()) {
          final backendDir = File('$currentDir\\backend\\app\\main.py').existsSync()
              ? '$currentDir\\backend'
              : 'backend';

          await Process.start(
            f.path,
            ['-m', 'uvicorn', 'app.main:app', '--app-dir', backendDir, '--host', '0.0.0.0', '--port', '8000'],
            environment: {'PYTHONPATH': backendDir},
            mode: ProcessStartMode.detached,
          );
          await Future.delayed(const Duration(milliseconds: 1500));
          break;
        }
      }
    } catch (_) {}
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ensureServerRunning();
  runApp(
    const ProviderScope(
      child: NammaOoruApp(),
    ),
  );
}
