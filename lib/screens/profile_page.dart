import 'package:flutter/material.dart';
import '../services/app_data.dart';
import '../services/theme_service.dart';
import 'dashboard_page.dart';
import 'checklist_page.dart';
import 'reminder_page.dart';
import 'alert_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Form controllers
  late TextEditingController _nameController;
  final TextEditingController _emailController = TextEditingController(text: 'angel@gmail.com');
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  late String _selectedTheme;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: AppData.instance.userName);
    _selectedTheme = AppData.instance.selectedTheme;
    ThemeService().setTheme(AppData.instance.selectedTheme);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final newName = _nameController.text.trim();
    
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty!')),
      );
      return;
    }

    setState(() {
      AppData.instance.userName = newName;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully!')),
    );
  }

  void _changeTheme(String themeName) {
    setState(() {
      _selectedTheme = themeName;
      AppData.instance.selectedTheme = themeName;
      ThemeService().setTheme(themeName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme changed to $themeName')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService().currentTheme;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildThemeSection(theme),
                  const SizedBox(height: 16),
                  _buildAccountProfileSection(theme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, theme),
    );
  }

  Widget _buildHeader(AppTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
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

  Widget _buildThemeSection(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Profile and settings', style: TextStyle(color: Colors.black54, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // User Info Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6))],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.primaryLighter,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.person, size: 32, color: theme.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppData.instance.userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const SizedBox(height: 6),
                      const Text('angel@gmail.com', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.school, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text('Student', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildThemeOption('Monochromatic Blue', theme, [
            const Color(0xFFE0F2FE),
            const Color(0xFF7DD3FC),
            const Color(0xFF2563EB),
            const Color(0xFF1E3A8A),
            const Color(0xFF0F172A),
          ]),
          const SizedBox(height: 12),
          _buildThemeOption('Monochromatic Teal', theme, [
            const Color(0xFFCCFBF1),
            const Color(0xFF5EEAD4),
            const Color(0xFF0D9488),
            const Color(0xFF0F766E),
            const Color(0xFF134E4A),
          ]),
          const SizedBox(height: 12),
          _buildThemeOption('Monochromatic Purple', theme, [
            const Color(0xFFF3E8FF),
            const Color(0xFFC084FC),
            const Color(0xFF7C3AED),
            const Color(0xFF5B21B6),
            const Color(0xFF3B0764),
          ]),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String name, AppTheme currentTheme, List<Color> colors) {
    final isActive = _selectedTheme == name;
    return GestureDetector(
      onTap: () => _changeTheme(name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? currentTheme.primary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: currentTheme.primary.withOpacity(0.2), blurRadius: 8)]
              : const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                if (isActive)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: currentTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors.map((color) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountProfileSection(AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Account profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            
            // Name Field
            const Text('Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter your name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            // Email Field
            const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Your@email.com',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            
            // Password Management Section
            const Text('Password Management', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            
            // Old Password
            const Text('Old Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOldPassword,
              decoration: InputDecoration(
                hintText: '••••••••••',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(_obscureOldPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // New Password
            const Text('New Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                hintText: '••••••••••',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Confirm Password
            const Text('Confirm New Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                hintText: '••••••••••',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Save Changes Button
            SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, AppTheme theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
          _navItem(icon: Icons.notifications_none, label: 'Alert', theme: theme, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AlertPage()))),
          _navItem(icon: Icons.person_outline, label: 'Profile', active: true, theme: theme, onTap: () {}),
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
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