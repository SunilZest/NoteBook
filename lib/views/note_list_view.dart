import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_theme.dart';
import '../provider/note_provider.dart';
import '../data/note_model.dart';
import 'note_edit_view.dart';
import 'package:flutter/cupertino.dart';

class NoteListView extends ConsumerWidget {
  const NoteListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(noteProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final isSyncing = ref.watch(
      isSyncingProvider,
    ); // Watches active loading states

    final currentTitleStyle = isDarkMode
        ? AppTextStyles.noteTitleDark
        : AppTextStyles.noteTitleLight;
    final bodyTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteBook', style: AppTextStyles.brandHeader),
        actions: [
      
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: AppColors.crimsonRed,
            ),
            onPressed: () =>
                ref.read(isDarkModeProvider.notifier).state = !isDarkMode,
          ),

          isSyncing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.crimsonRed,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.sync, color: AppColors.crimsonRed),
                  onPressed: () =>
                      ref.read(noteProvider.notifier).syncData(ref),
                ),
        ],
      ),
      body: notes.isEmpty
          ? Center(
              child: Text(
                'No Notes Recorded',
                style: TextStyle(color: bodyTextColor),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Dismissible(
                  key: Key(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "DELETE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.delete_sweep, color: Colors.white, size: 28),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CupertinoAlertDialog(
                          title: const Text(
                            "Confirm Delete",
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                          content: const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Are you sure you want to delete this note offline?",
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction:
                                  true, // Gives it the proper iOS priority layout
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                "DELETE",
                                style: TextStyle(
                                  color: AppColors.crimsonRed,
                                  fontWeight: FontWeight
                                      .w700, // Explicit FontWeight setup
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (_) {
                    ref.read(noteProvider.notifier).deleteNote(note.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '"${note.title}" moved to local deletion queue.',
                        ),
                        backgroundColor: const Color(0xFF2A2A2A),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: note.syncStatus == SyncStatus.conflict
                            ? AppColors.crimsonRed
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: ListTile(
                      title: Text(note.title, style: currentTitleStyle),
                      subtitle: Text(
                        note.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.noteBody.copyWith(
                          color: bodyTextColor,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSyncBadge(note.syncStatus),
                          IconButton(
                            icon: const Icon(Icons.edit_note),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditView(note: note),
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (note.syncStatus == SyncStatus.conflict) {
                          _showConflictSheet(context, ref, note);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditView(note: note),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.crimsonRed,
        label: const Text(
          'NEW NOTE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NoteEditView()),
        ),
      ),
    );
  }

  Widget _buildSyncBadge(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced:
        return const Icon(
          Icons.check_circle_outline,
          color: AppColors.softEmerald,
          size: 20,
        );
      case SyncStatus.pendingSync:
        return const Icon(
          Icons.radio_button_checked,
          color: AppColors.warmAmber,
          size: 20,
        );
      case SyncStatus.conflict:
        return const Icon(
          Icons.gpp_maybe,
          color: AppColors.crimsonRed,
          size: 22,
        );
    }
  }

  void _showConflictSheet(
    BuildContext context,
    WidgetRef ref,
    NoteModel localNote,
  ) {
    final serverMock = localNote.copyWith(
      title: "${localNote.title} [Cloud Only Changes]",
      body:
          "Overriding contents fetched directly from remote cloud storage configurations.",
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "CONFLICT RESOLUTION",
              style: TextStyle(
                color: AppColors.crimsonRed,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(noteProvider.notifier).resolveConflict(localNote);
                Navigator.pop(context);
              },
              child: Text("Keep Local Version: ${localNote.title}"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.crimsonRed,
              ),
              onPressed: () {
                ref.read(noteProvider.notifier).resolveConflict(serverMock);
                Navigator.pop(context);
              },
              child: const Text(
                "Keep Cloud Server Version",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
