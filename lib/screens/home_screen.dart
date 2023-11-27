import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_notes_app/screens/edit_note_screen.dart';
import 'package:flutter_notes_app/screens/note_detail_screen.dart';
import 'package:flutter_notes_app/screens/note_input_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  _loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = prefs.getStringList('notes')?.map((note) => Map<String, String>.from(json.decode(note)))?.toList() ?? [];
    });
  }

  _saveNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notes', notes.map((note) => json.encode(note)).toList());
  }

  _editNote(BuildContext context, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(
          initialTitle: notes[index]['title'] ?? '',
          initialContent: notes[index]['content'] ?? '',
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        notes[index]['title'] = result['title'] ?? '';
        notes[index]['content'] = result['content'] ?? '';
        _saveNotes();
      });
    }
  }

  _deleteNote(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Catatan'),
        content: Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                notes.removeAt(index);
                _saveNotes();
              });
              Navigator.pop(context);
            },
            child: Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan', style: TextStyle(color: Colors.white),),

        backgroundColor: Colors.blue,
      ),
      body: notes.isEmpty
          ? Center(
        child: Text('Catatan masih kosong. Tambahkan catatan baru!', style: TextStyle(fontSize: 18)),
      )
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) => Card(
          elevation: 3,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(notes[index]['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(notes[index]['content']!),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _editNote(context, index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteNote(context, index);
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteDetailScreen(
                    title: notes[index]['title'] ?? '',
                    content: notes[index]['content'] ?? '',
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteInputScreen(),
            ),
          );

          if (result != null && result is Map<String, String>) {
            setState(() {
              notes.add(result);
              _saveNotes();
            });
          }
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
