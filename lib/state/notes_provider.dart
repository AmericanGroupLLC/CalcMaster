import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Note {
  final String id;
  final String title;
  final String body;
  final int createdAt;
  final int updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        createdAt: json['createdAt'] as int,
        updatedAt: json['updatedAt'] as int,
      );

  Note copyWith({String? title, String? body, int? updatedAt}) => Note(
        id: id,
        title: title ?? this.title,
        body: body ?? this.body,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class NotesProvider extends ChangeNotifier {
  static const _kNotes = 'notes';
  List<Note> _notes = [];

  List<Note> get notes => List.unmodifiable(_notes);

  NotesProvider() {
    _hydrate();
  }

  Future<void> _hydrate() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kNotes);
    if (raw == null) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _notes = list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kNotes, jsonEncode(_notes.map((n) => n.toJson()).toList()));
  }

  Note add({required String title, required String body}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final n = Note(
      id: '${now.toRadixString(36)}-${(now % 1000)}',
      title: title.isEmpty ? 'Untitled' : title,
      body: body,
      createdAt: now,
      updatedAt: now,
    );
    _notes = [n, ..._notes];
    notifyListeners();
    _persist();
    return n;
  }

  void update(String id, {String? title, String? body}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    _notes = [
      for (final n in _notes)
        if (n.id == id) n.copyWith(title: title, body: body, updatedAt: now) else n,
    ];
    notifyListeners();
    _persist();
  }

  void remove(String id) {
    _notes = _notes.where((n) => n.id != id).toList();
    notifyListeners();
    _persist();
  }
}
