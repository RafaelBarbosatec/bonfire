[EN](https://github.com/RafaelBarbosatec/bonfire/blob/master/README.md) | PT

[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=102)](https://github.com/RafaelBarbosatec/bonfire)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)
[![pub package](https://img.shields.io/pub/v/bonfire.svg)](https://pub.dev/packages/bonfire)

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/bonfire.gif)

# Bonfire


Construa games do tipo RPG ou similares explorando o poder do [FlameEngine](https://flame-engine.org/)!

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/video_example.gif)

[Download Demo](https://github.com/RafaelBarbosatec/bonfire/raw/master/demo/demo.apk)

Você encontra o código completo desse exemplo [aqui](https://github.com/RafaelBarbosatec/bonfire/tree/master/example).

## Sumário
1. [Como funciona?](#como-funciona)
   - [Map](#map)
   - [Decorations](#decorations)
   - [Enemy](#enemy)
   - [Player](#player)
   - [Interface](#interface)
   - [Joystick](#joystick)
4. [Componentes úteis](#componentes-úteis)
3. [Próximos passos](#próximos-passos)

## Como funciona?

Essa ferramenta foi construida utilizando os recursos do [FlameEngine](https://flame-engine.org/) e todos eles estão disponíveis para serem utilizados além dos implementados pelo Bonfire. Por conta disso, recomenda-se dar uma olhadinha no [FlameEngine](https://flame-engine.org/) antes de iniciar a brincadeira com o Bonfire.

Para executar o game com Bonfire, basta utilizar o seguinte widget:

```dart
@override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: MyJoystick(), // required
      map: DungeonMap.map(), // required
      player: Knight(), // Caso o player não seja especificado, o direcional do joystick terá a função de explorar o mapa, sendo bem útil para auxiliar na construção do mapa.
      interface: KnightInterface(),
      decorations: DungeonMap.decorations(),
      enemies: DungeonMap.enemies(),
      background: BackgroundColorGame(Colors.blueGrey[900]),
      constructionMode: false, // Se true ativa hot reload para facilitar construção do mapa e desenha grid.
      showCollisionArea: false, // Se true, exibe área de colisão dos objetos.
      gameController: GameController() // Caso deseja escutar modificações do game para fazer algo.
      constructionModeColor: Colors.blue, // Caso deseje customizar a cor do grid.
      collisionAreaColor: Colors.blue, // Caso deseje customizar a cor da área de colisão.
    );
  }
```

Descrição dos componentes e organização:

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/game_diagram.png)

### Map
Representa nada mais que o mapa (ou mundo) em que o jogo ocorre. 

Consiste em uma matriz de quadradinhos (Tiles), que em conjunto formam o seu mundo [(veja)](https://www.mapeditor.org/img/screenshot-terrain.png). Atualmente você monta essa matriz manualmente, como podemos ver nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/map/dungeon_map.dart), mas futuramente terá suporte para o carregamento de mapas montados com [Tiled](https://www.mapeditor.org/).

Existe um componente pronto e o nome dele é: 
```dart
MapWorld(List<Tile>())
```
Nele passamos a lista de Tiles que montará nosso mapa e toda a movimentação de câmera durante as ações do Player estão incluídas nele.

```dart
Tile(
   'tile/wall_left.png', // Imagem que representa esse Tile.
   Position(positionX, positionY), // posição no mapa onde será renderizado.
   collision: true, // se ele possui colisão, ou seja, nem o player nem inimigos irão passar por ele (ideal para muros e obstáculos).
   size: 32 // Tamanho do tile, nesse caso 32x32
)

ou 

Tile.fromSprite(
            Sprite('wall.png'),
            getPosition(x, y),
            size: 32,
          )
```

### Decorations
Representa qualquer coisa que você queira adicionar ao cenário, podendo ser um simples "barril" no meio do caminho ou mesmo um NPC que você poderá utilizar para interagir com o seu player.

Você poderá criar seu decoration utilizando:

```dart
GameDecoration.sprite(
  Sprite('itens/table.png'), // imagem que será renderizada.
  initPosition: getRelativeTilePosition(10, 6), // posição no mundo que será posicionado.
  width: 32,
  height: 32,
  withCollision: true, // adiciona colisão default.
  collision: Collision( // caso queira customizar a área de colisão.
    width: 18,
    height: 32,
  ),
//  isTouchable: false, // caso deseje que esse componente receba interação de toque. Será notificado em 'void onTap()'
//  animation: FlameAnimation(), // caso você queira adicionar algo animado você pode passar sua animação aqui e não passar o 'spriteImg'.
//  frontFromPlayer: false // caso queira forçar que esse elemento fique por cima do player ao passar por ele.
)

ou

GameDecoration.animation(
  FlameAnimation.Animation.sequenced('sequence.png'), // animação que será renderizada.
  initPosition: getRelativeTilePosition(10, 6), // posição no mundo que será posicionado.
  width: 32,
  height: 32,
  withCollision: true, // adiciona colisão default.
  collision: Collision( // caso queira customizar a área de colisão.
    width: 18,
    height: 32,
  ),
//  isTouchable: false, // caso deseje que esse componente receba interação de toque. Será notificado em 'void onTap()'
//  animation: FlameAnimation(), // caso você queira adicionar algo animado você pode passar sua animação aqui e não passar o 'spriteImg'.
//  frontFromPlayer: false // caso queira forçar que esse elemento fique por cima do player ao passar por ele.
)
```   

ou também poderá criar sua própria classe, bastando extender de ```GameDecoration``` e adicionar os comportamentos que desejar utilizando o ```update``` e/ou ```render```, como feito nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/decoration/chest.dart) (um baú que ao player se aproximar, se remove do game e faz "brotar" duas poções de vida que também são ```GameDecoration```).

Neste componente como em todos os demais, você tem acesso ao ```BuildContext``` do Widget que renderiza o game, portanto é possível exibir dialogs, overlays, entre outros componentes do Flutter para exibir algo na tela.

### Enemy
É utilizado para representar seus inimigos. Nesse componente existem ações e movimentos prontos para serem utilizados e configurados se quiser. Todavia, caso deseje algo diferente terá a total liberdade de customizar suas ações e movimentos.

Existe no momento dois tipos de Enemies implementados: ```SimpleEnemy``` e ```RotationEnemy```.

Para criar seu inimigo você deverá criar uma classe que o represente e extenda de ```SimpleEnemy``` ou ```RotationEnemy``` como nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/enemy/goblin.dart). No construtor você terá os seguintes parâmetros de configuração:

```dart
// SimpleEnemy : Para enemies com visualização de perspectiva 45° ou 67.5°. Com animações IDLE,LEFT,RIGHT,TOP,BOTTOM
Goblin() : super(
          animationIdleRight: FlameAnimation(), //required
          animationIdleLeft: FlameAnimation(), // required
          animationIdleTop: FlameAnimation(),
          animationIdleBottom: FlameAnimation(),
          animationRunRight: FlameAnimation(), //required
          animationRunLeft: FlameAnimation(), //required
          animationRunTop: FlameAnimation(),
          animationRunBottom: FlameAnimation(),
          initDirection: Direction.right,
          initPosition: Position(x,y),
          width: 25,
          height: 25,
          speed: 100, //pt/segundos
          life: 100,
          collision: Collision(), // Caso deseje editar área de colisão
        );

// RotationEnemy : Para enemies com visualização de perspectiva 90°. Com animações IDLE,RUN.
GoblinRotation() : super(
          animIdle: FlameAnimation(), //required
          animRun: FlameAnimation(), // required
          initPosition: Position(x,y),
          initDirection: Direction.right,
          currentRadAngle: -1.55,
          width: 25,
          height: 25,
          speed: 100, //pt/segundos
          life: 100,
          collision: Collision(), // Caso deseje editar área de colisão
        );
```   

Após esse passos, seu inimigo já está pronto, mas ele não fará nada além de ficar parado. Para adicionar movimentos a ele, você precisará sobrescrever o método ```Update``` e implementar alí o seu comportamento.
Já existem algumas ações prontas que você poderá utilizar como visto nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/enemy/goblin.dart), são eles:


```dart

//movimentos básicos
void moveBottom({double moveSpeed})
void moveTop({double moveSpeed})
void moveLeft({double moveSpeed})
void moveRight({double moveSpeed})
    
  // De acordo com o raio passado por parâmetro, o inimigo irá procurar e observar o player.
  void seePlayer(
        {
         Function(Player) observed,
         Function() notObserved,
         int visionCells = 3,
        }
  )
  
  // De acordo com o raio configurado, o inimigo irá procurar o player, caso o encontre, irá se movimentar em direção ao player e ao chegar próximo, o método 'closePlayer' será disparado.
  void seeAndMoveToPlayer(
     {
      Function(Player) closePlayer,
      int visionCells = 3
     }
  )
 
  // Executa um ataque físico ao player infligindo o dano configurado com a frequência configurada. Poderá adicionar animações para representar esse ataque.
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
  
  // Executa um ataque a distância. Será adicionado ao game um 'FlyingAttackObject' que é um componente que se moverá pelo mapa na direção configurada e causará dano a aquele que atingir ou se destruir ao se bater em barreiras.
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
  
  // De acordo com o raio configurado o inimigo irá procurar o player, caso o encontre, irá se posicionar para executar um ataque a distância. Ao chegar nessa posição ele notificará pela função 'positioned'.
  void seeAndMoveToAttackRange(
      {
        Function(Player) positioned,
        int visionCells = 5
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
    
    // Adicione em 'render' caso deseje desenhar área de colisão.
    void drawPositionCollision(Canvas canvas)
    
    // Caso precise saber em qual direção o player em relação a você.
    Direction directionThatPlayerIs()
    
    // Caso deseje adicionar uma animação curta (animação sem loop, ele executa somente uma vez).
    void addFastAnimation(FlameAnimation.Animation animation)
    
    // Caso deseje infligir dano a ele.
    void receiveDamage(double damage)
    
    // Caso deseje adicionar vida.
    void addLife(double life)
    
    // Adicione em 'render' caso deseje desenhar área de colisão.
    void drawPositionCollision(Canvas canvas)

    // Desenha a barra padrão de vida. Deve ser utilizado sobrescrevendo o método 'render'.
    void drawDefaultLifeBar(
      Canvas canvas,
      {
        bool drawInBottom = false,
        double padding = 5,
        double strokeWidth = 2,
      }
    )
    
```

### Player
Representa o seu personagem. Nele também existem ações e movimentos prontos para serem utilizados.

Existe no momento dois tipos de Enemies implementados: ```SimplePlayer``` e ```RotationPlayer```.

Para criar seu player, você deverá criar uma classe que o represente e extender de ```SimplePlayer``` ou ```RotationEnemyPlayer``` como nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/player/knight.dart). No construtor você terá os seguintes parâmetros de configuração:

```dart
//SimplePlayer: Para players com visualização de perspectiva 45° ou 67.5°. Com animações IDLE,LEFT,RIGHT,TOP,BOTTOM
Knight() : super(
          animIdleLeft: FlameAnimation(), // required
          animIdleRight: FlameAnimation(), //required
          animIdleTop: FlameAnimation(),
          animIdleBottom: FlameAnimation(),
          animRunRight: FlameAnimation(), //required
          animRunLeft: FlameAnimation(), //required
          animRunTop: FlameAnimation(),
          animRunBottom: FlameAnimation(),
          width: 32,
          height: 32,
          initPosition: Position(x,y), //required
          initDirection: Direction.right,
          life: 200,
          speed: 150, //pt/segundos
          collision: Collision(), // Caso deseje editar área de colisão
          sizeCentralMovementWindow: Size(100,100); // janela de movimentação do player no centro da tela.
        );

// RotationPlayer: Para players com visualização de perspectiva 90°. Com animações IDLE,RUN.
RotationKnight() : super(
          animIdle: FlameAnimation(), // required
          animRun: FlameAnimation(), //required
          animIdleTop: FlameAnimation(),
          width: 32,
          height: 32,
          initPosition: Position(x,y), //required
          currentRadAngle: -1.55,
          life: 200,
          speed: 150, //pt/segundos
          collision: Collision(), // Caso deseje editar área de colisão
          sizeCentralMovementWindow: Size(100,100); // janela de movimentação do player no centro da tela.
        );
```   

No player, você poderá receber as ações que foram configuradas em seu Joystick (essa configuração você verá com mais detalhes a frente) sobrescrevendo o método:

```dart
  @override
  void joystickAction(int action) {}
```

Ao perceber o toque nessas ações do joystick, você poderá executar outras ações. Assim como no inimigo, aqui também temos algumas ações prontas para serem utilizadas:

```dart
  
  // Executa um ataque físico ao inimigo infligindo o dano configurado com a frequência configurada. Poderá adicionar animações para representar esse ataque.
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
  
  // Executa um ataque a distância. Será adicionado ao game um 'FlyingAttackObject' que é um componente que se moverá pelo mapa na direção configurada e causará dano a aquele que atingir ou se destruir ao se bater em barreiras.
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
    
    // De acordo com o raio passado por parâmetro o player irá procurar e observar inimigos.
    void seeEnemy(
       {
          Function(List<Enemy>) observed,
          Function() notObserved,
          int visionCells = 3,
       }
    )
    
    // Adicione em 'render' caso deseje desenhar área de colisão.
    void drawPositionCollision(Canvas canvas)
    
    // Caso deseje adicionar uma animação curta (animação sem loop, ele executa somente uma vez).
    void addFastAnimation(FlameAnimation.Animation animation)
    
    // Caso deseje infligir dano a ele.
    void receiveDamage(double damage)
    
    // Caso deseje adicionar vida.
    void addLife(double life)
  
```

### Interface
É um meio disponibilizado para você desenhar a interface do game, como barra de vida, stamina, configurações, ou seja, qualquer outra coisa que queira adicionar à tela.

Para criar sua interface você deverá criar uma classe e extender de ```GameInterface``` como nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/interface/knight_interface.dart).

Para adicionar elementos na sua interface utilizamos ```InterfaceComponent``` como no exemplo:

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

Adicionando a nossa interface:

```dart
class MinhaInterface extends GameInterface {
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

OBS: É recomendado adiciona-lo no ```resize```, poís alí terá acesso ao ```size``` do game para poder calcular a posição do seu componente na tela se necessário.

Caso deseje criar um componente de interface mais complexo e customisável é somente criar a sua propria classe extender ```InterfaceComponent``` como nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/interface/bar_life_component.dart).

### Joystick
É responsável por controlar seu personagem. Existe um componente totalmente pronto e configurável para você personalizar o visual e adicionar a quantidade de ações que achar necessário, ou você também poderá criar o seu próprio joystick utilizando nossa classe abstrata.

Também temos um componente prontinho para te ajudar nessa etapa, mas se quiser construir o seu pŕoprio basta extender de ```JoystickController``` e notificar os eventos utilizando o ```joystickListener``` que estará disponível para você.

O componente default que existe para ser utilizado é configurável da seguinte maneira:

```dart

      Joystick(
        pathSpriteBackgroundDirectional: 'joystick_background.png', // imagem do background do direcional.
        pathSpriteKnobDirectional: 'joystick_knob.png', // imagem da bolinha que indica a movimentação do direcional.
        directionalColor: Colors.blue, // caso não passe 'pathSpriteBackgroundDirectional' ou  'pathSpriteKnobDirectional' você poderá definir uma cor para o direcional.
        sizeDirectional: 100, // tamanho do direcional.
        marginBottomDirectional: 100,
        marginLeftDirectional: 100,
        actions: [         // Você adicionará quantos actions desejar.
          JoystickAction(
            actionId: 0,      //(required) Id que irá ser acionado ao Player no método 'void joystickAction(int action) {}' quando for clicado.
            pathSprite: 'joystick_atack.png',     //(required) imagem da ação.
            pathSpritePressed : 'joystick_atack.png', // caso queira, poderá adicionar uma imagem que será exibida quando for clicado.
            size: 80,
            margin: EdgeInsets.only(bottom: 50, right: 50),
            align = JoystickActionAlign.BOTTOM_RIGHT,
          ),
          JoystickAction(
            actionId: 1,
            pathSprite: 'joystick_atack_range.png',
            size: 50,
            margin: EdgeInsets.only(bottom: 50, right: 160),
            align = JoystickActionAlign.BOTTOM_RIGHT,
          )
        ],
      )
      
```

Veja o [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/main.dart).

### OBS:
Esses elementos do game utilizam o mixin ´HasGameRef´, então você terá acesso a todos esses componentes (Map,Decoration,Enemy,Player,...) internamente, que serão úteis para a criação de qualquer tipo de interação ou adição de novos componentes programaticamente.

Se for necessário obter a posição de um componente para ser utilizado como base para adicionar outros componentes no mapa ou coisa do tipo, sempre utilize o ```positionInWorld```, ele é a posição atual do componente no mapa. A variável ```position``` refere-se a posição na tela para ser renderizado.

## Componentes úteis

São componentes que executam algum tipo de comportamento e podem ser úteis. Assim como qualquer outro componente criado por você que extenda de ```Component``` do flame ou ```AnimatedObject``` do Bonfire, você pode utilizá-lo no seu game programaticamente dessa forma:

```dart
this.gameRef.add(COMPONENTE);
```

Os componentes disponíveis até o momento são:

```dart

// Componente que executa sua animação uma única vez e logo após se destrói.
AnimatedObjectOnce(
   {
      Rect position,
      FlameAnimation.Animation animation,
      VoidCallback onFinish,
      bool onlyUpdate = false,
   }
)

// Esse componente assim como o anterior, pode executar sua animação e se destruir ou continuar executando em loop. Mas o grande diferencial é que ele é executado seguindo a posição de um outro componente como um player, enemy ou decoration.
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

Se for necessário adicionar qualquer um dos componentes que fazem parte da base do game no Bonfire(Decorations ou Enemy), deverá ser adicionado com seus métodos específicos:

```dart
this.gameRef.addEnemy(ENEMY);
this.gameRef.addDecoration(DECORATION);
```

### Câmera
É possível movimentar a câmera de forma animada para uma determinada posição do mapa e depois voltar para o personagem. Lembrando que ao movimentar a câmera para uma determinada posição, o player fica bloqueado de ações e movimentos e só é desbloqueado quando a câmera volta a focar nele.

```dart
 gameRef.gameCamera.moveToPosition(Position(X,Y));
 gameRef.gameCamera.moveToPlayer();
 gameRef.gameCamera.moveToPositionAnimated(Position(X,Y));
 gameRef.gameCamera.moveToPlayerAnimated();
```

## Próximos passos
- [ ] Documentação detalhada dos componentes.
- [ ] Support with [Tiled](https://www.mapeditor.org/)
- [ ] Using Box2D

## Game exemplo
[![](https://github.com/RafaelBarbosatec/darkness_dungeon/blob/master/icone/icone_small.png)](https://github.com/RafaelBarbosatec/darkness_dungeon)
