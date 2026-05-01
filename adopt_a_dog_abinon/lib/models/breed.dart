class Breed {
final String name; // e.g. 'bulldog'
final List<String> subBreeds; // e.g. ['french', 'english']
const Breed({required this.name, required this.subBreeds});
// Display name with optional sub-breed
String displayName([String? sub]) =>
sub != null ? '$sub $name' : name;
}