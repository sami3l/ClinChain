import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/lot_provider.dart';
import '../models/lot.dart';
import '../config/app_theme.dart';
import '../widgets/skeleton_loader.dart';
import 'lot_detail_screen.dart';

class LotListScreen extends StatefulWidget {
  @override
  State<LotListScreen> createState() => _LotListScreenState();
}

class _LotListScreenState extends State<LotListScreen> {
  String _searchQuery = '';
  String? _statusFilter; // null = all, 'validated', 'pending'
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LotProvider>(
      builder: (context, provider, _) {
        final filteredLots = _filterLots(provider.lots);

        return Column(
          children: [
            _buildSearchAndFilters(),
            const SizedBox(height: 8),
            Expanded(
              child: provider.loading
                  ? const LotListSkeleton()
                  : filteredLots.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: provider.loadLots,
                          child: ListView.builder(
                            itemCount: filteredLots.length,
                            padding: const EdgeInsets.only(bottom: 80),
                            itemBuilder: (context, idx) {
                              final lot = filteredLots[idx];
                              return _buildLotCard(context, lot);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Rechercher un médicament...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        const SizedBox(height: 12),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Tous'),
                selected: _statusFilter == null,
                onSelected: (selected) {
                  setState(() {
                    _statusFilter = null;
                  });
                },
                selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        size: 16, color: AppTheme.accentGreen),
                    SizedBox(width: 4),
                    Text('Validés'),
                  ],
                ),
                selected: _statusFilter == 'validated',
                onSelected: (selected) {
                  setState(() {
                    _statusFilter = selected ? 'validated' : null;
                  });
                },
                selectedColor: AppTheme.accentGreen.withOpacity(0.2),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_bottom,
                        size: 16, color: AppTheme.warningOrange),
                    SizedBox(width: 4),
                    Text('En attente'),
                  ],
                ),
                selected: _statusFilter == 'pending',
                onSelected: (selected) {
                  setState(() {
                    _statusFilter = selected ? 'pending' : null;
                  });
                },
                selectedColor: AppTheme.warningOrange.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Lot> _filterLots(List<Lot> lots) {
    var filtered = lots;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((lot) {
        return lot.medName.toLowerCase().contains(_searchQuery) ||
            lot.createdBy.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Filter by status
    if (_statusFilter == 'validated') {
      filtered = filtered.where((lot) => lot.validated).toList();
    } else if (_statusFilter == 'pending') {
      filtered = filtered.where((lot) => !lot.validated).toList();
    }

    return filtered;
  }

  Widget _buildLotCard(BuildContext context, Lot lot) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LotDetailScreen(lotId: lot.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with colored background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.getStatusBackgroundColor(lot.validated),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  lot.validated ? Icons.check_circle : Icons.hourglass_bottom,
                  color: AppTheme.getStatusColor(lot.validated),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Lot info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.medName,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Qty: ${lot.quantity}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.person_outline,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            lot.createdBy,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          dateFmt.format(lot.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.getStatusBackgroundColor(lot.validated),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.getStatusColor(lot.validated),
                    width: 1,
                  ),
                ),
                child: Text(
                  lot.validated ? 'Validé' : 'En attente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getStatusColor(lot.validated),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty || _statusFilter != null
                ? Icons.search_off
                : Icons.inventory_2_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _statusFilter != null
                ? 'Aucun lot trouvé'
                : 'Aucun lot disponible',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _statusFilter != null
                ? 'Essayez de modifier vos filtres'
                : 'Les lots apparaîtront ici',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
