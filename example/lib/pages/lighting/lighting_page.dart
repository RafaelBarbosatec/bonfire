import 'package:bonfire/bonfire.dart';
import 'package:example/pages/lighting/demo_player.dart';
import 'package:example/pages/lighting/magic_crystal.dart';
import 'package:example/pages/lighting/simple_torch.dart';
import 'package:flutter/material.dart';

/// Interactive showcase of every lighting feature:
///
/// * `LightingMode.cutout` torches with gradient falloff, flicker and `align`;
/// * `LightingMode.additive` crystal that glows under the ambient darkness;
/// * shadow casting with `LightingOccluder`s and `LightingQuality`;
/// * `LightingPreset` ambient colors (day/night and friends);
/// * `copyWith` (which now preserves `align`);
/// * `LightingApi.animateTo`, `LightingInterface.fadeIn`/`fadeOut`;
/// * `LightSource` added/removed at runtime (`addLight`/`removeLight`);
/// * lights staying aligned while the camera is rotated.
class LightingPage extends StatefulWidget {
  const LightingPage({super.key});

  @override
  State<LightingPage> createState() => _LightingPageState();
}

class _LightingPageState extends State<LightingPage> {
  static const double tileSize = 16;

  /// The game widget is built once and kept alive: rebuilding it would restart
  /// the game and lose the state we are demonstrating.
  Widget? _gameWidget;
  BonfireGameInterface? _game;

  late final DemoPlayer _player;
  late final MagicCrystal _crystal;
  SimpleTorch? _torch;

  final _isNight = ValueNotifier(true);
  final _cameraRotated = ValueNotifier(false);
  final _torchWide = ValueNotifier(false);
  final _crystalOn = ValueNotifier(true);
  final _shadows = ValueNotifier(true);
  final _debug = ValueNotifier(false);
  final _quality = ValueNotifier(LightingQuality.medium);

  @override
  void initState() {
    super.initState();
    _player = DemoPlayer(position: Vector2(tileSize * 4, tileSize * 7));
    _crystal = MagicCrystal(position: Vector2(tileSize * 7, tileSize * 9));
  }

  @override
  void dispose() {
    _isNight.dispose();
    _cameraRotated.dispose();
    _torchWide.dispose();
    _crystalOn.dispose();
    _shadows.dispose();
    _debug.dispose();
    _quality.dispose();
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
                      valueListenable: _crystalOn,
                      builder: (_, on, __) => _DemoButton(
                        icon: Icons.diamond,
                        label: on ? 'Crystal: off' : 'Crystal: on',
                        onPressed: _toggleCrystal,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _shadows,
                      builder: (_, on, __) => _DemoButton(
                        icon: Icons.dark_mode_outlined,
                        label: on ? 'Shadows: on' : 'Shadows: off',
                        onPressed: _toggleShadows,
                      ),
                    ),
                    ValueListenableBuilder<LightingQuality>(
                      valueListenable: _quality,
                      builder: (_, quality, __) => _DemoButton(
                        icon: Icons.tune,
                        label: 'Quality: ${quality.name}',
                        onPressed: _cycleQuality,
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _debug,
                      builder: (_, on, __) => _DemoButton(
                        icon: Icons.bug_report,
                        label: on ? 'Debug: on' : 'Debug: off',
                        onPressed: _toggleDebug,
                      ),
                    ),
                    _DemoButton(
                      icon: Icons.bolt,
                      label: 'Flash (addLight)',
                      onPressed: _flash,
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
                    'Move with the joystick. The torch casts shadows through the '
                    'invisible walls (press Debug to see them). The crystal is '
                    'additive and glows under the ambient darkness. Flash adds '
                    'a temporary LightSource.',
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
      lightingColorGame: LightingPreset.night.ambient,
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
      onReady: (game) {
        _game = game;
        _setupOccluders();
      },
    );
  }

  /// Registers the invisible walls used by the torch shadows.
  ///
  /// In a real game these would come from the map collision layer. Here they
  /// are two rectangles near the first torch; enable `Debug` to see them.
  void _setupOccluders() {
    final lighting = _game?.lighting;
    if (lighting == null) {
      return;
    }

    lighting
      ..addOccluder(
        LightingOccluder.rect(
          Rect.fromLTWH(tileSize * 4.5, 0, tileSize * 0.5, tileSize * 2.5),
        ),
      )
      ..addOccluder(
        LightingOccluder.rect(
          Rect.fromLTWH(
            tileSize * 1.25,
            tileSize * 2.25,
            tileSize * 2,
            tileSize * 0.5,
          ),
        ),
      );
  }

  void _toggleAmbient() {
    final lighting = _game?.lighting;
    if (lighting == null) {
      return;
    }

    final night = !_isNight.value;
    final preset = night ? LightingPreset.night : LightingPreset.day;
    preset.apply(lighting);
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
        radius: wide ? 72 : 40,
        color: wide ? Colors.deepOrange : Colors.deepOrangeAccent,
        intensity: wide ? 0.95 : 0.7,
      ),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
    _torchWide.value = wide;
  }

  /// Adds a temporary additive [LightSource] at the player position.
  ///
  /// Demonstrates [LightingInterface.addLight]/`removeLight`, which do not
  /// require a component.
  void _flash() {
    final lighting = _game?.lighting;
    if (lighting == null || !_player.hasGameRef) {
      return;
    }

    final light = lighting.addLight(
      LightSource(
        position: _player.absoluteCenter.clone(),
        config: LightingConfig(
          radius: 170,
          color: Colors.white.withValues(alpha: 0.9),
          mode: LightingMode.additive,
          falloff: LightFalloff.smooth,
          innerRadius: 0.2,
        ),
      ),
    );

    Future.delayed(
      const Duration(milliseconds: 300),
      () => lighting.removeLight(light),
    );
  }

  void _toggleCrystal() {
    final on = !_crystalOn.value;
    _crystal.lighting.enabled = on;
    _crystalOn.value = on;
  }

  void _toggleShadows() {
    final lighting = _torch?.lighting;
    final current = lighting?.config;
    if (lighting == null || current == null) {
      return;
    }

    final enabled = !_shadows.value;
    lighting.setup(current.copyWith(castShadows: enabled));
    _shadows.value = enabled;
  }

  void _toggleDebug() {
    final lighting = _game?.lighting;
    if (lighting == null) {
      return;
    }

    final enabled = !_debug.value;
    lighting.debug = enabled;
    _debug.value = enabled;
  }

  void _cycleQuality() {
    final lighting = _game?.lighting;
    if (lighting == null) {
      return;
    }

    const values = LightingQuality.values;
    final next = values[(values.indexOf(_quality.value) + 1) % values.length];
    lighting.quality = next;
    _quality.value = next;
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
