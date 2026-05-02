import 'package:flutter/material.dart';

import '../../models/battle_record.dart';
import '../../router/app_router.dart';
import '../../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const int _initialVisibleCount = 8;

  static const String _openDrawerArg = 'openDrawer';
  static const String _fromDrawerArg = 'fromDrawer';
  bool _showAllRecords = false;

  void _goBack(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final openedFromDrawer =
        args is Map<String, dynamic> && args[_fromDrawerArg] == true;
    if (openedFromDrawer) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteNames.home,
        (_) => false,
        arguments: <String, dynamic>{_openDrawerArg: true},
      );
      return;
    }

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushReplacementNamed(
      RouteNames.home,
      arguments: <String, dynamic>{_openDrawerArg: true},
    );
  }

  String _formatDate(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) {
      return iso;
    }
    final local = parsed.toLocal();
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$mm-$dd $hh:$min';
  }

  Widget _buildStatCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color accent,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleCard(BuildContext context, BattleRecord record) {
    final theme = Theme.of(context);
    final resultText = record.playerWon ? 'Win' : 'Loss';
    final accent = record.playerWon ? const Color(0xFF4FCB71) : const Color(0xFFFF5E57);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.24),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    record.playerWon ? Icons.emoji_events : Icons.close,
                    color: accent,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your Team vs Opponent Team',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    resultText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.56),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Rounds: ${record.roundsPlayed}',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.56),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _formatDate(record.playedAt),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.56),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Starter: ${record.playerHero}',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.56),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Enemy starter: ${record.aiHero}',
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => _goBack(context),
        ),
        title: const Text('Battle History'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.scaffoldBackgroundColor,
              theme.colorScheme.surface.withValues(alpha: 0.65),
            ],
          ),
        ),
        child: FutureBuilder<List<BattleRecord>>(
            future: DatabaseService().loadHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              final records = snapshot.data ?? <BattleRecord>[];
              if (records.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.24),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.history_toggle_off,
                          size: 40,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 10),
                        const Text('No battles recorded yet.'),
                      ],
                    ),
                  ),
                );
              }

              final winCount = records.where((r) => r.playerWon).length;
              final winRate = ((winCount / records.length) * 100).toStringAsFixed(1);
              final recordsToDisplay = _showAllRecords
                ? records
                : records.take(_initialVisibleCount).toList();
              final hasMoreRecords = records.length > _initialVisibleCount;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth >= 1100 ? 24.0 : 14.0;
                  final crossAxisCount = constraints.maxWidth >= 900 ? 2 : 1;

                  return CustomScrollView(
                    slivers: <Widget>[
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          14,
                          horizontalPadding,
                          8,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: <Widget>[
                              SizedBox(
                              width: constraints.maxWidth >= 650
                                  ? (constraints.maxWidth - (horizontalPadding * 2) - 20) / 3
                                  : constraints.maxWidth - (horizontalPadding * 2),
                              child: _buildStatCard(
                                context: context,
                                icon: Icons.sports_martial_arts,
                                label: 'Total Battles',
                                value: '${records.length}',
                                accent: theme.colorScheme.primary,
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth >= 650
                                  ? (constraints.maxWidth - (horizontalPadding * 2) - 20) / 3
                                  : constraints.maxWidth - (horizontalPadding * 2),
                              child: _buildStatCard(
                                context: context,
                                icon: Icons.emoji_events,
                                label: 'Wins',
                                value: '$winCount',
                                accent: const Color(0xFF4FCB71),
                              ),
                            ),
                            SizedBox(
                              width: constraints.maxWidth >= 650
                                  ? (constraints.maxWidth - (horizontalPadding * 2) - 20) / 3
                                  : constraints.maxWidth - (horizontalPadding * 2),
                              child: _buildStatCard(
                                context: context,
                                icon: Icons.trending_up,
                                label: 'Win Rate',
                                value: '$winRate%',
                                accent: const Color(0xFF5CC6FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hasMoreRecords)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            2,
                            horizontalPadding,
                            6,
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                _showAllRecords
                                    ? 'Showing all ${records.length} battles'
                                    : 'Showing recent ${recordsToDisplay.length} of ${records.length}',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showAllRecords = !_showAllRecords;
                                  });
                                },
                                icon: Icon(
                                  _showAllRecords
                                      ? Icons.unfold_less_rounded
                                      : Icons.unfold_more_rounded,
                                ),
                                label: Text(
                                  _showAllRecords ? 'Show Less' : 'Show More',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        8,
                        horizontalPadding,
                        24,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildBattleCard(context, recordsToDisplay[index]),
                          childCount: recordsToDisplay.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 138,
                        ),
                      ),
                    ),
                    ],
                  );
                },
              );
            },
          ),
      ),
    );
  }
}
