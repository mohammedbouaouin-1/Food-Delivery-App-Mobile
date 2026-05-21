import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/order_provider.dart';
import '../providers/loyalty_provider.dart';
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
    
    // confirmation
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text('Déconnexion'),
          ],
        ),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.white),
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

  /// Amélioration #9: Dialogue d'édition du profil fonctionnel
  Future<void> _showEditProfileDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final userData = await authProvider.getUserData();
    
    final nameController = TextEditingController(
      text: user?.displayName ?? userData?['name'] ?? '',
    );
    final phoneController = TextEditingController(
      text: userData?['phone'] ?? '',
    );
    final formKey = GlobalKey<FormState>();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.brown),
              SizedBox(width: 10),
              Text('Modifier le profil'),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  validator: Validators.validateName,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  validator: Validators.validatePhone,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final success = await authProvider.updateUserProfile(
                    name: nameController.text.isNotEmpty ? nameController.text.trim() : null,
                    phone: phoneController.text.isNotEmpty ? phoneController.text.trim() : null,
                  );
                  
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? '✅ Profil mis à jour avec succès'
                              : '❌ Erreur lors de la mise à jour',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
              ),
              child: const Text(
                'Enregistrer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Profil utilisateur
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

          // #34 — Tableau de bord statistiques
          _buildStatsRow(context, isDark),
          const SizedBox(height: 16),

          // #3 — Carte de fidélité
          _buildLoyaltyCard(context, isDark),
          const SizedBox(height: 20),
          
          _buildSection(
            title: 'Compte',
            isDark: isDark,
            items: [
              _buildSettingItem(
                icon: Icons.person,
                title: 'Mon profil',
                subtitle: 'Gérer vos informations personnelles',
                isDark: isDark,
                onTap: () => _showEditProfileDialog(context),
              ),
              _buildSettingItem(
                icon: Icons.location_on,
                title: 'Mes adresses',
                subtitle: 'Gérer vos adresses de livraison',
                isDark: isDark,
                isComingSoon: true,
              ),
              _buildSettingItem(
                icon: Icons.payment,
                title: 'Moyens de paiement',
                subtitle: 'Cartes bancaires enregistrées',
                isDark: isDark,
                isComingSoon: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSection(
            title: 'Préférences',
            isDark: isDark,
            items: [
              _buildSettingItem(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: themeProvider.notificationsEnabled ? 'Activées' : 'Désactivées',
                isDark: isDark,
                trailing: Switch(
                  value: themeProvider.notificationsEnabled,
                  onChanged: (value) {
                    themeProvider.toggleNotifications();
                  },
                  activeThumbColor: Colors.brown[700],
                ),
              ),
              // Amélioration #9: Mode sombre fonctionnel
              _buildSettingItem(
                icon: Icons.dark_mode,
                title: 'Mode sombre',
                subtitle: isDark ? 'Activé' : 'Désactivé',
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
                title: 'Langue',
                subtitle: 'Français',
                isDark: isDark,
                isComingSoon: true,
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
                title: 'Aide & FAQ',
                subtitle: 'Questions fréquentes',
                isDark: isDark,
                isComingSoon: true,
              ),
              _buildSettingItem(
                icon: Icons.phone,
                title: 'Contactez-nous',
                subtitle: 'Support client',
                isDark: isDark,
                isComingSoon: true,
              ),
              _buildSettingItem(
                icon: Icons.star,
                title: 'Évaluer l\'application',
                subtitle: 'Donnez votre avis',
                isDark: isDark,
                isComingSoon: true,
              ),
              _buildSettingItem(
                icon: Icons.info,
                title: 'À propos',
                subtitle: 'Version 1.0.0',
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
                      const Text('Application de livraison de nourriture'),
                      const SizedBox(height: 10),
                      const Text('Développée avec Flutter'),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Bouton de déconnexion
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
              label: const Text(
                'Se déconnecter',
                style: TextStyle(
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
          const SizedBox(height: 100), // Espace pour la barre de navigation
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
          child: Icon(icon, color: isDark ? Colors.brown[300] : Colors.brown[800], size: 24),
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
        trailing: trailing ?? (isComingSoon
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  // #34 — Tableau de bord statistiques
  Widget _buildStatsRow(BuildContext context, bool isDark) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final stats = orderProvider.getStatistics();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.receipt_long,
            value: '${stats['totalOrders']}',
            label: 'Commandes',
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
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            value: (stats['averageOrderValue'] as num).toStringAsFixed(0),
            label: 'Moy/cmd',
            color: Colors.orange,
            isDark: isDark,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
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

  // #3 — Carte de fidélité
  Widget _buildLoyaltyCard(BuildContext context, bool isDark) {
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
                      Text(loyalty.levelEmoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      const Text(
                        'Programme Fidélité',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    'points',
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
                  '${loyalty.pointsToNextLevel} points pour le niveau ${loyalty.level == 'Bronze' ? 'Silver' : 'Gold'}',
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