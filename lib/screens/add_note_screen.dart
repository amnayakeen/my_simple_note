import 'package:flutter/material.dart';
import 'package:my_simple_note/db_helper/database_handler.dart';
import '../models/notes_model.dart';

class AddNote extends StatefulWidget {
  final Note? note;
  const AddNote({super.key, this.note});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  final _formKey = GlobalKey<FormState>();
  final _titleText = TextEditingController();
  final _bodyText = TextEditingController();
  final DatabaseHandler _databaseHandler = DatabaseHandler();
  late String _initialTitle;
  late String _initialBody;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleText.text = widget.note!.title;
      _bodyText.text = widget.note!.body;
      _initialTitle = widget.note!.title;
      _initialBody = widget.note!.body;
    } else {
      _initialTitle = '';
      _initialBody = '';
    }
  }

  bool _hasChanges() {
    return _titleText.text != _initialTitle || _bodyText.text != _initialBody;
  }

  Future<bool> _showSaveDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save changes?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                letterSpacing: 1,
              )),
          content: const Text('You have unsaved changes. Do you want to save them before leaving?',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                letterSpacing: 1,
              )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('No',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    letterSpacing: 1,
                  )),
            ),
            TextButton(
              onPressed: () async {
                final note = Note(
                  id: widget.note?.id,
                  title: _titleText.text,
                  body: _bodyText.text,
                  dateTime: DateTime.now().toString(),
                );
                await _databaseHandler.addNote(note);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Yes',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    letterSpacing: 1,
                  )),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _onBackPressed() async {
    if (_hasChanges()) {
      bool shouldSave = await _showSaveDialog();
      if (shouldSave) {
        Navigator.pop(context);
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleText.dispose();
    _bodyText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Ensures scrolling when the keyboard appears
        appBar: AppBar(
          backgroundColor: Colors.orange[300],
          iconTheme: const IconThemeData(color: Colors.white),
          title: TextField(
            controller: _titleText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontFamily: 'Poppins',
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Title',
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onBackPressed,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.task_alt, size: 35),
              onPressed: () async {
                final note = Note(
                  id: widget.note?.id,
                  title: _titleText.text,
                  body: _bodyText.text,
                  dateTime: DateTime.now().toString(),
                );
                await _databaseHandler.addNote(note);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: SingleChildScrollView(
                      child: TextFormField(
                        controller: _bodyText,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Poppins',
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Your note...',
                        ),
                        maxLines: null, // Allows multiline input
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
