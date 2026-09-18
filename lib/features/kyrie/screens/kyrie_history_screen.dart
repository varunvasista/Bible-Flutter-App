import 'package:flutter/material.dart';

import '../../../core/services/service_locator.dart';
import '../services/panic_history_service.dart';
import 'package:bible_app/core/theme/app_colors.dart';

/// Lists all past spiritual guidance sessions stored in [PanicHistoryService].
class PanicHistoryScreen extends StatefulWidget {
  const PanicHistoryScreen({super.key});

  @override
  State<PanicHistoryScreen> createState() => _PanicHistoryScreenState();
}

class _PanicHistoryScreenState extends State<PanicHistoryScreen> {
  List<PanicHistoryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entries = panicHistoryService.getAllEntries();
    });
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear history?'),
        content:
            const Text('This will permanently delete all guidance sessions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await panicHistoryService.clearAll();
      _loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Kyrie History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.white : AppColors.primary,
          ),
        ),
        actions: [
          if (_entries.isNotEmpty)
            IconButton(
              onPressed: _confirmClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: _entries.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _entries.length,
              itemBuilder: (context, index) =>
                  _HistoryTile(entry: _entries[index]),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_edu_rounded, size: 52, color: AppColors.black26),
            SizedBox(height: 16),
            Text(
              'No Kyrie sessions yet.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Sessions will appear here after you open Kyrie.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final PanicHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final preview = entry.userMessage.length > 120
        ? '${entry.userMessage.substring(0, 120)}…'
        : entry.userMessage;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date column
            Container(
              constraints: const BoxConstraints(minWidth: 52),
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                children: [
                  Text(
                    _dayLabel(entry.date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _monthLabel(entry.date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const VerticalDivider(width: 1, color: AppColors.border),
            const SizedBox(width: 10),
            // Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preview,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.55,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 11, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Kyrie ref: ${entry.responseId}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _dayLabel(String dateKey) {
    // dateKey = "2026-03-12"
    final parts = dateKey.split('-');
    if (parts.length < 3) return dateKey;
    return parts[2]; // day
  }

  String _monthLabel(String dateKey) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final parts = dateKey.split('-');
    if (parts.length < 2) return '';
    final month = int.tryParse(parts[1]);
    if (month == null || month < 1 || month > 12) return '';
    return months[month - 1];
  }
}
