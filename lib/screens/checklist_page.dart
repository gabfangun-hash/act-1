// lib/screens/checklist_page.dart
import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../services/theme_service.dart';
import 'dashboard_page.dart';
import 'reminder_page.dart';
import 'alert_page.dart';
import 'profile_page.dart';

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  _ChecklistPageState createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final List<TextEditingController> _itemControllers = [];
  final TextEditingController _newChecklistController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  String _selectedCategory = 'Work';

  @override
  void initState() {
    super.initState();
    AppData.instance.seedIfEmpty();
    _syncControllersWithAppData();
    ThemeService().setTheme(AppData.instance.selectedTheme);
    _selectedCategory = AppData.instance.categories.isNotEmpty ? AppData.instance.categories.first : 'Work';
  }

  @override
  void dispose() {
    for (final c in _itemControllers) {
      c.dispose();
    }
    _newChecklistController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _syncControllersWithAppData() {
    final lists = AppData.instance.checklists;
    while (_itemControllers.length < lists.length) {
      _itemControllers.add(TextEditingController());
    }
    while (_itemControllers.length > lists.length) {
      final c = _itemControllers.removeLast();
      c.dispose();
    }
  }

  void _showNewChecklistDialog() {
    _newChecklistController.clear();
    _customCategoryController.clear();
    _selectedCategory = AppData.instance.categories.isNotEmpty ? AppData.instance.categories.first : 'Work';
    final theme = ThemeService().currentTheme;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('New Checklist'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create a new checklist to keep track of your tasks.'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _newChecklistController,
                      decoration: const InputDecoration(
                        labelText: 'Checklist Name',
                        hintText: 'e.g., Daily Essentials',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCategory,
                      items: [
                        ...AppData.instance.categories.map((cat) {
                          return DropdownMenuItem<String>(value: cat, child: Text(cat));
                        }),
                        const DropdownMenuItem<String>(
                          value: '__add_new__',
                          child: Text('+ Add New Category', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == '__add_new__') {
                          _showAddCategoryDialog(setStateDialog);
                        } else if (value != null) {
                          setStateDialog(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
                  onPressed: () {
                    final name = _newChecklistController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        AppData.instance.addChecklist(
                          ChecklistModel(
                            title: name,
                            category: _selectedCategory,
                          ),
                        );
                        _syncControllersWithAppData();
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddCategoryDialog(Function setStateDialog) {
    _customCategoryController.clear();
    final theme = ThemeService().currentTheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: _customCategoryController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g., Health',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
              onPressed: () {
                final categoryName = _customCategoryController.text.trim();
                if (categoryName.isNotEmpty) {
                  AppData.instance.addCategory(categoryName);
                  setStateDialog(() {
                    _selectedCategory = categoryName;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _toggleExpanded(int index) {
    setState(() {
      AppData.instance.checklists[index].expanded = !AppData.instance.checklists[index].expanded;
    });
  }

  void _deleteChecklist(int index) {
    setState(() {
      AppData.instance.deleteChecklistAt(index);
      _syncControllersWithAppData();
    });
  }

  void _addItemToList(int listIndex) {
    _syncControllersWithAppData();
    final text = _itemControllers[listIndex].text.trim();
    if (text.isEmpty) return;
    setState(() {
      AppData.instance.checklists[listIndex].items.add(ChecklistItem(text: text));
      _itemControllers[listIndex].clear();
    });
  }

  void _removeItem(int listIndex, int itemIndex) {
    setState(() {
      AppData.instance.checklists[listIndex].items.removeAt(itemIndex);
    });
  }

  void _toggleItemChecked(int listIndex, int itemIndex, {bool refresh = true}) {
    final it = AppData.instance.checklists[listIndex].items[itemIndex];
    it.checked = !it.checked;
    if (refresh) setState(() {});
  }

  double _computeProgressValue(int listIndex) {
    final items = AppData.instance.checklists[listIndex].items;
    if (items.isEmpty) return 0.0;
    final completed = items.where((i) => i.checked).length;
    return completed / items.length;
  }

  String _progressText(int listIndex) {
    final items = AppData.instance.checklists[listIndex].items;
    final completed = items.where((i) => i.checked).length;
    return '$completed/${items.length} Completed';
  }

  String _progressPercent(int listIndex) {
    final percent = (_computeProgressValue(listIndex) * 100).round();
    return '$percent%';
  }

  @override
  Widget build(BuildContext context) {
    _syncControllersWithAppData();
    final lists = AppData.instance.checklists;
    final theme = ThemeService().currentTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          _buildHeader(theme),
          Expanded(child: _buildBody(lists, theme)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, theme),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      height: 84.0,
      decoration: BoxDecoration(
        color: theme.primary,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
              ]),
              child: Center(child: Icon(Icons.vpn_key, color: theme.primary)),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Remindly', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
                SizedBox(height: 2),
                Text('Never Forget', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Text('Hi, ${AppData.instance.userName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<ChecklistModel> lists, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Checklists', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Create & manage your lists', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showNewChecklistDialog,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  backgroundColor: theme.primary,
                  minimumSize: const Size(44, 44),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: lists.isEmpty ? _emptyState(theme) : _listsView(lists, theme)),
        ],
      ),
    );
  }

  Widget _emptyState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('No checklists yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _showNewChecklistDialog,
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
            icon: const Icon(Icons.add),
            label: const Text('Create Checklist', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _listsView(List<ChecklistModel> lists, AppTheme theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: List.generate(lists.length, (index) {
          final list = lists[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildChecklistCard(list, index, theme),
          );
        }),
      ),
    );
  }

  Widget _buildChecklistCard(ChecklistModel list, int index, AppTheme theme) {
    final progress = _computeProgressValue(index);
    final controller = _itemControllers[index];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(list.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.primaryLighter,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        list.category,
                        style: TextStyle(color: theme.primary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(_progressText(index), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(width: 12),
                    Text(_progressPercent(index), style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    const SizedBox(width: 8),
                    InkWell(onTap: () => _toggleExpanded(index), child: Icon(list.expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black54)),
                    const SizedBox(width: 8),
                    InkWell(onTap: () => _deleteChecklist(index), child: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(_progressPercent(index), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  if (list.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('No items. Add new item below.', style: TextStyle(color: Colors.black54)),
                    )
                  else
                    Column(
                      children: List.generate(list.items.length, (itemIndex) {
                        final it = list.items[itemIndex];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            decoration: BoxDecoration(color: theme.primaryLighter, borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              leading: Checkbox(
                                value: it.checked,
                                activeColor: theme.primary,
                                onChanged: (_) => _toggleItemChecked(index, itemIndex),
                              ),
                              title: Opacity(
                                opacity: it.checked ? 0.6 : 1.0,
                                child: Text(it.text, style: TextStyle(decoration: it.checked ? TextDecoration.lineThrough : TextDecoration.none, fontSize: 14)),
                              ),
                              trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.black54), onPressed: () => _removeItem(index, itemIndex)),
                            ),
                          ),
                        );
                      }),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                          child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Add new item', border: InputBorder.none), onSubmitted: (_) => _addItemToList(index)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addItemToList(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            crossFadeState: list.expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: theme.primaryLighter, border: Border(top: BorderSide(color: Colors.black12.withOpacity(0.03)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(icon: Icons.home, label: 'Home', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardPage()))),
          _navItem(icon: Icons.list_alt, label: 'Checklist', active: true, theme: theme, onTap: () {}),
          _navItem(icon: Icons.access_time, label: 'Reminder', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReminderPage()))),
          _navItem(icon: Icons.notifications_none, label: 'Alert', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertPage()))),
          _navItem(icon: Icons.person_outline, label: 'Profile', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()))),
        ],
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required AppTheme theme, bool active = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: active ? theme.primary.withOpacity(0.12) : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: active ? theme.primary : Colors.black54),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}