import '../models/hero_model.dart';

class BattleEngine {
	static bool playerActsFirst(HeroModel player, HeroModel ai) {
		return player.initiative >= ai.initiative;
	}

	static int calculateDamage({
		required int attack,
		required int defense,
		bool isSpecial = false,
	}) {
		final adjustedAttack = isSpecial ? (attack * 1.2).round() : attack;
		final reduced = adjustedAttack - defense;
		return reduced <= 0 ? 1 : reduced;
	}
}
