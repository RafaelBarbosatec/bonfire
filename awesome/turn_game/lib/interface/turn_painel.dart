import 'package:flutter/material.dart';
import 'package:turn_game/util/turn_manager.dart';

class TurnPainel extends StatefulWidget {
  const TurnPainel({super.key});

  @override
  State<TurnPainel> createState() => _TurnPainelState();
}

class _TurnPainelState extends State<TurnPainel> with TickerProviderStateMixin {
  late TurnManager _turnManager;
  late AnimationController _controller;
  late Animation<Offset> _animation;
  OwnerTurn? _currentOwnerTurn;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(_controller);
    _turnManager = TurnManager.instance;
    _turnManager.addListener(_turnListener);
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _turnManager.removeListener(_turnListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _animation,
          child: FadeTransition(
            opacity: _controller,
            child: Container(
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _turnManager.ownerTurn == OwnerTurn.ally
                    ? Colors.blue
                    : Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                  Text(
                    'Actions: ${_turnManager.countAction}/${TurnManager.MAX_ACTION}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _turnListener() async {
    bool needAnimate = _currentOwnerTurn != _turnManager.ownerTurn;
    _currentOwnerTurn = _turnManager.ownerTurn;

    setState(() {});
    if (needAnimate) {
      await _controller.forward(from: 0.0);
    }
  }

  String _getText() {
    if (_turnManager.ownerTurn == OwnerTurn.ally) {
      return 'Ally turn';
    } else {
      return 'Enemy turn';
    }
  }
}
