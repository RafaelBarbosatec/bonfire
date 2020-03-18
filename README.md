[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=102)](https://github.com/RafaelBarbosatec/bonfire)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)


<img src="https://github.com/RafaelBarbosatec/bonfire/blob/master/media/bonfire.gif" height="110" />

# Bonfire


Construa games do tipo RPG ou similares explorando o poder do [FlameEngine](https://flame-engine.org/)!

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/video_example.gif)

[Download Demo](https://github.com/RafaelBarbosatec/bonfire/blob/master/demo/demo.apk)

Você encontra o código completo desse exemplo [aqui](https://github.com/RafaelBarbosatec/bonfire/tree/master/example).

## Sumário
1. [Como funciona?](#como-funciona)
   - [Map](#map)
   - [Derocations](#derocations)
   - [Enemy](#enemy)
   - [Player](#player)
   - [Interface](#interface)
   - [Joystick](#joystick)
2. [Próximos passos](#próximos-passos)

## Como funciona?

Essa ferramenta foi construida utilizando os recursos disponíveis pelo [FlameEngine](https://flame-engine.org/) e todos eles estarão disponíveis para serem utilizados além dos implementados pelo Bonfire. Por conta disso recomenda-se dar uma olhadinha no [FlameEngine](https://flame-engine.org/) antes de iniciar a brincadeira com o Bonfire.

Para executar o game com Bonfire basta utilizar esse widget:

```dart
@override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: MyJoystick(),
      player: Knight(
        initPosition: Position(5, 6),
      ),
      interface: KnightInterface(),
      map: DungeonMap.map(),
      decorations: DungeonMap.decorations(),
      enemies: DungeonMap.enemies(),
    );
  }
```

Descrevendo um pouco mais componentes e organização:

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/game_diagram.png)

### Map
Ele representa nada mais que o mapa ou mundo em que o jogo ocorre. 

Consiste em uma matriz de quadradinhos (Tiles), que em conjunto formam o seu mundo [(veja)](https://www.mapeditor.org/img/screenshot-terrain.png). Atualmente você monta essa matriz manualmente, como podemos ver nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/map/dungeon_map.dart), mas futuramente terá suporte para o carregamento de mapas montados com [Tiled](https://www.mapeditor.org/).

Existe um componente pronto e o nome dele é: 
```dart
MapWorld(List<Tile>())
```
Nele passamos a lista de Tiles que montará nosso mapa.

```dart
Tile(
   'tile/wall_left.png', // Imagem que representa esse Tile
   Position(positionX, positionY), // posição no mapa onde será renderizado.
   collision: true, // se ele possue colisão, ou seja, o player nem inimigos iram passar por ele(Ideal para muros e obstáculos).
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

ou poderá criar sua própria classe, extender de ```GameDecoration``` e adicionar conportamentos que desejar utilizando o ```update``` e/ou ```render```, como feito nesse  [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/decoration/chest.dart) (um baú que ao player se aproximar se remove do game e faz brotar duas poções de vida que tabém são ```GameDecoration```).

### Enemy
É utilizado para representar seus inimigos. Nesse componente existem ações e movimentos prontos para serem utilizados e configurados se quiser. Mas, caso deseje algo diferente terá a total liberdade de customizar suas ações e movimentos.

Para criar seu inimigo deverá criar uma classe que o represente e extenda de ```Enemy``` como nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/enemy/goblin.dart). No construtor você terá os seguintes parametros de configuração do mesmo:

```dart
Goblin() : super(
          animationIdleRight: FlameAnimation(),
          animationIdleLeft: FlameAnimation(),
          animationIdleTop: FlameAnimation(),
          animationIdleBottom: FlameAnimation(),
          animationRunRight: FlameAnimation(),
          animationRunLeft: FlameAnimation(),
          animationRunTop: FlameAnimation(),
          animationRunBottom: FlameAnimation(),
          initDirection: Direction.right,
          initPosition: Position(x,y),
          width: 25,
          height: 25,
          speed: 1.5,
          life: 100,
          drawDefaultLife:true, // desenhará acima do enimigo uma barra de vida. Caso queira desenhar sua própria sobescrevendo o 'render', marque aqui como false.
        );
```   

Depois disso já terá seu inimigo mas ele não farar nada só ficará parado. Para adicionar conportamentos a ele você precisarar sobescrever o método ```Update``` e adicionar lá seu comportamento.
Já existe algumas ações prontas que você poderar utilzar como visto nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/enemy/goblin.dart), são eles:


```dart
// De acordo com o raio em celulas passada por parámetro o player irá procurar e observar o player.
void seePlayer(
     {
      Function(Player) observed,
      Function() notObserved,
      int visionCells = 3,
     }
  )
  
  // De acordo com o raio em células configuradas ele irá procurar e se observar o player ele irá se movimentar em direção ao player. Estando do lado dele será notificado pela função 'closePlayer'.
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
  
  // Executa um ataque a distância. Será adicionado ao game um 'FlyingAttackObject' que é um componente que se moverá pelo mapa na direção configurada e infligirar dano a aquele q atingir ou se destruir ao se bater em barreiras.
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
  
  // De acordo com o raio em células configuradas ele irá procurar e se observar o player ele irá se posicionar para executar um ataque a distância. Ao chegar nessa posição ele notificará pela função 'positioned'.
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
    
    // Caso precise saber em qual direção o player estar de você. poderá utilizar essa função.
    Direction directionThatPlayerIs()
    
```

### Player
Representa o seu personagem. Nele também existem ações e movimentos prontos para serem utilizados.

### Interface
É um meio disponibilizado para você desenhar a interface do game, como barra de vida, stamina, configurações, etc; qualquer coisa que queira adicionar à tela.

### Joystick
É responsavel por controlar seu personagem. Existe um componente totalmente pronto e configurável para você personalizar o visual e adicionar a quantidade de ações que achar necessário, ou poderá criar o seu próprio joystick utilizando nossa classe abstrata.

### OBS:
Esses elementos do game utilizam o mixin ´HasGameRef´, então você terá acesso a todos esses componentes (Map,Decoration,Enemy,Player,...) internamente, que serão úteis para a criação de qualquer tipo de interação ou adição de novos componentes programaticamente.

## Próximos passos
- [ ] Documentação detalhada dos componentes.
- [ ] Support with [Tiled](https://www.mapeditor.org/)
- [ ] Using Box2D
