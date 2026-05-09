import 'package:flutter/foundation.dart';

import '../engine/battle_engine.dart';
import '../models/battle_record.dart';
import '../models/hero_model.dart';
import '../services/database_service.dart';

class BattleProvider extends ChangeNotifier {
	HeroModel? _playerHero;
	HeroModel? _aiHero;
	int _playerHp = 0;
	int _aiHp = 0;
	int _round = 0;
	bool _isBattleActive = false;
	bool? _playerWon;
	final List<String> _battleLog = [];

	HeroModel? get playerHero => _playerHero;
	HeroModel? get aiHero => _aiHero;
	int get playerHp => _playerHp;
	int get aiHp => _aiHp;
	int get round => _round;
	bool get isBattleActive => _isBattleActive;
	bool? get playerWon => _playerWon;
	List<String> get battleLog => List.unmodifiable(_battleLog);

	void startBattle({required HeroModel playerHero, required HeroModel aiHero}) {
		_playerHero = playerHero;
		_aiHero = aiHero;
		_playerHp = playerHero.maxHp;
		_aiHp = aiHero.maxHp;
		_round = 1;
		_isBattleActive = true;
		_playerWon = null;
		_battleLog
			..clear()
			..add('Battle started: ${playerHero.name} vs ${aiHero.name}');
		notifyListeners();
	}

	Future<void> playRound() async {
		if (!_isBattleActive || _playerHero == null || _aiHero == null) return;

		final pHero = _playerHero!;
		final aHero = _aiHero!;
		final playerFirst = BattleEngine.playerActsFirst(pHero, aHero);
		final useSpecial = _round % 3 == 0;

		if (playerFirst) {
			final playerDamage = BattleEngine.calculateDamage(
				attack: useSpecial ? pHero.specialAttack : pHero.attack,
				defense: aHero.defense,
				isSpecial: useSpecial,
			);
			_aiHp = (_aiHp - playerDamage).clamp(0, aHero.maxHp);
			_battleLog.add('${pHero.name} hit ${aHero.name} for $playerDamage');

			if (_aiHp == 0) {
				await finishBattle(playerWon: true);
				return;
			}

			final aiDamage = BattleEngine.calculateDamage(
				attack: aHero.attack,
				defense: pHero.defense,
			);
			_playerHp = (_playerHp - aiDamage).clamp(0, pHero.maxHp);
			_battleLog.add('${aHero.name} hit ${pHero.name} for $aiDamage');
		} else {
			final aiDamage = BattleEngine.calculateDamage(
				attack: aHero.attack,
				defense: pHero.defense,
			);
			_playerHp = (_playerHp - aiDamage).clamp(0, pHero.maxHp);
			_battleLog.add('${aHero.name} hit ${pHero.name} for $aiDamage');

			if (_playerHp == 0) {
				await finishBattle(playerWon: false);
				return;
			}

			final playerDamage = BattleEngine.calculateDamage(
				attack: useSpecial ? pHero.specialAttack : pHero.attack,
				defense: aHero.defense,
				isSpecial: useSpecial,
			);
			_aiHp = (_aiHp - playerDamage).clamp(0, aHero.maxHp);
			_battleLog.add('${pHero.name} hit ${aHero.name} for $playerDamage');
		}

		if (_playerHp == 0 || _aiHp == 0) {
			await finishBattle(playerWon: _aiHp == 0);
			return;
		}

		_round++;
		notifyListeners();
	}

	Future<void> finishBattle({required bool playerWon}) async {
		if (_playerHero == null || _aiHero == null) return;

		_isBattleActive = false;
		_playerWon = playerWon;
		_battleLog.add(playerWon ? 'Player won the battle.' : 'AI won the battle.');

		await DatabaseService().saveBattleRecord(
			BattleRecord(
				playerHero: _playerHero!.name,
				aiHero: _aiHero!.name,
				playerWon: playerWon,
				roundsPlayed: _round,
				playedAt: DateTime.now().toIso8601String(),
			),
		);

		notifyListeners();
	}

	void resetBattle() {
		_playerHero = null;
		_aiHero = null;
		_playerHp = 0;
		_aiHp = 0;
		_round = 0;
		_isBattleActive = false;
		_playerWon = null;
		_battleLog.clear();
		notifyListeners();
	}
}
