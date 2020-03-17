[![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=102)](https://github.com/RafaelBarbosatec/bonfire)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Flutter](https://img.shields.io/badge/Made%20with-Flutter-blue.svg)](https://flutter.dev/)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php)


<img src="https://github.com/RafaelBarbosatec/bonfire/blob/master/media/bonfire.gif" height="110" />
 # Bonfire


Construa games do tipo RPG ou similares explorando o poder do [FlameEngine](https://flame-engine.org/)!

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/video_example.gif)

Você encontra o código completo desse exemplo [aqui](https://github.com/RafaelBarbosatec/bonfire/tree/master/example).

## Como funciona?

Essa ferramenta foi construida utilizando os recursos disponíveis pelo [FlameEngine](https://flame-engine.org/) e todos eles estarão disponíveis para ser utilizados alem dos implementados pelo Bonfire.

Por conta disso recomenda-se dar uma olhadinha no [FlameEngine](https://flame-engine.org/) antes de iniciar a brincadeira com o Bonfire.

Bonfire nos ajuda a montar um game utilizando aos seguintes componentes e organização:

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/game_diagram.png)

### Map
Esse componente representa nada mais que o mapa ou mundo em que o jogo ocorre. 

Consiste uma matriz de quadradinhos(Tiles) que em conjunto forma o seu mundo [veja](https://www.mapeditor.org/img/screenshot-terrain.png). Atualmente você monta essa matriz na mão como pode ver nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/map/dungeon_map.dart), mas futuramente terá suporte a carregar mapas montados com [Tiled](https://www.mapeditor.org/).

### Derocations
Esse componente representa qualquer coisa que queira adicionar ao cenário, ele pode ser um simples 'barril" no meio do caminho, a um NPC que você poderá utilizar para interagir com o seu player.

### Enemy
Esse componente é utilizado para representar seus inimigos. Nele existe algumas ações e movimentos prontos para você configurar-lo. Mas, caso deseje algo diferente terá a total liberdade de customizar suas ações e movimentos.

### Player
Esse componente representa o seu personagem. Nele também existe ações e movimentos prontos para ser utilizados.

### Interface
Esse componente é um meio disponibilizado para você desenhar a interface do game, como barra de vida, stamina, configurações, etc. qualquer coisa que queira adicionar a tela durante o game rodando.

### Joystick
Esse componente é responsavel por controcar seu personagem. Existe um componente totalmente pronto e configuravel para vc personalizar o visual e adicionar a quantidade de ações que achar necessário. Ou, pode criar o seu próprio utilizando nossa classe abstrata.

### OBS:
Todos esses componentes utilizam o mixin ´HasGameRef´ então você tera acesso a todos os componentes do game (Map,Decoration,Enemy,Player,...), isso será útil para criar qualquer tipo de interação ou adicionar novos componentes programaticamente.

## Próximos passos
- [ ] Documentação detalhada dos componentes.
- [ ] Support with [Tiled](https://www.mapeditor.org/)
- [ ] Using Box2D
