import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/constants.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Personal';
  String _selectedPriority = 'Medium';
  Task? _editingTask;
  bool _isInit = false;

  final List<String> _categories = ['Personal', 'Study', 'Work', 'Important'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _editingTask = ModalRoute.of(context)?.settings.arguments as Task?;
      if (_editingTask != null) {
        _titleController.text = _editingTask!.title;
        _descriptionController.text = _editingTask!.description;
        _selectedDate = _editingTask!.dueDate;
        _selectedCategory = _editingTask!.category;
        _selectedPriority = _editingTask!.priority;
      }
      _isInit = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.navyBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.assignment_add,
              size: 32,
              color: Color(0xFF0D005F),
            ),
            const SizedBox(height: 12),
            Text(
              _editingTask == null ? 'Add To-Do' : 'Edit To-Do',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0D005F),
              ),
            ),
            const SizedBox(height: 32),
            
            // Title Field
            _buildLabel('Title *'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter your task here...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description Field
            _buildLabel('Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter more details about your task...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Selection
            _buildLabel('Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _categories.map((c) {
                return ChoiceChip(
                  label: Text(c),
                  selected: _selectedCategory == c,
                  onSelected: (s) => setState(() => _selectedCategory = c),
                  selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                  labelStyle: TextStyle(color: _selectedCategory == c ? AppColors.primaryBlue : Colors.black),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Priority Selection
            _buildLabel('Priority'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) => setState(() => _selectedPriority = v!),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Integrated Calendar
            _buildLabel('Due Date'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
                onDateChanged: (date) {
                  setState(() => _selectedDate = date);
                },
              ),
            ),
            const SizedBox(height: 32),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF0D005F),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D005F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _editingTask == null ? 'Add' : 'Save',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    final newTask = Task(
      id: _editingTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _selectedDate,
      category: _selectedCategory,
      priority: _selectedPriority,
      createdAt: _editingTask?.createdAt ?? DateTime.now(),
      isCompleted: _editingTask?.isCompleted ?? false,
    );

    if (_editingTask == null) {
      context.read<TaskProvider>().addTask(newTask);
    } else {
      context.read<TaskProvider>().updateTask(newTask);
    }
    
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _editingTask == null ? 'Task added successfully' : 'Task updated successfully',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // pop dialog
                      Navigator.pop(context); // pop screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D005F),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
