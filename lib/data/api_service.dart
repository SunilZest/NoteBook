import 'dart:convert';
import 'package:http/http.dart' as http;
import 'note_model.dart';

class ApiService {
  // Configured to point directly to machine's active local port sequence
  final String baseUrl ='http://192.168.1.45:3000/notes';

  Future<List<NoteModel>> fetchNotes() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => NoteModel.fromMap(item).copyWith(syncStatus: SyncStatus.synced)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> upsertNote(NoteModel note) async {
    final payload = jsonEncode(note.toMap());
    try {
      final check = await http.get(Uri.parse('$baseUrl/${note.id}'));
      if (check.statusCode == 200) {
        await http.put(Uri.parse('$baseUrl/${note.id}'), headers: {"Content-Type": "application/json"}, body: payload);
      } else {
        await http.post(Uri.parse(baseUrl), headers: {"Content-Type": "application/json"}, body: payload);
      }
    } catch (_) {}
  }

  Future<void> deleteNote(String id) async {
    try {
      await http.delete(Uri.parse('$baseUrl/$id'));
    } catch (_) {}
  }
}