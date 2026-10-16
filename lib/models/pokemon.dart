class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.frontSprite,
    required this.backSprite,
    required this.artwork,
    required this.types,
    required this.height,
    required this.weight,
    required this.baseExperience,
  });

  final int id;
  final String name;
  final String? frontSprite;
  final String? backSprite;
  final String? artwork;
  final List<String> types;
  final int height;
  final int weight;
  final int? baseExperience;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>? ?? {};
    final other = sprites['other'] as Map<String, dynamic>? ?? {};
    final officialArtwork =
        other['official-artwork'] as Map<String, dynamic>? ?? {};
    final types = (json['types'] as List<dynamic>? ?? [])
        .map((entry) => (entry as Map<String, dynamic>)['type']
            as Map<String, dynamic>)
        .map((type) => type['name'] as String)
        .toList(growable: false);

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      frontSprite: sprites['front_default'] as String?,
      backSprite: sprites['back_default'] as String?,
      artwork: officialArtwork['front_default'] as String?,
      types: types,
      height: json['height'] as int? ?? 0,
      weight: json['weight'] as int? ?? 0,
      baseExperience: json['base_experience'] as int?,
    );
  }
}
