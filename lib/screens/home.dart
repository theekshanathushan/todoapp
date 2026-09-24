import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final todos = Todo.toDoList();
  List<Todo> _searchToDo = [];
  final todoTextInput = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchToDo = todos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 228, 228),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 3, 39, 68),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
            const CircleAvatar(
              backgroundImage: AssetImage("assets/profile.png"), 
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _searchBox(),
            _list(),
            _input(),
          ],
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            onChanged: (value) => searchData(value),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.black),
              hintText: "Search",
            ),
          ),
        ),
      ),
    );
  }

  Widget _list() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "ALL TODOS",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  for (Todo todo in _searchToDo.reversed)
                    TodoItem(
                      todo: todo,
                      onclick: () {
                        setState(() {
                          todo.toggleDone();
                        });
                      },
                      onDelete: () {
                        setState(() {
                          todos.removeWhere((item) => item.id == todo.id);
                          _searchToDo.removeWhere((item) => item.id == todo.id);
                        });
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: todoTextInput,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Add New To Do",
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (todoTextInput.text.trim().isNotEmpty) {
                    setState(() {
                      todos.add(Todo(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: todoTextInput.text.trim(),
                      ));
                      _searchToDo = todos;
                      todoTextInput.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void searchData(String text) {
    List<Todo> results = [];
    if (text.isEmpty) {
      results = todos;
    } else {
      results = todos
          .where((item) =>
              item.title.toLowerCase().contains(text.toLowerCase()))
          .toList();
    }

    setState(() {
      _searchToDo = results;
    });
  }
}