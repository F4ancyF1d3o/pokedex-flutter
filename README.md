# PULSEDEX

Una Pokédex futurista en Flutter que consulta PokéAPI con `Dio`. Incluye un
catálogo global con paginación infinita, búsqueda entre los Pokémon cargados,
tarjetas animadas en cascada y una pantalla de detalle con transición compartida
Hero, tipos, medidas y sprites frontal/posterior.

## Ejecutar

```sh
flutter pub get
flutter run
```

## Estructura

- `lib/models/pokemon.dart`: modelo tipado y conversión desde JSON.
- `lib/models/pokemon_list_entry.dart`: modelo de las entradas del catálogo e
  imagen oficial derivada del ID, además del resultado paginado.
- `lib/services/pokemon_api.dart`: cliente HTTP para el catálogo y detalle de
  `https://pokeapi.co/api/v2`.
- `lib/screens/pokemon_catalog_screen.dart`: catálogo, búsqueda y animaciones.
- `lib/screens/pokemon_detail_screen.dart`: ficha de detalle y Hero de la
  ilustración.
- `lib/main.dart`: tema y punto de entrada de la aplicación.

No se requieren nuevas dependencias; `dio` ya está configurado.
