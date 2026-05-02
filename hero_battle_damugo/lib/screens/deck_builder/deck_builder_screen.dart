import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_config.dart';
import '../../models/hero_model.dart';
import '../../providers/battle_provider.dart';
import '../../providers/deck_provider.dart';
import '../../router/app_router.dart';
import '../../services/superhero_api_service.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  static const String _fallbackAvatarAsset =
      'assets/images/fallbackAvatar.png';

  static const String _openDrawerArg = 'openDrawer';
  static const String _fromDrawerArg = 'fromDrawer';
  final SuperheroApiService _api = SuperheroApiService(
    apiToken: AppConfig.superheroApiToken,
  );
  final Set<int> _hoveredEmptySlots = <int>{};
  final Set<int> _pressedEmptySlots = <int>{};
  final Set<int> _hoveredHeroSlots = <int>{};
  final Set<int> _hoveredRemoveSlots = <int>{};
  final Set<int> _pressedRemoveSlots = <int>{};
  final Map<int, Offset> _heroTiltBySlot = <int, Offset>{};
  bool _isBattleButtonHovered = false;
  bool _isRandomFilling = false;
  bool _isNeedFiveCardsModalOpen = false;

  Future<void> _showNeedFiveCardsModal() async {
    if (_isNeedFiveCardsModalOpen || !mounted) {
      return;
    }

    _isNeedFiveCardsModalOpen = true;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Team Incomplete'),
            content: const Text('You need 5 cards to play.'),
            actions: <Widget>[
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      _isNeedFiveCardsModalOpen = false;
    }
  }

  void _setSlotHover(Set<int> target, int index, bool value) {
    if (value == target.contains(index)) {
      return;
    }
    setState(() {
      if (value) {
        target.add(index);
      } else {
        target.remove(index);
      }
    });
  }

  void _setHeroHover(int index, bool value) {
    if (value == _hoveredHeroSlots.contains(index)) {
      return;
    }
    setState(() {
      if (value) {
        _hoveredHeroSlots.add(index);
      } else {
        _hoveredHeroSlots.remove(index);
      }
    });
  }

  void _updateHeroTilt(int index, Offset localPosition, Size slotSize) {
    if (slotSize.width <= 0 || slotSize.height <= 0) {
      return;
    }

    final center = Offset(slotSize.width / 2, slotSize.height / 2);
    final dx = ((localPosition.dx - center.dx) / center.dx).clamp(-1.0, 1.0);
    final dy = ((localPosition.dy - center.dy) / center.dy).clamp(-1.0, 1.0);
    final nextTilt = Offset(dx.toDouble(), dy.toDouble());
    final previousTilt = _heroTiltBySlot[index];
    if (previousTilt == nextTilt) {
      return;
    }

    setState(() {
      _heroTiltBySlot[index] = nextTilt;
    });
  }

  void _resetHeroTilt(int index) {
    if (!_heroTiltBySlot.containsKey(index)) {
      return;
    }
    setState(() {
      _heroTiltBySlot.remove(index);
    });
  }

  Matrix4 _buildCard3DTransform(Offset tilt, bool isHeroHovered) {
    final matrix = Matrix4.identity()..setEntry(3, 2, 0.0019);
    if (!isHeroHovered) {
      return matrix;
    }

    return matrix
      ..rotateX(-tilt.dy * 0.2)
      ..rotateY(tilt.dx * 0.2)
      ..translateByDouble(tilt.dx * 7.0, tilt.dy * 3.0, 18.0, 1.0);
  }

  Widget _buildHoverShine(bool isHeroHovered) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          opacity: isHeroHovered ? 1 : 0,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              TweenAnimationBuilder<double>(
                key: ValueKey<bool>(isHeroHovered),
                tween: Tween<double>(
                  begin: isHeroHovered ? -1.3 : 0.8,
                  end: 1.4,
                ),
                duration: const Duration(milliseconds: 920),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final travelX = constraints.maxWidth * value;
                      return Transform.translate(
                        offset: Offset(travelX, 0),
                        child: child,
                      );
                    },
                  );
                },
                child: _buildShineBand(width: 62, peakAlpha: 0.48),
              ),
              TweenAnimationBuilder<double>(
                key: ValueKey<String>('trail-$isHeroHovered'),
                tween: Tween<double>(
                  begin: isHeroHovered ? -1.45 : 0.85,
                  end: 1.45,
                ),
                duration: const Duration(milliseconds: 980),
                curve: const Interval(0.18, 1.0, curve: Curves.easeOutCubic),
                builder: (context, value, child) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final travelX = constraints.maxWidth * value;
                      return Transform.translate(
                        offset: Offset(travelX, 0),
                        child: child,
                      );
                    },
                  );
                },
                child: _buildShineBand(width: 52, peakAlpha: 0.24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShineBand({required double width, required double peakAlpha}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Transform.rotate(
        angle: -0.32,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: peakAlpha * 0.4),
                Colors.white.withValues(alpha: peakAlpha),
                Colors.white.withValues(alpha: peakAlpha * 0.4),
                Colors.white.withValues(alpha: 0),
              ],
              stops: const <double>[0, 0.2, 0.5, 0.8, 1],
            ),
          ),
        ),
      ),
    );
  }

  List<BoxShadow>? _buildDirectionalCardShadows({
    required bool isEmpty,
    required bool isHeroHovered,
    required Offset tilt,
  }) {
    if (isEmpty || !isHeroHovered) {
      return null;
    }

    final intensity = (tilt.dx.abs() + tilt.dy.abs()).clamp(0.0, 2.0).toDouble();
    final castOffset = Offset(tilt.dx * 18, (tilt.dy * 14) + 14);

    return <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.34 + (intensity * 0.08)),
        blurRadius: 24 + (intensity * 8),
        spreadRadius: 1 + (intensity * 1.2),
        offset: castOffset,
      ),
      BoxShadow(
        color: Colors.blueAccent.withValues(alpha: 0.22 + (intensity * 0.1)),
        blurRadius: 18 + (intensity * 6),
        spreadRadius: 0.5 + (intensity * 0.8),
        offset: Offset(tilt.dx * 9, (tilt.dy * 6) + 8),
      ),
    ];
  }

  Widget _buildPulsingStatPentagon({
    required String pulseKey,
    required int value,
    required Color fillColor,
    required bool isHeroHovered,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('pulse-$pulseKey-$isHeroHovered'),
      tween: Tween<double>(begin: 0, end: isHeroHovered ? 1 : 0),
      duration: Duration(milliseconds: isHeroHovered ? 360 : 180),
      curve: isHeroHovered ? Curves.easeOutCubic : Curves.easeOut,
      builder: (context, progress, child) {
        final pulse = isHeroHovered ? math.sin(progress * math.pi) : progress;
        final scale = 1.0 + (pulse * 0.12);
        final glowAlpha = isHeroHovered ? (0.18 + (pulse * 0.36)) : 0.0;
        return Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: fillColor.withValues(alpha: glowAlpha),
                  blurRadius: 8.0 + (pulse * 10.0),
                  spreadRadius: pulse * 1.2,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: _DeckStatPentagon(value: value, fillColor: fillColor),
    );
  }

  Offset _parallaxOffset({
    required Offset tilt,
    required bool isHeroHovered,
    required double strength,
    bool invert = false,
  }) {
    if (!isHeroHovered) {
      return Offset.zero;
    }
    final direction = invert ? -1.0 : 1.0;
    return Offset(tilt.dx * strength * direction, tilt.dy * strength * direction);
  }

  Widget _buildParallaxLayer({
    required Offset offset,
    required Widget child,
    Duration duration = const Duration(milliseconds: 110),
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: Offset.zero, end: offset),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, nestedChild) {
        return Transform.translate(offset: value, child: nestedChild);
      },
      child: child,
    );
  }

  void _goBack() {
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

  Future<void> _promptSaveDeck(DeckProvider deck) async {
    final controller = TextEditingController(text: 'My Deck');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Deck name'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true && controller.text.trim().isNotEmpty) {
        try {
          await deck.saveDeckToDb(controller.text.trim());
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Deck Saved')),
          );
        } catch (e) {
          if (!mounted) {
            return;
          }
          final message = e.toString().contains(
                'same name and heroes already exists',
              )
              ? 'This deck is already saved.'
              : 'Could not save deck. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
    }
  }

  int _teamTotalHp(List<HeroModel> heroes) {
    return heroes.fold<int>(0, (sum, hero) => sum + hero.maxHp);
  }

  double _teamAverageAttack(List<HeroModel> heroes) {
    if (heroes.isEmpty) {
      return 0;
    }
    final sum = heroes.fold<int>(0, (total, hero) => total + hero.attack);
    return sum / heroes.length;
  }

  double _teamAverageDefense(List<HeroModel> heroes) {
    if (heroes.isEmpty) {
      return 0;
    }
    final sum = heroes.fold<int>(0, (total, hero) => total + hero.defense);
    return sum / heroes.length;
  }

  HeroModel? _fastestHero(List<HeroModel> heroes) {
    if (heroes.isEmpty) {
      return null;
    }
    return heroes.reduce(
      (a, b) => a.initiative >= b.initiative ? a : b,
    );
  }

  int _heroPowerScore(HeroModel hero) {
    return (hero.maxHp * 2) + (hero.attack * 2) + (hero.defense * 3) + hero.initiative;
  }

  String _teamGrade(List<HeroModel> heroes) {
    if (heroes.isEmpty) {
      return '-';
    }

    final avgHp = _teamTotalHp(heroes) / heroes.length;
    final avgAtk = _teamAverageAttack(heroes);
    final avgDef = _teamAverageDefense(heroes);
    final avgSpeed = heroes.fold<int>(0, (sum, hero) => sum + hero.initiative) / heroes.length;

    final score = (avgHp * 0.35) + (avgAtk * 0.3) + (avgDef * 0.2) + (avgSpeed * 0.15);
    if (score >= 70) {
      return 'A';
    }
    if (score >= 58) {
      return 'B';
    }
    if (score >= 48) {
      return 'C';
    }
    return 'D';
  }

  void _showInfoSnack(String message) {
    // Intentionally no-op: keep quick actions silent with no bottom toast.
  }

  void _sortDeckBy(
    DeckProvider deck,
    int Function(HeroModel hero) metric,
    String label,
  ) {
    final sorted = <HeroModel>[...deck.deck]..sort((a, b) => metric(b).compareTo(metric(a)));
    deck.replaceDeck(sorted);
    _showInfoSnack('Sorted by $label.');
  }

  void _clearWeakestHero(DeckProvider deck) {
    if (deck.deck.isEmpty) {
      return;
    }
    final weakest = deck.deck.reduce(
      (a, b) => _heroPowerScore(a) <= _heroPowerScore(b) ? a : b,
    );
    deck.removeHero(weakest);
    _showInfoSnack('${weakest.name} removed as weakest hero.');
  }

  Future<void> _fillDeckWithRandomHeroes(DeckProvider deck) async {
    if (_isRandomFilling || deck.isFull) {
      return;
    }

    setState(() {
      _isRandomFilling = true;
    });

    try {
      final remaining = DeckProvider.maxDeckSize - deck.deckSize;
      final existingIds = deck.deck.map((hero) => hero.id).toSet();
      var addedCount = 0;

      final initialFetchCount = (remaining * 4).clamp(remaining, 24);
      final candidates = await _api.fetchRandomHeroes(count: initialFetchCount);

      for (final hero in candidates) {
        if (deck.isFull) {
          break;
        }
        if (!existingIds.add(hero.id)) {
          continue;
        }
        deck.addHero(hero);
        addedCount++;
      }

      var fallbackAttempts = 0;
      while (!deck.isFull && fallbackAttempts < 14) {
        fallbackAttempts++;
        try {
          final hero = await _api.fetchRandomHeroFast();
          if (!existingIds.add(hero.id)) {
            continue;
          }
          deck.addHero(hero);
          addedCount++;
        } catch (_) {
          break;
        }
      }

      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      final remainingAfter = DeckProvider.maxDeckSize - deck.deckSize;
      if (addedCount == 0) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not add random heroes right now.')),
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            remainingAfter == 0
                ? 'Deck filled with random heroes.'
                : 'Added $addedCount random hero${addedCount == 1 ? '' : 'es'}.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch random heroes. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRandomFilling = false;
        });
      }
    }
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 168,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        border: Border.all(color: color.withValues(alpha: 0.38)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSectionCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.03),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: child,
    );
  }

  Widget _buildBattleButton({required bool isComplete}) {
    final enabled = isComplete;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!enabled) {
          return;
        }
        if (_isBattleButtonHovered) {
          return;
        }
        setState(() {
          _isBattleButtonHovered = true;
        });
      },
      onExit: (_) {
        if (!enabled) {
          return;
        }
        if (!_isBattleButtonHovered) {
          return;
        }
        setState(() {
          _isBattleButtonHovered = false;
        });
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: _isBattleButtonHovered && enabled ? 1 : 0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          final scale = 1.0 + (value * 0.04);
          final glow = 0.06 + (value * 0.16);

          return Transform.scale(
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.12 + (value * 0.4)),
                  width: 1.0 + (value * 0.6),
                ),
                boxShadow: enabled
                    ? <BoxShadow>[
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: glow + (value * 0.12)),
                          blurRadius: 20 + (value * 28),
                          spreadRadius: 1.5 + (value * 4.0),
                          offset: Offset(0, 6 + (value * 5)),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.06 + (value * 0.22)),
                          blurRadius: 12 + (value * 12),
                          spreadRadius: value * 1.5,
                        ),
                      ]
                    : const <BoxShadow>[],
              ),
              child: child,
            ),
          );
        },
        child: FilledButton.tonal(
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
          onPressed: () {
            if (!enabled) {
              unawaited(_showNeedFiveCardsModal());
              return;
            }
            context.read<BattleProvider>().reset(notify: false);
            Navigator.pushNamed(context, RouteNames.battle);
          },
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: _isBattleButtonHovered && enabled
                        ? Colors.blueAccent.withValues(alpha: 0.12)
                        : Colors.transparent,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _isBattleButtonHovered && enabled ? 1 : 0),
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        final lift = -4.0 * value;
                        final sway = math.sin(value * math.pi * 3.0) * 2.8 * value;
                        final spin = -0.22 * value;
                        final pulse = 1.0 + (value * 0.18);

                        return Transform.translate(
                          offset: Offset(sway, lift),
                          child: Transform.rotate(
                            angle: spin,
                            child: Transform.scale(
                              scale: pulse,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.sports_martial_arts),
                    ),
                    const SizedBox(width: 8),
                    const Text('Battle'),
                  ],
                ),
                if (enabled)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 120),
                        opacity: _isBattleButtonHovered ? 1 : 0,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: _isBattleButtonHovered ? -1.35 : 0.75,
                                end: 1.5,
                              ),
                              duration: const Duration(milliseconds: 560),
                              curve: Curves.easeOutCubic,
                              builder: (context, sweep, child) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final travelX = constraints.maxWidth * sweep;
                                    return Transform.translate(
                                      offset: Offset(travelX, 0),
                                      child: child,
                                    );
                                  },
                                );
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Transform.rotate(
                                  angle: -0.3,
                                  child: Container(
                                    width: 132,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: <Color>[
                                          Colors.white.withValues(alpha: 0),
                                          Colors.white.withValues(alpha: 0.12),
                                          Colors.white.withValues(alpha: 0.42),
                                          Colors.white.withValues(alpha: 0.12),
                                          Colors.white.withValues(alpha: 0),
                                        ],
                                        stops: const <double>[0, 0.2, 0.5, 0.8, 1],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: _isBattleButtonHovered ? -1.6 : 0.6,
                                end: 1.65,
                              ),
                              duration: const Duration(milliseconds: 760),
                              curve: const Interval(0.18, 1.0, curve: Curves.easeOutCubic),
                              builder: (context, sweep, child) {
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final travelX = constraints.maxWidth * sweep;
                                    return Transform.translate(
                                      offset: Offset(travelX, 0),
                                      child: child,
                                    );
                                  },
                                );
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Transform.rotate(
                                  angle: -0.3,
                                  child: Container(
                                    width: 110,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: <Color>[
                                          Colors.transparent,
                                          Colors.blueAccent.withValues(alpha: 0.08),
                                          Colors.white.withValues(alpha: 0.24),
                                          Colors.white.withValues(alpha: 0.08),
                                          Colors.transparent,
                                        ],
                                        stops: const <double>[0, 0.2, 0.5, 0.8, 1],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 140),
                                  opacity: _isBattleButtonHovered ? 1 : 0,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        width: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInsights(DeckProvider deck) {
    final heroes = deck.deck;
    final totalHp = _teamTotalHp(heroes);
    final avgAtk = _teamAverageAttack(heroes);
    final avgDef = _teamAverageDefense(heroes);
    final fastest = _fastestHero(heroes);
    final grade = _teamGrade(heroes);

    Widget insightsPanel() {
      return _buildInsightSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Team Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: Colors.amber.withValues(alpha: 0.16),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    'Grade $grade',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _buildMetricCard('Total HP', '$totalHp', Icons.favorite, Colors.redAccent),
                _buildMetricCard('Avg ATK', avgAtk.toStringAsFixed(1), Icons.flash_on, Colors.orangeAccent),
                _buildMetricCard('Avg DEF', avgDef.toStringAsFixed(1), Icons.shield, Colors.lightBlueAccent),
                _buildMetricCard(
                  'Fastest',
                  fastest == null ? '-' : '${fastest.name} (${fastest.initiative})',
                  Icons.speed,
                  Colors.greenAccent,
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget quickActionsPanel() {
      ButtonStyle alignedActionStyle = FilledButton.styleFrom(
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        alignment: Alignment.centerLeft,
      );

      return _buildInsightSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                FilledButton.tonalIcon(
                  style: alignedActionStyle,
                  onPressed: () => _sortDeckBy(deck, (hero) => hero.maxHp, 'HP'),
                  icon: const Icon(Icons.favorite_outline, size: 18),
                  label: const Text('Sort HP'),
                ),
                FilledButton.tonalIcon(
                  style: alignedActionStyle,
                  onPressed: () => _sortDeckBy(deck, (hero) => hero.attack, 'ATK'),
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text('Sort ATK'),
                ),
                FilledButton.tonalIcon(
                  style: alignedActionStyle,
                  onPressed: () => _sortDeckBy(deck, (hero) => hero.defense, 'DEF'),
                  icon: const Icon(Icons.security, size: 18),
                  label: const Text('Sort DEF'),
                ),
                FilledButton.tonalIcon(
                  style: alignedActionStyle,
                  onPressed: () => _sortDeckBy(deck, _heroPowerScore, 'strongest'),
                  icon: const Icon(Icons.workspace_premium_outlined, size: 18),
                  label: const Text('Sort strongest'),
                ),
                FilledButton.tonalIcon(
                  style: alignedActionStyle,
                  onPressed: () => _clearWeakestHero(deck),
                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                  label: const Text('Clear weakest'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideLayout = constraints.maxWidth >= 900;

        if (!isWideLayout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              insightsPanel(),
              const SizedBox(height: 10),
              quickActionsPanel(),
            ],
          );
        }

        final panelHeight = constraints.maxWidth >= 1200 ? 128.0 : 138.0;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: panelHeight,
                  child: insightsPanel(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: panelHeight,
                  child: quickActionsPanel(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillPercentage = (deck.deckSize / DeckProvider.maxDeckSize * 100).toInt();
    final isComplete = deck.isFull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: _goBack,
        ),
        title: const Text('Deck Builder'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          // Progress Header
          _buildInsightSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Your Team Composition',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isComplete ? Colors.greenAccent.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isComplete ? Colors.greenAccent : Colors.orange,
                        ),
                      ),
                      child: Text(
                        '${deck.deckSize}/${DeckProvider.maxDeckSize}',
                        style: TextStyle(
                          color: isComplete ? Colors.greenAccent.shade200 : Colors.orangeAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: fillPercentage / 100,
                    minHeight: 8,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isComplete ? Colors.greenAccent : Colors.blueAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isComplete
                      ? 'Your team is ready for battle'
                      : 'Add ${DeckProvider.maxDeckSize - deck.deckSize} more hero${DeckProvider.maxDeckSize - deck.deckSize != 1 ? 's' : ''} to form your team',
                  style: TextStyle(
                    color: isComplete
                        ? (isDark ? Colors.greenAccent.shade200 : Colors.green.shade700)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Card Slots Grid
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Team Slots',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: deck.isFull || _isRandomFilling
                    ? null
                    : () => _fillDeckWithRandomHeroes(deck),
                icon: _isRandomFilling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.casino_outlined),
                label: Text(_isRandomFilling ? 'Filling...' : 'Random Fill'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: DeckProvider.maxDeckSize,
            itemBuilder: (context, index) {
              final hero = index < deck.deck.length ? deck.deck[index] : null;
              return _buildCardSlot(context, index, hero, deck);
            },
          ),

          const SizedBox(height: 18),

          // Team Insights
          if (deck.deck.isNotEmpty) _buildTeamInsights(deck),

          const SizedBox(height: 18),

          // Action Buttons
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: deck.deck.isEmpty ? null : () => _promptSaveDeck(deck),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Deck'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildBattleButton(isComplete: isComplete)),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.pushNamed(context, RouteNames.savedDecks),
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('View Saved Decks'),
          ),
        ],
      ),
    );
  }

  void _openHeroSearch(DeckProvider deck) {
    Navigator.pushNamed(
      context,
      RouteNames.home,
      arguments: <String, dynamic>{'fromDeckBuilder': true},
    );
  }

  Future<void> _handleEmptySlotTap(DeckProvider deck, int index) async {
    _setSlotHover(_pressedEmptySlots, index, true);
    await Future<void>.delayed(const Duration(milliseconds: 110));
    if (!mounted) {
      return;
    }
    _setSlotHover(_pressedEmptySlots, index, false);
    _openHeroSearch(deck);
  }

  Widget _buildCardSlot(BuildContext context, int index, HeroModel? hero, DeckProvider deck) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final slotSize = const Size(220, 295);
    final isEmpty = hero == null;
    final isEmptyHovered = _hoveredEmptySlots.contains(index);
    final isEmptyPressed = _pressedEmptySlots.contains(index);
    final isHeroHovered = _hoveredHeroSlots.contains(index);
    final heroTilt = _heroTiltBySlot[index] ?? Offset.zero;
    final backgroundParallax = _parallaxOffset(
      tilt: heroTilt,
      isHeroHovered: isHeroHovered,
      strength: 5.2,
    );
    final heroParallax = _parallaxOffset(
      tilt: heroTilt,
      isHeroHovered: isHeroHovered,
      strength: 12.0,
    );
    final hudParallax = _parallaxOffset(
      tilt: heroTilt,
      isHeroHovered: isHeroHovered,
      strength: 2.2,
      invert: true,
    );
    final isRemoveHovered = _hoveredRemoveSlots.contains(index);
    final isRemovePressed = _pressedRemoveSlots.contains(index);
    final directionalShadows = _buildDirectionalCardShadows(
      isEmpty: isEmpty,
      isHeroHovered: isHeroHovered,
      tilt: heroTilt,
    );
    final cardScale = isEmpty
        ? (isEmptyPressed ? 0.985 : (isEmptyHovered ? 1.01 : 1.0))
      : (isHeroHovered ? 1.07 : 1.0);

    return MouseRegion(
      cursor: isEmpty ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) {
        if (isEmpty) {
          _setSlotHover(_hoveredEmptySlots, index, true);
          return;
        }
        _setHeroHover(index, true);
      },
      onHover: (event) {
        if (isEmpty) {
          return;
        }
        _updateHeroTilt(index, event.localPosition, slotSize);
      },
      onExit: (_) {
        if (isEmpty) {
          _setSlotHover(_hoveredEmptySlots, index, false);
          _setSlotHover(_pressedEmptySlots, index, false);
          return;
        }
        _setHeroHover(index, false);
        _resetHeroTilt(index);
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: cardScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 170),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEmpty
                  ? (isEmptyHovered
                      ? Colors.blueAccent.withValues(alpha: 0.95)
                  : (isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : theme.colorScheme.outline.withValues(alpha: 0.55)))
                  : Colors.blueAccent.withValues(alpha: 0.6),
              width: 2,
            ),
            color: isEmpty
                ? (isEmptyHovered
                    ? Colors.blueAccent.withValues(alpha: 0.16)
                : (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)))
                : Colors.blueAccent.withValues(alpha: 0.08),
            boxShadow: directionalShadows,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.blueAccent.withValues(alpha: 0.28),
              highlightColor: Colors.blueAccent.withValues(alpha: 0.18),
              onHighlightChanged: isEmpty
                  ? (value) => _setSlotHover(_pressedEmptySlots, index, value)
                  : null,
              onTap: isEmpty ? () => _handleEmptySlotTap(deck, index) : null,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: <Widget>[
                  Transform(
                    alignment: Alignment.center,
                    transform: _buildCard3DTransform(heroTilt, isHeroHovered && !isEmpty),
                    child: Stack(
                      fit: StackFit.expand,
                      clipBehavior: Clip.none,
                      children: <Widget>[
                    if (hero != null)
                      GestureDetector(
                        onLongPress: () => deck.removeHero(hero),
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          offset: isHeroHovered ? const Offset(0, -0.1) : Offset.zero,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      _buildParallaxLayer(
                                        offset: backgroundParallax,
                                        duration: const Duration(milliseconds: 120),
                                        child: AnimatedScale(
                                          duration: const Duration(milliseconds: 260),
                                          curve: Curves.easeOutCubic,
                                          scale: isHeroHovered ? 1.12 : 1.02,
                                          child: _buildImageWithFallbacks(hero),
                                        ),
                                      ),
                                      _buildParallaxLayer(
                                        offset: heroParallax,
                                        duration: const Duration(milliseconds: 150),
                                        child: AnimatedScale(
                                          duration: const Duration(milliseconds: 260),
                                          curve: Curves.easeOutCubic,
                                          scale: isHeroHovered ? 1.12 : 1.0,
                                          child: _buildImageWithFallbacks(hero),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: <Color>[
                                                Colors.black.withValues(alpha: 0.0),
                                                Colors.black.withValues(alpha: 0.35),
                                                Colors.black.withValues(alpha: 0.82),
                                              ],
                                              stops: const <double>[0.45, 0.68, 1],
                                            ),
                                          ),
                                        ),
                                      ),
                                      _buildHoverShine(isHeroHovered),
                                      Positioned(
                                        left: 8,
                                        right: 8,
                                        bottom: 8,
                                        child: _buildParallaxLayer(
                                          offset: hudParallax,
                                          duration: const Duration(milliseconds: 180),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                hero.name.toUpperCase(),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.4,
                                                  shadows: <Shadow>[
                                                    Shadow(
                                                      color: Colors.black54,
                                                      blurRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  _buildPulsingStatPentagon(
                                                    pulseKey: 'hp-$index',
                                                    value: hero.maxHp,
                                                    fillColor: Colors.red.shade700,
                                                    isHeroHovered: isHeroHovered,
                                                  ),
                                                  _buildPulsingStatPentagon(
                                                    pulseKey: 'def-$index',
                                                    value: hero.defense,
                                                    fillColor: Colors.blue.shade700,
                                                    isHeroHovered: isHeroHovered,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: _buildParallaxLayer(
                                          offset: Offset(hudParallax.dx * 0.65, hudParallax.dy * 0.65),
                                          duration: const Duration(milliseconds: 180),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.35),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              hero.publisher,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimatedScale(
                              duration: const Duration(milliseconds: 120),
                              scale: isEmptyPressed ? 0.92 : (isEmptyHovered ? 1.14 : 1.0),
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 28,
                                color: isEmptyHovered
                                    ? Colors.blueAccent
                                    : theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.7 : 0.62),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Slot ${index + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isEmptyHovered
                                    ? Colors.blueAccent.withValues(alpha: 0.9)
                                    : theme.colorScheme.onSurface.withValues(alpha: isDark ? 0.4 : 0.66),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                  if (hero != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => _setSlotHover(_hoveredRemoveSlots, index, true),
                        onExit: (_) {
                          _setSlotHover(_hoveredRemoveSlots, index, false);
                          _setSlotHover(_pressedRemoveSlots, index, false);
                        },
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkResponse(
                            radius: 18,
                            highlightShape: BoxShape.circle,
                            splashColor: Colors.redAccent.withValues(alpha: 0.35),
                            highlightColor: Colors.redAccent.withValues(alpha: 0.24),
                            onHighlightChanged: (value) =>
                                _setSlotHover(_pressedRemoveSlots, index, value),
                            onTap: () => deck.removeHero(hero),
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 120),
                              scale: isRemovePressed ? 0.86 : (isRemoveHovered ? 1.1 : 1.0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 120),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isRemoveHovered
                                      ? Colors.redAccent
                                      : Colors.redAccent.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent.withValues(
                                        alpha: isRemoveHovered ? 0.6 : 0.4,
                                      ),
                                      blurRadius: isRemoveHovered ? 9 : 4,
                                      spreadRadius: isRemoveHovered ? 2 : 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWithFallbacks(HeroModel hero) {
    final candidates = hero.displayImageCandidates;
    if (candidates.isEmpty) {
      return _buildFallbackAvatarImage();
    }

    return Image.network(
      candidates.first,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        if (candidates.length > 1) {
          return Image.network(
            candidates[1],
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildFallbackAvatarImage(),
          );
        }
        return _buildFallbackAvatarImage();
      },
      loadingBuilder: (context, child, progress) =>
        progress == null
            ? child
            : Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                      : null,
                ),
              ),
    );
  }

  Widget _buildFallbackAvatarImage() {
    return ColoredBox(
      color: const Color(0xFF1E1D2A),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Image.asset(
          _fallbackAvatarAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Container(
            color: Colors.grey.shade700,
            child: const Icon(Icons.image_not_supported, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

class _DeckStatPentagon extends StatelessWidget {
  const _DeckStatPentagon({
    required this.value,
    required this.fillColor,
  });

  final int value;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ) ??
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CustomPaint(
          painter: _DeckPentagonPainter(fillColor: fillColor),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Center(
              child: Text(value.toString(), style: textStyle.copyWith(fontSize: 10)),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeckPentagonPainter extends CustomPainter {
  _DeckPentagonPainter({required this.fillColor});

  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final path = Path();

    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + (2 * math.pi * i / 5);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final fill = Paint()..color = fillColor;
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _DeckPentagonPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor;
  }
}