import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Captures a patient photo or a photographed document (e.g. ID
/// proof) via [image_picker], then copies it into the app's own
/// documents folder so it survives independent of wherever the OS
/// picker's temp file lives. Gallery/file-selection source only —
/// [ImageSource.camera] isn't reliably available on Windows desktop,
/// so this sticks to the cross-platform-safe path.
class PatientMediaService {
  PatientMediaService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<Directory> _photosDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(documentsDir.path, 'aks_medicare_patient_photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Returns the new local file path, or null if the user cancelled.
  static Future<String?> pickAndSaveImage({required String filePrefix}) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (picked == null) return null;

    final dir = await _photosDirectory();
    final extension = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
    final destPath = p.join(
      dir.path,
      '${filePrefix}_${DateTime.now().millisecondsSinceEpoch}$extension',
    );

    await File(picked.path).copy(destPath);
    return destPath;
  }
}
