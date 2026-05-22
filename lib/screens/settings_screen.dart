import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/order_provider.dart';
import '../providers/loyalty_provider.dart';
import '../providers/locale_provider.dart';
import '../data/app_constants.dart';
import '../utils/validators.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _handleSignOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 10),
            Text(localeProvider.translate('logout_btn')),
          ],
        ),
        content: Text(localeProvider.translate('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(localeProvider.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              localeProvider.translate('logout_btn'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut == true && context.mounted) {
      await authProvider.signOut();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final user = authProvider.user;
    final userData = await authProvider.getUserData();

    final initialName = user?.displayName ?? userData?['name'] ?? '';
    final initialPhone = userData?['phone'] ?? '';

    if (!context.mounted) return;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return _EditProfileDialog(
          authProvider: authProvider,
          initialName: initialName,
          initialPhone: initialPhone,
        );
      },
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${localeProvider.translate('profile_updated')}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (result == false && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${localeProvider.translate('error')}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final user = authProvider.user;
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(localeProvider.translate('settings_title')),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF3E2723), const Color(0xFF4E342E)]
                      : [Colors.brown[700]!, Colors.brown[500]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.brown[300],
                      child: Text(
                        (user.displayName ?? 'U')[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[900],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Utilisateur',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _showEditProfileDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildStatsRow(context, isDark),
          const SizedBox(height: 16),
          _buildLoyaltyCard(context, isDark),
          const SizedBox(height: 20),
          _buildSection(
            title: localeProvider.translate('profile_section'),
            isDark: isDark,
            items: [
              _buildSettingItem(
                icon: Icons.person,
                title: localeProvider.translate('edit_profile'),
                subtitle: localeProvider.translate('profile_section'),
                isDark: isDark,
                onTap: () => _showEditProfileDialog(context),
              ),
              _buildSettingItem(
                icon: Icons.location_on,
                title: localeProvider.translate('address'),
                subtitle: localeProvider.translate('address'),
                isDark: isDark,
                isComingSoon: true,
              ),
              _buildSettingItem(
                icon: Icons.payment,
                title: localeProvider.translate('total'),
                subtitle: localeProvider.translate('total'),
                isDark: isDark,
                isComingSoon: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: localeProvider.translate('settings_title'),
            isDark: isDark,
            items: [
              _buildSettingItem(
                icon: Icons.notifications,
                title: localeProvider.translate('notifications'),
                subtitle: themeProvider.notificationsEnabled
                    ? localeProvider.translate('enabled')
                    : localeProvider.translate('disabled'),
                isDark: isDark,
                trailing: Switch(
                  value: themeProvider.notificationsEnabled,
                  onChanged: (value) {
                    themeProvider.toggleNotifications();
                  },
                  activeThumbColor: Colors.brown[700],
                ),
              ),
              _buildSettingItem(
                icon: Icons.dark_mode,
                title: localeProvider.translate('theme_mode'),
                subtitle: isDark
                    ? localeProvider.translate('enabled_singular')
                    : localeProvider.translate('disabled_singular'),
                isDark: isDark,
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeThumbColor: Colors.brown[700],
                ),
              ),
              _buildSettingItem(
                icon: Icons.language,
                title: localeProvider.translate('language_section'),
                subtitle:
                    localeProvider.localeCode == 'fr' ? 'Français' : 'English',
                isDark: isDark,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => localeProvider.changeLanguage('fr'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: localeProvider.localeCode == 'fr'
                              ? Colors.brown[700]
                              : (isDark ? Colors.grey[850] : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Text('🇫🇷', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text(
                              'FR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => localeProvider.changeLanguage('en'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: localeProvider.localeCode == 'en'
                              ? Colors.brown[700]
                              : (isDark ? Colors.grey[850] : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Text('🇬🇧', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text(
                              'EN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Support',
            isDark: isDark,
            items: [
              _buildSettingItem(
                icon: Icons.help,
                title: localeProvider.translate('help_faq'),
                subtitle: localeProvider.translate('faq_subtitle'),
                isDark: isDark,
                isComingSoon: true,
              ),
              _buildSettingItem(
                icon: Icons.phone,
                title: localeProvider.translate('contact_us'),
                subtitle: localeProvider.translate('contact_subtitle'),
                isDark: isDark,
                isComingSoon: true,
              ),
              _buildSettingItem(
                icon: Icons.star,
                title: localeProvider.translate('rate_app'),
                subtitle: localeProvider.translate('rate_subtitle'),
                isDark: isDark,
                isComingSoon: true,
              ),
              _buildSettingItem(
                icon: Icons.info,
                title: localeProvider.translate('about'),
                subtitle: localeProvider.translate('about_subtitle'),
                isDark: isDark,
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Food Delivery',
                    applicationVersion: '1.0.0',
                    applicationIcon: Icon(
                      Icons.restaurant_menu,
                      size: 50,
                      color: Colors.brown[700],
                    ),
                    children: [
                      Text(localeProvider.translate('about_desc')),
                      const SizedBox(height: 10),
                      Text(localeProvider.translate('developed_with')),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _handleSignOut(context),
              icon: const Icon(Icons.logout),
              label: Text(
                localeProvider.translate('logout_btn'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.brown[300] : Colors.brown[700],
            ),
          ),
        ),
        Card(
          elevation: 2,
          color: isDark ? const Color(0xFF1E1E1E) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
    Widget? trailing,
    bool isComingSoon = false,
  }) {
    final opacity = isComingSoon ? 0.55 : 1.0;
    return Opacity(
      opacity: opacity,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.brown[900] : Colors.brown[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              color: isDark ? Colors.brown[300] : Colors.brown[800], size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey[500] : Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        trailing: trailing ??
            (isComingSoon
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Bientôt',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  )
                : Icon(Icons.chevron_right, color: Colors.grey[400])),
        onTap: isComingSoon ? null : onTap,
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isDark) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final stats = orderProvider.getStatistics();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.receipt_long,
            value: '${stats['totalOrders']}',
            label: localeProvider.translate('stats_orders'),
            color: Colors.blue,
            isDark: isDark,
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.payments,
            value: (stats['totalSpent'] as double).toStringAsFixed(0),
            label: AppConstants.currency,
            color: Colors.green,
            isDark: isDark,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            value: (stats['averageOrderValue'] as num).toStringAsFixed(0),
            label: localeProvider.translate('stats_avg_order'),
            color: Colors.orange,
            isDark: isDark,
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3E3E3E) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(BuildContext context, bool isDark) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Consumer<LoyaltyProvider>(
      builder: (context, loyalty, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: loyalty.level == 'Gold'
                  ? [const Color(0xFFFFD700), const Color(0xFFFFA000)]
                  : loyalty.level == 'Silver'
                      ? [const Color(0xFF9E9E9E), const Color(0xFF757575)]
                      : [Colors.brown[600]!, Colors.brown[400]!],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(loyalty.levelEmoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        localeProvider.translate('loyalty_program'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      loyalty.level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${loyalty.points}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    localeProvider.translate('loyalty_points_label'),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              if (loyalty.level != 'Gold') ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: loyalty.progressToNextLevel.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${loyalty.pointsToNextLevel} ${localeProvider.translate('loyalty_points_needed')} ${loyalty.level == 'Bronze' ? 'Silver' : 'Gold'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final AuthProvider authProvider;
  final String initialName;
  final String initialPhone;

  const _EditProfileDialog({
    required this.authProvider,
    required this.initialName,
    required this.initialPhone,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(Icons.edit, color: Colors.brown),
          const SizedBox(width: 10),
          Text(localeProvider.translate('edit_profile')),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              validator: Validators.validateName,
              decoration: InputDecoration(
                labelText: localeProvider.translate('name'),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              validator: Validators.validatePhone,
              decoration: InputDecoration(
                labelText: localeProvider.translate('phone'),
                hintText: '0612345678',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(localeProvider.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() => _isSaving = true);
                    final success = await widget.authProvider.updateUserProfile(
                      name: _nameController.text.isNotEmpty
                          ? _nameController.text.trim()
                          : null,
                      phone: _phoneController.text.isNotEmpty
                          ? _phoneController.text.trim()
                          : null,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop(success);
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown[700],
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  localeProvider.translate('save'),
                  style: const TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
