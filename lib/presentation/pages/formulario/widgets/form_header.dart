import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../theme/medical_colors.dart';
import '../../../blocs/auth/auth_bloc.dart';

class FormHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onInfoPressed;

  const FormHeader({
    super.key,
    required this.onInfoPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MedicalColors.primaryBlue,
            MedicalColors.primaryBlue.withAlpha((0.85 * 255).toInt()),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: MedicalColors.primaryBlue.withAlpha((0.3 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.2 * 255).toInt()),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withAlpha((0.3 * 255).toInt()),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Título
                  const Expanded(
                    child: Text(
                      'Etiquetado Cardíaco',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Botón de información
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.15 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: onInfoPressed,
                      tooltip: 'Información',
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Botón de cerrar sesión
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha((0.15 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => _showLogoutConfirmation(context),
                      tooltip: 'Cerrar sesión',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de cerrar sesión
  void _showLogoutConfirmation(BuildContext context) {
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
              // Cerrar el diálogo
              Navigator.pop(dialogContext);

              // Despachar evento de cerrar sesión
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
}
