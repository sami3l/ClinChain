import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/lot_provider.dart';
import '../models/user.dart';
import '../config/app_theme.dart';
import '../widgets/statistics_charts.dart';
import '../screens/qr_scanner_screen.dart';
import 'lot_list_screen.dart';
import 'create_lot_screen.dart';
import 'lot_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late LotProvider lotProvider;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      lotProvider = Provider.of<LotProvider>(context, listen: false);
      lotProvider.loadLots();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    // Si l'utilisateur est déconnecté, ne rien afficher (sera redirigé vers LoginScreen)
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClinChain - Gestion des lots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scanner un QR Code',
            onPressed: _openScanner,
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Déconnexion',
            onPressed: () {
              _showLogoutDialog(context);
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.list), text: 'Lots'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(user),
          _buildLotsTab(),
        ],
      ),
      floatingActionButton: _floatingActionForRole(user.role),
    );
  }

  Widget _buildDashboardTab(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserBanner(user),
          const SizedBox(height: 16),
          _buildStatsCards(),
          const SizedBox(height: 16),
          Consumer<LotProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  LotStatisticsChart(lots: provider.lots),
                  const SizedBox(height: 16),
                  QuantityTrendChart(lots: provider.lots),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLotsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LotListScreen(),
    );
  }

  Future<void> _openScanner() async {
    final lotId = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (lotId != null && mounted) {
      // Navigate to lot detail if found
      final provider = Provider.of<LotProvider>(context, listen: false);
      final lot = provider.lots.where((l) => l.id == lotId).firstOrNull;

      if (lot != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LotDetailScreen(lotId: lotId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lot non trouvé'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Widget _buildUserBanner(User user) {
    return Card(
      elevation: 0,
      color: AppTheme.getRoleColor(user.role.name).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.getRoleColor(user.role.name),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${user.username}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.getRoleColor(user.role.name),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getRoleLabel(user.role),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<LotProvider>(
      builder: (context, provider, _) {
        final totalLots = provider.lots.length;
        final validatedLots = provider.lots.where((l) => l.validated).length;
        final pendingLots = totalLots - validatedLots;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.inventory_2,
                label: 'Total lots',
                value: totalLots.toString(),
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                label: 'Validés',
                value: validatedLots.toString(),
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.hourglass_bottom,
                label: 'En attente',
                value: pendingLots.toString(),
                color: AppTheme.warningOrange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel(Role role) {
    switch (role) {
      case Role.grossiste:
        return 'Grossiste';
      case Role.hopitale:
        return 'Hôpital';
      case Role.pharmacien:
        return 'Pharmacien';
      case Role.infirmier:
        return 'Infirmier';
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Nettoyer les données des lots avant de se déconnecter
              Provider.of<LotProvider>(context, listen: false).clear();
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  Widget? _floatingActionForRole(Role role) {
    // Only grossiste can create lots in this mapping
    if (role == Role.grossiste) {
      return FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nouveau lot'),
        tooltip: 'Créer lot de médicament',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CreateLotScreen()),
          );
        },
      );
    }
    return null;
  }
}
