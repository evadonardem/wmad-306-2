import 'dart:math';

class BattleTurnResult {
	final int playerDamage;
	final int aiDamage;

	const BattleTurnResult({
		required this.playerDamage,
		required this.aiDamage,
	});
}

class BattleEngine {
	static BattleTurnResult resolveTurn({
		required int round,
		required int playerAttack,
		required int playerSpecialAttack,
		required int playerDefense,
		required int aiAttack,
		required int aiSpecialAttack,
		required int aiDefense,
	}) {
		final rng = Random(round * 917);
		final playerUsesSpecial = round % 3 == 0;
		final aiUsesSpecial = round % 4 == 0;

		final basePlayer = playerUsesSpecial ? playerSpecialAttack : playerAttack;
		final baseAi = aiUsesSpecial ? aiSpecialAttack : aiAttack;

		final playerVariance = rng.nextInt(9) - 4;
		final aiVariance = rng.nextInt(9) - 4;

		final playerDamage = max(5, basePlayer - aiDefense + playerVariance);
		final aiDamage = max(5, baseAi - playerDefense + aiVariance);

		return BattleTurnResult(playerDamage: playerDamage, aiDamage: aiDamage);
	}
}

