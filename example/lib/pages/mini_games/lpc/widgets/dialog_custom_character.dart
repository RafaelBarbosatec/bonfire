import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/lpc/lpc_sprite_sheet_loader.dart';
import 'package:flutter/material.dart';

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
/// on 27/06/22
class DialogCustomCharacter extends StatefulWidget {
  final void Function(SimpleDirectionAnimation animation, CustomStatus status)
      simpleAnimationChanged;
  final CustomStatus customStatus;
  const DialogCustomCharacter(
      {Key? key,
      required this.simpleAnimationChanged,
      required this.customStatus})
      : super(key: key);

  @override
  State<DialogCustomCharacter> createState() => _DialogCustomCharacterState();
}

class _DialogCustomCharacterState extends State<DialogCustomCharacter> {
  late CustomStatus status;

  @override
  void initState() {
    status = widget.customStatus;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Body'),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                _buildLabel(
                  'Light',
                  LPCBodyEnum.light,
                  status.body,
                  _updateBody,
                ),
                _buildLabel(
                  'Brown',
                  LPCBodyEnum.brown,
                  status.body,
                  _updateBody,
                ),
              ],
            ),
            Row(
              children: [
                _buildLabel(
                  'Skeleton',
                  LPCBodyEnum.skeleton,
                  status.body,
                  _updateBody,
                ),
                _buildLabel(
                  'Orc',
                  LPCBodyEnum.orc,
                  status.body,
                  _updateBody,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Hair'),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                _buildLabel(
                  'Empty',
                  LPCHairEnum.empty,
                  status.hair,
                  _updateHair,
                ),
                _buildLabel(
                  'Single',
                  LPCHairEnum.single,
                  status.hair,
                  _updateHair,
                ),
                _buildLabel(
                  'Curly',
                  LPCHairEnum.curly,
                  status.hair,
                  _updateHair,
                ),
              ],
            ),
            Row(
              children: [
                _buildLabel(
                  'LongKNot',
                  LPCHairEnum.longknot,
                  status.hair,
                  _updateHair,
                ),
                _buildLabel(
                  'XLong',
                  LPCHairEnum.xlong,
                  status.hair,
                  _updateHair,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Equipments'),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                _buildCheckBox('Helm', status.withHelm, (value) {
                  setState(() {
                    status = status.copyWith(withHelm: value);
                  });
                  _updateCharacter();
                }),
                _buildCheckBox('Chest', status.withChest, (value) {
                  setState(() {
                    status = status.copyWith(withChest: value);
                  });
                  _updateCharacter();
                }),
              ],
            ),
            Row(
              children: [
                _buildCheckBox('Leg', status.withLeg, (value) {
                  setState(() {
                    status = status.copyWith(withLeg: value);
                  });
                  _updateCharacter();
                }),
                _buildCheckBox('Gloves', status.withGloves, (value) {
                  setState(() {
                    status = status.copyWith(withGloves: value);
                  });
                  _updateCharacter();
                }),
              ],
            ),
            Row(
              children: [
                _buildCheckBox('Arms', status.withArms, (value) {
                  setState(() {
                    status = status.copyWith(withArms: value);
                  });
                  _updateCharacter();
                }),
                _buildCheckBox('Feet', status.withFeet, (value) {
                  setState(() {
                    status = status.copyWith(withFeet: value);
                  });
                  _updateCharacter();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateCharacter() {
    LPCSpriteSheetLoader.geSpriteSheet(
      status: status,
    ).then((value) {
      widget.simpleAnimationChanged(value, status);
    });
  }

  Widget _buildLabel<T>(
    String label,
    T value,
    T valueSelected,
    void Function(T value) onChange,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<T>(
          value: value,
          groupValue: valueSelected,
          onChanged: (value) {
            if (value != null) {
              onChange(value);
            }
          },
        ),
        Text(label),
      ],
    );
  }

  void _updateBody(LPCBodyEnum value) {
    setState(() {
      status = status.copyWith(body: value);
    });
    _updateCharacter();
  }

  void _updateHair(LPCHairEnum value) {
    setState(() {
      status = status.copyWith(hair: value);
    });
    _updateCharacter();
  }

  _buildCheckBox(
    String label,
    bool selected,
    void Function(bool value) onChanged,
  ) {
    return Row(
      children: [
        Checkbox(
          value: selected,
          onChanged: (v) => onChanged(v ?? false),
        ),
        Text(label)
      ],
    );
  }
}
