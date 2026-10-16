class PokemonListEntry {
  const PokemonListEntry({required this.id, required this.name});

  final int id;
  final String name;

  String get artworkUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/'
      'sprites/pokemon/other/official-artwork/$id.png';

  factory PokemonListEntry.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    final url = json['url'] as String?;
    if (name == null || url == null) {
      throw const FormatException('Entrada incompleta en el catálogo.');
    }

    final segments = Uri.parse(url).pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    if (segments.length < 2 || segments[segments.length - 2] != 'pokemon') {
      throw FormatException('URL de Pokémon no válida: $url');
    }

    final id = int.tryParse(segments.last);
    if (id == null) {
      throw FormatException('No se pudo obtener el ID desde la URL: $url');
    }

    return PokemonListEntry(id: id, name: name);
  }
}

class PokemonListPage {
  const PokemonListPage({
    required this.results,
    required this.totalCount,
    required this.hasMore,
  });

  final List<PokemonListEntry> results;
  final int totalCount;
  final bool hasMore;

  factory PokemonListPage.fromJson(Map<String, dynamic> json) {
    final count = json['count'];
    final next = json['next'];
    final results = json['results'];
    if (count is! int || next != null && next is! String || results is! List) {
      throw const FormatException('La respuesta paginada no es válida.');
    }

    final entries = <PokemonListEntry>[];
    for (final entry in results) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Una entrada del catálogo no es válida.');
      }
      entries.add(PokemonListEntry.fromJson(entry));
    }

    return PokemonListPage(
      results: entries,
      totalCount: count,
      hasMore: next != null,
    );
  }
}
