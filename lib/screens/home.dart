import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/todo.dart';
import '../widgets/todo_item.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Local fallback for testing when Firebase is not initialized
  final List<Todo> _localTodos = Todo.toDoList();
  String _searchQuery = '';
  final todoTextInput = TextEditingController();

  CollectionReference<Map<String, dynamic>> get _todosCollection =>
      FirebaseFirestore.instance.collection('todos');

  bool get _isFirebaseReady => Firebase.apps.isNotEmpty;

  @override
  void dispose() {
    todoTextInput.dispose();
    super.dispose();
  }

  // Add new ToDo to Firestore
  Future<void> _addTodo() async {
    final title = todoTextInput.text.trim();
    if (title.isEmpty) return;

    if (_isFirebaseReady) {
      await _todosCollection.add({
        'title': title,
        'isDone': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      setState(() {
        _localTodos.add(Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
        ));
      });
    }
    todoTextInput.clear();
  }

  // Toggle ToDo status in Firestore
  Future<void> _toggleDone(Todo todo) async {
    if (_isFirebaseReady) {
      await _todosCollection.doc(todo.id).update({
        'isDone': !todo.isDone,
      });
    } else {
      setState(() {
        todo.toggleDone();
      });
    }
  }

  // Delete ToDo from Firestore
  Future<void> _deleteTodo(String id) async {
    if (_isFirebaseReady) {
      await _todosCollection.doc(id).delete();
    } else {
      setState(() {
        _localTodos.removeWhere((item) => item.id == id);
      });
    }
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
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _searchBox(),
            Expanded(child: _buildTodoList()),
            _input(),
          ],
        ),
      ),
    );
  }

  // Search Box UI
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
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
            },
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

  // Todo List UI with Firestore Stream
  Widget _buildTodoList() {
    return Padding(
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
            child: _isFirebaseReady ? _buildFirestoreStream() : _buildLocalList(),
          ),
        ],
      ),
    );
  }

  // Real-time Firestore stream
  Widget _buildFirestoreStream() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _todosCollection.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        final todos = docs.map((doc) {
          return Todo.fromFirestore(doc.data(), doc.id);
        }).toList();

        final filteredTodos = _searchQuery.isEmpty
            ? todos
            : todos
                .where((item) =>
                    item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

        if (filteredTodos.isEmpty) {
          return const Center(
            child: Text(
              "No ToDos found",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView(
          children: [
            for (Todo todo in filteredTodos)
              TodoItem(
                todo: todo,
                onclick: () => _toggleDone(todo),
                onDelete: () => _deleteTodo(todo.id),
              ),
          ],
        );
      },
    );
  }

  // Fallback for tests
  Widget _buildLocalList() {
    final filtered = _searchQuery.isEmpty
        ? _localTodos
        : _localTodos
            .where((item) =>
                item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return ListView(
      children: [
        for (Todo todo in filtered.reversed)
          TodoItem(
            todo: todo,
            onclick: () => _toggleDone(todo),
            onDelete: () => _deleteTodo(todo.id),
          ),
      ],
    );
  }

  // Input Box UI
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
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addTodo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}