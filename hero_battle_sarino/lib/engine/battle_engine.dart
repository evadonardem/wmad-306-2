// Pure Dart combat logic utilities

int calculateDamage(int attackerAttack, int defenderDefense) {
  final baseDamage = attackerAttack;
  return (baseDamage - defenderDefense).clamp(0, baseDamage);
}

bool isCriticalHit() {
  // Simple 10% chance
  return (DateTime.now().millisecondsSinceEpoch % 10) == 0;
}