import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudflare_r2/cloudflare_r2.dart';
import 'package:flutter/material.dart';

import '../consts/messages_data.dart';

class MessageService {
  MessageService._();

  static final MessageService instance = MessageService._();

  // ==========================================================
  // FIRESTORE
  // ==========================================================

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==========================================================
  // CLOUDFLARE R2
  // ==========================================================

  static const String accountId = '1fba4f4f8af19dab0b312ab32537657a';

  static const String bucketName = 'messages';

  static const String publicR2Url =
      'https://pub-66782e6699ae4a029a932352ac62598b.r2.dev';

  // ==========================================================
  // INITIALIZE R2
  // ==========================================================

  void initializeR2({
    required String accessKeyId,
    required String secretAccessKey,
  }) {
    CloudFlareR2.init(
      accountId: accountId,
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
    );

    debugPrint('========== R2 INITIALIZED ==========');
    debugPrint('Account: $accountId');
    debugPrint('Bucket: $bucketName');
  }

  // ==========================================================
  // TEST R2
  // ==========================================================

  Future<void> testR2() async {
    try {
      final objects = await CloudFlareR2.listObjectsV2(bucket: bucketName);

      debugPrint('========== R2 TEST ==========');
      debugPrint('SUCCESS');
      debugPrint('Objects: ${objects.length}');

      for (final object in objects) {
        debugPrint('Object: ${object.key}');
      }
    } catch (e, stackTrace) {
      debugPrint('========== R2 TEST ERROR ==========');
      debugPrint('ERROR: $e');
      debugPrint('$stackTrace');
    }
  }

  // ==========================================================
  // GENERIC R2 UPLOAD
  //
  // IMPORTANT:
  // Do NOT use _safeFileName() here.
  //
  // _safeFileName() is PDF-specific and automatically adds
  // ".pdf". Generic files must preserve their extension.
  // ==========================================================

