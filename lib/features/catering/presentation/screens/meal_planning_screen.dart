import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/entities/menu_item.dart';
import '../bloc/catering_bloc.dart';
import '../bloc/catering_event.dart';
import '../bloc/catering_state.dart';

class MealPlanningScreen extends StatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  State<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  void _loadMenu() {
    context.read<CateringBloc>().add(LoadWeeklyMenu(_selectedDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planning & Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
                _loadMenu();
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<CateringBloc, CateringState>(
        builder: (context, state) {
          if (state is CateringLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WeeklyMenuLoaded) {
            return Column(
              children: [
                _buildDaySelector(),
                Expanded(
                  child: state.menuItems.isEmpty
                      ? _buildEmptyState()
                      : _buildMenuList(state.menuItems),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenuItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDaySelector() {
    // A horizontal list of days for the selected week
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = _selectedDate
              .subtract(Duration(days: _selectedDate.weekday - 1))
              .add(Duration(days: index));
          final isSelected =
              day.day == _selectedDate.day && day.month == _selectedDate.month;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = day);
              _loadMenu();
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No menu set for this day',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showAddMenuItemDialog(context),
            child: const Text('Add Menu Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(List<MenuItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              item.mealCategoryId,
            ), // Replace with actual category name
            subtitle: Text(item.items.join(', ')),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAddMenuItemDialog(context, item: item),
            ),
          ),
        );
      },
    );
  }

  void _showAddMenuItemDialog(BuildContext context, {MenuItem? item}) {
    // Simplified dialog for adding/editing menu items
    final controller = TextEditingController(
      text: item?.items.join(', ') ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Menu Item' : 'Edit Menu Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // In a real app, add category selection dropdown
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Food Items (comma separated)',
                hintText: 'e.g. Rice, Beans, Beef',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newMenuItem = MenuItem(
                id:
                    item?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                mealCategoryId: 'Lunch', // Simplified
                dayOfWeek: 'Monday', // Simplified
                date: _selectedDate,
                items: controller.text.split(',').map((e) => e.trim()).toList(),
              );
              context.read<CateringBloc>().add(SaveMenuItemEvent(newMenuItem));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
