import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_api.dart';

class PokemonDetailScreen extends StatefulWidget {
  const PokemonDetailScreen({super.key, required this.pokemonId});

  final int pokemonId;

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final PokemonApi _pokemonApi = PokemonApi();
  Pokemon? _pokemon;
  int _requestedId = 1;
  int _requestSequence = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestedId = widget.pokemonId;
    _fetchPokemon(widget.pokemonId, initial: true);
  }

  Future<void> _fetchPokemon(int id, {bool initial = false}) async {
    final sequence = ++_requestSequence;
    if (!initial) {
      setState(() {
        _requestedId = id;
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final pokemon = await _pokemonApi.fetchPokemon(id);
      if (!mounted || sequence != _requestSequence) return;
      setState(() {
        _pokemon = pokemon;
        _requestedId = id;
        _isLoading = false;
        _errorMessage = null;
      });
    } on DioException catch (error) {
      if (!mounted || sequence != _requestSequence) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.response?.statusCode == 404
            ? 'No encontramos el Pokémon #${id.toString().padLeft(4, '0')}.'
            : 'No se pudo conectar con PokéAPI. Revisa tu conexión e inténtalo otra vez.';
      });
    } on FormatException catch (error) {
      if (!mounted || sequence != _requestSequence) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'La respuesta de PokéAPI no es válida: ${error.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AmbientBackground()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 34),
                      _buildIntro(),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 550),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0, 0.045),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offset,
                              child: child,
                            ),
                          );
                        },
                        child: _buildMainPanel(),
                      ),
                      if (_pokemon != null &&
                          !_isLoading &&
                          _errorMessage == null)
                        _buildPokemonDetails(_pokemon!),
                      const SizedBox(height: 22),
                      _buildControls(),
                      const SizedBox(height: 22),
                      const Center(
                        child: Text(
                          'POKÉAPI  ·  SISTEMA DE ANÁLISIS EN VIVO',
                          style: TextStyle(
                            color: Color(0xFF657083),
                            fontSize: 9,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
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

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Volver al catálogo',
          onPressed: () => Navigator.of(context).maybePop(),
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF70F4E2),
            backgroundColor: const Color(0xFF101B29),
            side: const BorderSide(color: Color(0x3370F4E2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 9),
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

  Widget _buildIntro() {
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
              Text(
                'Pokédex',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 39,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.6,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF70F4E2).withValues(alpha: 0.16),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Explora la vida salvaje, un Pokémon a la vez.',
                style: TextStyle(color: Color(0xFF8792A5), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'TARGET ID',
              style: TextStyle(
                color: Color(0xFF68758A),
                fontSize: 8,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '#${_requestedId.toString().padLeft(4, '0')}',
              style: const TextStyle(
                color: Color(0xFF70F4E2),
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainPanel() {
    if (_isLoading) {
      return _PanelFrame(
        key: ValueKey('loading-$_requestedId'),
        child: _RadarLoader(id: _requestedId),
      );
    }
    if (_errorMessage != null) {
      return _PanelFrame(
        key: ValueKey('error-$_requestedId'),
        child: _ErrorPanel(
          id: _requestedId,
          message: _errorMessage!,
          onRetry: () => _fetchPokemon(_requestedId),
        ),
      );
    }
    final pokemon = _pokemon;
    if (pokemon == null) {
      return const SizedBox.shrink();
    }
    return _PanelFrame(
      key: ValueKey('pokemon-${pokemon.id}'),
      child: _PokemonShowcase(pokemon: pokemon),
    );
  }

  Widget _buildPokemonDetails(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 23),
        Row(
          children: [
            const Text(
              'DATOS DE CAMPO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            const Icon(Icons.auto_awesome, color: Color(0xFF70F4E2), size: 13),
            const SizedBox(width: 6),
            Text(
              'REGISTRO #${pokemon.id.toString().padLeft(4, '0')}',
              style: const TextStyle(
                color: Color(0xFF7B879A),
                fontSize: 8,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.height_rounded,
                label: 'ALTURA',
                value: '${(pokemon.height / 10).toStringAsFixed(1)} m',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoTile(
                icon: Icons.monitor_weight_outlined,
                label: 'PESO',
                value: '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoTile(
                icon: Icons.bolt_rounded,
                label: 'EXP. BASE',
                value: pokemon.baseExperience?.toString() ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Text(
              'VISTAS DEL ESPÉCIMEN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                letterSpacing: 1.45,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            const Text(
              'SPRITE ARCHIVE / 02',
              style: TextStyle(
                color: Color(0xFF68758A),
                fontSize: 8,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SpriteCard(
                title: 'FRONTAL',
                imageUrl: pokemon.frontSprite,
                accent: const Color(0xFF70F4E2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SpriteCard(
                title: 'POSTERIOR',
                imageUrl: pokemon.backSprite,
                accent: const Color(0xFFFF7C9A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: IconButton.filledTonal(
            tooltip: 'Pokémon anterior',
            onPressed: _isLoading || _requestedId <= 1
                ? null
                : () => _fetchPokemon(_requestedId - 1),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF151E2D),
              foregroundColor: const Color(0xFFB6C3D3),
              disabledBackgroundColor: const Color(0xFF111722),
              disabledForegroundColor: const Color(0xFF4A5565),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF273348)),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              key: const ValueKey('next-pokemon-button'),
              onPressed: _isLoading
                  ? null
                  : () => _fetchPokemon(_requestedId + 1),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF70F4E2),
                foregroundColor: const Color(0xFF081117),
                disabledBackgroundColor: const Color(0xFF314B4B),
                disabledForegroundColor: const Color(0xFF9AA7A7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.travel_explore_rounded, size: 19),
              label: const Text(
                'ESCANEAR SIGUIENTE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PanelFrame extends StatelessWidget {
  const _PanelFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF293447)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172132), Color(0xFF0E1522)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
          BoxShadow(color: Color(0x1170F4E2), blurRadius: 34, spreadRadius: 1),
        ],
      ),
      child: CustomPaint(painter: _PanelGridPainter(), child: child),
    );
  }
}

class _PokemonShowcase extends StatelessWidget {
  const _PokemonShowcase({required this.pokemon});

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    final accent = _typeColor(pokemon.types.isEmpty ? '' : pokemon.types.first);
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 590;
        return SizedBox(
          height: isWide ? 350 : 378,
          child: Stack(
            children: [
              Positioned(
                top: -105,
                right: -95,
                child: Container(
                  width: 265,
                  height: 265,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.055),
                  ),
                ),
              ),
              Positioned(
                right: 18,
                top: 20,
                child: Text(
                  pokemon.id.toString().padLeft(3, '0'),
                  style: TextStyle(
                    fontSize: isWide ? 90 : 74,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -5,
                    color: Colors.white.withValues(alpha: 0.035),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 34 : 22,
                  vertical: isWide ? 25 : 21,
                ),
                child: isWide
                    ? Row(
                        children: [
                          Expanded(
                            flex: 11,
                            child: _PokemonArtwork(
                              key: ValueKey(pokemon.id),
                              imageUrl: pokemon.artwork ?? pokemon.frontSprite,
                              pokemonId: pokemon.id,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 9,
                            child: _buildPokemonLabel(accent, alignEnd: true),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: _PokemonArtwork(
                              key: ValueKey(pokemon.id),
                              imageUrl: pokemon.artwork ?? pokemon.frontSprite,
                              pokemonId: pokemon.id,
                            ),
                          ),
                          _buildPokemonLabel(accent),
                        ],
                      ),
              ),
              Positioned(
                left: 0,
                top: 28,
                bottom: 28,
                child: Container(
                  width: 3,
                  color: accent.withValues(alpha: 0.72),
                ),
              ),
              Positioned(
                right: 22,
                top: 18,
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 5, color: accent),
                    const SizedBox(width: 5),
                    const Text(
                      'DNA LOCKED',
                      style: TextStyle(
                        color: Color(0xFF8C98AA),
                        fontSize: 7,
                        letterSpacing: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPokemonLabel(Color accent, {bool alignEnd = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.center,
      children: [
        Text(
          'SPECIMEN ${pokemon.id.toString().padLeft(4, '0')}',
          style: TextStyle(
            color: accent,
            fontSize: 8,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _capitalize(pokemon.name),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
        ),
        const SizedBox(height: 9),
        Wrap(
          alignment: alignEnd ? WrapAlignment.end : WrapAlignment.center,
          spacing: 7,
          runSpacing: 6,
          children: pokemon.types
              .map((type) => _TypeChip(type: type, color: _typeColor(type)))
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _PokemonArtwork extends StatelessWidget {
  const _PokemonArtwork({
    super.key,
    required this.imageUrl,
    required this.pokemonId,
  });

  final String? imageUrl;
  final int pokemonId;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.72, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 196,
            height: 196,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF70F4E2).withValues(alpha: 0.105),
                  const Color(0xFF70F4E2).withValues(alpha: 0),
                ],
              ),
            ),
          ),
          if (imageUrl == null)
            const Icon(
              Icons.catching_pokemon_rounded,
              size: 120,
              color: Color(0xFF667287),
            )
          else
            Hero(
              tag: 'pokemon-artwork-$pokemonId',
              child: Image.network(
                imageUrl!,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.catching_pokemon_rounded,
                  size: 120,
                  color: Color(0xFF667287),
                ),
              ),
            ),
          Positioned(
            bottom: 5,
            child: Container(
              width: 116,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF70F4E2).withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type, required this.color});

  final String type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF111927).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF222E40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF70F4E2), size: 13),
              const SizedBox(width: 5),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF7D899C),
                      fontSize: 7,
                      letterSpacing: 0.9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpriteCard extends StatelessWidget {
  const _SpriteCard({
    required this.title,
    required this.imageUrl,
    required this.accent,
  });

  final String title;
  final String? imageUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        color: const Color(0xFF111927),
        border: Border.all(color: const Color(0xFF273346)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -50,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.055),
              ),
            ),
          ),
          Center(
            child: imageUrl == null
                ? Icon(
                    Icons.catching_pokemon_rounded,
                    size: 64,
                    color: accent.withValues(alpha: 0.35),
                  )
                : Image.network(
                    imageUrl!,
                    width: 108,
                    height: 108,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.catching_pokemon_rounded,
                      size: 64,
                      color: accent.withValues(alpha: 0.35),
                    ),
                  ),
          ),
          Positioned(
            top: 11,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0A111C).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: accent,
                  fontSize: 7,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarLoader extends StatefulWidget {
  const _RadarLoader({required this.id});

  final int id;

  @override
  State<_RadarLoader> createState() => _RadarLoaderState();
}

class _RadarLoaderState extends State<_RadarLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 378,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RadarPainter(progress: _controller.value),
                    child: child,
                  );
                },
                child: const Center(
                  child: Icon(
                    Icons.catching_pokemon_rounded,
                    size: 42,
                    color: Color(0xFF70F4E2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'RASTREANDO SEÑAL',
              style: TextStyle(
                color: Color(0xFF70F4E2),
                fontSize: 9,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Conectando con el espécimen #${widget.id.toString().padLeft(4, '0')}…',
              style: const TextStyle(color: Color(0xFF8792A5), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({
    required this.id,
    required this.message,
    required this.onRetry,
  });

  final int id;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 378,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.portable_wifi_off_rounded,
                color: Color(0xFFFF7892),
                size: 40,
              ),
              const SizedBox(height: 14),
              const Text(
                'SEÑAL INTERRUMPIDA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
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
              const SizedBox(height: 17),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text('REINTENTAR'),
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
          ),
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AmbientPainter(),
      child: const SizedBox.expand(),
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

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.shader =
        const RadialGradient(colors: [Color(0xFF112C36), Color(0x00080C16)])
            .createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.93, size.height * 0.12),
                radius: size.width * 0.7,
              ),
            );
    canvas.drawRect(Offset.zero & size, paint);

    paint.shader =
        const RadialGradient(colors: [Color(0xFF251426), Color(0x00080C16)])
            .createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.03, size.height * 0.69),
                radius: size.width * 0.7,
              ),
            );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PanelGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0870F4E2)
      ..strokeWidth = 0.6;
    for (var x = 20.0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 20.0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final line = Paint()
      ..color = const Color(0x4470F4E2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final factor in [0.42, 0.68, 0.94]) {
      canvas.drawCircle(center, radius * factor, line);
    }
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), line);
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), line);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 3.14,
        colors: [
          const Color(0x0070F4E2),
          const Color(0x0070F4E2),
          const Color(0x6670F4E2),
        ],
        stops: const [0, 0.72, 1],
        transform: GradientRotation(progress * 6.28318),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.94, sweepPaint);

    final pulse = Paint()
      ..color = const Color(0xFF70F4E2).withValues(alpha: 1 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * (0.2 + progress * 0.75), pulse);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

Color _typeColor(String type) {
  const colors = <String, Color>{
    'normal': Color(0xFFC4C7D2),
    'fire': Color(0xFFFF795B),
    'water': Color(0xFF63B7FF),
    'electric': Color(0xFFFFD45C),
    'grass': Color(0xFF73D69A),
    'ice': Color(0xFF75E8E2),
    'fighting': Color(0xFFFF7777),
    'poison': Color(0xFFCB83F2),
    'ground': Color(0xFFE0B878),
    'flying': Color(0xFFA5B4FF),
    'psychic': Color(0xFFFF79B0),
    'bug': Color(0xFFB3D85B),
    'rock': Color(0xFFC8AE7B),
    'ghost': Color(0xFF9B8BE5),
    'dragon': Color(0xFF8D9DFF),
    'dark': Color(0xFF9B91A5),
    'steel': Color(0xFF9CB7C9),
    'fairy': Color(0xFFFFA9D2),
  };
  return colors[type] ?? const Color(0xFF70F4E2);
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';
