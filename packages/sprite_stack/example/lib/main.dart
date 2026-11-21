import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sprite_stack/sprite_stack.dart';

const int _sliceCount = 24;

void main() => runApp(const SpriteStackExampleApp());

class SpriteStackExampleApp extends StatelessWidget {
  const SpriteStackExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sprite_stack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6FA0FF),
        useMaterial3: true,
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final Future<SpriteStack> _stackFuture;

  SpriteStack? _stack;
  Duration _lastTick = Duration.zero;

  double _yaw = 0.6;
  double _pitch = SpriteStack.defaultPitch;
  double _scale = 6;
  double _spacing = 1;
  bool _spinning = true;

  @override
  void initState() {
    super.initState();
    _stackFuture = SpriteStack.load(
      'assets/robot_stack.png',
      sliceCount: _sliceCount,
    );
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final delta = (elapsed - _lastTick).inMicroseconds / 1000000;
    _lastTick = elapsed;
    if (!_spinning) return;
    setState(() => _yaw += delta * 1.4);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stack?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('sprite_stack — turntable')),
      body: FutureBuilder<SpriteStack>(
        future: _stackFuture,
        builder: (context, snapshot) {
          final stack = snapshot.data;
          if (stack != null) _stack = stack;

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: snapshot.hasError
                      ? Text('Could not load the strip: ${snapshot.error}')
                      : stack == null
                          ? const SizedBox(
                              width: 460,
                              height: 460,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : CustomPaint(
                              size: const Size(460, 460),
                              painter: SpriteStackPainter(
                                stack: stack,
                                yaw: _yaw,
                                pitch: _pitch,
                                scale: _scale,
                                spacing: _spacing,
                              ),
                            ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${stack?.sliceCount ?? _sliceCount} slices · '
                        '${stack?.sliceWidth ?? 32}x${stack?.sliceHeight ?? 32} px',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      _Slider(
                        label: 'Yaw',
                        value: _yaw % (2 * math.pi),
                        min: 0,
                        max: 2 * math.pi,
                        onChanged: (value) => setState(() => _yaw = value),
                      ),
                      _Slider(
                        label: 'Pitch',
                        value: _pitch,
                        min: 0.05,
                        max: math.pi / 2,
                        onChanged: (value) => setState(() => _pitch = value),
                      ),
                      _Slider(
                        label: 'Scale',
                        value: _scale,
                        min: 1,
                        max: 12,
                        onChanged: (value) => setState(() => _scale = value),
                      ),
                      _Slider(
                        label: 'Slice spacing',
                        value: _spacing,
                        min: 0.5,
                        max: 3,
                        onChanged: (value) => setState(() => _spacing = value),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _spinning,
                        title: const Text('Auto spin'),
                        onChanged: (value) => setState(() => _spinning = value),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Drag the sliders to rotate in place. Rendering is one '
                        'drawImageRect per slice, no 3D pipeline involved.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
