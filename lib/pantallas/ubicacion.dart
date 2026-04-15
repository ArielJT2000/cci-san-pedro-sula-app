import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../widgets/swipe_back_wrapper.dart';

class Ubicacion extends StatefulWidget {
  const Ubicacion({super.key});

  @override
  State<Ubicacion> createState() => _UbicacionState();
}

class _UbicacionState extends State<Ubicacion> {
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  String _temperature = "Cargando...";
  String _weatherCondition = "";
  int? _weatherCode;
  bool _isLoadingWeather = true;

  // Coordenadas de la iglesia en San Pedro Sula
  final double _churchLat = 15.4993977;
  final double _churchLng = -88.0429316;

  // Dirección completa de la iglesia
  final String _churchAddress = kChurchAddress;

  Timer? _weatherRefreshTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _fetchWeather();
    _weatherRefreshTimer =
        Timer.periodic(const Duration(minutes: 30), (_) => _fetchWeather());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _weatherRefreshTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  Future<void> _fetchWeather() async {
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$_churchLat&longitude=$_churchLng'
        '&current=temperature_2m,weather_code'
        '&timezone=America/Tegucigalpa',
      );
      final response = await http.get(uri).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Timeout'),
          );
      if (response.statusCode != 200)
        throw Exception('HTTP ${response.statusCode}');
      final data = json.decode(response.body) as Map<String, dynamic>;
      final current = data['current'] as Map<String, dynamic>?;
      if (current == null) throw Exception('Sin datos');
      final temp = current['temperature_2m'] as num?;
      final code = current['weather_code'] as int?;
      final condition = _weatherCodeToCondition(code ?? 0);
      if (mounted) {
        setState(() {
          _temperature = temp != null ? '${(temp + 3).round()}°C' : 'N/A';
          _weatherCondition = condition;
          _weatherCode = code;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _temperature = 'N/A';
          _weatherCondition = 'Sin datos';
          _weatherCode = null;
          _isLoadingWeather = false;
        });
      }
    }
  }

  /// Códigos WMO de Open-Meteo a texto en español.
  String _weatherCodeToCondition(int code) {
    if (code == 0) return 'Despejado';
    if (code == 1) return 'Mayormente despejado';
    if (code == 2) return 'Parcialmente nublado';
    if (code == 3) return 'Nublado';
    if (code == 45 || code == 48) return 'Neblina';
    if (code >= 51 && code <= 57) return 'Llovizna';
    if (code >= 61 && code <= 67) return 'Lluvia';
    if (code >= 71 && code <= 77) return 'Nieve';
    if (code >= 80 && code <= 82) return 'Lluvia intensa';
    if (code >= 85 && code <= 86) return 'Nieve';
    if (code == 95) return 'Tormenta';
    if (code == 96 || code == 99) return 'Tormenta con granizo';
    return 'Variable';
  }

  IconData _weatherCodeToIcon(int? code) {
    if (code == null) return Icons.wb_cloudy;
    if (code == 0) return Icons.wb_sunny;
    if (code == 1) return Icons.wb_twilight;
    if (code == 2) return Icons.cloud;
    if (code == 3) return Icons.cloud_queue;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 57) return Icons.grain;
    if (code >= 61 && code <= 67) return Icons.water_drop;
    if (code >= 71 && code <= 77 || code >= 85 && code <= 86)
      return Icons.ac_unit;
    if (code >= 80 && code <= 82) return Icons.water_drop;
    if (code == 95 || code == 96 || code == 99) return Icons.thunderstorm;
    return Icons.wb_cloudy;
  }

  Color _weatherIconColor(int? code) {
    if (code == null) return Colors.orange;
    if (code == 0 || code == 1) return Colors.orange;
    if (code == 2 || code == 3) return Colors.grey;
    if (code == 45 || code == 48) return Colors.grey;
    if (code >= 51 && code <= 57) return Colors.blue.shade300;
    if (code >= 61 && code <= 67 || (code >= 80 && code <= 82))
      return Colors.blue;
    if (code >= 71 && code <= 77 || code >= 85 || code >= 86)
      return Colors.lightBlue.shade100;
    if (code == 95 || code == 96 || code == 99) return Colors.amber;
    return Colors.orange;
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12;
    final hour12 = hour == 0 ? 12 : hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return "$hour12:$minute $period";
  }

  String _formatDate(DateTime time) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    const days = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo'
    ];

    return "${days[time.weekday - 1]}, ${time.day} de ${months[time.month - 1]}";
  }

  /// Ciclo: Miércoles 7:00 PM → Domingo 9:00 AM → Domingo 11:30 AM → (repite) Miércoles 7:00 PM
  Duration _getTimeToNextService() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime nextWed7pm = _nextWeekdayAt(today, DateTime.wednesday, 19, 0);
    DateTime nextSun9am = _nextWeekdayAt(today, DateTime.sunday, 9, 0);
    DateTime nextSun1130 = _nextWeekdayAt(today, DateTime.sunday, 11, 30);

    final candidates = <DateTime>[nextWed7pm, nextSun9am, nextSun1130];
    DateTime? nextService;
    for (final d in candidates) {
      if (d.isAfter(now) && (nextService == null || d.isBefore(nextService))) {
        nextService = d;
      }
    }
    if (nextService == null) {
      nextService = nextWed7pm.add(const Duration(days: 7));
    }
    return nextService.difference(now);
  }

  /// Próxima fecha/hora para un día de la semana (1=lunes, 7=domingo) a una hora dada.
  /// Si hoy es ese día y ya pasó la hora, devuelve el de la próxima semana.
  DateTime _nextWeekdayAt(DateTime from, int weekday, int hour, int minute) {
    int daysToAdd = (weekday - from.weekday + 7) % 7;
    final targetDate = from.add(Duration(days: daysToAdd));
    var d = DateTime(
        targetDate.year, targetDate.month, targetDate.day, hour, minute);
    if (!d.isAfter(DateTime.now())) {
      final nextWeek = targetDate.add(const Duration(days: 7));
      d = DateTime(nextWeek.year, nextWeek.month, nextWeek.day, hour, minute);
    }
    return d;
  }

  String _formatCountdown(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return "${days}d ${hours}h ${minutes}m";
    } else if (hours > 0) {
      return "${hours}h ${minutes}m ${seconds}s";
    } else {
      return "${minutes}m ${seconds}s";
    }
  }

  Future<void> _openInMaps(String app) async {
    String url;
    final encodedAddress = Uri.encodeComponent(
        "Centro Cristiano Internacional - CCI, 21 Avenida C, San Pedro Sula 21104, Honduras");

    switch (app) {
      case 'google':
      case 'googlemaps':
        // Usar coordenadas exactas para mejor precisión
        url =
            "https://www.google.com/maps/search/?api=1&query=$_churchLat,$_churchLng";
        // Alternativa con dirección: url = "https://www.google.com/maps/search/?api=1&query=$encodedAddress";
        break;
      case 'apple':
      case 'applemaps':
        // Apple Maps con coordenadas
        url =
            "https://maps.apple.com/?ll=$_churchLat,$_churchLng&q=$encodedAddress";
        break;
      case 'waze':
        // Waze con coordenadas y navegación
        url = "https://waze.com/ul?ll=$_churchLat,$_churchLng&navigate=yes";
        break;
      default:
        return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: intentar con URL alternativa
        if (app == 'google' || app == 'googlemaps') {
          final fallbackUri = Uri.parse(
              "https://www.google.com/maps/dir/?api=1&destination=$_churchLat,$_churchLng");
          if (await canLaunchUrl(fallbackUri)) {
            await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
          }
        }
      }
    } catch (e) {
      debugPrint('Error abriendo mapa: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final countdown = _getTimeToNextService();

    return SwipeBackWrapper(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getGradientBackground(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: scrollScreenPadding(
              context,
              screenWidth,
              topExtra: screenHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(screenWidth),
                SizedBox(height: screenHeight * 0.03),

                // Location Card
                _buildLocationCard(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.02),

                // Weather and Time Card
                _buildWeatherTimeCard(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.02),

                // Countdown Card
                _buildCountdownCard(screenWidth, screenHeight, countdown),
                SizedBox(height: screenHeight * 0.08),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ubicación",
          overflow: TextOverflow.visible,
          style: getTitulo(screenWidth),
        ),
        SizedBox(height: screenWidth * 0.02),
        Text(
          kLocationName,
          overflow: TextOverflow.visible,
          style: getLocationTextStyle(screenWidth),
        ),
      ],
    );
  }

  Widget _buildLocationCard(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: colorWithOpacity(blanco, 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorWithOpacity(blanco, 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: beigeCream,
                size: screenWidth * widthSpacingXL,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  "Ubicación de la Iglesia",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: blanco,
                    fontSize: screenWidth < 360 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            _churchAddress,
            overflow: TextOverflow.visible,
            style: getInfoTextStyle(screenWidth,
                color: colorWithOpacity(blanco, 0.8)),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            "Abrir en:",
            overflow: TextOverflow.visible,
            style: getLabelTextStyle(screenWidth),
          ),
          SizedBox(height: screenHeight * 0.015),
          Row(
            children: [
              _buildMapButton("Google Maps", "assets/images/gmaps.png",
                  Colors.blue, screenWidth),
              SizedBox(width: screenWidth * 0.03),
              _buildMapButton("Apple Maps", "assets/images/apmaps.png",
                  Colors.grey, screenWidth),
              SizedBox(width: screenWidth * 0.03),
              _buildMapButton(
                  "Waze", "assets/images/waze.png", Colors.purple, screenWidth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(
      String label, String imagePath, Color color, double screenWidth) {
    String mapKey = label.toLowerCase();
    if (mapKey == 'google maps') {
      mapKey = 'googlemaps';
    } else if (mapKey == 'apple maps') {
      mapKey = 'applemaps';
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => _openInMaps(mapKey.replaceAll(' ', '')),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
          decoration: BoxDecoration(
            color: colorWithOpacity(color, 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 1),
          ),
          child: Column(
            children: [
              Image.asset(
                imagePath,
                width: screenWidth * 0.08,
                height: screenWidth * 0.08,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.map,
                    color: color,
                    size: screenWidth * 0.05,
                  );
                },
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: screenWidth < 360 ? 10 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherTimeCard(double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: colorWithOpacity(blanco, 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorWithOpacity(blanco, 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Weather Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _weatherCodeToIcon(_weatherCode),
                      color: _weatherIconColor(_weatherCode),
                      size: screenWidth * 0.06,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        "Clima",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: getCardContentStyle(screenWidth),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                if (_isLoadingWeather)
                  CircularProgressIndicator(
                    color: beigeCream,
                    strokeWidth: 2,
                  )
                else ...[
                  Text(
                    _temperature,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: getCardContentStyle(screenWidth, color: blanco)
                        .copyWith(
                      fontSize: getFontSizeHeadingLarge(screenWidth),
                    ),
                  ),
                  Text(
                    _weatherCondition,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: getInfoTextStyle(screenWidth),
                  ),
                ],
              ],
            ),
          ),
          // Time Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: beigeCream,
                      size: screenWidth * 0.06,
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Expanded(
                      child: Text(
                        "Hora Local",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: getCardContentStyle(screenWidth),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  _formatTime(_currentTime),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: blanco,
                    fontSize: screenWidth < 360 ? 24 : 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(_currentTime),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: colorWithOpacity(blanco, 0.8),
                    fontSize: screenWidth < 360 ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard(
      double screenWidth, double screenHeight, Duration countdown) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: colorWithOpacity(blanco, 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorWithOpacity(blanco, 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.church,
                color: const Color(0xFFF5F5DC),
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: Text(
                  "Próxima Celebración",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: getCardContentStyle(screenWidth),
                ),
              ),
            ],
          ),
          Text(
            "Miércoles:",
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: colorWithOpacity(blanco, 0.8),
              fontSize: screenWidth < 360 ? 14 : 16,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "7:00 PM",
            overflow: TextOverflow.visible,
            style: getLabelTextStyle(screenWidth, color: blanco).copyWith(
              fontSize: getFontSizeBodyXLarge(screenWidth),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            "Domingo:",
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: colorWithOpacity(blanco, 0.8),
              fontSize: screenWidth < 360 ? 14 : 16,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            "9:00 AM y 11:30 AM",
            overflow: TextOverflow.visible,
            style: getLabelTextStyle(screenWidth, color: blanco).copyWith(
              fontSize: getFontSizeBodyXLarge(screenWidth),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: colorWithOpacity(beigeCream, 0.1),
              borderRadius: BorderRadius.circular(borderRadiusSmall),
              border: Border.all(
                color: beigeCream,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  "Tiempo restante:",
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: colorWithOpacity(blanco, 0.8),
                    fontSize: screenWidth < 360 ? 12 : 14,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  _formatCountdown(countdown),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: getCardContentStyle(screenWidth, color: beigeCream)
                      .copyWith(
                    fontSize: getFontSizeHeadingMedium(screenWidth),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
