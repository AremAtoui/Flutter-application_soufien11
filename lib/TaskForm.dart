import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';

class TaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Task Manager'),
        ),
        body: TaskForm(),
      ),
    );
  }
}

class TaskForm extends StatefulWidget {
  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final List<String> categories = ['Important', 'Urgent', 'Pending'];
  String taskTitle = '';
  String taskDescription = '';
  String selectedCategory = 'Important';
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Formulaire pour ajouter une tâche
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (value) => taskTitle = value,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => taskDescription = value,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedCategory = value!),
                    isExpanded: true,
                    hint: Text('Select a category'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      selectedDate == null
                          ? 'Select Date and Time'
                          : '${selectedDate!.toLocal()}'.split(' ')[0] + ' ' + '${selectedDate!.hour}:${selectedDate!.minute}:${selectedDate!.second}',
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (taskTitle.isNotEmpty && taskDescription.isNotEmpty) {
                            taskProvider.addTask({
                              'title': taskTitle,
                              'description': taskDescription,
                              'category': selectedCategory,
                              'date': selectedDate != null ? selectedDate.toString() : 'No date',
                            });
                            setState(() {
                              taskTitle = '';
                              taskDescription = '';
                              selectedCategory = 'Important';
                              selectedDate = null;
                            });
                          }
                        },
                        child: Text('Add Task'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Liste des tâches
          Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task List',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(task['title']!),
                          subtitle: Text(
                            '${task['description']} - ${task['category']} - ${task['date']}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => taskProvider.removeTask(index),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }
}