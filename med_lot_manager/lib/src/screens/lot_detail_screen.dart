import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_lot_manager/src/models/user.dart';
import 'package:provider/provider.dart';
import '../providers/lot_provider.dart';
import '../providers/auth_provider.dart';
import '../models/lot.dart';
import '../config/app_theme.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/lot_qr_code.dart';
import '../widgets/history_timeline.dart';
import 'package:intl/intl.dart';

class LotDetailScreen extends StatefulWidget {
  final String lotId;
  LotDetailScreen({required this.lotId});

  @override
  State<LotDetailScreen> createState() => _LotDetailScreenState();
}

class _LotDetailScreenState extends State<LotDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final lotProvider = Provider.of<LotProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final current = lotProvider.lots.firstWhere((l) => l.id == widget.lotId);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du lot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'Voir le QR Code',
            onPressed: () =>
                LotQRCode.showDialog(context, current.id, current.medName),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Voir l\'historique complet',
            onPressed: () => _showHistory(context, current),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.getStatusBackgroundColor(
                                current.validated),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            current.validated
                                ? Icons.check_circle
                                : Icons.hourglass_bottom,
                            size: 32,
                            color: AppTheme.getStatusColor(current.validated),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current.medName,
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.getStatusBackgroundColor(
                                      current.validated),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.getStatusColor(
                                        current.validated),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  current.validated ? 'Validé' : 'En attente',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getStatusColor(
                                        current.validated),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildInfoRow(Icons.inventory_2, 'Quantité',
                        '${current.quantity} unités'),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.person, 'Créé par', current.createdBy),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.calendar_today, 'Date de création',
                        dateFmt.format(current.createdAt)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions section
            Text(
              'Actions disponibles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildActionsCard(context, current, auth, lotProvider),
            const SizedBox(height: 16),

            // History section with Timeline
            Text(
              'Historique',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: HistoryTimeline(history: current.history),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard(BuildContext context, Lot current, AuthProvider auth,
      LotProvider lotProvider) {
    final actions = <Widget>[];

    if (!current.validated && auth.user?.role == Role.hopitale) {
      actions.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Valider la réception'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
          ),
          onPressed: () async {
            await lotProvider.validateReception(current.id);
            if (context.mounted) {
              AppSnackBar.showSuccess(context, 'Réception validée avec succès');
            }
          },
        ),
      );
    }

    if (current.validated && auth.user?.role == Role.pharmacien) {
      actions.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.remove_circle_outline),
          label: const Text('Retirer des unités'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.warningOrange,
          ),
          onPressed: () => _showWithdrawDialog(context, current),
        ),
      );
    }

    if (auth.user?.role == Role.infirmier) {
      actions.add(
        ElevatedButton.icon(
          icon: const Icon(Icons.send),
          label: const Text('Commander'),
          onPressed: () async {
            await lotProvider.addHistory(current.id, 'Commande de médicaments');
            if (context.mounted) {
              AppSnackBar.showSuccess(context, 'Commande envoyée');
            }
          },
        ),
      );
    }

    if (actions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aucune action disponible pour votre rôle',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: actions
              .map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: action,
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showHistory(BuildContext context, Lot current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Historique complet'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: current.history.length,
            itemBuilder: (context, idx) {
              final h = current.history.reversed.toList()[idx];
              return ListTile(
                title: Text(h.action),
                subtitle: Text('${h.actor} — ${h.at}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text('Fermer'))
        ],
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context, Lot current) {
    final qtyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Retirer des unités'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2,
                      color: AppTheme.primaryBlue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Disponible: ${current.quantity} unités',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Quantité à retirer',
                hintText: 'Ex: 50',
                prefixIcon: Icon(Icons.remove_circle_outline),
                suffixText: 'unités',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final qty = int.tryParse(qtyController.text) ?? 0;
              if (qty <= 0) {
                AppSnackBar.showError(context, 'Entrez une quantité valide');
                return;
              }
              if (qty > current.quantity) {
                AppSnackBar.showError(context,
                    'Quantité insuffisante (disponible: ${current.quantity})');
                return;
              }
              try {
                await Provider.of<LotProvider>(context, listen: false)
                    .withdraw(current.id, qty);
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  AppSnackBar.showSuccess(
                      context, '$qty unités retirées avec succès');
                }
              } catch (e) {
                if (ctx.mounted) Navigator.of(ctx).pop();
                if (context.mounted) {
                  AppSnackBar.showError(
                      context, 'Erreur lors du retrait: ${e.toString()}');
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningOrange,
            ),
            child: const Text('Retirer'),
          )
        ],
      ),
    );
  }
}
