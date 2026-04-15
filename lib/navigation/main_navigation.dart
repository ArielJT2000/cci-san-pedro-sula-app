import 'package:flutter/material.dart';
import '../pantallas/inicio.dart';
import '../pantallas/eventos.dart';
import '../pantallas/iglesia.dart';
import '../pantallas/ministerios.dart';
import '../pantallas/transmisiones.dart';
import '../pantallas/ofrendas.dart';
import '../pantallas/next.dart';
import '../pantallas/ubicacion.dart';
import '../utils/constants.dart';
import '../utils/fcm_service.dart';
import '../widgets/back_button_widget.dart';

class MainNavigation extends StatefulWidget {
  final bool fromSplash;

  const MainNavigation({super.key, this.fromSplash = false});

  @override
  State<MainNavigation> createState() => _MainNavigationState();

  // Método estático para navegación desde notificaciones
  static void navigateToPage(int index) {
    _MainNavigationState._instance?._navigateToPage(index);
  }

  /// True cuando el shell con PageView ya está montado (evita no-op silencioso al navegar).
  static bool get canNavigate => _MainNavigationState._instance != null;
}

class _MainNavigationState extends State<MainNavigation> {
  late PageController _pageController;
  int _currentIndex = 0;
  double _dragDeltaX = 0.0;
  bool _isVerticalScroll = false;

  late final List<Widget> _screens;

  // Instancia estática para acceso desde notificaciones
  static _MainNavigationState? _instance;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _instance = this;

    _screens = [
      Inicio(fromSplash: widget.fromSplash),
      const Eventos(),
      const Iglesia(),
      const Ministerios(),
      const Transmisiones(),
      const Ofrendas(),
      const Ubicacion(),
      const Next(),
    ];
    
    // Notificar a FCMService que MainNavigation está listo para manejar navegación pendiente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FCMService().onMainNavigationReady();
    });
  }

  @override
  void dispose() {
    if (_instance == this) {
      _instance = null;
    }
    _pageController.dispose();
    super.dispose();
  }


  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToPage(int index) {
    if (index == _currentIndex) return;
    var attempts = 0;
    void tryNavigate() {
      attempts++;
      if (attempts > 24) return;
      if (!_pageController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) => tryNavigate());
        return;
      }
      _pageController.animateToPage(
        index,
        duration: duracionLarga,
        curve: curvaSuave,
      );
    }

    tryNavigate();
  }

  /// Ya no hay pantalla Welcome: en el tab Inicio, no hacemos "back" extra.
  void _handleBackToWelcome(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getGradientBackground(),
        child: GestureDetector(
          onHorizontalDragStart: (details) {
            _dragDeltaX = 0.0;
            _isVerticalScroll = false;
            // Solo procesar si el gesto empieza desde el borde izquierdo (primeros 60px)
            if (details.globalPosition.dx > 60) {
              _isVerticalScroll =
                  true; // Ignorar gestos que no empiezan desde la izquierda
            }
          },
          onHorizontalDragUpdate: (details) {
            if (_isVerticalScroll)
              return; // Ignorar si no empezó desde la izquierda

            // Acumular solo si el movimiento es principalmente horizontal
            final absDx = details.delta.dx.abs();
            final absDy = details.delta.dy.abs();

            if (absDx > absDy) {
              // Movimiento principalmente horizontal
              _dragDeltaX += details.delta.dx;
            } else {
              // Movimiento principalmente vertical, ignorar este gesto
              _isVerticalScroll = true;
            }
          },
          onHorizontalDragEnd: (details) {
            if (_isVerticalScroll) {
              _dragDeltaX = 0.0;
              _isVerticalScroll = false;
              return;
            }

            // Solo procesar si fue un movimiento desde la izquierda hacia la derecha
            // _dragDeltaX positivo = deslizar desde izquierda hacia la derecha (retroceder)
            if (_dragDeltaX > 100) {
              // Deslizamiento desde la izquierda hacia la derecha (retroceder)
              if (_currentIndex > 0) {
                _navigateToPage(_currentIndex - 1);
              } else {
                _handleBackToWelcome(context);
              }
            }
            // Resetear valores
            _dragDeltaX = 0.0;
            _isVerticalScroll = false;
          },
          behavior: HitTestBehavior.translucent,
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics:
                const NeverScrollableScrollPhysics(), // Deshabilita el scroll del PageView
            children: _screens.map((screen) {
              return PageTransitionWrapper(
                child: screen,
              );
            }).toList(),
          ),
        ),
            ),
          ),
          if (_currentIndex > 0)
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                bottom: false,
                child: BackButtonWidget(
                  onPressed: () => _navigateToPage(0),
                ),
              ),
            ),
        ],
      ),
    );
  }

}

class PageTransitionWrapper extends StatelessWidget {
  final Widget child;

  const PageTransitionWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
