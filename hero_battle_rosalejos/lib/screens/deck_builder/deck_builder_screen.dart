import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/deck_provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../widgets/stat_row.dart';
import '../../models/hero_model.dart';
import '../../router/app_router.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  bool _isSearching = false;
  int? _activeFilter; // 1-6 cost filter

  @override
  void initState() {
    super.initState();
    // Ensures deck is fresh every time the builder is entered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeckProvider>().clearDeck();
    });
  }

  @override
  Widget build(BuildContext context) {
    final deckProvider = context.watch<DeckProvider>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('DECK BUILDER'),
          actions: [
            TextButton(
              onPressed: () => deckProvider.clearDeck(),
              child: const Text('CLEAR DECK',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'TOTAL COST: ${deckProvider.totalCost} / 15',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: deckProvider.totalCost > 15
                          ? Colors.red
                          : Colors.white,
                    ),
              ),
            ),
            Expanded(
              child: _buildDeckGrid(deckProvider),
            ),
            if (deckProvider.deckSize > 0)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: deckProvider.totalCost > 15
                      ? null
                      : () => _showSaveDialog(context, deckProvider),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('SAVE DECK'),
                ),
              ),
          ],
        ),
        bottomSheet: _isSearching ? _buildSearchOverlay() : null,
      ),
    );
  }

  Widget _buildDeckGrid(DeckProvider deckProvider) {
    final cards = List.generate(5, (index) {
      if (index < deckProvider.deckSize) {
        return _buildHeroSlot(deckProvider.deck[index], () {
          deckProvider.removeHero(deckProvider.deck[index]);
        });
      } else {
        return _buildEmptySlot(() {
          setState(() => _isSearching = true);
        });
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: cards[4],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSlot(HeroModel hero, VoidCallback onRemove) {
    return AspectRatio(
      aspectRatio: 0.7,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: hero.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: onRemove,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(hero.name,
                        style: const TextStyle(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text('Cost: ${hero.cost}',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot(VoidCallback onTap) {
    return AspectRatio(
      aspectRatio: 0.7,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: DashedRectPainter(color: Colors.white54),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.add, size: 40, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchOverlay() {
    // Trigger initialization and random fetch when search opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HeroSearchProvider>();
      if (provider.randomResults.isEmpty) {
        provider.initialize();
      }
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildSearchHeader(),
          _buildSearchAndFilters(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text('DISCOVER HEROES',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              context.read<HeroSearchProvider>().clearSearch();
              setState(() => _isSearching = false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by name...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (query) {
              context.read<HeroSearchProvider>().search(query);
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: List.generate(6, (index) {
              final cost = index + 1;
              final isSelected = _activeFilter == cost;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text('Cost $cost'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _activeFilter = selected ? cost : null);
                    // Clear search when switching to cost categories to show all heroes of that cost
                    if (selected) context.read<HeroSearchProvider>().clearSearch();
                  },
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Consumer<HeroSearchProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<HeroModel> displayHeroes;
        
        // If a cost filter is active, filter from the FULL database to provide substantial results
        if (_activeFilter != null) {
          displayHeroes = provider.fullDatabase
              .where((h) => h.cost == _activeFilter)
              .toList();
          // Sort alphabetically for better discovery
          displayHeroes.sort((a, b) => a.name.compareTo(b.name));
        } else {
          displayHeroes = provider.results.isNotEmpty 
              ? provider.results 
              : provider.randomResults;
        }

        if (displayHeroes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(_activeFilter != null 
                    ? 'No Cost $_activeFilter heroes found.' 
                    : 'No matches found.',
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: displayHeroes.length,
          itemBuilder: (context, i) {
            final hero = displayHeroes[i];
            final canAdd = context.read<DeckProvider>().canAdd(hero);
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: hero.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.black12),
                    errorWidget: (context, url, error) => const Icon(Icons.person),
                  ),
                ),
              ),
              title: Text(hero.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Cost: ${hero.cost} • ${hero.publisher}'),
              trailing: ElevatedButton(
                onPressed: canAdd
                    ? () {
                        context.read<DeckProvider>().addHero(hero);
                        context.read<HeroSearchProvider>().clearSearch();
                        setState(() => _isSearching = false);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAdd ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('ADD'),
              ),
              onTap: () => Navigator.pushNamed(context, RouteNames.heroDetail, arguments: hero),
            );
          },
        );
      },
    );
  }

  void _showSaveDialog(BuildContext context, DeckProvider deck) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter deck name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await deck.saveDeckToDb(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deck saved!')));
                }
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter(
      {this.color = Colors.black, this.strokeWidth = 2.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double x = size.width;
    double y = size.height;

    Path path = Path();
    path.addRRect(RRect.fromLTRBR(0, 0, x, y, const Radius.circular(8)));

    Path dashPath = Path();

    double dashWidth = 10.0;
    double dashSpace = 5.0;
    double distance = 0.0;

    for (var i in path.computeMetrics()) {
      while (distance < i.length) {
        dashPath.addPath(
          i.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, dashedPaint);
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) => false;
}
