EN | [PT](https://github.com/RafaelBarbosatec/bonfire/blob/master/README_PT.md)

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)
[![pub package](https://img.shields.io/pub/v/bonfire.svg)](https://pub.dev/packages/bonfire)
[![buymeacoffee](https://i.imgur.com/aV6DDA7.png)](https://www.buymeacoffee.com/rafaelbarbosa)


![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/bonfire.gif)

# Bonfire

Build RPG games and similar with the power of [FlameEngine](https://flame-engine.org/)!

[Documentation (under construction)](https://bonfire-engine.github.io/)

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/video.gif)

[Download Demo](https://github.com/RafaelBarbosatec/bonfire/raw/master/demo/demo.apk)

[Demo Web](https://rafaelbarbosatec.github.io/bonfire/)

Find the complete code of this example [here](https://github.com/RafaelBarbosatec/bonfire/tree/master/example).

Bonfire is ideal for building games from the following perspectives:

![](https://github.com/RafaelBarbosatec/bonfire/blob/feature/separate-player/media/perspectiva.jpg)

## WARN

Due to changes in the Flutter engine in the latest versions that caused a loss of performance. We recommend using the `Channel stable version, v1.17.5`!

## Summary
1. [How it works?](#how-it-works)
   - [Map](#map)
   - [Decorations](#decorations);
   - [Enemy](#enemy)
   - [Player](#player)
   - [Interface](#interface)
   - [Joystick](#joystick)
2. [Utility Components](#utility-components)
   - [Camera](#camera)
   - [Lighting](#lighting-experimental)
3. [Tiled support](#tiled-support)
4. [Next steps](#next-steps)

OBS: To use package remove `flutter_test` of the `dev_dependencies` and add `test: any`.

## How it works?

This tool was built over [FlameEngine](https://flame-engine.org/) and all its resources and classes are available to be used along with Bonfire. With that said, it is recommended to give a look into [FlameEngine](https://flame-engine.org/) before start rocking with Bonfire.  

To run a game with Bonfire, use the following widget:

```dart
@override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: MyJoystick(), // required
      map: DungeonMap.map(), // required
      player: Knight(), // If player is omitted, the joystick directional will control the map view, being very useful in the process of building maps
      interface: KnightInterface(),
      decorations: DungeonMap.decorations(),
      enemies: DungeonMap.enemies(),
      background: BackgroundColorGame(Colors.blueGrey[900]),
      constructionMode: false, // If true, activates hot reload to ease the map constructions and draws the grid
      showCollisionArea: false, // If true, show collision area of the elements
      gameController: GameController() // If you want to hear changes to the game to do something.
      constructionModeColor: Colors.blue, // If you wan customize the grid color.
      collisionAreaColor: Colors.blue, // If you wan customize the collision area color.
      lightingColorGame: Colors.black.withOpacity(0.4), // if you want to add general lighting for the game
      zoom: 1, // here you can set the default zoom for the camera. You can still zoom directly on the camera
    );
  }
```

Components description and organization:

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/game_diagram.png)

### Map
Represents a map (or world) where the game occurs

It is a  matrix of small tiles that toghether assembles the map [(see)](https://www.mapeditor.org/img/screenshot-terrain.png). Right now the matrix is created manually, but in the future it will be possible to load maps created with [Tiled](https://www.mapeditor.org/)

There is a component for this: 
```dart
MapWorld(List<Tile>())
```

MapWorld receives a list of tiles that will assemble our map. The whole camera movimentation during Player actons are included on it. 

```dart
Tile(
   'tile/wall_left.png', // Tile image
   Position(positionX, positionY), // Map coordinates of this tile
   collision: true, // Define if this tile will be not transpassable by players and enemies (ideal for walls and obstacles)
   size: 32 // Tile size (width and height)
)

or 

Tile.fromSprite(
            Sprite('wall.png'),
            getPosition(x, y),
            size: 32,
          )
```

### Decorations
Anything that you may add to the scenery. For example a Barrel in the way or even a NPC in which you can use to interact with your player.

To create a decoration:

```dart
GameDecoration.sprite(
  Sprite('itens/table.png'), // Image to be rendered
  initPosition: getRelativeTilePosition(10, 6), // World coordinates in which this decoration will be positioned
  width: 32,
  height: 32,
  collision: Collision( // A custom collision area
    width: 18,
    height: 32,
  ),
//  isTouchable: false, // if you want this component to receive touch interaction. You will be notified at 'void onTap()'
//  animation: FlameAnimation(), // Optional param to create an animated decoration. When using this, do not specify spriteImg.
//  frontFromPlayer: false // Define true if this decoration shall be rendered above the Player
//  isSensor: false, // if you want this component to be only a sensor. It will trigger the onContact method when collision occurs. Useful to make things like spikes, lava or ground buttons, where you need to detect collision without stopping player from moving.
)

or

GameDecoration.animation(
   FlameAnimation.Animation.sequenced('sequence.png'), // Image to be rendered
  initPosition: getRelativeTilePosition(10, 6), // World coordinates in which this decoration will be positioned
  width: 32,
  height: 32,
  withCollision: true, // Adds a default collision area
  collision: Collision( // A custom collision area
    width: 18,
    height: 32,
  ),
//  isTouchable: false, // if you want this component to receive touch interaction. You will be notified at 'void onTap()'
//  animation: FlameAnimation(), // Optional param to create an animated decoration. When using this, do not specify spriteImg.
//  frontFromPlayer: false // Define true if this decoration shall be rendered above the Player
//  isSensor: false, // if you want this component to be only a sensor. It will trigger the onContact method when collision occurs. Useful to make things like spikes, lava or ground buttons.
)
```   

You can also create your own decoration class by extending `GameDecoration` and implement `update` and `render`  methods with your own behavior. As this [example](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/decoration/chest.dart): A treasure chest that opens when a player gets close, removes itself from the game and puts two life potions in its place (being the life portions a `GameDecoration` as well).

In this component (like all others), you have access to `BuildContext` of the game widget. Therefore, is possible to open dialogs, show overlays and other Flutter components that may depend on that.  

### Enemy
Represents enemies characters in the game. Instances of this class has actions and movements ready to be used and configured whenever you want. At the same time, you can customize  all actions and movements in the way that fits your needs.

There are currently two types of Enemies implemented: ```SimpleEnemy``` and ```RotationEnemy```.

To create an enemy you shall create an `SimpleEnemy` or `RotationEnemy` subclass to represent it. Like in this [example](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/enemy/goblin.dart).

The constructor looks like:
```dart

// SimpleEnemy: For enemies with 45° or 67.5° perspective view. With animations IDLE, LEFT, RIGHT, TOP, BOTTOM
Goblin() : super(
          animIdleRight: FlameAnimation(), //required
          animIdleLeft: FlameAnimation(), // required
          animIdleTop: FlameAnimation(),
          animIdleBottom: FlameAnimation(),
          animIdleTopLeft: FlameAnimation(),
          animIdleTopRight: FlameAnimation(),
          animIdleBottomLeft: FlameAnimation(),
          animIdleBottomRight: FlameAnimation(),
          animRunRight: FlameAnimation(), //required
          animRunLeft: FlameAnimation(), //required
          animRunTop: FlameAnimation(),
          animRunBottom: FlameAnimation(),
          animRunTopLeft: FlameAnimation(),
          animRunTopRight: FlameAnimation(),
          animRunBottomLeft: FlameAnimation(),
          animRunBottomRight: FlameAnimation(),
          initDirection: Direction.right,
          initPosition: Position(x,y),
          width: 25,
          height: 25,
          speed: 100, // pt/seconds
          life: 100,
          collision: Collision(), // A custom collision area
        );

or

// RotationEnemy: For enemies with 90 ° perspective view. With IDLE and RUN animation.

GoblinRotation() : super(
          animIdle: FlameAnimation(), //required
          animRun: FlameAnimation(), // required
          initPosition: Position(x,y),
          currentRadAngle: -1.55,
          width: 25,
          height: 25,
          speed: 100, // pt/seconds
          life: 100,
          collision: Collision(), // A custom collision area
        );
```   

After these steps, the enemy is ready, but it will stay still. To add movements and behaviors, you shall implement them on the `update` method.

There is already some pre included actions that you can use (as seen on this [example](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/enemy/goblin.dart)), they are:


```dart

//basic movements
void moveBottom({double moveSpeed})
void moveTop({double moveSpeed})
void moveLeft({double moveSpeed})
void moveRight({double moveSpeed})
    
  // Will observe the player when within the radius (radiusVision)
  void seePlayer(
        {
         Function(Player) observed,
         Function() notObserved,
         int radiusVision = 32,
        }
  )
  
  // Will move in the direction of the player once it gets close within the visibleCells radius . Once it gets to the player, `closePlayer` shall be fired 
  void seeAndMoveToPlayer(
     {
      Function(Player) closePlayer,
      int radiusVision = 32
     }
  )
  
  // Executes a physical attack to the player, making the configured damage with the configured frequency. You can add animations to represent this attack.
  void simpleAttackMelee(
     {
       @required double damage,
       @required double heightArea,
       @required double widthArea,
       int interval = 1000,
       FlameAnimation.Animation attackEffectRightAnim,
       FlameAnimation.Animation attackEffectBottomAnim,
       FlameAnimation.Animation attackEffectLeftAnim,
       FlameAnimation.Animation attackEffectTopAnim,
     }
  )

  // Executes a distance attack. Will add a `FlyingAttackObject` to the game and will be send in the configures direction and will make some damage to whomever it hits, or be destroyed as it hits barriers (collision defined tiles).
  void simpleAttackRange(
     {
       @required FlameAnimation.Animation animationRight,
       @required FlameAnimation.Animation animationLeft,
       @required FlameAnimation.Animation animationTop,
       @required FlameAnimation.Animation animationBottom,
       @required FlameAnimation.Animation animationDestroy,
       @required double width,
       @required double height,
       double speed = 150,
       double damage = 1,
       Direction direction,
       int interval = 1000,
     }
  )
  // Will seek for the player in the defined radius. When the player is found, will position itself to perform a distance attack. Once it reaches the attack position, will fire the `positioned` callback.
  void seeAndMoveToAttackRange(
      {
        Function(Player) positioned,
        int radiusVision = 32
      }
  )
  
  // Exibe valor do dano no game com uma animação.
   void showDamage(
      double damage,
      {
         TextConfig config = const TextConfig(
           fontSize: 10,
           color: Colors.white,
         )
      }
    )
    
    // Add to `render` method if you want to draw the collision area.
    void drawPositionCollision(Canvas canvas)
    
    // Gives the direction of the player in relation to this enemy
    Direction directionThatPlayerIs()
    
    // Executes an animation once.
    void addFastAnimation(FlameAnimation.Animation animation)
    
    // Applies damage to the enemy
    void receiveDamage(double damage)
    
    // Restore life point to the enemy
    void addLife(double life)
  
    // Add to 'render' if you want to draw the collision area
    void drawPositionCollision(Canvas canvas)


    // Draws the default life bar, Should be used in the `render` method.
    void drawDefaultLifeBar(
      Canvas canvas,
      {
        bool drawInBottom = false,
        double padding = 5,
        double strokeWidth = 2,
      }
    )
    
```

OBS: Enemies only move if visible on the camera. if you want to disable this add `false` in `collisionOnlyVisibleScreen`.

### Player
Represents the character controlled by the user in the game. Instances of this class has actions and movements ready to be used and configured.

There are currently two types of Enemies implemented: ```SimplePlayer``` and ```RotationPlayer```.

To create an enemy you shall create an `SimplePlayer` or `RotationPlayer` subclass to represent it. Like in this [example](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/player/knight.dart).

The constructor looks like:
```dart

// SimplePlayer: For players with 45 ° or 67.5 ° perspective view. With animations IDLE, LEFT, RIGHT, TOP, BOTTOM

Knight() : super(
          animIdleLeft: FlameAnimation(), // required
          animIdleRight: FlameAnimation(), //required
          animIdleTop: FlameAnimation(),
          animIdleBottom: FlameAnimation(),
          animIdleTopLeft: FlameAnimation(),
          animIdleTopRight: FlameAnimation(),
          animIdleBottomLeft: FlameAnimation(),
          animIdleBottomRight: FlameAnimation(),
          animRunRight: FlameAnimation(), //required
          animRunLeft: FlameAnimation(), //required
          animRunTop: FlameAnimation(),
          animRunBottom: FlameAnimation(),
          animRunTopLeft: FlameAnimation(),
          animRunTopRight: FlameAnimation(),
          animRunBottomLeft: FlameAnimation(),
          animRunBottomRight: FlameAnimation(),
          width: 32,
          height: 32,
          initPosition: Position(x,y), //required
          initDirection: Direction.right,
          life: 200,
          speed: 150,  //pt/seconds
          collision: Collision(), // A custom collision area
          sizeCentralMovementWindow: Size(100,100); // player movement window in the center of the screen.
        );

// RotationPlayer: For players with 90° perspective view. With IDLE and RUN animations.

RotationKnight() : super(
          animIdle: FlameAnimation(), // required
          animRun: FlameAnimation(), //required
          animIdleTop: FlameAnimation(),
          width: 32,
          height: 32,
          initPosition: Position(x,y), //required
          currentRadAngle: -1.55,
          life: 200,
          speed: 150, //pt/seconds
          collision: Collision(), // A custom collision area
          sizeCentralMovementWindow: Size(100,100); // player movement window in the center of the screen.
        );
```   

Player instances can receive action configured on the Joystick (read more about it below) by overriding the following method:

```dart
  @override
  void joystickAction(int action) {}
```

Actions can be fired when a joystick action is received. Just like `Enemy`, here we have some pre-included actions:

```dart
  
  // Executes a physical attack to the player, making the configured damage with the configured frequency. You can add animations to represent this attack.
  void simpleAttackMelee(
     {
       @required FlameAnimation.Animation attackEffectRightAnim,
       @required FlameAnimation.Animation attackEffectBottomAnim,
       @required FlameAnimation.Animation attackEffectLeftAnim,
       @required FlameAnimation.Animation attackEffectTopAnim,
       @required double damage,
       double heightArea = 32,
       double widthArea = 32,
     }
  )
  
  // Executes a distance attack. Will add a `FlyingAttackObject` to the game and will be send in the configures direction and will make some damage to whomever it hits, or be destroyed as it hits barriers (collision defined tiles).
  void simpleAttackRange(
     {
       @required FlameAnimation.Animation animationRight,
       @required FlameAnimation.Animation animationLeft,
       @required FlameAnimation.Animation animationTop,
       @required FlameAnimation.Animation animationBottom,
       @required FlameAnimation.Animation animationDestroy,
       @required double width,
       @required double height,
       double speed = 150,
       double damage = 1,
     }
  )

  // Shows the damage value as an animation on the game.
   void showDamage(
      double damage,
      {
         TextConfig config = const TextConfig(
           fontSize: 10,
           color: Colors.white,
         )
      }
    )
    
    // Will observe enemies when within the radius (radiusVision)
    void seeEnemy(
       {
          Function(List<Enemy>) observed,
          Function() notObserved,
          int radiusVision = 32,
       }
    )
    
    // Add to `render` method if you want to draw the collision area.
    void drawPositionCollision(Canvas canvas)
    
    // Executes an animation once.
    void addFastAnimation(FlameAnimation.Animation animation)
    
    // Applies damage to the enemy
    void receiveDamage(double damage)
    
    // Restore life point to the enemy
    void addLife(double life)
  
```

### Interface

The way you cand raw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.

To create your interface you must create a class and extend it from ```GameInterface``` like this [example](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/interface/knight_interface.dart).

To add elements to your interface we use ```InterfaceComponent```:

```dart
    InterfaceComponent(
      sprite: Sprite('blue_button1.png'), // Sprite que será desenhada.
      spriteSelected: Sprite('blue_button2.png'), // Sprite que será desenhada ao pressionar.
      height: 40,
      width: 40,
      id: 5,
      position: Position(150, 20), // Posição na tela que deseja desenhar.
      onTapComponent: () {
        print('Test button');
      },
    )
```

Adding them to the interface:

```dart
class MyInterface extends GameInterface {
  @override
  void resize(Size size) {
    add(InterfaceComponent(
      sprite: Sprite('blue_button1.png'),
      spriteSelected: Sprite('blue_button2.png'),
      height: 40,
      width: 40,
      id: 5,
      position: Position(150, 20),
      onTapComponent: () {
        print('Test button');
      },
    ));
    super.resize(size);
  }
}
```

OBS: It is recommended to add it to the ```resize```, there you will have access to ```size``` of the game to be able to calculate the position of its component on the screen if necessary.

If you want to create a more complex and customizable interface component, just create your own extender class ```InterfaceComponent``` like this [example](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/interface/bar_life_component.dart).

### Joystick
The player-controlling component. 

There is a pre-included implementation (`Joystick`) ready to use, but also configurable to add a custom looking or even add as many actions as you will.
Or you can implement `JoystickController` yourself and emit event trough a `JoystickListener`.

Joystick is configurable by the following parameters:
```dart

        Joystick(
        directional: JoystickDirectional(
          spriteBackgroundDirectional: Sprite('joystick_background.png'), //directinal control background
          spriteKnobDirectional: Sprite('joystick_knob.png'), // directional indicator circle background
          color: Colors.black, // if you do not pass  'pathSpriteBackgroundDirectional' or  'pathSpriteKnobDirectional' you can define a color for the directional.
          size: 100, // directional control size
          isFixed: false, // enables directional with dynamic position in relation to the first touch on the screen
        ),
        actions: [
          JoystickAction(
            actionId: 1, //(required) Action identifier, will be sent to 'void joystickAction(JoystickActionEvent event) {}' when pressed
            sprite: Sprite('joystick_atack_range.png'), // the action image
            spritePressed: Sprite('joystick_atack_range.png'), // Optional image to be shown when the action is fired
            spriteBackgroundDirection: Sprite('joystick_background.png'), //directinal control background
            enableDirection: true, // enable directional in action
            align: JoystickActionAlign.BOTTOM_RIGHT,
            color: Colors.blue,
            size: 50,
            margin: EdgeInsets.only(bottom: 50, right: 160),
          )
        ],
      )

```

Check a [example](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/main.dart).

### Observations:

Since all of these elements uses the ´HasGameRef´ mixin, it is possible to acess all components internally. This will be useful for any kind of interaction between elements or the creation of a new one programatically.

## Utility components

Some components with a unique purpose that can be useful. Since any other component that extends Flame's `Component` or Bonfire's `AnimatedObject`, you use it on your game in the following way:

```dart
this.gameRef.add(YOUR_FANCY_COMPONENT);
```

The components are:

```dart

// To run an animation once before it destroys itself
AnimatedObjectOnce(
   {
      Rect position,
      FlameAnimation.Animation animation,
      VoidCallback onFinish,
      bool onlyUpdate = false,
   }
)

// Like the previous one, this can play an animation once before it destroys itself and can also can can keep playing in a loop. But the most important feature is that this component follows another element on the map, like a player, enemy or decoration.
AnimatedFollowerObject(
    {
      FlameAnimation.Animation animation,
      AnimatedObject target,
      Position positionFromTarget,
      double height = 16,
      double width = 16,
      bool loopAnimation = false
   }
)

// Componente que anda em determinada direção configurada em uma determinada velocidade também configurável e somente para ao atingir um inimigo ou player infligindo dano, ou pode se destruir ao atigir algum componente que tenha colisão (Tiles,Decorations).
FlyingAttackObject(
   {
      @required this.initPosition,
      @required FlameAnimation.Animation flyAnimation,
      @required Direction direction,
      @required double width,
      @required double height,
      FlameAnimation.Animation this.destroyAnimation,
      double speed = 1.5,
      double damage = 1,
      bool damageInPlayer = true,
      bool damageInEnemy = true,
  }
)
  
```

If it is necesssary to add a instance of a Bonfire's basic component class (Decorations, Enemy, etc), one shall use:
```dart
this.gameRef.addGameComponent(COMPONENT);
```

### Camera

It is possible to move the camera to some position and go back to the player afterwards. To make the camera always follow the player you should call `moveToPlayer(horizontal: 0, vertical: 0)`, so that it keeps the player centralized on screen. If you want the player to be able to move a bit before you call `moveToPlayer` with horizontal and vertical set to how much you want the player to be able to distance from the center of screen on each direction.

```dart
 gameRef.gameCamera.moveToPosition(Position(X,Y));
 gameRef.gameCamera.moveToPlayer();
 gameRef.gameCamera.moveToPositionAnimated(Position(X,Y));
 gameRef.gameCamera.moveToPlayerAnimated();
```

### Lighting (experimental)

By setting the `lightingColorGame` property on BofireWidget you automatically enable this lighting system. and to add light to the objects, just add the `Lighting` mixin to the component and configure its light by overwriting the `lightingConfig` variable:

```dart
 lightingConfig = LightingConfig(
       gameComponent: this,
       color: Colors.yellow.withOpacity(0.1),
       radius: 40,
       blurBorder: 20,
       withPulse: true,
       pulseVariation: 0.1,
     );
```

## Tiled support

Support for maps built with Tiled using the extension .json.

- [x] Multi TileLayer
- [x] Multi ObjectLayer
- [x] TileSet
- [x] Tile Animated

Collision
   - [x] MultiCollision
   - [x] Retangle Collision
   - [ ] Point Collision
   - [ ] Ellipse Collision
   - [ ] Polygon Collision

### Get Started

Add the files generated by Tiled to the project by following the base: `assets/images/`

```yaml
flutter:
  assets:
    - assets/images/tiled/map.json
    - assets/images/tiled/tile_set.json
    - assets/images/tiled/img_tile_set.png
```

For maps built with Tiled we must use the Widget `BonfireTiledWidget` (example [here]()):

```dart
TiledWorldMap map = TiledWorldMap(
        'tiled/mapa.json', // main file path
        forceTileSize: DungeonMap.tileSize, // if you want to force the size of the Tile to be larger or smaller than the original
      )
        ..registerObject('goblin', (x, y, width, height) => Goblin(Position(x, y))) // Records objects that will be placed on the map when the name is found.
        ..registerObject('torch', (x, y, width, height) => Torch(Position(x, y)))
        ..registerObject('barrel', (x, y, width, height) => BarrelDraggable(Position(x, y)));

return BonfireTiledWidget(
      joystick: Joystick(
        directional: JoystickDirectional(
          size: 100,
          isFixed: false,
        ),
      map: map,
      lightingColorGame: Colors.black.withOpacity(0.5),
    );
```

### Tiled map example

If you want the Tile to be drawn above the player add type: `above` in your tileSet.

![](https://github.com/RafaelBarbosatec/bonfire/blob/feature/tiled-support/media/print_exemplo_tiled.png)

### Result

![](https://github.com/RafaelBarbosatec/bonfire/blob/feature/tiled-support/media/print_result_tiled.png)


## Next steps
- [ ] Component docs
- [x] [Tiled](https://www.mapeditor.org/) support


## Example games
[![](https://github.com/RafaelBarbosatec/darkness_dungeon/blob/master/icone/icone_small.png)](https://github.com/RafaelBarbosatec/darkness_dungeon)

[Mountain Fight](https://github.com/RafaelBarbosatec/mountain_fight) (Multiplayer)

[Mini Fantasy](https://github.com/RafaelBarbosatec/mini_fantasy)

## Credits

 * The entire FlameEngine team, especially [Erick](https://github.com/erickzanardo).
 * [Renan](https://github.com/renancaraujo) That helped in the translation of the readme.
 * And all those who were able to contribute as they could.
 
