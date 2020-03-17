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

Essa ferramenta foi construida utilizando os recursos disponíveis pelo [FlameEngine](https://flame-engine.org/) e todos eles estarão disponíveis para serem utilizados além dos implementados pelo Bonfire. Por conta disso recomenda-se dar uma olhadinha no [FlameEngine](https://flame-engine.org/) antes de iniciar a brincadeira com o Bonfire.

O Bonfire nos ajuda a montar um game utilizando os seguintes componentes e organização:

![](https://github.com/RafaelBarbosatec/bonfire/blob/master/media/game_diagram.png)

### Map
Esse componente representa nada mais que o mapa ou mundo em que o jogo ocorre. 

Consiste em uma matriz de quadradinhos (Tiles), que em conjunto formam o seu mundo [(veja)](https://www.mapeditor.org/img/screenshot-terrain.png). Atualmente você monta essa matriz manualmente, como podemos ver nesse [exemplo](https://github.com/RafaelBarbosatec/bonfire/blob/master/example/lib/map/dungeon_map.dart), mas futuramente terá suporte para o carregamento de mapas montados com [Tiled](https://www.mapeditor.org/).

### Derocations
Representa qualquer coisa que queira adicionar ao cenário, ele pode ser um simples "barril" no meio do caminho a um NPC que você poderá utilizar para interagir com o seu player.

### Enemy
É utilizado para representar seus inimigos. Nesse componente existem movimentos prontos para você configurá-lo. Mas, caso deseje algo diferente terá a total liberdade de customizar suas ações e movimentos.

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
