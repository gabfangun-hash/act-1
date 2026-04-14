import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../services/theme_service.dart';
import 'dashboard_page.dart';
import 'checklist_page.dart';
import 'reminder_page.dart';
import 'profile_page.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  _AlertPageState createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  @override
  void initState() {
    super.initState();
    AppData.instance.seedIfEmpty();
    ThemeService().setTheme(AppData.instance.selectedTheme);
  }

  void _markAsRead(int alertIndex) {
    setState(() {
      AppData.instance.alerts[alertIndex].isRead = true;
    });
  }

  void _deleteAlert(int alertIndex) {
    setState(() {
      AppData.instance.alerts.removeAt(alertIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final alerts = AppData.instance.alerts;
    final newAlerts = alerts.where((a) => !a.isRead).toList();
    final readAlerts = alerts.where((a) => a.isRead).toList();
    final theme = ThemeService().currentTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: _buildBody(newAlerts, readAlerts, theme),
          ),
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
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
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Hi, ${AppData.instance.userName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<AlertModel> newAlerts, List<AlertModel> readAlerts, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alerts',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Notifications and Alerts',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (newAlerts.isNotEmpty) ...[
              const Text(
                'New',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              ...List.generate(newAlerts.length, (index) {
                final alert = newAlerts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildAlertCard(alert, newAlerts.indexOf(alert), isNew: true, theme: theme),
                );
              }),
              const SizedBox(height: 16),
            ],
            if (readAlerts.isNotEmpty) ...[
              const Text(
                'Read',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              ...List.generate(readAlerts.length, (index) {
                final alert = readAlerts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildAlertCard(alert, AppData.instance.alerts.indexOf(alert), isNew: false, theme: theme),
                );
              }),
            ],
            if (newAlerts.isEmpty && readAlerts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Column(
                    children: const [
                      Icon(Icons.notifications_off, size: 48, color: Colors.black26),
                      SizedBox(height: 16),
                      Text(
                        'No alerts yet',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert, int index, {required bool isNew, required AppTheme theme}) {
    Color borderColor;
    Color backgroundColor;
    Color iconColor;
    IconData iconData;

    if (alert.severity == 'Critical') {
      borderColor = const Color(0xFFFF6B6B);
      backgroundColor = const Color(0xFFFFF0F0);
      iconColor = const Color(0xFFFF6B6B);
      iconData = Icons.error_outline;
    } else if (alert.severity == 'Warning') {
      borderColor = const Color(0xFFFFC78A);
      backgroundColor = const Color(0xFFFFF9E6);
      iconColor = const Color(0xFFFF8A50);
      iconData = Icons.warning_outlined;
    } else {
      borderColor = theme.primaryLight;
      backgroundColor = theme.primaryLighter;
      iconColor = theme.primary;
      iconData = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(iconData, color: iconColor, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert.checklistTitle} • ${alert.timeAgo}',
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isNew)
            ElevatedButton(
              onPressed: () => _markAsRead(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Mark Read', style: TextStyle(fontSize: 11)),
            ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _deleteAlert(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline, size: 18, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryLighter,
        border: Border(top: BorderSide(color: Colors.black12.withOpacity(0.03))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(icon: Icons.home, label: 'Home', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DashboardPage()))),
          _navItem(icon: Icons.list_alt, label: 'Checklist', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChecklistPage()))),
          _navItem(icon: Icons.access_time, label: 'Reminder', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReminderPage()))),
          _navItem(icon: Icons.notifications_none, label: 'Alert', active: true, theme: theme, onTap: () {}),
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
              child: Icon(
                icon,
                color: active ? theme.primary : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}