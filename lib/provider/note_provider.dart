import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import '../data/note_model.dart';
import '../data/database_helper.dart';
import '../data/api_service.dart';

final isDarkModeProvider = StateProvider<bool>((ref) => true);
final isSyncingProvider = StateProvider<bool>((ref) => false);

final apiServiceProvider = Provider((ref) => ApiService());
final dbHelperProvider = Provider((ref) => DatabaseHelper.instance);

final noteProvider = StateNotifierProvider<NoteNotifier, List<NoteModel>>((ref) {
  return NoteNotifier(ref.read(dbHelperProvider), ref.read(apiServiceProvider));
});

class NoteNotifier extends StateNotifier<List<NoteModel>> {
  final DatabaseHelper _db;
  final ApiService _api;
  StreamSubscription? _connectivitySubscription;
  final _uuid = const Uuid();

  NoteNotifier(this._db, this._api) : super([]) {
    _loadLocalNotes();
    _initConnectivityListener();
  }

  Future<void> _loadLocalNotes() async {
    final notes = await _db.getNotes();
    state = notes.where((n) => !n.isDeleted).toList();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
  
      }
    });
  }

  Future<void> addNote(String title, String body) async {
    final newNote = NoteModel(
      id: _uuid.v4(),
      title: title,
      body: body,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: SyncStatus.pendingSync,
    );
    await _db.insertOrUpdate(newNote);
    await _loadLocalNotes();
  }

  Future<void> updateNote(NoteModel note, String title, String body) async {
    final updated = note.copyWith(
      title: title,
      body: body,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: SyncStatus.pendingSync,
    );
    await _db.insertOrUpdate(updated);
    await _loadLocalNotes();
  }

  Future<void> deleteNote(String id) async {
    await _db.softDelete(id);
    await _loadLocalNotes();
  }

  Future<void> resolveConflict(NoteModel resolvedNote) async {
    final note = resolvedNote.copyWith(
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: SyncStatus.pendingSync,
    );
    await _db.insertOrUpdate(note);
    await _loadLocalNotes();
  }

  Future<void> syncData(WidgetRef ref) async {
    final connections = await Connectivity().checkConnectivity();
    if (connections.isEmpty || connections.first == ConnectivityResult.none) return;

    try {
      ref.read(isSyncingProvider.notifier).state = true;
      
      final serverNotes = await _api.fetchNotes();
      for (var serverNote in serverNotes) {
        final localNote = await _db.getNoteById(serverNote.id);

        if (localNote == null) {
          await _db.insertOrUpdate(serverNote.copyWith(syncStatus: SyncStatus.synced));
        } else if (localNote.syncStatus == SyncStatus.pendingSync && localNote.updatedAt != serverNote.updatedAt) {
          await _db.insertOrUpdate(localNote.copyWith(syncStatus: SyncStatus.conflict));
        } else if (serverNote.updatedAt > localNote.updatedAt) {
          await _db.insertOrUpdate(serverNote.copyWith(syncStatus: SyncStatus.synced));
        }
      }

      final pendingNotes = await _db.getPendingNotes();
      for (var note in pendingNotes) {
        if (note.isDeleted) {
          await _api.deleteNote(note.id);
          await _db.hardDelete(note.id);
        } else if (note.syncStatus == SyncStatus.pendingSync) {
          await _api.upsertNote(note);
          await _db.insertOrUpdate(note.copyWith(syncStatus: SyncStatus.synced));
        }
      }
    } catch (_) {} finally {
      ref.read(isSyncingProvider.notifier).state = false;
      _loadLocalNotes();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}