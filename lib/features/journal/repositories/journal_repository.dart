import '../models/journal_entry.dart';
import '../services/journal_storage_service.dart';

/// Thin repository layer over [JournalStorageService].
///
/// Provides a clean API for the rest of the app without exposing storage
/// implementation details.
class JournalRepository {
  JournalRepository({required this.storage});

  final JournalStorageService storage;

  Future<void> init() => storage.init();

  List<JournalEntry> getAllEntries() => storage.getAllEntries();

  JournalEntry? getLatestEntry() => storage.getLatestEntry();

  Future<void> saveEntry(JournalEntry entry) => storage.saveEntry(entry);

  int get count => getAllEntries().length;

  Future<void> clearAll() => storage.clearAll();
}
