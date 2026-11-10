import 'package:bonfire/bonfire.dart';
import 'package:example/pages/lighting/demo_player.dart';
import 'package:example/pages/lighting/magic_crystal.dart';
import 'package:example/pages/lighting/shadow_torch.dart';
import 'package:example/pages/lighting/simple_torch.dart';
import 'package:flutter/material.dart';

/// Interactive showcase of every lighting feature, split into independent
/// demos so each configuration can be read on its own:
///
/// * **Default torch** (top left, from the map): the classic `cutout` light
///   with `blurBorder`, pulse and `align` — no gradient, no flicker and no
///   shadows;
/// * **Shadow torch** (top right): `LightFalloff.linear` + flicker +
///   `castShadows`, blocked by the L-shaped wall declared in Tiled in the
///   `lighting_occluders` object layer; enable `Debug` to see the occluders;
/// * **Crystal** (bottom left): `LightingMode.additive` glow under the ambient
///   darkness;
/// * `LightingPreset` ambient colors (day/night and friends);
/// * `copyWith` (which preserves `align`), `LightingApi.animateTo`,
///   `LightingInterface.fadeIn`/`fadeOut`;
/// * `LightSource` added/removed at runtime (`addLight`/`removeLight`);
/// * `LightingQuality` and the debug overlay, which affect the shadow demo;
/// * lights staying aligned while the camera is rotated.
class LightingPage extends StatefulWidget {
  const LightingPage({super.key});

  @override
  State<LightingPage> createState() => _LightingPageState();
}

class _LightingPageState extends State<LightingPage> {
  static const double tileSize = 16;

  static final TextPaint _labelStyle = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 7,
      shadows: [Shadow(color: Colors.black, blurRadius: 2)],
    ),
  );

  /// The game widget is built once and kept alive: rebuilding it would restart
  /// the game and lose the state we are demonstrating.
  Widget? _gameWidget;
  BonfireGameInterface? _game;

  late final DemoPlayer _player;
  late final MagicCrystal _crystal;
  late final ShadowTorch _shadowTorch;
  SimpleTorch? _defaultTorch;

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
    // Each demo has its own area: the default torch comes from the map, the
    // shadow torch and the crystal are placed away from it so their lights do
    // not overlap.
    _shadowTorch = ShadowTorch(position: Vector2(tileSize * 6.5, tileSize * 4));
    _crystal = MagicCrystal(position: Vector2(tileSize * 2, tileSize * 10));
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
                        label: wide ? 'Default torch: 34' : 'Default torch: 60',
                        onPressed: _animateTorch,
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
                      valueListenable: _crystalOn,
                      builder: (_, on, __) => _DemoButton(
                        icon: Icons.diamond,
                        label: on ? 'Crystal: off' : 'Crystal: on',
                        onPressed: _toggleCrystal,
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
                    'Three independent demos: default torch (top left), shadows '
                    'cast by walls (top right, press Debug to see them) and an '
                    'additive crystal (bottom left). Move with the joystick; '
                    'Flash adds a temporary LightSource.',
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
          // Only the first torch of the map is used: it is the default demo.
          'torch': (prop) => _defaultTorch ??= SimpleTorch(prop.position),
        },
      ),
      backgroundColor: const Color(0xFF101820),
      lightingColorGame: LightingPreset.night.ambient,
      player: _player,
      playerControllers: [
        Joystick(directional: JoystickDirectional()),
        Keyboard(),
      ],
      components: [
        _shadowTorch,
        _crystal,
        _label('default', Vector2(tileSize * 2.2, tileSize * 0.1)),
        _label('shadows', Vector2(tileSize * 6, tileSize * 2.9)),
        _label('additive', Vector2(tileSize * 1.1, tileSize * 8.9)),
      ],
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 14),
        initPosition: Vector2(tileSize * 5, tileSize * 7),
      ),
      onReady: (game) => _game = game,
    );
  }

  _DemoLabel _label(String text, Vector2 position) {
    return _DemoLabel(text, position: position, style: _labelStyle);
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

  /// Animates only the radius of the default torch, to show `animateTo` without
  /// changing its configuration (no gradient, flicker or shadows).
  void _animateTorch() {
    final torch = _defaultTorch;
    final current = torch?.lighting.config;
    if (torch == null || current == null) {
      return;
    }

    final wide = !_torchWide.value;
    torch.lighting.animateTo(
      // `copyWith` keeps `align`, `blurBorder` and the pulse settings.
      current.copyWith(radius: wide ? 60 : 34),
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
    final lighting = _shadowTorch.lighting;
    final current = lighting.config;
    if (current == null) {
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

/// World-space text label used to name each demo area.
///
/// `TextComponent` is a Flame component, and `BonfireWidget.components`
/// expects `GameComponent`s, so this small wrapper renders the text itself.
class _DemoLabel extends GameComponent {
  final String text;
  final TextPaint style;

  _DemoLabel(this.text, {required Vector2 position, required this.style}) {
    this.position = position;
    size = style.getLineMetrics(text).size;
  }

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {
    style.render(canvas, text, Vector2.zero());
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
