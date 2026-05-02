import 'battle_types.dart';

class Battlefield {
  final BattlefieldType type;
  final String imageUrl;

  const Battlefield({required this.type, required this.imageUrl});

  static const Battlefield defaultField = Battlefield(
    type: BattlefieldType.city,
    imageUrl: '',
  );
}
