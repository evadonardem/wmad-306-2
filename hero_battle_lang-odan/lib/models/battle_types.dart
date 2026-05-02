enum BattleStyle { classicRPG }

enum BattleFormat {
  oneVsOne(1),
  twoVsTwo(2),
  threeVsThree(3),
  fiveVsFive(5);

  const BattleFormat(this.teamSize);

  final int teamSize;

  String get label {
    switch (this) {
      case BattleFormat.oneVsOne:
        return '1v1';
      case BattleFormat.twoVsTwo:
        return '2v2';
      case BattleFormat.threeVsThree:
        return '3v3';
      case BattleFormat.fiveVsFive:
        return '5v5';
    }
  }
}

enum BattlefieldType {
  city('City'),
  forest('Forest'),
  desert('Desert');

  const BattlefieldType(this.name);

  final String name;
}
