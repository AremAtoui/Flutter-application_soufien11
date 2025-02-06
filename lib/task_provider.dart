import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskProvider with ChangeNotifier {
  List<Map<String, String>> _tasks = [];
  List<Map<String, String>> get tasks => _tasks;

  TaskProvider() {
    _loadTasks();
  }

  // Charger les tâches depuis SharedPreferences
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTasks = prefs.getStringList('tasks');
    if (savedTasks != null) {
      _tasks = savedTasks.map((task) => Map<String, String>.from(jsonDecode(task))).toList();
      notifyListeners();
    }
  }

  // Sauvegarder les tâches dans SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskStrings = _tasks.map((task) => jsonEncode(task)).toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  // Ajouter une nouvelle tâche
  void addTask(Map<String, String> newTask) {
    _tasks.add(newTask);
    _saveTasks();
    notifyListeners();
  }

  // Supprimer une tâche
  void removeTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }
}