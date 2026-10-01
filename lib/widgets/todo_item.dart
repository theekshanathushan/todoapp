import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final Function onclick;
  final Function onDelete;
  
  const TodoItem({
    super.key,
    required this.todo,
    required this.onclick,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 2, 40, 71),
        borderRadius: BorderRadius.circular(20),
      ),
      // TODO 1: Build the UI for a single ToDo item using a ListTile
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () {
            onclick();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: Icon(
            todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
            color: Colors.white,
          ),
          title: Text(
            todo.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              decoration: todo.isDone ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              onDelete();
            },
          ),
        ),
      ),
    );
  }
}