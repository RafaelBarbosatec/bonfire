import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 28/03/22
class CustomParticleComponent extends ParticleComponent {
  CustomParticleComponent(Particle particle) : super(particle);

  @override
  int get priority => LayerPriority.MAP + 1;
}
