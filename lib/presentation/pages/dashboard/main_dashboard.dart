import 'package:flutter/material.dart';
import '../../../presentation/theme/medical_colors.dart';
import '../formulario/formulario_page.dart';
import '../profile/profile_page.dart';

/// Dashboard principal con navegación inferior
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  // Páginas del dashboard
  final List<Widget> _pages = [
    const FormularioPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: MedicalColors.primaryBlue,
        unselectedItemColor: MedicalColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 0
                    ? MedicalColors.primaryBlue.withAlpha((0.1 * 255).toInt())
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _currentIndex == 0 ? Icons.favorite : Icons.favorite_border,
                size: 26,
              ),
            ),
            label: 'Formulario',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _currentIndex == 1
                    ? MedicalColors.primaryBlue.withAlpha((0.1 * 255).toInt())
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _currentIndex == 1 ? Icons.person : Icons.person_outline,
                size: 26,
              ),
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
