class Favorite {
  final String breedName;
  final String imageUrl;

  const Favorite({required this.breedName, required this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      'breedName': breedName,
      'imageUrl': imageUrl,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      breedName: map['breedName'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Favorite &&
           other.breedName == breedName &&
           other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => breedName.hashCode ^ imageUrl.hashCode;
}