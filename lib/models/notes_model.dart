class Note{
  final int? id;
  final String title;
  final String body;
  final String dateTime;
  bool isPriority;

  Note({
    this.id,
    required this.title,
    required this.body,
    required this.dateTime,
    this.isPriority = false
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'body': body,
      'dateTime': dateTime,
      'isPriority': isPriority ? 1 : 0,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map){
    return Note(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      dateTime: map['dateTime'],
      isPriority: map['isPriority'] == 1
    );
  }
}