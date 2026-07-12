import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/secure_storage_service.dart';

class NotesPage extends StatefulWidget {
  final String subject;
  const NotesPage({super.key, required this.subject});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final TextEditingController _controller = TextEditingController();
  final SecureStorageService _secureStorage = SecureStorageService();
  String _savedNote = '';
  bool _isEditing = false;
  DateTime? _lastEdited;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  Future<void> _loadNote() async {
    final stored = await _secureStorage.readNote(widget.subject);
    if (stored != null) {
      _savedNote = stored;
      _controller.text = _savedNote;
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveNote() async {
    await _secureStorage.saveNote(widget.subject, _controller.text);
    setState(() {
      _savedNote = _controller.text;
      _isEditing = false;
      _lastEdited = DateTime.now();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota guardada'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        title: Text('Notas: ${widget.subject}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(icon: const Icon(Icons.save_rounded, color: AppColors.primary), onPressed: _saveNote)
          else
            IconButton(icon: const Icon(Icons.edit_rounded, color: AppColors.primary), onPressed: () => setState(() => _isEditing = true)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_lastEdited != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Última edición: ${_lastEdited!.day}/${_lastEdited!.month}/${_lastEdited!.year} ${_lastEdited!.hour}:${_lastEdited!.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.secondaryText, fontSize: 11),
                ),
              ),
            if (_isEditing) ...[
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(color: AppColors.lightText, fontSize: 15, height: 1.6),
                  decoration: InputDecoration(
                    hintText: 'Escribe tus notas aquí...',
                    hintStyle: TextStyle(color: AppColors.secondaryText.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: AppColors.darkCard,
                    border: const OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ] else
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: SingleChildScrollView(
                    child: _savedNote.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 80),
                              Icon(Icons.note_add_rounded, size: 64, color: AppColors.secondaryText.withValues(alpha: 0.4)),
                              const SizedBox(height: 16),
                              const Text('No hay notas aún', style: TextStyle(color: AppColors.secondaryText)),
                              const SizedBox(height: 8),
                              const Text('Toca el lápiz para empezar', style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                            ],
                          )
                        : Text(_savedNote, style: const TextStyle(color: AppColors.lightText, fontSize: 15, height: 1.6)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
