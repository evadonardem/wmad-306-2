import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hero_search_provider.dart';
import '../../widgets/hero_card.dart';
import '../../widgets/stat_row.dart';
import '../../router/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HeroSearchProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<HeroSearchProvider>().loadMoreRandom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    // We want the Profile button to match the Menu button (FAB).
    // In Material 3, the FAB uses primaryContainer by default.
    final profileBtnColor = colorScheme.primaryContainer;
    final profileIconColor = colorScheme.onPrimaryContainer;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 64, // Increased to accommodate 48px buttons
          titleSpacing: 16,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _searchController,
                    textAlignVertical: TextAlignVertical.center,
                    maxLines: 1,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search Heroes...',
                      hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black45, fontSize: 14),
                      filled: true,
                      fillColor: isDark ? Colors.white12 : Colors.black.withAlpha(13),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                context.read<HeroSearchProvider>().search('');
                                setState(() {}); // Refresh to hide X
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.black12),
                      ),
                    ),
                    onChanged: (val) => setState(() {}), // Show/hide X button
                    onSubmitted: (query) =>
                        context.read<HeroSearchProvider>().search(query),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 48,
                height: 48,
                child: Material(
                  elevation: 4,
                  shadowColor: Colors.black45,
                  color: profileBtnColor,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () =>
                        Navigator.pushNamed(context, RouteNames.profile),
                    child: Icon(
                      Icons.person, 
                      color: profileIconColor, 
                      size: 24
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Consumer<HeroSearchProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error.isNotEmpty) {
                  return Center(child: Text(provider.error));
                }
                final displayHeroes = provider.results.isNotEmpty 
                    ? provider.results 
                    : provider.randomResults;

                if (displayHeroes.isEmpty) {
                  return const Center(
                      child: Text('No heroes found. Start searching!'));
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(
                      left: 8, right: 8, top: 8, bottom: 80),
                  itemCount: displayHeroes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, i) =>
                      HeroCard(hero: displayHeroes[i]),
                );
              },
            ),
            // Bottom Buttons Overlay
            Positioned(
              left: 16,
              bottom: 16,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, RouteNames.savedDecks),
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('TO BATTLE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_isMenuOpen) ...[
                    _buildMenuButton(
                      label: 'History',
                      icon: Icons.history,
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteNames.history),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuButton(
                      label: 'Saved Decks',
                      icon: Icons.save_alt,
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteNames.savedDecks),
                    ),
                    const SizedBox(height: 8),
                    _buildMenuButton(
                      label: 'Create Deck',
                      icon: Icons.add_box,
                      onPressed: () =>
                          Navigator.pushNamed(context, RouteNames.deckBuilder),
                    ),
                    const SizedBox(height: 8),
                  ],
                  FloatingActionButton(
                    heroTag: 'menuFAB',
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    onPressed: () => setState(() => _isMenuOpen = !_isMenuOpen),
                    child: Icon(_isMenuOpen ? Icons.close : Icons.menu),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Tooltip(
      message: label,
      child: FloatingActionButton.small(
        heroTag: null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}
