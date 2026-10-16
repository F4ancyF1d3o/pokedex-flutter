import 'package:dio/dio.dart';

import '../models/pokemon.dart';
import '../models/pokemon_list_entry.dart';

class PokemonApi {
  PokemonApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://pokeapi.co/api/v2',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  Future<PokemonListPage> fetchPokemonList({
    int limit = 30,
    int offset = 0,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/pokemon',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = response.data;
    if (data == null) {
      throw const FormatException('La respuesta del catálogo está vacía.');
    }
    return PokemonListPage.fromJson(data);
  }

  Future<Pokemon> fetchPokemon(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/pokemon/$id');
    final data = response.data;
    if (data == null) {
      throw const FormatException('La respuesta de PokéAPI está vacía.');
    }
    return Pokemon.fromJson(data);
  }
}
