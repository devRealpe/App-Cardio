import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/theme/medical_colors.dart';

/// Página de perfil de usuario
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedicalColors.backgroundLight,
      appBar: _buildAppBar(),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return _buildProfileContent(context, state.user);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mi Perfil'),
      centerTitle: true,
      backgroundColor: MedicalColors.primaryBlue,
      elevation: 0,
    );
  }

  Widget _buildProfileContent(BuildContext context, UserEntity user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildProfileHeader(user),
          const SizedBox(height: 40),
          _buildInfoCard(user),
          const SizedBox(height: 24),
          _buildAccountSection(context),
          const SizedBox(height: 24),
          _buildAboutSection(),
          const SizedBox(height: 40),
          _buildLogoutButton(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity user) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                MedicalColors.primaryBlue,
                MedicalColors.lightBlue,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: MedicalColors.primaryBlue.withAlpha((0.3 * 255).toInt()),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: user.photoUrl != null && user.photoUrl!.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    user.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(user),
                  ),
                )
              : _buildDefaultAvatar(user),
        ),
        const SizedBox(height: 16),
        Text(
          user.displayName ?? 'Usuario',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: MedicalColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        _buildVerificationBadge(user.emailVerified),
      ],
    );
  }

  Widget _buildDefaultAvatar(UserEntity user) {
    final initial = (user.displayName?.isNotEmpty ?? false)
        ? user.displayName![0].toUpperCase()
        : (user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U');

    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildVerificationBadge(bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isVerified
            ? MedicalColors.successGreen.withAlpha((0.1 * 255).toInt())
            : MedicalColors.warningOrange.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.info_outline,
            size: 16,
            color: isVerified
                ? MedicalColors.successGreen
                : MedicalColors.warningOrange,
          ),
          const SizedBox(width: 6),
          Text(
            isVerified ? 'Verificado' : 'No verificado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isVerified
                  ? MedicalColors.successGreen
                  : MedicalColors.warningOrange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(UserEntity user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Información de la cuenta'),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.email_outlined,
              'Correo electrónico',
              user.email,
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.calendar_today,
              'Miembro desde',
              _formatDate(user.createdAt),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.login,
              'Último acceso',
              _formatDate(user.lastSignIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: MedicalColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: MedicalColors.primaryBlue.withAlpha((0.1 * 255).toInt()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: MedicalColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: MedicalColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.lock_outline,
            title: 'Cambiar contraseña',
            onTap: () {
              // TODO: Implementar cambio de contraseña
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función en desarrollo'),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildMenuTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            onTap: () {
              // TODO: Implementar configuración de notificaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función en desarrollo'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Acerca de'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Versión',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Text(
                  '1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MedicalColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Aplicación',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Text(
                  'ASCS - Etiquetado Cardíaco',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: MedicalColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: MedicalColors.primaryBlue.withAlpha((0.1 * 255).toInt()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: MedicalColors.primaryBlue,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: MedicalColors.errorRed,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20),
            const SizedBox(width: 12),
            const Text(
              'CERRAR SESIÓN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: MedicalColors.warningOrange,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Cerrar sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?\n\n'
          'Deberás iniciar sesión nuevamente para usar la aplicación.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MedicalColors.errorRed,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
