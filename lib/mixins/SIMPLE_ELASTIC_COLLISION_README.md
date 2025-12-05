# SimpleElasticCollision - Simplified Bounce Physics

Um sistema de colisão elástica simplificado que funciona com `SimpleCollision`, oferecendo comportamento de ricochete realista e fácil de usar.

## 🎯 Objetivo

Criar um sistema de física elástica que seja:
- ✅ **Simples**: Fácil de configurar e usar
- ✅ **Realista**: Comportamento de ricochete convincente  
- ✅ **Flexível**: Configurável para diferentes tipos de objetos
- ✅ **Performático**: Cálculos otimizados
- ✅ **Intuitivo**: Presets para objetos comuns

## 📊 Comparação com ElasticCollision Original

| Aspecto | ElasticCollision | SimpleElasticCollision |
|---------|------------------|------------------------|
| **Dependência** | BlockMovementCollision | SimpleCollision |
| **Algoritmo** | Impulso baseado em massa | Reflexão simples |
| **Configuração** | Restitution (0-2+) | Bounciness (0-1) |
| **Complexidade** | Alta (física realística) | Baixa (resultado convincente) |
| **Predicabilidade** | Pode ser instável | Sempre estável |
| **Performance** | Pesada | Leve |
| **Facilidade de uso** | Difícil | Muito fácil |

## 🚀 Uso Básico

```dart
class BouncyBall extends GameComponent 
    with SimpleMovement, SimpleCollision, SimpleElasticCollision, HasCollisionDetection {
  
  BouncyBall({required Vector2 position}) {
    this.position = position;
    add(CircleHitbox(radius: 16));
    
    // Setup colisão + elasticidade
    setupCollision(bodyType: BodyType.dynamic);
    makeRubberBall(); // Comportamento predefinido!
    
    velocity = Vector2(100, -150);
  }

  @override
  void onBounce(PositionComponent other, CollisionData data, Vector2 bounceVel) {
    print('Ricocheteou com velocidade: ${bounceVel.length}');
    // Adicionar efeitos visuais, som, etc.
  }
}
```

## 🎮 Comportamentos Predefinidos

### Objetos Comuns
```dart
// Bola de borracha - ricochete alto
makeRubberBall();

// Basquete - ricochete médio, realista
makeBasketball();

// Ping-pong - ricochete muito alto
makePingPongBall();

// Objeto pesado - pouco ricochete
makeHeavyObject();

// Bola caindo - perde energia gradualmente
makeDroppedBall();
```

### Configuração Manual
```dart
setupElasticCollision(
  enabled: true,
  bounciness: 0.8,        // 80% da energia mantida (0.0 - 1.0)
  minBounceVelocity: 10.0, // Velocidade mínima para ricochetear
);
```

## 📚 API Completa

### Configuração
```dart
// Setup básico
makeRubberBall();

// Setup customizado
setupElasticCollision(
  enabled: true,           // Ativar/desativar elasticidade
  bounciness: 0.8,         // Energia mantida após ricochete (0-1)
  minBounceVelocity: 10.0, // Velocidade mínima para ricochetear
);

// Controle dinâmico
stopBouncing();          // Desativar ricochete
makeBouncy();           // Reativar com configuração padrão
```

### Propriedades
- `double bounciness` - Fator de ricochete (0.0 a 1.0)
- `double minBounceVelocity` - Velocidade mínima para ricochete
- `bool elasticEnabled` - Se elasticidade está ativa

### Callbacks
```dart
@override
void onBounce(
  PositionComponent other,
  CollisionData collisionData, 
  Vector2 bounceVelocity,
) {
  // Efeitos customizados de ricochete
  // - Som de ricochete
  // - Partículas
  // - Screen shake
  // - Mudança de cor
}
```

## 🎪 Exemplos Práticos

### 1. Jogo Breakout Simples
```dart
void setupBreakout() {
  // Bola que ricocheta
  final ball = BouncyBall(
    position: Vector2(400, 300),
    initialVelocity: Vector2(150, -200),
  );
  add(ball);
  
  // Raquete (não ricocheta)
  final paddle = Paddle(position: Vector2(350, 550));
  add(paddle);
  
  // Paredes que causam ricochete
  add(Wall(position: Vector2(0, 0), size: Vector2(800, 20))); // Topo
  add(Wall(position: Vector2(0, 0), size: Vector2(20, 600))); // Esquerda
  add(Wall(position: Vector2(780, 0), size: Vector2(20, 600))); // Direita
}
```

### 2. Simulador de Gravidade com Ricochete
```dart
class FallingBall extends GameComponent 
    with SimpleMovement, SimpleCollision, SimpleElasticCollision, HasCollisionDetection {
  
  FallingBall() {
    add(CircleHitbox(radius: 12));
    setupCollision(bodyType: BodyType.dynamic);
    makeDroppedBall(); // Perde energia gradualmente
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Simular gravidade
    velocity.y += 400 * dt; // Acelera para baixo
  }

  @override
  void onBounce(PositionComponent other, CollisionData data, Vector2 bounceVel) {
    super.onBounce(other, data, bounceVel);
    
    // Parar de ricochetear quando muito devagar
    if (bounceVel.length < 20) {
      stopBouncing();
    }
  }
}
```

