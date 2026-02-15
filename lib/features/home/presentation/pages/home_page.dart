import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _AppDrawer(),
      appBar: AppBar(
        title: const Text(
          'AGROGEST',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),

        // ✅ Clave para Material 3 (evita que se ponga blanco)
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,

        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B3D2E), Color(0xFF1B5E20), Color(0xFF43A047)],
            ),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F3FA), Color(0xFFEEF6F0)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _KpiCard(
                    title: 'Bienvenido',
                    subtitle:
                        'Selecciona una cartilla desde el menú ☰ para iniciar una evaluación.',
                    icon: Icons.fact_check_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Header del Drawer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0B3D2E),
                    Color(0xFF1B5E20),
                    Color(0xFF43A047),
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AGROGEST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text('Evaluaciones', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            // Opciones
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Text(
                      'Módulos',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // =========================
                  // ESTIMACIÓN (carpeta)
                  // =========================
                  _DrawerFolder(
                    icon: Icons.insights_outlined,
                    title: 'Estimación',
                    children: [
                      _DrawerItem(
                        icon: Icons.assignment_outlined,
                        title: 'Medición Brix Pre Cosecha',
                        onTap: () {
                          Navigator.pop(context);
                          context.go('/estimacion/brix');
                        },
                      ),
                    ],
                  ),

                  // =========================
                  // CALIDAD (carpeta)
                  // =========================
                  _DrawerFolder(
                    icon: Icons.verified_outlined,
                    title: 'Calidad',
                    children: [
                      _DrawerItem(
                        icon: Icons.fact_check_outlined,
                        title: 'Cartillas de Calidad',
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Calidad (pendiente)'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // =========================
                  // FITOSANITARIAS (carpeta)
                  // =========================
                  _DrawerFolder(
                    icon: Icons.bug_report_outlined,
                    title: 'Evaluaciones Fitosanitarias',
                    children: [
                      _DrawerItem(
                        icon: Icons.assignment_turned_in_outlined,
                        title: 'Evaluación Fitosanitaria',
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitosanitarias (pendiente)'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Ajustes',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ajustes (pendiente)')),
                      );
                    },
                  ),

                  _DrawerItem(
                    icon: Icons.logout,
                    title: 'Cerrar sesión',
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                    },
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Text(
                'AGG • Evaluar. Medir. Mejorar.',
                style: TextStyle(color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerFolder extends StatelessWidget {
  const _DrawerFolder({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1B5E20).withOpacity(0.10),
          child: Icon(icon, color: const Color(0xFF1B5E20)),
        ),
        // ✅ AHORA LAS CARPETAS USAN EL ESTILO “FUERTE”
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 10, right: 8, bottom: 8),
        children: children,
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF1B5E20).withOpacity(0.10),
        child: Icon(icon, color: const Color(0xFF1B5E20)),
      ),
      // ✅ AHORA LOS SUBITEMS USAN EL ESTILO “DELGADO/PEQUEÑO”
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Colors.green),
        ],
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1B5E20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
