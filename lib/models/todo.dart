class Todo {
  String id;
  String title;
  bool isDone;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  void toggleDone() {
    isDone = !isDone;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isDone': isDone,
    };
  }

  factory Todo.fromFirestore(Map<String, dynamic> data, String id) {
    return Todo(
      id: id,
      title: data['title'] ?? '',
      isDone: data['isDone'] ?? false,
    );
  }

  static List<Todo> toDoList() {
    return [
      Todo(id: '1', title: "Morning Gym", isDone: true),
      Todo(id: '2', title: "Breakfast"),
      Todo(id: '3', title: "Office"),
      Todo(id: '4', title: "Lunch"),
      Todo(id: '5', title: "Evening Gym"),
    ];
  }
}