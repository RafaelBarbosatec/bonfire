import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'shader_config_controller.dart';

class ShaderConfigPanel extends StatefulWidget {
  final ShaderConfigController controller;
  const ShaderConfigPanel({super.key, required this.controller});

  @override
  State<ShaderConfigPanel> createState() => _ShaderConfigPanelState();
}

class _ShaderConfigPanelState extends State<ShaderConfigPanel> {
  late double speed;
  late double distortionStrength;
  late Color toneColor;
  late Color lightColor;

  @override
  void initState() {
    speed = widget.controller.config.speed;
    distortionStrength = widget.controller.config.distortionStrength;
    toneColor = widget.controller.config.toneColor;
    lightColor = widget.controller.config.lightColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Speed: ${speed.toStringAsFixed(3)}'),
            Slider(
              value: speed,
              min: 0,
              max: 0.5,
              onChanged: (value) {
                setState(() {
                  speed = value;
                });
                widget.controller.update(
                  widget.controller.config.copyWith(
                    speed: speed,
                  ),
                );
              },
            ),
            Text(
                'Distortion Strength: ${distortionStrength.toStringAsFixed(3)}'),
            Slider(
              value: distortionStrength,
              min: 0,
              max: 0.5,
              onChanged: (value) {
                setState(() {
                  distortionStrength = value;
                });
                widget.controller.update(
                  widget.controller.config.copyWith(
                    distortionStrength: distortionStrength,
                  ),
                );
              },
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Tone color'),
                  const SizedBox(
                    width: 16,
                  ),
                  InkWell(
                    onTap: () {
                      showColorPicker(
                        toneColor,
                        (value) {
                          setState(() {
                            toneColor = value;
                          });
                          widget.controller.update(
                            widget.controller.config.copyWith(
                              toneColor: toneColor,
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: toneColor,
                        shape: BoxShape.circle,
                      ),
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text('Light color'),
                  const SizedBox(
                    width: 16,
                  ),
                  InkWell(
                    onTap: () {
                      showColorPicker(
                        lightColor,
                        (value) {
                          setState(() {
                            lightColor = value;
                          });
                          widget.controller.update(
                            widget.controller.config.copyWith(
                              lightColor: lightColor,
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: lightColor,
                        shape: BoxShape.circle,
                      ),
                      width: 30,
                      height: 30,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void showColorPicker(Color color, ValueChanged<Color> onChange) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color!'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: color,
              onColorChanged: onChange,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
