enum SyncStatus { synced, pendingSync, conflict }

class NoteModel {
  final String id;
  final String title;
  final String body;
  final int updatedAt;
  final SyncStatus syncStatus;
  final bool isDeleted;

  NoteModel({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    required this.syncStatus,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'updated_at': updatedAt,
      'sync_status': syncStatus.name,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      updatedAt: map['updated_at'],
      syncStatus: SyncStatus.values.byName(map['sync_status']),
      isDeleted: map['is_deleted'] == 1,
    );
  }

  NoteModel copyWith({
    String? title,
    String? body,
    int? updatedAt,
    SyncStatus? syncStatus,
    bool? isDeleted,
  }) {
    return NoteModel(
      id: this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}