import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/messages_data.dart';
import '../services/message_service.dart';

class AddEditSeries extends StatefulWidget {
  final SeriesModel? series;

  const AddEditSeries({super.key, this.series});

  bool get isEditing => series != null;

  @override
  State<AddEditSeries> createState() => _AddEditSeriesState();
}

class _AddEditSeriesState extends State<AddEditSeries> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;

  bool _isUploadingImage = false;

  bool _imageUploaded = false;

  String? _selectedImageName;

  String _imageUrl = '';

  @override
  void initState() {
    super.initState();

    final series = widget.series;

    _titleController = TextEditingController(text: series?.seriesTitle ?? '');

    if (series != null) {
      _imageUrl = series.seriesImage;

      if (_imageUrl.trim().isNotEmpty) {
        _imageUploaded = true;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();

    super.dispose();
  }

  // ==========================================================
  // PICK SERIES IMAGE
  // ==========================================================

  Future<void> _pickImage() async {
    if (_isUploadingImage) {
      return;
    }

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
      );

      if (result.isEmpty) {
        return;
      }

      final file = result.single;

      final extension = file.extension?.toLowerCase();

      const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

      if (extension == null || !allowedExtensions.contains(extension)) {
        _showError('Please select a JPG, JPEG, PNG, or WebP image.');

        return;
      }

      if (file.path == null || file.path!.isEmpty) {
        _showError('Unable to access the selected image.');

        return;
      }

      final localFile = File(file.path!);

      if (!await localFile.exists()) {
        _showError('The selected image could not be found.');

        return;
      }

      final Uint8List bytes = await localFile.readAsBytes();

      if (bytes.isEmpty) {
        _showError('The selected image is empty.');

        return;
      }

      final contentType = _contentTypeForExtension(extension);

      setState(() {
        _isUploadingImage = true;
        _imageUploaded = false;
        _selectedImageName = file.name;
      });

      final imageUrl = await MessageService.instance.uploadFile(
        bytes: bytes,
        fileName: file.name,
        contentType: contentType,
        folder: 'series_images',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _imageUrl = imageUrl;
        _imageUploaded = true;
        _isUploadingImage = false;
        _selectedImageName = file.name;
      });

      Get.snackbar(
        'Image Uploaded',
        'Series image uploaded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e, stackTrace) {
      debugPrint('Series image upload error: $e');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingImage = false;
        _imageUploaded = _imageUrl.trim().isNotEmpty;
        _selectedImageName = null;
      });

      _showError('Unable to upload the series image. Please try again.');
    }
  }

  // ==========================================================
  // CONTENT TYPE
  // ==========================================================

  String _contentTypeForExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      default:
        return 'application/octet-stream';
    }
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Future<void> _save() async {
    if (_isUploadingImage) {
      return;
    }

    if (!_imageUploaded || _imageUrl.trim().isEmpty) {
      _showError('Please upload a series image first.');

      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final series = SeriesModel(
        id: widget.series?.id ?? '',
        seriesTitle: _titleController.text.trim(),
        seriesImage: _imageUrl.trim(),
      );

      if (widget.isEditing) {
        await MessageService.instance.updateSeries(series);
      } else {
        final id = await MessageService.instance.addSeries(series);

        // Return the newly created model with Firestore ID.
        final savedSeries = SeriesModel(
          id: id,
          seriesTitle: series.seriesTitle,
          seriesImage: series.seriesImage,
        );

        if (!mounted) {
          return;
        }

        Get.back(result: savedSeries);

        Get.snackbar(
          'Added',
          'Series added successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );

        return;
      }

      if (!mounted) {
        return;
      }

      Get.back(result: series);

      Get.snackbar(
        'Updated',
        'Series updated successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e, stackTrace) {
      debugPrint('Save series error: $e');
      debugPrint('$stackTrace');

      _showError('Unable to save the series.');
    }
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    final canSubmit =
        !_isUploadingImage && _imageUploaded && _imageUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF171717),
        title: Text(
          isEditing ? 'Edit Series' : 'Add Series',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            _sectionTitle(
              icon: Icons.video_collection_outlined,
              title: 'Series Information',
            ),

            const SizedBox(height: 12),

            _field(
              controller: _titleController,
              label: 'Series Title',
              hint: 'Enter series title',
              icon: Icons.title_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the series title.';
                }

                return null;
              },
            ),

            const SizedBox(height: 26),

            _sectionTitle(icon: Icons.image_outlined, title: 'Series Image'),

            const SizedBox(height: 12),

            _imagePicker(),

            const SizedBox(height: 30),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: canSubmit ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3157D5),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.grey.shade600,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),

                    const SizedBox(width: 9),

                    Text(
                      isEditing ? 'Save Changes' : 'Add Series',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // IMAGE PICKER
  // ==========================================================

  Widget _imagePicker() {
    final hasImage = _imageUploaded && _imageUrl.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isUploadingImage ? null : _pickImage,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasImage ? Colors.green.shade300 : Colors.transparent,
                width: hasImage ? 1.5 : 0,
              ),
            ),
            child: _buildImageContent(hasImage),
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Icon(
              hasImage
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              size: 15,
              color: hasImage ? Colors.green.shade700 : Colors.grey.shade600,
            ),

            const SizedBox(width: 6),

            Expanded(
              child: Text(
                _isUploadingImage
                    ? 'Uploading image...'
                    : hasImage
                    ? 'Series image uploaded successfully.'
                    : 'Recommended: JPG, PNG, or WebP.',
                style: TextStyle(
                  fontSize: 11,
                  color: _isUploadingImage
                      ? const Color(0xFF3157D5)
                      : hasImage
                      ? Colors.green.shade700
                      : Colors.grey.shade600,
                  fontWeight: hasImage || _isUploadingImage
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageContent(bool hasImage) {
    if (_isUploadingImage) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF3157D5),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Uploading image...',
            style: TextStyle(
              color: Color(0xFF3157D5),
              fontWeight: FontWeight.w600,
            ),
          ),

          if (_selectedImageName != null) ...[
            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _selectedImageName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
          ],
        ],
      );
    }

    if (hasImage) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              _imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _imagePlaceholder(hasExistingImage: true);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3157D5)),
                );
              },
            ),
          ),

          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 15, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'Change',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return _imagePlaceholder(hasExistingImage: false);
  }

  Widget _imagePlaceholder({required bool hasExistingImage}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            size: 32,
            color: Color(0xFF3157D5),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          hasExistingImage ? 'Image unavailable' : 'Tap to select series image',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 5),

        Text(
          hasExistingImage
              ? 'Tap to select another image'
              : 'JPG, PNG, JPEG or WebP',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2FF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: const Color(0xFF3157D5), size: 21),
        ),

        const SizedBox(width: 11),

        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  // ==========================================================
  // FIELD
  // ==========================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF3157D5), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
