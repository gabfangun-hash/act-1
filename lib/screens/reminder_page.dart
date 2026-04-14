import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import 'dashboard_page.dart';
import 'checklist_page.dart';
import 'alert_page.dart';
import 'profile_page.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  @override
  void initState() {
    super.initState();
    AppData.instance.seedIfEmpty();
    ThemeService().setTheme(AppData.instance.selectedTheme);
    NotificationService().initializeNotifications();
  }

  DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _timeOfDayToDateTime(TimeOfDay tod, DateTime date) {
    return DateTime(date.year, date.month, date.day, tod.hour, tod.minute);
  }

  bool _isDateTimeInPast(DateTime? date, TimeOfDay? time) {
    if (date == null) return false;
    if (time == null) return false;
    final combined = _timeOfDayToDateTime(time, date);
    return combined.isBefore(DateTime.now());
  }

  Future<void> _requestNotificationPermission() async {
    final granted = await NotificationService().requestNotificationPermission();
    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications enabled! You will receive reminders.')),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied. Notifications disabled.')),
      );
    }
  }

  Future<void> _showNewReminderDialog() async {
    final titleController = TextEditingController();
    String? selectedChecklist;
    DateTime? chosenDate;
    TimeOfDay? chosenTime;
    String repeat = 'Never';
    bool active = true;

    final checklists = AppData.instance.checklists;
    final theme = ThemeService().currentTheme;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              width: 360,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('New Reminder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                        InkWell(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Daily Essentials'),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Checklist',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedChecklist,
                          hint: const Text('Select Checklist'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String?>(value: null, child: Text('None')),
                            ...checklists.map((c) => DropdownMenuItem<String>(value: c.title, child: Text(c.title))),
                          ],
                          onChanged: (v) => setStateDialog(() => selectedChecklist = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final initial = (chosenDate == null || chosenDate!.isBefore(_todayDateOnly()))
                                  ? _todayDateOnly()
                                  : chosenDate!;
                              final d = await showDatePicker(
                                context: context,
                                initialDate: initial,
                                firstDate: _todayDateOnly(),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) setStateDialog(() => chosenDate = d);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Date', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                              child: Text(chosenDate == null ? 'mm/dd/yyyy' : '${chosenDate!.month}/${chosenDate!.day}/${chosenDate!.year}'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final t = await showTimePicker(context: context, initialTime: chosenTime ?? TimeOfDay.now());
                              if (t == null) return;
                              if (chosenDate != null) {
                                final chosenDateOnly = DateTime(chosenDate!.year, chosenDate!.month, chosenDate!.day);
                                final todayOnly = _todayDateOnly();
                                if (chosenDateOnly.isAtSameMomentAs(todayOnly)) {
                                  final pickedDT = _timeOfDayToDateTime(t, chosenDate!);
                                  if (pickedDT.isBefore(DateTime.now())) {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Invalid time'),
                                        content: const Text('Selected time is in the past. Please choose a future time.'),
                                        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                                      ),
                                    );
                                    return;
                                  }
                                }
                              }
                              setStateDialog(() => chosenTime = t);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Time', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                              child: Text(chosenTime == null ? '--:--' : chosenTime!.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(labelText: 'Repeat', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: repeat,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'Never', child: Text('Never')),
                            DropdownMenuItem(value: 'Every Day', child: Text('Every Day')),
                            DropdownMenuItem(value: 'Every Week', child: Text('Every Week')),
                          ],
                          onChanged: (v) => setStateDialog(() => repeat = v ?? 'Never'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Active'),
                                Switch(value: active, activeColor: theme.primary, onChanged: (v) => setStateDialog(() => active = v)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
                          onPressed: () {
                            final title = titleController.text.trim();
                            if (title.isEmpty) return;
                            if (_isDateTimeInPast(chosenDate, chosenTime)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected date/time is in the past.')));
                              return;
                            }
                            final rem = ReminderModel(
                              title: title,
                              checklistTitle: selectedChecklist,
                              date: chosenDate,
                              time: chosenTime,
                              repeat: repeat,
                              active: active,
                            );
                            AppData.instance.addReminder(rem);
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          child: const Text('Create', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _showEditReminderDialog(int reminderIndex) async {
    final reminder = AppData.instance.reminders[reminderIndex];
    final titleController = TextEditingController(text: reminder.title);
    String? selectedChecklist = reminder.checklistTitle;
    DateTime? chosenDate = reminder.date;
    TimeOfDay? chosenTime = reminder.time;
    String repeat = reminder.repeat;
    bool active = reminder.active;

    final theme = ThemeService().currentTheme;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          final checklists = AppData.instance.checklists;
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(16),
              width: 360,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Edit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                        InkWell(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Daily Essentials'),
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Checklist',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: selectedChecklist,
                          hint: const Text('Select Checklist'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String?>(value: null, child: Text('None')),
                            ...checklists.map((c) => DropdownMenuItem<String>(value: c.title, child: Text(c.title))),
                          ],
                          onChanged: (v) => setStateDialog(() => selectedChecklist = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final initial = (chosenDate == null || chosenDate!.isBefore(_todayDateOnly()))
                                  ? _todayDateOnly()
                                  : chosenDate!;
                              final d = await showDatePicker(
                                context: context,
                                initialDate: initial,
                                firstDate: _todayDateOnly(),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) setStateDialog(() => chosenDate = d);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Date', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                              child: Text(chosenDate == null ? 'mm/dd/yyyy' : '${chosenDate!.month}/${chosenDate!.day}/${chosenDate!.year}'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final t = await showTimePicker(context: context, initialTime: chosenTime ?? TimeOfDay.now());
                              if (t == null) return;
                              if (chosenDate != null) {
                                final chosenDateOnly = DateTime(chosenDate!.year, chosenDate!.month, chosenDate!.day);
                                final todayOnly = _todayDateOnly();
                                if (chosenDateOnly.isAtSameMomentAs(todayOnly)) {
                                  final pickedDT = _timeOfDayToDateTime(t, chosenDate!);
                                  if (pickedDT.isBefore(DateTime.now())) {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Invalid time'),
                                        content: const Text('Selected time is in the past. Please choose a future time.'),
                                        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                                      ),
                                    );
                                    return;
                                  }
                                }
                              }
                              setStateDialog(() => chosenTime = t);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(labelText: 'Time', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                              child: Text(chosenTime == null ? '--:--' : chosenTime!.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(labelText: 'Repeat', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: repeat,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'Never', child: Text('Never')),
                            DropdownMenuItem(value: 'Every Day', child: Text('Every Day')),
                            DropdownMenuItem(value: 'Every Week', child: Text('Every Week')),
                          ],
                          onChanged: (v) => setStateDialog(() => repeat = v ?? 'Never'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Active'),
                                Switch(value: active, activeColor: theme.primary, onChanged: (v) => setStateDialog(() => active = v)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
                          onPressed: () {
                            final title = titleController.text.trim();
                            if (title.isEmpty) return;
                            if (_isDateTimeInPast(chosenDate, chosenTime)) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selected date/time is in the past.')));
                              return;
                            }
                            setState(() {
                              final r = AppData.instance.reminders[reminderIndex];
                              r.title = title;
                              r.checklistTitle = selectedChecklist;
                              r.date = chosenDate;
                              r.time = chosenTime;
                              r.repeat = repeat;
                              r.active = active;
                            });
                            Navigator.of(context).pop();
                          },
                          child: const Text('Update', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = AppData.instance.reminders;
    final theme = ThemeService().currentTheme;
    final notificationsEnabled = AppData.instance.notificationsPermissionGranted;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          _buildHeader(theme),
          Expanded(child: _buildBody(reminders, theme, notificationsEnabled)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, theme),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return Container(
      height: 84.0,
      decoration: BoxDecoration(color: theme.primary, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(14), bottomRight: Radius.circular(14))),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]), child: Center(child: Icon(Icons.vpn_key, color: theme.primary))),
            const SizedBox(width: 12),
            Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Remindly', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
              SizedBox(height: 2),
              Text('Never Forget', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: Text('Hi, ${AppData.instance.userName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<ReminderModel> reminders, AppTheme theme, bool notificationsEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reminders', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Schedule & manage alerts', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showNewReminderDialog,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFC78A), width: 2),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 6))],
            ),
            child: Row(children: [
              Row(children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFFFF0E6), shape: BoxShape.circle), child: Center(child: Icon(Icons.notifications_off, color: const Color(0xFFFF8A50)))),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(notificationsEnabled ? 'Notifications On' : 'Notifications Off', style: const TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text(notificationsEnabled ? 'You will receive reminders' : 'Tap to enable', style: const TextStyle(color: Colors.black54, fontSize: 13))
                ]),
              ]),
              const Spacer(),
              ElevatedButton(
                onPressed: notificationsEnabled ? null : _requestNotificationPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: notificationsEnabled ? Colors.grey : Colors.white,
                  foregroundColor: Colors.black87,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(notificationsEnabled ? 'Enabled' : 'Enable'),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: reminders.isEmpty
                ? const Center(child: Text('No reminders yet'))
                : ListView.separated(
                    itemCount: reminders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final r = reminders[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 6))]),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w700))),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                              child: IconButton(
                                icon: const Icon(Icons.access_time, size: 18, color: Colors.black54),
                                onPressed: () => _showEditReminderDialog(i),
                                tooltip: 'Edit reminder',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), onPressed: () {
                              setState(() {
                                AppData.instance.deleteReminderAt(i);
                              });
                            })),
                          ]),
                          const SizedBox(height: 8),
                          if (r.checklistTitle != null) Row(children: [const Icon(Icons.bookmarks_outlined, size: 14, color: Colors.black45), const SizedBox(width: 6), Text(r.checklistTitle!, style: TextStyle(color: Colors.black54, fontSize: 13))]),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.black45),
                            const SizedBox(width: 6),
                            Text(r.date == null ? '--' : '${r.date!.month}/${r.date!.day}/${r.date!.year}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            const SizedBox(width: 16),
                            const Icon(Icons.access_time, size: 14, color: Colors.black45),
                            const SizedBox(width: 6),
                            Text(r.time == null ? '--' : r.time!.format(context), style: const TextStyle(color: Colors.black54, fontSize: 13)),
                            const SizedBox(width: 12),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: theme.primaryLighter, borderRadius: BorderRadius.circular(12)), child: Text(r.active ? 'Active' : 'Inactive', style: TextStyle(color: theme.primary, fontSize: 12))),
                            const SizedBox(width: 8),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: theme.primaryLighter, borderRadius: BorderRadius.circular(12)), child: Text(r.repeat, style: TextStyle(color: theme.primary, fontSize: 12))),
                          ]),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: theme.primaryLighter, border: Border(top: BorderSide(color: Colors.black12.withOpacity(0.03)))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _navItem(icon: Icons.home, label: 'Home', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardPage()))),
        _navItem(icon: Icons.list_alt, label: 'Checklist', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChecklistPage()))),
        _navItem(icon: Icons.access_time, label: 'Reminder', active: true, theme: theme, onTap: () {}),
        _navItem(icon: Icons.notifications_none, label: 'Alert', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertPage()))),
        _navItem(icon: Icons.person_outline, label: 'Profile', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfilePage()))),
      ]),
    );
  }

  Widget _navItem({required IconData icon, required String label, required AppTheme theme, bool active = false, VoidCallback? onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(30), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: active ? theme.primary.withOpacity(0.12) : Colors.transparent, shape: BoxShape.circle), child: Icon(icon, color: active ? theme.primary : Colors.black54)), const SizedBox(height: 4), Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54))])));
  }
}