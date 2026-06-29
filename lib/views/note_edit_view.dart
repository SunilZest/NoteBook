import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/app_theme.dart';
import '../data/note_model.dart';
import '../provider/note_provider.dart';

class NoteEditView extends ConsumerStatefulWidget {
  final NoteModel? note;
  const NoteEditView({super.key, this.note});

  @override
  ConsumerState<NoteEditView> createState() => _NoteEditViewState();
}

class _NoteEditViewState extends ConsumerState<NoteEditView> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Create Note' : 'Edit Note',  
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 22, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: 'Heading String...',
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.crimsonRed)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true,
                style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.black87, fontSize: 16),
                decoration: const InputDecoration(hintText: 'Start writing concepts here...', border: InputBorder.none),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.crimsonRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final notifier = ref.read(noteProvider.notifier);
                  if (widget.note == null) {
                    notifier.addNote(_titleController.text, _bodyController.text);
                  } else {
                    notifier.updateNote(widget.note!, _titleController.text, _bodyController.text);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save', style: AppTextStyles.actionButton),
              ),
            )
          ],
        ),
      ),
    );
  }
}