[EN](https://github.com/RafaelBarbosatec/bonfire/blob/master/README.md) | PT

[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=102)](https://github.com/RafaelBarbosatec/bonfire)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/bonfire.gif)

# Bonfire


Construa games do tipo RPG ou similares explorando o poder do [FlameEngine](https://flame-engine.org/)!

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/video_example.gif)

[Download Demo](https://github.com/RafaelBarbosatec/bonfire/raw/master/demo/demo.apk)

Você encontra o código completo desse exemplo [aqui](https://github.com/RafaelBarbosatec/bonfire/tree/master/example).

## Sumário
1. [Como funciona?](#como-funciona)
   - [Map](#map)
   - [Derocations](#derocations)
   - [Enemy](#enemy)
   - [Player](#player)
   - [Interface](#interface)
   - [Joystick](#joystick)
4. [Componentes úteis](#componentes-úteis)
3. [Próximos passos](#próximos-passos)

## Como funciona?

Essa ferramenta foi construida utilizando os recursos disponíveis pelo [FlameEngine](https://flame-engine.org/) e todos eles estarão disponíveis para serem utilizados além dos implementados pelo Bonfire. Por conta disso recomenda-se dar uma olhadinha no [FlameEngine](https://flame-engine.org/) antes de iniciar a brincadeira com o Bonfire.

Para executar o game com Bonfire basta utilizar o seguinte widget:

```dart
@override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: MyJoystick(),
      player: Knight(),
      interface: KnightInterface(),
      map: DungeonMap.map(),
      decorations: DungeonMap.decorations(),
      enemies: DungeonMap.enemies(),
    );
  }
```

Descrevendo um pouco mais sobre os componentes e organização:

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/game_diagram.png)

### Map
Ele representa nada mais que o mapa ou mundo em que o jogo ocorre. 

Consiste em uma matriz de quadradinhos (Tiles), que em conjunto formam o seu mundo [(veja)](https://www.mapeditor.org/img/screenshot-terrain.png). Atualmente você monta essa matriz manualmente, como podemos ver nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/map/dungeon_map.dart), mas futuramente terá suporte para o carregamento de mapas montados com [Tiled](https://www.mapeditor.org/).

Existe um componente pronto e o nome dele é: 
```dart
MapWorld(List<Tile>())
```
Nele passamos a lista de Tiles que montará nosso mapa e toda a movimentação de câmera durante a movimentação do Player ele cuida pra você.

```dart
Tile(
   'tile/wall_left.png', // Imagem que representa esse Tile
   Position(positionX, positionY), // posição no mapa onde será renderizado.
   collision: true, // se ele possui colisão, ou seja, o player nem inimigos iram passar por ele(Ideal para muros e obstáculos).
   size:16 // Tamanho do tile, nesse caso 16x16
)
```

### Derocations
Representa qualquer coisa que queira adicionar ao cenário, ele pode ser um simples "barril" no meio do caminho a um NPC que você poderá utilizar para interagir com o seu player.

Você poderá criar seu decoration utilizando:

```dart
GameDecoration(
  spriteImg: 'itens/table.png', // imagem que será renderizado
  initPosition: getRelativeTilePosition(10, 6), // posição no mundo que será posicionado
  width: 32,
  height: 32,
  collision: true, // se terá colisão
//  animation: false, // caso você queira adicionar algo animado vc pode passar sua animação aqui e não passar o 'spriteImg'
//  frontFromPlayer: false // caso queira forçar que esse elemento fique por cima do player ao passar por ele
)
```   

ou poderá criar sua própria classe, extender de ```GameDecoration``` e adicionar comportamentos que desejar utilizando o ```update``` e/ou ```render```, como feito nesse  [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/decoration/chest.dart) (um baú que ao player se aproximar se remove do game e faz "brotar" duas poções de vida que tabém são ```GameDecoration```).

Nesse componente como em todos os demais, você tem acesso ao ```BuildContext``` do Widget que renderiza o game, então poderá exibir dialogs, overlays, entre outros componentes do Flutter para exibir algo na tela.

### Enemy
É utilizado para representar seus inimigos. Nesse componente existem ações e movimentos prontos para serem utilizados e configurados se quiser. Mas, caso deseje algo diferente terá a total liberdade de customizar suas ações e movimentos.

Para criar seu inimigo você deverá criar uma classe que o represente e extenda de ```Enemy``` como nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/enemy/goblin.dart). No construtor você terá os seguintes parâmetros de configuração:

```dart
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
          speed: 1.5,
          life: 100,
        );
```   

Depois disso já terá seu inimigo mas ele não fará nada além de ficar parado. Para adicionar movimentos a ele, você precisará sobescrever o método ```Update``` e implementar alí o seu comportamento.
Já existe algumas ações prontas que você poderar utilzar como visto nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/enemy/goblin.dart), são eles:


```dart

//movimentos básicos
void moveBottom({double moveSpeed})
void moveTop({double moveSpeed})
void moveLeft({double moveSpeed})
void moveRight({double moveSpeed})
    
// De acordo com o raio passado por parámetro o inimigo irá procurar e observar o player.
void seePlayer(
     {
      Function(Player) observed,
      Function() notObserved,
      int visionCells = 3,
     }
  )
  
  // De acordo com o raio configurado ele irá procurar e se observar o player irá se movimentar em direção. Estando do lado dele será notificado pela função 'closePlayer'.
  void seeAndMoveToPlayer(
     {
      Function(Player) closePlayer,
      int visionCells = 3
     }
  )
 
  // Executa um ataque físico ao player infligindo o dano configurado com a frequencia configurada. Poderá adicionar animações para represetar esse ataque.
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
  
  // Executa um ataque a distância. Será adicionado ao game um 'FlyingAttackObject' que é um componente que se moverá pelo mapa na direção configurada e infligirar dano a aquele que atingir ou se destruir ao se bater em barreiras.
  void simpleAttackRange(
     {
       @required FlameAnimation.Animation animationRight,
       @required FlameAnimation.Animation animationLeft,
       @required FlameAnimation.Animation animationTop,
       @required FlameAnimation.Animation animationBottom,
       @required FlameAnimation.Animation animationDestroy,
       @required double width,
       @required double height,
       double speed = 1.5,
       double damage = 1,
       Direction direction,
       int interval = 1000,
     }
  )
  
  // De acordo com o raio configurado ele irá procurar e se observar o player ele irá se posicionar para executar um ataque a distância. Ao chegar nessa posição ele notificará pela função 'positioned'.
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
    
    // De acordo com o raio passado por parámetro o player irá procurar e observar inimigos.
    void seeEnemy(
       {
          Function(List<Enemy>) observed,
          Function() notObserved,
          int visionCells = 3,
       }
    )
    
    // Caso precise saber em qual direção o player estar de você. poderá utilizar essa função.
    Direction directionThatPlayerIs()
    
    // Caso deseje adicionar uma animação curta (animação sem loop, ele excuta somente uma vez).
    void addFastAnimation(FlameAnimation.Animation animation)
    
    // Caso deseje infligir dano a ele.
    void receiveDamage(double damage)
    
    // Caso deseje adicionar vida.
    void addLife(double life)

    // Desenha barra padrão de vida. Deve ser utilizado sobescrevendo o método 'render'.
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

Para criar seu player deverá criar uma classe que o represente e extenda de ```Player``` como nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/player/knight.dart). No construtor você terá os seguintes parâmetros de configuração:

```dart
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
          speed: 2.5,
        );
```   

No player você poderá escultar as as ações que foram configuradas em seu Joystick(essa configuração você verá com mais detalhes a frente). Poderá escultar essas ações sobescrevendo o método:

```dart
  @override
  void joystickAction(int action) {}
```

E ao perceber o toque nessas ações do joystick você poderá executar ações. Assim como no inimigo aqui também temos algumas ações prontas para serem utilizadas:

```dart
  
  // Executa um ataque físico ao player infligindo o dano configurado com a frequência configurada. Poderá adicionar animações para represetar esse ataque.
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
  
  // Executa um ataque a distância. Será adicionado ao game um 'FlyingAttackObject' que é um componente que se moverá pelo mapa na direção configurada e infligirar dano a aquele que atingir ou se destruir ao se bater em barreiras.
  void simpleAttackRange(
     {
       @required FlameAnimation.Animation animationRight,
       @required FlameAnimation.Animation animationLeft,
       @required FlameAnimation.Animation animationTop,
       @required FlameAnimation.Animation animationBottom,
       @required FlameAnimation.Animation animationDestroy,
       @required double width,
       @required double height,
       double speed = 1.5,
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
    
    // Caso deseje adicionar uma animação curta (animação sem loop, ele excuta somente uma vez).
    void addFastAnimation(FlameAnimation.Animation animation)
    
    // Caso deseje infligir dano a ele.
    void receiveDamage(double damage)
    
    // Caso deseje adicionar vida.
    void addLife(double life)
  
```

### Interface
É um meio disponibilizado para você desenhar a interface do game, como barra de vida, stamina, configurações, etc; qualquer coisa que queira adicionar à tela.

Para criar sua interface você deverá criar uma classe e extender de ```GameInterface``` como nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/player/knight_interface.dart). 

Sobescrevendo os médodos ```Update``` e ```Render``` você poderá desenhar sua interface utilizando Canvas ou utilizando componentes disponibilizados pelo [FlameEngine](https://flame-engine.org/).

### Joystick
É responsavel por controlar seu personagem. Existe um componente totalmente pronto e configurável para você personalizar o visual e adicionar a quantidade de ações que achar necessário, ou poderá criar o seu próprio joystick utilizando nossa classe abstrata.

Também temos um componente prontinho para te ajudar nessa etapa, mas se quiser construir o seu pŕoprio basta extender de ```JoystickController``` e notificar os eventos utilizando o ```joystickListener``` que estará disponível para você.

O componente default que existe para ser utilizado é configurável da seguinte maneira:

```dart

      Joystick(
        pathSpriteBackgroundDirectional: 'joystick_background.png', //(required) imagem do backgroud do direcional.
        pathSpriteKnobDirectional: 'joystick_knob.png', //(required) imagem da bolinha que indica a movimentação do direcional.
        sizeDirectional: 100, // tamanho do direcional.
        marginBottomDirectional: 100,
        marginLeftDirectional: 100,
        actions: [         // Você adicionará quantos actions desejar. Eles ficarão posicionados sempre no lado direto da tela e você poderá definir em que posisão deseja que cada um fique.
          JoystickAction(
            actionId: 0,      //(required) Id que irá ser acionado ao Player no método 'void joystickAction(int action) {}' quando for clicado.
            pathSprite: 'joystick_atack.png',     //(required) imagem da ação
            pathSpritePressed : 'joystick_atack.png', // caso queira poderá adiciona uma imagem q exibirá quando for clicado.
            size: 80,
            marginBottom: 50,
            marginRight: 50,
            align = JoystickActionAlign.BOTTOM // eles sempre estarão alinhado a direita da tela, ams poderá definir se queira que se posicione em cima ou em baixo (JoystickActionAlign.TOP/JoystickActionAlign.BOTTOM).
          ),
          JoystickAction(
            actionId: 1,
            pathSprite: 'joystick_atack_range.png',
            size: 50,
            marginBottom: 50,
            marginRight: 160,
            align = JoystickActionAlign.BOTTOM
          )
        ],
      )
      
```

veja o [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/main.dart).

### OBS:
Esses elementos do game utilizam o mixin ´HasGameRef´, então você terá acesso a todos esses componentes (Map,Decoration,Enemy,Player,...) internamente, que serão úteis para a criação de qualquer tipo de interação ou adição de novos componentes programaticamente.

Se for necessário obter a posição de um componente para ser utilizado como base para adicionar outros componentes no mapa ou coisa do tipo, sempre utilize o ```positionInWorld``` ela é a posição atual do componente no mapa. A variavel ```position``` refere-se a posição na tela para ser rendereziado.

## Componentes úteis

São componentes que executam algum tipo de comportamento e podem ser úteis. Assim como qualquer outro componente criado por você que extenda de ```Component``` do flame ou ```AnimatedObject``` do Bonfire você pode utiliza-lo ao seu game programaticamente dessa forma:

```dart
this.gameRef.add(COMPONENTE);
```

Esses são os componentes disponíveis até o momento:

```dart

// Componente que executa sua animação uma única vez e logo após se destroi.
AnimatedObjectOnce(
   {
      Rect position,
      FlameAnimation.Animation animation,
      VoidCallback onFinish,
      bool onlyUpdate = false,
   }
)

// Esse componente assim como o anterior pode executar sua animação e se destruir ou continuar executando em loop. Mas o grande diferencial é que ele é executado seguindo a posição de um outro componente como um player, enemy ou decoration.
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

// Componente que anda em determinada direção configurada em uma determinada velocidade também configurável e somente para ao atingir um inimigo ou player infligindo dano, ou pode se destruir ao atigir algum componente que tenha colisão(Tiles,Decorations).
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

Se for necessário adicionar de forma programática qualquer um dos componentes que fazem parte da base do game no Bonfire(Decorations ou Enemy), deve ser adicionado com seus métodos específicos:

```dart
this.gameRef.addEnemy(ENEMY);
this.gameRef.addDecoration(DECORATION);
```



## Próximos passos
- [ ] Documentação detalhada dos componentes.
- [ ] Support with [Tiled](https://www.mapeditor.org/)
- [ ] Using Box2D
