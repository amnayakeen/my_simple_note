import 'package:flutter/material.dart';
import 'package:my_simple_note/db_helper/database_handler.dart';
import 'package:my_simple_note/models/notes_model.dart';
import 'package:my_simple_note/screens/view_edit_note_screen.dart';

import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final DatabaseHandler _databaseHandler = DatabaseHandler();
  List<Note> _notes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _databaseHandler.getAllNotes();
    // Sort notes with priority flag on top
    notes.sort((a, b) => b.isPriority ? 1 : -1);
    setState(() {
      _notes = notes;
    });
  }

  String _getDateTime(String dateTime){
    final DateTime editedDateTime = DateTime.parse(dateTime);
    final todayDateTime = DateTime.now();

    if(editedDateTime.year == todayDateTime.year && editedDateTime.month == todayDateTime.month && editedDateTime.day == todayDateTime.day){
      return "Today, ${editedDateTime.hour.toString().padLeft(2, '0')}:${editedDateTime.minute.toString().padLeft(2, '0')}";
    }
    else{
      return "${editedDateTime.day}/${editedDateTime.month}/${editedDateTime.year}, ${editedDateTime.day.toString().padLeft(2, '0')}:${editedDateTime.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _showPriorityDialog(BuildContext context, Note note) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String dialogTitle = note.isPriority ? 'Remove Priority' : 'Set Priority';
        String dialogContent = note.isPriority ? 'Do you want to remove the priority from this note?' : 'Do you want to mark this note as a priority?';

        return AlertDialog(
          title: Text(dialogTitle),
          content: Text(dialogContent),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                note.isPriority = !note.isPriority; // Toggle priority
                await _databaseHandler.updateNote(note);
                _loadNotes();
                Navigator.pop(context);
              },
              child: Text(note.isPriority ? 'Remove' : 'Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.orange[300],
            title: const Text("My Simple Note",
              style: TextStyle(
              fontSize: 28.0,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
            ),
          ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];

            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewEditNote(note: note)),
                );
                _loadNotes();
              },
              onLongPress: () {
                _showPriorityDialog(context, note);
              },
              child: Stack(
                children: [
                  // Card Container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (note.isPriority)
                          const Icon(Icons.star, color: Colors.deepOrangeAccent, size: 20),
                        Text(
                          note.title,
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          note.body,
                          style: TextStyle(
                            fontSize: 21,
                            fontFamily: 'Poppins',
                            color: Colors.deepOrange[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          _getDateTime(note.dateTime),
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'PoppinsItalics',
                            color: Colors.deepOrange[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Delete Icon Overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                        padding: const EdgeInsets.all(3.0),
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text("Delete Alert",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                      letterSpacing: 1,
                                    )
                                ),
                                content: const Text("Do you want to delete this note?",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                    )
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: const Text("Cancel",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                          )
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await _databaseHandler.deleteNote(note.id!);
                                      _loadNotes();
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      color: Colors.redAccent[700],
                                      padding: const EdgeInsets.all(14),
                                      child: const Text("Delete",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        )
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete, size: 20,),
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        floatingActionButton: FloatingActionButton(
              onPressed: ()async{
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNote()));
                _loadNotes();
              },
            backgroundColor: Colors.teal[100],
            child: const Icon(Icons.add)
          ),
      ),
    );
  }
}
