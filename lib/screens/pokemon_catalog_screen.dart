import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/pokemon_list_entry.dart';
import '../services/pokemon_api.dart';
import 'pokemon_detail_screen.dart';

class PokemonCatalogScreen extends StatefulWidget {
  const PokemonCatalogScreen({super.key});

  @override
  State<PokemonCatalogScreen> createState() => _PokemonCatalogScreenState();
}

class _PokemonCatalogScreenState extends State<PokemonCatalogScreen> {
  static const int _pageSize = 30;

  final PokemonApi _pokemonApi = PokemonApi();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<PokemonListEntry> _pokemon = const [];
  int _offset = 0;
  int _totalCount = 0;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _loadMoreError;

  List<PokemonListEntry> get _filteredPokemon {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _pokemon;
    return _pokemon
        .where((pokemon) {
          return pokemon.name.contains(query) ||
              pokemon.id.toString().contains(query);
        })
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        _loadMoreError != null) {
      return;
    }

    final position = _scrollController.position;
    if (position.maxScrollExtent > 0 &&
        position.pixels >= position.maxScrollExtent * 0.9) {
      _loadNextPage();
    }
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _isLoading = true;
      _isLoadingMore = false;
      _offset = 0;
      _totalCount = 0;
      _hasMore = true;
      _pokemon = const [];
      _errorMessage = null;
      _loadMoreError = null;
    });
    try {
      final page = await _pokemonApi.fetchPokemonList(
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _pokemon = page.results;
        _offset = page.results.length;
        _totalCount = page.totalCount;
        _hasMore = page.hasMore && page.results.isNotEmpty;
        _isLoading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.response?.statusCode == 404
            ? 'El catálogo solicitado no está disponible.'
            : 'No se pudo conectar con PokéAPI. Revisa tu conexión e inténtalo otra vez.';
      });
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'La respuesta del catálogo no es válida: ${error.message}';
      });
    }
  }

  Future<void> _loadNextPage({bool retry = false}) async {
    if (_isLoading ||
        _isLoadingMore ||
        !_hasMore ||
        (!retry && _loadMoreError != null)) {
      return;
    }

    final requestOffset = _offset;
    setState(() {
      _isLoadingMore = true;
      _loadMoreError = null;
    });

    try {
      final page = await _pokemonApi.fetchPokemonList(
        limit: _pageSize,
        offset: requestOffset,
      );
      if (!mounted) return;
      setState(() {
        _pokemon = [..._pokemon, ...page.results];
        _offset = requestOffset + page.results.length;
        _totalCount = page.totalCount;
        _hasMore = page.hasMore && page.results.isNotEmpty;
        _isLoadingMore = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _loadMoreError = error.response?.statusCode == 404
            ? 'No hay más registros disponibles en este momento.'
            : 'No se pudo cargar el siguiente bloque. Revisa tu conexión.';
      });
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        _loadMoreError =
            'La respuesta del catálogo no es válida: ${error.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _CatalogBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 26),
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildSearch(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: _buildCatalogBody(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF101B29),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x3370F4E2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A70F4E2),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.radar_rounded,
            color: Color(0xFF70F4E2),
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PULSEDEX',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.3,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'FIELD RESEARCH UNIT',
              style: TextStyle(
                color: Color(0xFF788397),
                fontSize: 8,
                letterSpacing: 1.55,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF111A27),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF263345)),
          ),
          child: const Row(
            children: [
              _LiveDot(),
              SizedBox(width: 7),
              Text(
                'SYSTEM ONLINE',
                style: TextStyle(
                  color: Color(0xFFAAB5C5),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.05,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ARCHIVO DE ESPECÍMENES',
                style: TextStyle(
                  color: Color(0xFF70F4E2),
                  fontSize: 9,
                  letterSpacing: 2.4,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Pokédex',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.6,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona un espécimen para iniciar el análisis.',
                style: TextStyle(color: Color(0xFF8792A5), fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'GLOBAL DATABASE',
              style: TextStyle(
                color: Color(0xFF68758A),
                fontSize: 8,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${_pokemon.length} / $_totalCount',
              style: const TextStyle(
                color: Color(0xFF70F4E2),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF111927).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF293447)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        cursorColor: const Color(0xFF70F4E2),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o número…',
          hintStyle: const TextStyle(color: Color(0xFF6E7A8E), fontSize: 12),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF70F4E2),
            size: 20,
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar búsqueda',
                  onPressed: _searchController.clear,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 17,
                    color: Color(0xFF8792A5),
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCatalogBody() {
    if (_isLoading) {
      return const _CatalogStatus(
        key: ValueKey('catalog-loading'),
        icon: Icons.radar_rounded,
        title: 'SINCRONIZANDO ARCHIVO',
        message: 'Descargando el primer bloque de especímenes…',
        loading: true,
      );
    }
    if (_errorMessage != null) {
      return _CatalogStatus(
        key: const ValueKey('catalog-error'),
        icon: Icons.portable_wifi_off_rounded,
        title: 'SEÑAL INTERRUMPIDA',
        message: _errorMessage!,
        onRetry: _loadCatalog,
      );
    }
    final pokemon = _filteredPokemon;
    if (pokemon.isEmpty) {
      final canSearchMore =
          _searchController.text.trim().isNotEmpty && _hasMore;
      return _CatalogStatus(
        key: const ValueKey('catalog-empty'),
        icon: Icons.manage_search_rounded,
        title: canSearchMore
            ? 'SIN COINCIDENCIAS CARGADAS'
            : 'SIN COINCIDENCIAS',
        message: _loadMoreError ??
            (canSearchMore
                ? 'Amplía la búsqueda cargando el siguiente bloque.'
                : 'Prueba con otro nombre o número de Pokédex.'),
        loading: _isLoadingMore,
        onRetry: canSearchMore && !_isLoadingMore
            ? () => _loadNextPage(retry: true)
            : null,
        actionLabel: _loadMoreError == null ? 'CARGAR MÁS' : 'REINTENTAR',
      );
    }

    return LayoutBuilder(
      key: const ValueKey('catalog-grid'),
      builder: (context, constraints) {
        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(0, 2, 2, 18),
          itemCount:
              pokemon.length +
              (_isLoadingMore || _loadMoreError != null ? 1 : 0),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: constraints.maxWidth < 420 ? 185 : 220,
            mainAxisExtent: 184,
            crossAxisSpacing: 13,
            mainAxisSpacing: 13,
          ),
          itemBuilder: (context, index) {
            if (index >= pokemon.length) {
              return _LoadMoreFooter(
                isLoading: _isLoadingMore,
                errorMessage: _loadMoreError,
                onRetry: () => _loadNextPage(retry: true),
              );
            }
            final entry = pokemon[index];
            return _StaggeredEntrance(
              key: ValueKey('entry-${entry.id}'),
              index: index,
              child: _PokemonCard(
                pokemon: entry,
                onTap: () => Navigator.of(context).push(
                  PageRouteBuilder<void>(
                    transitionDuration: const Duration(milliseconds: 650),
                    reverseTransitionDuration: const Duration(
                      milliseconds: 450,
                    ),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        PokemonDetailScreen(pokemonId: entry.id),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          final curved = CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          );
                          return FadeTransition(
                            opacity: curved,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.025),
                                end: Offset.zero,
                              ).animate(curved),
                              child: child,
                            ),
                          );
                        },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111927).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFF293447)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: isLoading
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF70F4E2),
                        strokeWidth: 2.2,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      'CARGANDO',
                      style: TextStyle(
                        color: Color(0xFF9AA5B6),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 22,
                      color: Color(0xFFFF7C9A),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      errorMessage ?? 'Error de conexión',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9AA5B6),
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                    TextButton(
                      onPressed: onRetry,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF70F4E2),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 30),
                        textStyle: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      child: const Text('REINTENTAR'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PokemonCard extends StatelessWidget {
  const _PokemonCard({required this.pokemon, required this.onTap});

  final PokemonListEntry pokemon;
  final VoidCallback onTap;

  static const _accents = [
    Color(0xFF70F4E2),
    Color(0xFFFF7C9A),
    Color(0xFF8D9DFF),
    Color(0xFFFFD45C),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[(pokemon.id - 1) % _accents.length];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF121A29).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: const Color(0xFF293447)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Stack(
              children: [
                Positioned(
                  right: -32,
                  top: -44,
                  child: Container(
                    width: 142,
                    height: 142,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.07),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 8,
                  child: Text(
                    pokemon.id.toString().padLeft(3, '0'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.055),
                      fontSize: 37,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 5,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.5),
                          blurRadius: 9,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  top: 8,
                  bottom: 34,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Hero(
                      tag: 'pokemon-artwork-${pokemon.id}',
                      child: Image.network(
                        pokemon.artworkUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.catching_pokemon_rounded,
                          color: accent.withValues(alpha: 0.45),
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  right: 13,
                  bottom: 13,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _capitalize(pokemon.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.arrow_outward_rounded,
                        color: accent,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StaggeredEntrance extends StatefulWidget {
  const _StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  Timer? _entranceDelay;

  @override
  void initState() {
    super.initState();
    final staggerIndex = widget.index < 18 ? widget.index : 18;
    _entranceDelay = Timer(Duration(milliseconds: staggerIndex * 28), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _entranceDelay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _CatalogStatus extends StatelessWidget {
  const _CatalogStatus({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.onRetry,
    this.actionLabel = 'REINTENTAR',
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final VoidCallback? onRetry;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF121A29).withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF293447)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 25,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  color: Color(0xFF70F4E2),
                  strokeWidth: 2,
                ),
              )
            else
              Icon(icon, color: const Color(0xFF70F4E2), size: 35),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9AA5B6),
                fontSize: 11,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: Text(actionLabel),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF70F4E2),
                  textStyle: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CatalogBackground extends StatelessWidget {
  const _CatalogBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.9, -0.85),
          radius: 1.25,
          colors: [Color(0xFF112C36), Color(0xFF080C16)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFF70F4E2),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Color(0xAA70F4E2), blurRadius: 7, spreadRadius: 1),
        ],
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