### 3. Pinball/Flipper
```dart
class PinballBall extends GameComponent 
    with SimpleMovement, SimpleCollision, SimpleElasticCollision, HasCollisionDetection {
  
  PinballBall() {
    add(CircleHitbox(radius: 8));
    setupCollision(bodyType: BodyType.dynamic);
    
    // Pinball tem ricochete alto e rápido
    setupElasticCollision(
      enabled: true,
      bounciness: 0.9,
      minBounceVelocity: 5.0,
    );
  }

  @override
  void onBounce(PositionComponent other, CollisionData data, Vector2 bounceVel) {
    super.onBounce(other, data, bounceVel);
    
    // Efeitos de pinball
    if (other is PinballBumper) {
      // Bumper dá impulso extra
      velocity += data.normal * -100;
    }
  }
}
```

### 4. Ricochete com Decay Temporal
```dart
class DecayingBounce extends GameComponent 
    with SimpleMovement, SimpleCollision, SimpleElasticCollision, HasCollisionDetection {
  
  int bounceCount = 0;
  
  @override
  void onBounce(PositionComponent other, CollisionData data, Vector2 bounceVel) {
    super.onBounce(other, data, bounceVel);
    
    bounceCount++;
    
    // Reduzir ricochete a cada colisão
    final newBounciness = max(0.1, 0.9 - (bounceCount * 0.1));
    setupElasticCollision(
      enabled: true,
      bounciness: newBounciness,
    );
    
    // Parar após muitos ricochetes
    if (bounceCount > 8) {
      stopBouncing();
    }
  }
}
```

### 5. Trampolim com Impulso Extra
```dart
class Trampoline extends GameComponent 
    with SimpleMovement, SimpleCollision, HasCollisionDetection {
  
  Trampoline({required Vector2 position}) {
    this.position = position;
    add(RectangleHitbox(size: Vector2(80, 16)));
    setupCollision(bodyType: BodyType.static);
  }

  @override
  bool shouldBlockMovement(Set<Vector2> points, GameComponent other) {
    // Dar impulso extra para objetos elásticos
    if (other is SimpleElasticCollision && other is SimpleMovement) {
      final movementComponent = other as SimpleMovement;
      
      // Trampolim adiciona velocidade extra para cima
      movementComponent.velocity = Vector2(
        movementComponent.velocity.x,
        movementComponent.velocity.y - 300, // Impulso para cima!
      );
    }
    return true;
  }
}
```

## 🔧 Configuração de Bounciness

| Valor | Comportamento | Exemplo |
|-------|---------------|---------|
| `0.0` | Sem ricochete | Objeto mole/grudento |
| `0.2` | Ricochete baixo | Caixa pesada |
| `0.5` | Ricochete médio | Bola de tênis velha |
| `0.7` | Ricochete alto | Basquete |
| `0.8` | Ricochete muito alto | Bola de borracha |
| `0.9` | Ricochete quase perfeito | Super ball |
| `0.95+` | Ricochete quase infinito | Ping-pong |

## ⚡ Performance e Física

### Algoritmo Simplificado
O `SimpleElasticCollision` usa reflexão vetorial simples:
```
velocidade_ricochete = velocidade - 2 * (velocidade · normal) * normal
velocidade_final = velocidade_ricochete * bounciness
```

**Vantagens:**
- ✅ Sempre estável (não explode)
- ✅ Previsível e determinístico
- ✅ Performance excelente
- ✅ Fácil de debugar

### Quando Usar Cada Abordagem

**Use SimpleElasticCollision quando:**
- ✅ Quer ricochete simples e convincente
- ✅ Performance é importante
- ✅ Precisa de comportamento previsível
- ✅ Está fazendo jogos arcade/casual

**Use ElasticCollision original quando:**
- ❓ Precisa de física ultra-realística
- ❓ Simula múltiplos corpos com massa
- ❓ Requer conservação de momentum exata

## 🎯 Migração do ElasticCollision Original

### Antes
```dart
class MyBall extends GameComponent 
    with Movement, BlockMovementCollision, ElasticCollision, HasCollisionDetection {
  
  MyBall() {
    setupBlockMovementCollision(bodyType: BodyType.dynamic);
    setupElasticCollision(restitution: 1.8, enabled: true);
  }
}
```

### Depois  
```dart
class MyBall extends GameComponent 
    with SimpleMovement, SimpleCollision, SimpleElasticCollision, HasCollisionDetection {
  
  MyBall() {
    setupCollision(bodyType: BodyType.dynamic);
    makeRubberBall(); // ou setupElasticCollision(bounciness: 0.8)
  }
}
```

**Principais mudanças:**
- `restitution` (0-2+) → `bounciness` (0-1)
- Física de impulso → Reflexão simples
- Configuração complexa → Presets simples

## ✨ Conclusão

O `SimpleElasticCollision` oferece:
- **90% do realismo** com **20% da complexidade**
- **Comportamento previsível** e **sempre estável**
- **Setup super fácil** com presets intuitivos
- **Performance excelente** para jogos

**Ricochetes convincentes sem dor de cabeça!** 🏀⚡