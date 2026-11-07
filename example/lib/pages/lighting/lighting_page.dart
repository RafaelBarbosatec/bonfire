import 'package:bonfire/bonfire.dart';
import 'package:example/pages/lighting/lighting_player.dart';
import 'package:example/pages/lighting/magic_crystal.dart';
import 'package:example/pages/lighting/simple_torch.dart';
import 'package:flutter/material.dart';

/// Interactive showcase of every lighting feature:
///
/// * `LightingMode.cutout` torches with pulse (`pulseCurve`) and `align`;
/// * `LightingMode.additive` crystal that glows even without ambient darkness;
/// * arc light following the player angle (`useComponentAngle`);
/// * `copyWith` (which now preserves `align`);
/// * `LightingApi.animateTo`, `LightingInterface.fadeIn`/`fadeOut`;
/// * crisped edge light (`blurBorder: 0`);
/// * lights staying aligned while the camera is rotated.
class LightingPage extends StatefulWidget {
  const LightingPage({super.key});

  @override
  State<LightingPage> createState() => _LightingPageState();
}

class _LightingPageState extends State<LightingPage> {
  static const double tileSize = 16;
  static const Color _nightColor = Color(0xFF020617);

  /// The game widget is built once and kept alive: rebuilding it would restart
  /// the game and lose the state we are demonstrating.
  Widget? _gameWidget;
  BonfireGameInterface? _game;

  late final LightingPlayer _player;
  late final MagicCrystal _crystal;
  SimpleTorch? _torch;

  final _isNight = ValueNotifier(true);
  final _cameraRotated = ValueNotifier(false);
  final _torchWide = ValueNotifier(false);
  final _flashlight = ValueNotifier(true);
  final _crystalOn = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _player = LightingPlayer(position: Vector2(tileSize * 4, tileSize * 7));
    _crystal = MagicCrystal(position: Vector2(tileSize * 7, tileSize * 9));
  }

  @override
  void dispose() {
    _isNight.dispose();
    _cameraRotated.dispose();
    _torchWide.dispose();
    _flashlight.dispose();
    _crystalOn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _gameWidget ??= _buildGame(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _gameWidget!),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _isNight,
                      builder: (_, night, __) => _DemoButton(
                        icon: night ? Icons.dark_mode : Icons.light_mode,
                        label: night ? 'Ambient: night' : 'Ambient: day',
                        onPressed: _toggleAmbient,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _cameraRotated,
                      builder: (_, rotated, __) => _DemoButton(
                        icon: Icons.screen_rotation,
                        label: rotated ? 'Camera: 0°' : 'Camera: 25°',
                        onPressed: _toggleCameraRotation,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _torchWide,
                      builder: (_, wide, __) => _DemoButton(
                        icon: Icons.local_fire_department,
                        label: wide ? 'Torch: small' : 'Torch: big',
                        onPressed: _animateTorch,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _flashlight,
                      builder: (_, flashlight, __) => _DemoButton(
                        icon: Icons.flashlight_on,
                        label:
                            flashlight ? 'Player: round light' : 'Player: cone',
                        onPressed: _animatePlayerLight,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _crystalOn,
                      builder: (_, on, __) => _DemoButton(
                        icon: Icons.diamond,
                        label: on ? 'Crystal: off' : 'Crystal: on',
                        onPressed: _toggleCrystal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Move with the joystick: the cone follows the player angle. '
                    'Turn the ambient off: cutout lights disappear, but the '
                    'additive crystal keeps glowing.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame(BuildContext context) {
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/tiled_example.tmj'),
        objectsBuilder: {
          'torch': (prop) => _torch ??= SimpleTorch(prop.position),
        },
      ),
      backgroundColor: const Color(0xFF101820),
      lightingColorGame: _nightColor.withValues(alpha: 0.88),
      player: _player,
      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],
      components: [_crystal],
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 14),
        initPosition: Vector2(tileSize * 5, tileSize * 7),
      ),
      onReady: (game) => _game = game,
    );
  }

  void _toggleAmbient() {
    final lighting = _game?.lighting;
    if (lighting == null) {
      return;
    }

    final night = !_isNight.value;
    if (night) {
      lighting.fadeIn(
        _nightColor.withValues(alpha: 0.88),
        duration: const Duration(milliseconds: 900),
      );
    } else {
      lighting.fadeOut(duration: const Duration(milliseconds: 900));
    }
    _isNight.value = night;
  }

  void _toggleCameraRotation() {
    final camera = _game?.camera;
    if (camera == null) {
      return;
    }

    final rotated = !_cameraRotated.value;
    camera.angle = rotated ? 0.436 : 0; // 25 degrees
    _cameraRotated.value = rotated;
  }

  void _animateTorch() {
    final torch = _torch;
    if (torch == null) {
      return;
    }

    final wide = !_torchWide.value;
    final current = torch.lighting.config;
    if (current == null) {
      return;
    }

    torch.lighting.animateTo(
      // `copyWith` keeps `align` (it used to reset it to zero).
      current.copyWith(
        radius: wide ? 72 : 34,
        color: wide
            ? Colors.deepOrange.withValues(alpha: 0.45)
            : Colors.deepOrangeAccent.withValues(alpha: 0.3),
        blurBorder: wide ? 26 : 18,
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
    _torchWide.value = wide;
  }

  void _animatePlayerLight() {
    final flashlight = !_flashlight.value;
    _player.lighting.animateTo(
      flashlight ? LightingPlayer.flashlight : LightingPlayer.omni,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    _flashlight.value = flashlight;
  }

  void _toggleCrystal() {
    final on = !_crystalOn.value;
    _crystal.lighting.enabled = on;
    _crystalOn.value = on;
  }
}

class _DemoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _DemoButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
