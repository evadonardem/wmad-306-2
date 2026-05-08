/// Formats a Pokédex id like 25 → "#025", 721 → "#721".
String formatPokedexId(int id) => '#${id.toString().padLeft(3, '0')}';