  Future<String> uploadFile({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    String folder = 'uploads',
  }) async {
    if (bytes.isEmpty) {
      throw Exception('Cannot upload an empty file.');
    }

    final safeName = _safeUploadFileName(fileName);

    final objectName =
        '$folder/'
        '${DateTime.now().millisecondsSinceEpoch}_'
        '$safeName';

    debugPrint('========== R2 FILE UPLOAD ==========');
    debugPrint('Bucket: $bucketName');
    debugPrint('Folder: $folder');
    debugPrint('Original name: $fileName');
    debugPrint('Safe name: $safeName');
    debugPrint('Object: $objectName');
    debugPrint('Content type: $contentType');
    debugPrint('File size: ${bytes.length} bytes');

    try {
      await CloudFlareR2.putObject(
        bucket: bucketName,
        objectName: objectName,
        objectBytes: bytes,
        contentType: contentType,
      );

      final statusCode = CloudFlareR2.statusCode;

      debugPrint('R2 status: $statusCode');

      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final url = '$publicR2Url/$objectName';

        debugPrint('UPLOAD SUCCESS');
        debugPrint('URL: $url');

        return url;
      }

      throw Exception('R2 upload failed. Status code: $statusCode');
    } catch (e, stackTrace) {
      debugPrint('R2 FILE UPLOAD ERROR: $e');
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  // ==========================================================
  // UPLOAD PDF
  // ==========================================================

  Future<String> uploadPdf({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.isEmpty) {
      throw Exception('Cannot upload an empty PDF.');
    }

    final safeName = _safePdfFileName(fileName);

    final objectName =
        'message_notes/'
        '${DateTime.now().millisecondsSinceEpoch}_'
        '$safeName';

    debugPrint('========== R2 PDF UPLOAD ==========');
    debugPrint('Bucket: $bucketName');
    debugPrint('Object: $objectName');
    debugPrint('File size: ${bytes.length} bytes');

    try {
      await CloudFlareR2.putObject(
        bucket: bucketName,
        objectName: objectName,
        objectBytes: bytes,
        contentType: 'application/pdf',
      );

      final statusCode = CloudFlareR2.statusCode;

      debugPrint('R2 status: $statusCode');

      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final url = '$publicR2Url/$objectName';

        debugPrint('PDF UPLOAD SUCCESS');
        debugPrint('URL: $url');

        return url;
      }

      throw Exception('R2 PDF upload failed. Status code: $statusCode');
    } catch (e, stackTrace) {
      debugPrint('R2 PDF UPLOAD ERROR: $e');
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  // ==========================================================
  // UPLOAD SERIES IMAGE
  // ==========================================================

  Future<String> uploadSeriesImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.isEmpty) {
      throw Exception('Cannot upload an empty image.');
    }

    final safeName = _safeImageFileName(fileName);

    final objectName =
        'series_images/'
        '${DateTime.now().millisecondsSinceEpoch}_'
        '$safeName';

    final contentType = _imageContentType(safeName);

    debugPrint('========== R2 SERIES IMAGE UPLOAD ==========');
    debugPrint('Bucket: $bucketName');
    debugPrint('Original name: $fileName');
    debugPrint('Safe name: $safeName');
    debugPrint('Object: $objectName');
    debugPrint('Content type: $contentType');
    debugPrint('File size: ${bytes.length} bytes');

    try {
      await CloudFlareR2.putObject(
        bucket: bucketName,
        objectName: objectName,
        objectBytes: bytes,
        contentType: contentType,
      );

      final statusCode = CloudFlareR2.statusCode;

      debugPrint('R2 status: $statusCode');

      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        final url = '$publicR2Url/$objectName';

        debugPrint('SERIES IMAGE UPLOAD SUCCESS');
        debugPrint('URL: $url');

        return url;
      }

      throw Exception(
        'R2 series image upload failed. '
        'Status code: $statusCode',
      );
    } catch (e, stackTrace) {
      debugPrint('R2 SERIES IMAGE ERROR: $e');
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  // ==========================================================
  // ADD MESSAGE
  // ==========================================================

  Future<String> addMessage(MessageModel message) async {
    final document = await _firestore
        .collection('Messages')
        .add(message.toFirestore());

    debugPrint('Message added successfully: ${document.id}');

    return document.id;
  }

  // ==========================================================
  // UPDATE MESSAGE
  // ==========================================================

  Future<void> updateMessage(MessageModel message) async {
    if (message.id.isEmpty) {
      throw Exception('Cannot update a message without an ID.');
    }

    await _firestore
        .collection('Messages')
        .doc(message.id)
        .update(message.toFirestore());

    debugPrint('Message updated successfully: ${message.id}');
  }

  // ==========================================================
  // DELETE MESSAGE
  //
  // Deletes:
  //
  // 1. PDF from R2
  // 2. Firestore message
  // ==========================================================

  Future<void> deleteMessage(MessageModel message) async {
    if (message.id.isEmpty) {
      throw Exception('Cannot delete a message without an ID.');
    }

    debugPrint('========== DELETE MESSAGE ==========');
    debugPrint('Message ID: ${message.id}');
    debugPrint('Title: ${message.messageTitle}');

    // ----------------------------------------------------------
    // Delete PDF first
    // ----------------------------------------------------------

    if (message.messageNotes.trim().isNotEmpty) {
      try {
        await deletePdfFromR2(message.messageNotes.trim());
      } catch (e) {
        debugPrint('WARNING: Message PDF could not be deleted: $e');

        // We intentionally continue.
        //
        // The Firestore message can still be deleted even if
        // the R2 object could not be removed.
      }
    }

    // ----------------------------------------------------------
    // Delete Firestore document
    // ----------------------------------------------------------

    await _firestore.collection('Messages').doc(message.id).delete();

    debugPrint('MESSAGE DELETE SUCCESS');
  }

  // ==========================================================
  // REAL-TIME MESSAGES
  // ==========================================================

  Stream<List<MessageModel>> messagesStream() {
    return _firestore
        .collection('Messages')
        .orderBy('messageDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(MessageModel.fromFirestore).toList();
        });
  }

  // ==========================================================
  // ADD SERIES
  // ==========================================================

  Future<String> addSeries(SeriesModel series) async {
    final document = await _firestore
        .collection('Series')
        .add(series.toFirestore());

    debugPrint('Series added successfully: ${document.id}');

    return document.id;
  }

  // ==========================================================
  // UPDATE SERIES
  // ==========================================================

  Future<void> updateSeries(SeriesModel series) async {
    if (series.id.isEmpty) {
      throw Exception('Cannot update a series without an ID.');
    }

    await _firestore
        .collection('Series')
        .doc(series.id)
        .update(series.toFirestore());

    debugPrint('Series updated successfully: ${series.id}');
  }

  // ==========================================================
  // DELETE SERIES
  //
  // Deletes:
  //
  // 1. Series image from R2
  // 2. Firestore series document
  // ==========================================================

  Future<void> deleteSeries(SeriesModel series) async {
    if (series.id.isEmpty) {
      throw Exception('Cannot delete a series without an ID.');
    }

    debugPrint('========== DELETE SERIES ==========');
    debugPrint('Series ID: ${series.id}');
    debugPrint('Title: ${series.seriesTitle}');

    // ----------------------------------------------------------
    // Delete image from R2
    // ----------------------------------------------------------

    if (series.seriesImage.trim().isNotEmpty) {
      try {
        await deleteR2Object(series.seriesImage.trim());
      } catch (e) {
        debugPrint('WARNING: Series image could not be deleted: $e');

        // Continue deleting the Firestore document.
      }
    }

    // ----------------------------------------------------------
    // Delete Firestore document
    // ----------------------------------------------------------

    await _firestore.collection('Series').doc(series.id).delete();

    debugPrint('SERIES DELETE SUCCESS');
  }

