import 'package:flutter/material.dart';
import '../../models/battle_record.dart';
import '../../services/database_service.dart';
import 'battle_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isSelectionMode = false;
  final Set<int> _selectedRecords = {};
  List<BattleRecord> _records = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle History'),
        actions: _buildAppBarActions(),
      ),
      body: FutureBuilder<List<BattleRecord>>(
        future: DatabaseService().loadHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          _records = snapshot.data ?? [];
          if (_records.isEmpty) {
            return const Center(child: Text('No battle history yet'));
          }
          return ListView.builder(
            itemCount: _records.length,
            itemBuilder: (context, index) {
              final record = _records[index];
              return _buildHistoryItem(record, index);
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (!_isSelectionMode) {
      return [
        IconButton(
          icon: const Icon(Icons.select_all),
          onPressed: _enterSelectionMode,
          tooltip: 'Select items',
        ),
      ];
    }

    return [
      Text('${_selectedRecords.length} selected'),
      IconButton(
        icon: const Icon(Icons.select_all),
        onPressed: _toggleSelectAll,
        tooltip: 'Select all',
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: _selectedRecords.isNotEmpty ? _deleteSelected : null,
        tooltip: 'Delete selected',
      ),
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitSelectionMode,
        tooltip: 'Cancel selection',
      ),
    ];
  }

  Widget _buildHistoryItem(BattleRecord record, int index) {
    final isSelected = _selectedRecords.contains(record.id);

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: _isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  _toggleSelection(record.id!);
                },
              )
            : CircleAvatar(
                backgroundColor: record.playerWon ? Colors.green : Colors.red,
                child: Icon(
                  record.playerWon ? Icons.check : Icons.close,
                  color: Colors.white,
                ),
              ),
        title: Text('${record.playerHero} vs ${record.aiHero}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.playerWon ? 'Victory' : 'Defeat',
              style: TextStyle(
                color: record.playerWon ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Rounds: ${record.roundsPlayed}'),
            Text('Player team: ${record.playerTeam.length} heroes'),
            Text('AI team: ${record.aiTeam.length} heroes'),
            Text('Date: ${record.playedAt}'),
            if (!_isSelectionMode) ...[
              const SizedBox(height: 4),
              Text(
                'Tap to view details',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: _isSelectionMode ? null : const Icon(Icons.arrow_forward),
        onTap: _isSelectionMode
            ? () => _toggleSelection(record.id!)
            : () => _viewBattleDetails(record),
        onLongPress: !_isSelectionMode ? _enterSelectionMode : null,
      ),
    );
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedRecords.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedRecords.clear();
    });
  }

  void _toggleSelection(int recordId) {
    setState(() {
      if (_selectedRecords.contains(recordId)) {
        _selectedRecords.remove(recordId);
      } else {
        _selectedRecords.add(recordId);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectedRecords.length == _records.length) {
        _selectedRecords.clear();
      } else {
        _selectedRecords.clear();
        for (final record in _records) {
          if (record.id != null) {
            _selectedRecords.add(record.id!);
          }
        }
      }
    });
  }

  void _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Battle Records'),
        content: Text(
          'Are you sure you want to delete ${_selectedRecords.length} battle record(s)? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final recordId in _selectedRecords) {
        await DatabaseService().deleteBattleRecord(recordId);
      }
      setState(() {
        _records.removeWhere(
          (record) => record.id != null && _selectedRecords.contains(record.id),
        );
        _selectedRecords.clear();
        _isSelectionMode = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${_selectedRecords.length} record(s)'),
          ),
        );
      }
    }
  }

  void _viewBattleDetails(BattleRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BattleDetailScreen(record: record),
      ),
    );
  }
}
