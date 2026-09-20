import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/messages_data.dart';
import '../services/message_service.dart';

class AddEditMessage extends StatefulWidget {
  final MessageModel? message;

  const AddEditMessage({super.key, this.message});

  bool get isEditing => message != null;

  @override
  State<AddEditMessage> createState() => _AddEditMessageState();
}

class _AddEditMessageState extends State<AddEditMessage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _urlController;
  late final TextEditingController _lengthController;
  late final TextEditingController _seriesController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  late final TextEditingController _speakerController;

  /// Date of the actual message/sermon.
  DateTime _selectedMessageDate = DateTime.now();

  /// Date when this message was uploaded to the system.
  ///
  /// For a new message this is set when saving.
  /// For an existing message this is preserved.
  DateTime? _uploadDate;

  bool _isUploadingPdf = false;
  bool _pdfUploaded = false;

  String? _selectedPdfName;

  @override
  void initState() {
    super.initState();

    final message = widget.message;

    _titleController = TextEditingController(text: message?.messageTitle ?? '');

    _urlController = TextEditingController(text: message?.messageUrl ?? '');

    _lengthController = TextEditingController(
      text: message?.messageLength ?? '',
    );

    _seriesController = TextEditingController(
      text: message?.messageSeries ?? '',
    );

    _descriptionController = TextEditingController(
      text: message?.messageDescription ?? '',
    );

    _notesController = TextEditingController(text: message?.messageNotes ?? '');

    _speakerController = TextEditingController(
      text: message?.messageSpeaker ?? '',
    );

    // ==========================================================
    // EXISTING MESSAGE
    // ==========================================================

    if (message != null) {
      // This is the actual message/sermon date.
      _selectedMessageDate = message.messageDate;

      // IMPORTANT:
      // Preserve the original upload date when editing.
      _uploadDate = message.uploadDate;

      // Existing PDF URL means PDF requirement is satisfied.
      if (message.messageNotes.trim().isNotEmpty) {
        _pdfUploaded = true;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _lengthController.dispose();
    _seriesController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _speakerController.dispose();

    super.dispose();
  }

  // ==========================================================
  // PICK PDF
  // ==========================================================

  Future<void> _pickPdf() async {
    if (_isUploadingPdf) {
      return;
    }

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        allowMultiple: false,
      );

      if (result.isEmpty) {
        return;
      }

      final file = result.single;

      if (file.extension?.toLowerCase() != 'pdf') {
        _showError('Please select a PDF file.');
        return;
      }

      /*
       * Use file.path rather than file.bytes.
       *
       * This avoids the PlatformFile.bytes problem.
       */

      if (file.path == null || file.path!.isEmpty) {
        _showError('Unable to access the selected PDF.');
        return;
      }

      final localFile = File(file.path!);

      if (!await localFile.exists()) {
        _showError('The selected PDF could not be found.');
        return;
      }

      final Uint8List bytes = await localFile.readAsBytes();

      if (bytes.isEmpty) {
        _showError('The selected PDF is empty.');
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingPdf = true;
        _pdfUploaded = false;
        _selectedPdfName = file.name;

        _notesController.clear();
      });

      final pdfUrl = await MessageService.instance.uploadPdf(
        bytes: bytes,
        fileName: file.name,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _notesController.text = pdfUrl;
        _pdfUploaded = true;
        _isUploadingPdf = false;
      });

      Get.snackbar(
        'PDF Uploaded',
        'Message notes uploaded successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e, stackTrace) {
      debugPrint('PDF upload error: $e');
      debugPrint('$stackTrace');

      if (!mounted) {
        return;
      }

      setState(() {
        _isUploadingPdf = false;
        _pdfUploaded = false;
        _selectedPdfName = null;

        _notesController.clear();
      });

      _showError('Unable to upload the PDF. Please try again.');
    }
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Future<void> _save() async {
    if (_isUploadingPdf) {
      return;
    }

    // ========================================================
    // PDF VALIDATION
    // ========================================================

    if (!_pdfUploaded || _notesController.text.trim().isEmpty) {
      _showError('Please upload the message notes PDF first.');

      return;
    }

    // ========================================================
    // FORM VALIDATION
    // ========================================================

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final now = DateTime.now();

      /*
       * IMPORTANT DATE LOGIC
       *
       * messageDate:
       *   The date selected by the admin.
       *
       * uploadDate:
       *   New message -> now
       *   Existing message -> original uploadDate
       */

      final DateTime uploadDate = widget.isEditing && widget.message != null
          ? widget.message!.uploadDate
          : now;

      final message = MessageModel(
        id: widget.message?.id ?? '',

        messageTitle: _titleController.text.trim(),

        messageUrl: _urlController.text.trim(),

        messageLength: _lengthController.text.trim(),

        messageSeries: _seriesController.text.trim(),

        messageDescription: _descriptionController.text.trim(),

        // Actual sermon/message date.
        messageDate: _selectedMessageDate,

        // System upload date.
        uploadDate: uploadDate,

        messageNotes: _notesController.text.trim(),

        messageSpeaker: _speakerController.text.trim(),
      );

      // ========================================================
      // UPDATE
      // ========================================================

      if (widget.isEditing) {
        await MessageService.instance.updateMessage(message);
      }
      // ========================================================
      // ADD
      // ========================================================
      else {
        await MessageService.instance.addMessage(message);
      }

      if (!mounted) {
        return;
      }

      Get.back(result: message);

      Get.snackbar(
        widget.isEditing ? 'Updated' : 'Added',
        widget.isEditing
            ? 'Message updated successfully.'
            : 'Message added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e, stackTrace) {
      debugPrint('Save message error: $e');
      debugPrint('$stackTrace');

      _showError('Unable to save the message.');
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
  // SELECT MESSAGE DATE
  // ==========================================================

  Future<void> _selectMessageDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedMessageDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select Message Date',
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedMessageDate = pickedDate;
    });
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, '
        '${date.year}';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    final canSubmit =
        !_isUploadingPdf &&
        _pdfUploaded &&
        _notesController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF171717),
        title: Text(
          isEditing ? 'Edit Message' : 'Add Message',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            // ==================================================
            // MESSAGE INFORMATION
            // ==================================================
            _sectionTitle(
              icon: Icons.video_library_outlined,
              title: 'Message Information',
            ),

            const SizedBox(height: 12),

            _field(
              controller: _titleController,
              label: 'Message Title',
              hint: 'Enter message title',
              icon: Icons.title_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a message title.';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            _field(
              controller: _seriesController,
              label: 'Message Series',
              hint: 'Example: Faith Series',
              icon: Icons.video_collection_outlined,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the series.';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            _field(
              controller: _speakerController,
              label: 'Speaker',
              hint: 'Enter speaker name',
              icon: Icons.person_outline_rounded,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the speaker name.';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            // ==================================================
            // LENGTH + MESSAGE DATE
            // ==================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    controller: _lengthController,
                    label: 'Length',
                    hint: '42:15',
                    icon: Icons.timer_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(child: _messageDateField()),
              ],
            ),

            const SizedBox(height: 26),

            // ==================================================
            // VIDEO & NOTES
            // ==================================================
            _sectionTitle(icon: Icons.link_rounded, title: 'Video & Notes'),

            const SizedBox(height: 12),

            _field(
              controller: _urlController,
              label: 'YouTube URL',
              hint: 'https://youtube.com/watch?v=...',
              icon: Icons.play_circle_outline_rounded,
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter the YouTube URL.';
                }

                return null;
              },
            ),

            const SizedBox(height: 14),

            // ==================================================
            // PDF
            // ==================================================
            _pdfField(),

            const SizedBox(height: 26),

            // ==================================================
            // DESCRIPTION
            // ==================================================
            _sectionTitle(
              icon: Icons.description_outlined,
              title: 'Description',
            ),

            const SizedBox(height: 12),

            _field(
              controller: _descriptionController,
              label: 'Message Description',
              hint: 'Enter a short description...',
              icon: Icons.notes_rounded,
              maxLines: 5,
            ),

            const SizedBox(height: 30),

            // ==================================================
            // SAVE BUTTON
            // ==================================================
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
                      isEditing ? 'Save Changes' : 'Add Message',
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
  // PDF FIELD
  // ==========================================================

  Widget _pdfField() {
    final hasPdf = _pdfUploaded && _notesController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _isUploadingPdf ? null : _pickPdf,
          borderRadius: BorderRadius.circular(15),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Message Notes PDF',
              hintText: 'Pick PDF file',

              prefixIcon: const Icon(Icons.picture_as_pdf_outlined),

              suffixIcon: _isUploadingPdf
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF3157D5),
                        ),
                      ),
                    )
                  : Icon(
                      hasPdf
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      color: hasPdf ? Colors.green : const Color(0xFF3157D5),
                    ),

              filled: true,
              fillColor: Colors.white,

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),

            child: Text(
              _isUploadingPdf
                  ? 'Uploading PDF...'
                  : _selectedPdfName ??
                        (hasPdf ? 'PDF uploaded' : 'Tap to select PDF'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: _isUploadingPdf
                    ? const Color(0xFF3157D5)
                    : const Color(0xFF333333),
                fontWeight: hasPdf ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),

        if (hasPdf) ...[
          const SizedBox(height: 6),

          Text(
            'PDF uploaded successfully',
            style: TextStyle(
              fontSize: 11,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
  // MESSAGE DATE FIELD
  // ==========================================================

  Widget _messageDateField() {
    return InkWell(
      onTap: _selectMessageDate,
      borderRadius: BorderRadius.circular(15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Message Date',

          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),

          filled: true,
          fillColor: Colors.white,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),

        child: Text(
          _formatDate(_selectedMessageDate),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
        ),
      ),
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
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: maxLines > 1 ? 55 : 0),
          child: Icon(icon),
        ),

        alignLabelWithHint: maxLines > 1,

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
