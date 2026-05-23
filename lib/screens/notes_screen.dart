import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/notes_provider.dart';
import '../theme/tokens.dart';
import '../widgets/pill_badge.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _searchC = TextEditingController();
  final _titleC = TextEditingController();
  final _bodyC = TextEditingController();
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _searchC.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchC.dispose();
    _titleC.dispose();
    _bodyC.dispose();
    super.dispose();
  }

  void _save() {
    final notes = context.read<NotesProvider>();
    if (_titleC.text.trim().isEmpty && _bodyC.text.trim().isEmpty) return;
    if (_editingId != null) {
      notes.update(_editingId!, title: _titleC.text, body: _bodyC.text);
    } else {
      notes.add(title: _titleC.text, body: _bodyC.text);
    }
    setState(() {
      _editingId = null;
      _titleC.clear();
      _bodyC.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _startEdit(Note n) {
    setState(() {
      _editingId = n.id;
      _titleC.text = n.title;
      _bodyC.text = n.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.accentPrimary;
    final all = context.watch<NotesProvider>().notes;
    final q = _searchC.text.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((n) => n.title.toLowerCase().contains(q) || n.body.toLowerCase().contains(q)).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PillBadge(label: 'Saved Notes', color: accent),
              const SizedBox(height: Spacing.md),
              Text('Notes', style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 4),
              const Text('Save calculations, formulas, and reminders',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
              const SizedBox(height: Spacing.lg),

              // Search
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.button),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Row(children: [
                  const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchC,
                      style: const TextStyle(color: AppColors.text, fontSize: 15),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                        border: InputBorder.none,
                        hintText: 'Search notes',
                        hintStyle: TextStyle(color: AppColors.textDim),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: Spacing.md),

              // Editor
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.card),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(Spacing.md),
                child: Column(children: [
                  TextField(
                    controller: _titleC,
                    style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 6),
                      border: InputBorder.none,
                      hintText: _editingId != null ? 'Title' : 'New note title',
                      hintStyle: const TextStyle(color: AppColors.textDim),
                    ),
                  ),
                  TextField(
                    controller: _bodyC,
                    style: const TextStyle(color: AppColors.text, fontSize: 15),
                    minLines: 2,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.only(top: 8, bottom: 8),
                      border: InputBorder.none,
                      hintText: 'Body',
                      hintStyle: TextStyle(color: AppColors.textDim),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.text,
                        foregroundColor: AppColors.bg,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onPressed: _save,
                      child: Text(_editingId != null ? 'Save changes' : 'Add note'),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: Spacing.lg),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Spacing.lg),
                  child: Text(
                    'No notes yet. Add your first one above.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
              for (final n in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(Radii.button),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Radii.button),
                      onTap: () => _startEdit(n),
                      onLongPress: () => context.read<NotesProvider>().remove(n.id),
                      child: Container(
                        padding: const EdgeInsets.all(Spacing.md),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(Radii.button),
                        ),
                        child: Row(children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: AppColors.text,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                if (n.body.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      n.body,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textDim),
                        ]),
                      ),
                    ),
                  ),
                ),
              if (filtered.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: Spacing.sm),
                  child: Text(
                    'Tip: long-press a note to delete.',
                    style: TextStyle(color: AppColors.textDim, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
