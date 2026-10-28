import 'package:flutter/material.dart';
import 'app.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.initialize();
  runApp(StudyFlowApp(storage: storage));
}
