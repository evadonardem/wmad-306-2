class Breed {
  final String name;
  final List<String> subBreeds;
  
  const Breed({
    required this.name,
    required this.subBreeds,
  });
  
  bool get hasSubBreeds => subBreeds.isNotEmpty;
}