import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SavedMessagesController extends GetxController {
  final GetStorage _storage = GetStorage();

  static const String _storageKey = 'saved_message_ids';

  final RxList<String> savedMessageIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    final saved = _storage.read<List>(_storageKey);

    if (saved != null) {
      savedMessageIds.assignAll(saved.map((id) => id.toString()));
    }
  }

  // ==========================================================
  // CHECK SAVED
  // ==========================================================

  bool isSaved(String messageId) {
    return savedMessageIds.contains(messageId);
  }

  // ==========================================================
  // TOGGLE SAVED
  // ==========================================================

  void toggleSaved(String messageId) {
    if (messageId.isEmpty) return;

    if (savedMessageIds.contains(messageId)) {
      savedMessageIds.remove(messageId);
    } else {
      savedMessageIds.add(messageId);
    }

    _saveToStorage();
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  void saveMessage(String messageId) {
    if (messageId.isEmpty) return;

    if (!savedMessageIds.contains(messageId)) {
      savedMessageIds.add(messageId);
      _saveToStorage();
    }
  }

  // ==========================================================
  // REMOVE
  // ==========================================================

  void removeMessage(String messageId) {
    savedMessageIds.remove(messageId);
    _saveToStorage();
  }

  // ==========================================================
  // CLEAR ALL
  // ==========================================================

  void clearAll() {
    savedMessageIds.clear();
    _saveToStorage();
  }

  // ==========================================================
  // STORAGE
  // ==========================================================

  void _saveToStorage() {
    _storage.write(_storageKey, savedMessageIds.toList());
  }
}
