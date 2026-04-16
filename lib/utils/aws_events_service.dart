import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'aws_config.dart';
import '../models/event_model.dart';

/// Servicio de eventos en AWS. Eventos general = pantalla Eventos principal.
/// Eventos por ministerio = Next, Alive, Shift (categorías: next, alive, shift).
class AWSEventsService {
  static const String _generalKey = '__general__';

  static final ValueNotifier<int> cacheVersion = ValueNotifier<int>(0);

  static final Map<String, _CacheEntry> _cache = {};

  static void invalidateCache({String? category}) {
    // Siempre invalidar "general" porque lista completa cambia.
    _cache.remove(_generalKey);
    if (category != null && category.trim().isNotEmpty) {
      _cache.remove(category.trim().toLowerCase());
    } else {
      // Si no se sabe la categoría, invalidar todo.
      _cache.clear();
    }
    cacheVersion.value++;
  }

  /// Eventos general: pantalla "Eventos" principal (sin filtro de categoría).
  static Future<List<EventModel>> getEventsGeneral({bool forceRefresh = false}) async {
    return getEventsForMinistry(null, forceRefresh: forceRefresh);
  }

  /// Eventos de un ministerio (next, alive, shift). null = todos (Eventos general).
  static Future<List<EventModel>> getEventsForMinistry(
    String? category, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = (category == null || category.trim().isEmpty)
        ? _generalKey
        : category.trim().toLowerCase();

    if (!forceRefresh) {
      final entry = _cache[cacheKey];
      if (entry != null && entry.isValid) {
        return entry.events;
      }
    }

    try {
      final uri = category != null && category.isNotEmpty
          ? Uri.parse('${AWSConfig.eventsEndpoint}/events').replace(
              queryParameters: {'category': category},
            )
          : Uri.parse('${AWSConfig.eventsEndpoint}/events');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final eventsList = data['events'] as List? ?? [];
        final parsed = eventsList
            .map((event) => EventModel.fromJson(event as Map<String, dynamic>))
            .toList();
        _cache[cacheKey] = _CacheEntry(parsed, DateTime.now());
        return parsed;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

class _CacheEntry {
  final List<EventModel> events;
  final DateTime fetchedAt;

  _CacheEntry(this.events, this.fetchedAt);

  bool get isValid {
    final ttl = AWSConfig.cacheDuration;
    return DateTime.now().difference(fetchedAt) <= ttl;
  }
}
