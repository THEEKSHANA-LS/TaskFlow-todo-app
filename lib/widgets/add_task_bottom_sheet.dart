import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Task? task;
  const AddTaskBottomSheet({super.key, this.task});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _selectedDate;
  late String _selectedCategory;
  late String _selectedPriority;

  final List<String> _categories = ['Personal', 'Study', 'Work', 'Important'];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
    _selectedCategory = widget.task?.category ?? 'Personal';
    _selectedPriority = widget.task?.priority ?? 'Medium';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.task == null ? 'New Task' : 'Edit Task',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(controller: _titleController),
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(controller: _descController, maxLines: 3),
                  const SizedBox(height: 20),
                  const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Priority', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedPriority,
                              items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                              onChanged: (v) => setState(() => _selectedPriority = v!),
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) setState(() => _selectedDate = picked);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 18),
                                    const SizedBox(width: 8),
                                    Text(DateFormat('MMM d').format(_selectedDate)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                final task = Task(
                  id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  description: _descController.text,
                  dueDate: _selectedDate,
                  category: _selectedCategory,
                  priority: _selectedPriority,
                  createdAt: widget.task?.createdAt ?? DateTime.now(),
                  isCompleted: widget.task?.isCompleted ?? false,
                );
                
                if (widget.task == null) {
                  Provider.of<TaskProvider>(context, listen: false).addTask(task);
                } else {
                  Provider.of<TaskProvider>(context, listen: false).updateTask(task);
                }
                Navigator.pop(context);
              }
            },
            child: Text(widget.task == null ? 'Add Task' : 'Save Changes'),
          ),
        ],
      ),
    );
  }
}
