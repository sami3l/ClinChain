import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lot.dart';
import '../config/app_theme.dart';

/// Timeline widget for displaying lot history
class HistoryTimeline extends StatelessWidget {
  final List<LotHistoryEntry> history;

  const HistoryTimeline({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: AppTheme.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun historique',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedHistory = history.reversed.toList();
    final dateFmt = DateFormat('dd MMM yyyy, HH:mm');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedHistory.length,
      itemBuilder: (context, index) {
        final entry = sortedHistory[index];
        final isFirst = index == 0;
        final isLast = index == sortedHistory.length - 1;

        return _TimelineItem(
          entry: entry,
          isFirst: isFirst,
          isLast: isLast,
          dateFmt: dateFmt,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final LotHistoryEntry entry;
  final bool isFirst;
  final bool isLast;
  final DateFormat dateFmt;

  const _TimelineItem({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.dateFmt,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForAction(entry.action);
    final color = _getColorForAction(entry.action);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line
                if (!isFirst)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppTheme.dividerColor,
                    ),
                  )
                else
                  const SizedBox(height: 8),

                // Dot with icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    size: 20,
                    color: color,
                  ),
                ),

                // Bottom line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppTheme.dividerColor,
                    ),
                  )
                else
                  const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action text
                  Text(
                    entry.action,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Actor
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.actor,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Timestamp
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFmt.format(entry.at),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  // Badge for special actions
                  if (isFirst) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Plus récent',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForAction(String action) {
    final lowerAction = action.toLowerCase();
    if (lowerAction.contains('créé') || lowerAction.contains('created')) {
      return Icons.add_circle;
    } else if (lowerAction.contains('validé') ||
        lowerAction.contains('validated') ||
        lowerAction.contains('reception')) {
      return Icons.check_circle;
    } else if (lowerAction.contains('retir') ||
        lowerAction.contains('withdraw') ||
        lowerAction.contains('dispensed')) {
      return Icons.remove_circle;
    } else if (lowerAction.contains('commande') ||
        lowerAction.contains('order')) {
      return Icons.shopping_cart;
    } else {
      return Icons.info;
    }
  }

  Color _getColorForAction(String action) {
    final lowerAction = action.toLowerCase();
    if (lowerAction.contains('créé') || lowerAction.contains('created')) {
      return AppTheme.primaryBlue;
    } else if (lowerAction.contains('validé') ||
        lowerAction.contains('validated')) {
      return AppTheme.accentGreen;
    } else if (lowerAction.contains('retir') ||
        lowerAction.contains('withdraw')) {
      return AppTheme.warningOrange;
    } else if (lowerAction.contains('commande') ||
        lowerAction.contains('order')) {
      return AppTheme.secondaryTeal;
    } else {
      return AppTheme.textSecondary;
    }
  }
}