  // ==========================================================
  // REAL-TIME SERIES
  // ==========================================================

  Stream<List<SeriesModel>> seriesStream() {
    return _firestore.collection('Series').snapshots().map((snapshot) {
      return snapshot.docs.map(SeriesModel.fromFirestore).toList();
    });
  }

  // ==========================================================
  // DELETE PDF FROM R2
  // ==========================================================

  Future<void> deletePdfFromR2(String pdfUrl) async {
    if (pdfUrl.trim().isEmpty) {
      return;
    }

    debugPrint('========== R2 PDF DELETE ==========');

    await deleteR2Object(pdfUrl);
  }

  // ==========================================================
  // DELETE R2 OBJECT
  //
  // Accepts a full public R2 URL:
  //
  // https://pub-xxx.r2.dev/message_notes/123_file.pdf
  //
  // Extracts:
  //
  // message_notes/123_file.pdf
  // ==========================================================

  Future<void> deleteR2Object(String objectUrl) async {
    if (objectUrl.trim().isEmpty) {
      return;
    }

    final objectName = _extractR2ObjectName(objectUrl);

    if (objectName == null || objectName.isEmpty) {
      throw Exception('Could not extract R2 object name from URL: $objectUrl');
    }

    debugPrint('========== R2 DELETE ==========');
    debugPrint('Bucket: $bucketName');
    debugPrint('URL: $objectUrl');
    debugPrint('Object: $objectName');

    try {
      await CloudFlareR2.deleteObject(
        bucket: bucketName,
        objectName: objectName,
      );

      final statusCode = CloudFlareR2.statusCode;

      debugPrint('R2 delete status: $statusCode');

      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        debugPrint('R2 DELETE SUCCESS');
        return;
      }

      throw Exception('R2 delete failed. Status code: $statusCode');
    } catch (e, stackTrace) {
      debugPrint('R2 DELETE ERROR: $e');
      debugPrint('$stackTrace');

      rethrow;
    }
  }

  // ==========================================================
  // SAFE PDF FILE NAME
  // ==========================================================

  String _safePdfFileName(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    if (cleaned.isEmpty) {
      return 'message_notes.pdf';
    }

    if (!cleaned.toLowerCase().endsWith('.pdf')) {
      return '$cleaned.pdf';
    }

    return cleaned;
  }

  // ==========================================================
  // SAFE IMAGE FILE NAME
  //
  // IMPORTANT:
  // This does NOT add ".pdf".
  // ==========================================================

  String _safeImageFileName(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    if (cleaned.isEmpty) {
      return 'series_image.jpg';
    }

    return cleaned;
  }

  // ==========================================================
  // SAFE GENERIC FILE NAME
  //
  // Preserves the original extension.
  // ==========================================================

  String _safeUploadFileName(String name) {
    final cleaned = name.trim().replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');

    if (cleaned.isEmpty) {
      return 'upload';
    }

    return cleaned;
  }

  // ==========================================================
  // IMAGE CONTENT TYPE
  // ==========================================================

  String _imageContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      case 'gif':
        return 'image/gif';

      case 'bmp':
        return 'image/bmp';

      case 'svg':
        return 'image/svg+xml';

      case 'heic':
        return 'image/heic';

      case 'heif':
        return 'image/heif';

      default:
        return 'application/octet-stream';
    }
  }

  // ==========================================================
  // EXTRACT R2 OBJECT NAME
  // ==========================================================

  String? _extractR2ObjectName(String url) {
    final trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty) {
      return null;
    }

    // --------------------------------------------------------
    // Normal public R2 URL
    //
    // https://pub-xxx.r2.dev/series_images/image.jpg
    //
    // -> series_images/image.jpg
    // --------------------------------------------------------

    if (trimmedUrl.startsWith('$publicR2Url/')) {
      return trimmedUrl.substring('$publicR2Url/'.length);
    }

    // --------------------------------------------------------
    // Fallback for any valid URL
    // --------------------------------------------------------

    final uri = Uri.tryParse(trimmedUrl);

    if (uri == null) {
      return null;
    }

    var path = uri.path;

    if (path.isEmpty || path == '/') {
      return null;
    }

    if (path.startsWith('/')) {
      path = path.substring(1);
    }

    if (path.isEmpty) {
      return null;
    }

    // Decode URL-encoded characters.
    return Uri.decodeComponent(path);
  }
}
