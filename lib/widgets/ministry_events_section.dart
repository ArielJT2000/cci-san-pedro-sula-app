import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/aws_events_service.dart';
import '../models/event_model.dart';
import 'event_card.dart';

/// Sección reutilizable "Información" con eventos por categoría (next, alive, shift).
/// Usa AWS igual que Eventos general; las notificaciones se gestionan desde el backend por categoría.
class MinistryEventsSection extends StatefulWidget {
  /// Categoría del ministerio: 'next', 'alive' o 'shift'.
  final String category;

  const MinistryEventsSection({
    super.key,
    required this.category,
  });

  @override
  State<MinistryEventsSection> createState() => _MinistryEventsSectionState();
}

class _MinistryEventsSectionState extends State<MinistryEventsSection> {
  late Future<List<EventModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = AWSEventsService.getEventsForMinistry(widget.category);
    AWSEventsService.cacheVersion.addListener(_onEventsInvalidated);
  }

  @override
  void didUpdateWidget(covariant MinistryEventsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _future = AWSEventsService.getEventsForMinistry(widget.category);
    }
  }

  @override
  void dispose() {
    AWSEventsService.cacheVersion.removeListener(_onEventsInvalidated);
    super.dispose();
  }

  void _onEventsInvalidated() {
    if (!mounted) return;
    setState(() {
      _future = AWSEventsService.getEventsForMinistry(
        widget.category,
        forceRefresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: screenWidth * 0.02,
            bottom: screenHeight * 0.02,
          ),
          child: Text(
            'Información',
            style: getSectionTitleStyle(screenWidth),
          ),
        ),
        FutureBuilder<List<EventModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.04),
                  child: CircularProgressIndicator(color: accent),
                ),
              );
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final events = snapshot.data!;
            if (events.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: Text(
                  'No hay eventos programados.',
                  style:
                      getBodyTextStyle(screenWidth).copyWith(color: grisMedio),
                ),
              );
            }
            return Column(
              children: events
                  .map((e) => Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                        child: EventCard(
                          event: e,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
