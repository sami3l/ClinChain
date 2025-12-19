import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lot_provider.dart';
import '../models/blockchain_lot.dart';

/// Widget pour afficher l'état blockchain d'un lot
class BlockchainStateWidget extends StatefulWidget {
  final String lotId;

  const BlockchainStateWidget({
    Key? key,
    required this.lotId,
  }) : super(key: key);

  @override
  State<BlockchainStateWidget> createState() => _BlockchainStateWidgetState();
}

class _BlockchainStateWidgetState extends State<BlockchainStateWidget> {
  BlockchainLotDto? _blockchainState;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockchainState();
  }

  Future<void> _loadBlockchainState() async {
    setState(() => _loading = true);
    final lotProvider = Provider.of<LotProvider>(context, listen: false);
    final state = await lotProvider.getBlockchainState(widget.lotId);
    setState(() {
      _blockchainState = state;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_blockchainState == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              const Text('État blockchain non disponible'),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _loadBlockchainState,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final state = _blockchainState!;
    final date = DateTime.fromMillisecondsSinceEpoch(state.timestamp * 1000);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.link, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'État Blockchain',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    // Clear cache and reload
                    final lotProvider =
                        Provider.of<LotProvider>(context, listen: false);
                    lotProvider.clearBlockchainCache();
                    _loadBlockchainState();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  context,
                  'Lot ID',
                  state.lotId,
                  Icons.fingerprint,
                ),
                _buildInfoRow(
                  context,
                  'Nom',
                  state.name,
                  Icons.medical_information,
                ),
                _buildInfoRow(
                  context,
                  'Statut',
                  state.statusName,
                  Icons.info_outline,
                ),
                _buildInfoRow(
                  context,
                  'Code statut',
                  state.blockchainStatus.toString(),
                  Icons.numbers,
                ),
                _buildInfoRow(
                  context,
                  'Acteur',
                  state.actor,
                  Icons.person,
                ),
                _buildInfoRow(
                  context,
                  'Date',
                  dateFormat.format(date),
                  Icons.access_time,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      state.syncedWithDatabase
                          ? Icons.check_circle
                          : Icons.sync_problem,
                      color: state.syncedWithDatabase
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.syncedWithDatabase
                          ? 'Synchronisé avec la base de données'
                          : 'Non synchronisé',
                      style: TextStyle(
                        color: state.syncedWithDatabase
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
