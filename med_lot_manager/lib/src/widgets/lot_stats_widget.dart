import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lot_provider.dart';
import '../models/lot_stats.dart';

/// Widget pour afficher les statistiques des lots
class LotStatsWidget extends StatefulWidget {
  const LotStatsWidget({Key? key}) : super(key: key);

  @override
  State<LotStatsWidget> createState() => _LotStatsWidgetState();
}

class _LotStatsWidgetState extends State<LotStatsWidget> {
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final lotProvider = Provider.of<LotProvider>(context, listen: false);
    await lotProvider.loadStats();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LotProvider>(
      builder: (context, lotProvider, child) {
        final stats = lotProvider.stats;

        if (stats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Statistiques',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadStats,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  context,
                  'Total des lots',
                  stats.totalLots.toString(),
                  Icons.inventory,
                  Colors.blue,
                ),
                _buildStatRow(
                  context,
                  'Créés',
                  stats.createdLots.toString(),
                  Icons.add_circle_outline,
                  Colors.orange,
                ),
                _buildStatRow(
                  context,
                  'Validés',
                  stats.validatedLots.toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildStatRow(
                  context,
                  'En stock',
                  stats.inStockLots.toString(),
                  Icons.store,
                  Colors.purple,
                ),
                _buildStatRow(
                  context,
                  'Administrés',
                  stats.administeredLots.toString(),
                  Icons.medical_services,
                  Colors.red,
                ),
                const Divider(height: 24),
                _buildStatRow(
                  context,
                  'Quantité totale',
                  stats.totalQuantity.toString(),
                  Icons.numbers,
                  Colors.teal,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
