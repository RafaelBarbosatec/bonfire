# SimpleForces - Simplified Physics System

Um sistema de forças físicas simplificado que funciona com `SimpleMovement`, permitindo simular gravidade, vento, atrito, e outras forças de forma intuitiva e performática.

## 🎯 Objetivo

Criar um sistema de física que seja:
- ✅ **Fácil de usar**: Setup simples com presets inteligentes
- ✅ **Versátil**: Suporta gravidade, vento, atrito, forças customizadas
- ✅ **Performático**: Cálculos otimizados para casos comuns
- ✅ **Estável**: Sem explosões ou comportamento instável
- ✅ **Extensível**: Fácil de adicionar novos tipos de força

## 📊 Comparação com HandleForces Original

| Aspecto | HandleForces | SimpleForces |
|---------|--------------|--------------|
| **Dependência** | Movement | SimpleMovement |
| **Tipos de força** | 3 tipos complexos | 5 tipos + customizados |
| **Configuração** | Sistema Force2D | Métodos diretos |
| **Presets** | Nenhum | 8 presets prontos |
| **Performance** | Pesada | Otimizada |
| **Facilidade** | Difícil | Muito fácil |
| **Estabilidade** | Pode ser instável | Sempre estável |

## 🚀 Uso Básico

```dart
class FallingBall extends GameComponent 
    with SimpleMovement, SimpleForces, HasCollisionDetection {
  
  FallingBall() {
    add(CircleHitbox(radius: 16));
    
    // Setup simples de física
    enableEarthGravity(); // Gravidade realística
    velocity = Vector2(50, 0); // Velocidade inicial
  }
}
```

## 🎮 Presets Inteligentes

### Cenários Comuns
```dart
// Projétil com gravidade e resistência do ar
makeProjectile();

// Objeto voador afetado por vento
makeFlyingObject();

// Objeto terrestre com gravidade e atrito
makeGroundObject();

// Objeto espacial sem forças externas
makeSpaceObject();
```

### Forças Individuais
```dart
// Gravidade (pixels/segundo²)
enableEarthGravity();  // 300 px/s² para baixo
enableMoonGravity();   // 50 px/s² para baixo
enableZeroGravity();   // Sem gravidade

// Atrito (fator de redução 0-1)
enableIceFriction();     // 0.01 - muito escorregadio
enableNormalFriction();  // 0.1 - superfície normal
enableHighFriction();    // 0.3 - superfície rugosa

// Configurações customizadas
setGravity(Vector2(0, 400));      // Gravidade personalizada
setWind(Vector2(30, -10));        // Vento para direita e cima
setFriction(Vector2(0.05, 0.2)); // Atrito X e Y diferentes
```

## 📚 API Completa

### Configuração Básica
```dart
// Setup físicas gerais
setupPhysics(
  mass: 2.0,              // Massa do objeto (padrão: 1.0)
  dragCoefficient: 0.01,  // Resistência do ar (padrão: 0.01)
  enabled: true,          // Ativar/desativar forças
);

// Forças específicas
setGravity(Vector2(0, 300));      // Gravidade
setWind(Vector2(20, 0));          // Vento
setFriction(Vector2(0.1, 0.1));   // Atrito
```

### Forças Customizadas
```dart
// Adicionar força personalizada
addForce('engine', Vector2(100, 0));  // Motor empurrando para direita
addForce('magnetic', Vector2(0, -50)); // Força magnética para cima

// Remover força
removeForce('engine');

// Limpar todas as forças customizadas
clearForces();
```

### Controle de Estado
```dart
// Controlar temporariamente
enableForces();   // Ativar todas as forças
disableForces();  // Desativar temporariamente

// Verificar estado
if (forcesEnabled) {
  print('Forças ativas');
}
```

## 🎪 Exemplos Práticos

### 1. Canhão com Projéteis
```dart
class Cannonball extends GameComponent with SimpleMovement, SimpleForces {
  Cannonball({required Vector2 initialVelocity}) {
    add(CircleHitbox(radius: 8));
    
    makeProjectile(); // Gravidade + resistência do ar
    velocity = initialVelocity;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Remove quando atinge o chão
    if (position.y > 600) removeFromParent();
  }
}

// Disparo do canhão
void fireCannon(double angle, double power) {
  final velocity = Vector2(cos(angle), sin(angle)) * power;
  add(Cannonball(initialVelocity: velocity));
}
```

### 2. Carro com Motor e Freios
```dart
class Car extends GameComponent with SimpleMovement, SimpleForces {
  
  Car() {
    add(RectangleHitbox(size: Vector2(40, 20)));
    
    setupPhysics(mass: 2.0);
    enableNormalFriction(); // Atrito do chão
    enableZeroGravity();    // Carro no plano
  }

  void accelerate() {
    addForce('engine', Vector2(200, 0)); // Motor
  }

  void brake() {
    final brakeForce = velocity.normalized() * -300;
    addForce('brakes', brakeForce); // Freios
  }

  void coast() {
    removeForce('engine');  // Tirar pé do acelerador
    removeForce('brakes');  // Soltar freio
  }
}
```

### 3. Nave Espacial com Propulsores
```dart
class Spaceship extends GameComponent with SimpleMovement, SimpleForces {
  
  Spaceship() {
    add(RectangleHitbox(size: Vector2(20, 30)));
    
    makeSpaceObject(); // Sem atrito, gravidade, ou arrasto
    setupPhysics(mass: 1.5);
  }

  void thrustUp() => addForce('thrust', Vector2(0, -150));
  void thrustDown() => addForce('thrust', Vector2(0, 150));
  void thrustLeft() => addForce('thrust', Vector2(-150, 0));
  void thrustRight() => addForce('thrust', Vector2(150, 0));
  void stopThrust() => removeForce('thrust');

  @override
  void update(double dt) {
    super.update(dt);
    
    // Limitar velocidade máxima
    if (velocity.length > 200) {
      velocity = velocity.normalized() * 200;
    }
  }
}
```

### 4. Personagem de Plataforma
```dart
class PlatformerPlayer extends GameComponent 
    with SimpleMovement, SimpleForces, SimpleCollision {
  
  bool isOnGround = false;
  
  PlatformerPlayer() {
    add(RectangleHitbox(size: Vector2(16, 24)));
    
    makeGroundObject(); // Gravidade + atrito
    setupCollision(bodyType: BodyType.dynamic);
  }

  void jump() {
    if (isOnGround) {
      velocity = Vector2(velocity.x, -400); // Impulso para cima
      isOnGround = false;
    }
  }

  void moveLeft() => addForce('walk', Vector2(-300, 0));
  void moveRight() => addForce('walk', Vector2(300, 0));
  void stopWalking() => removeForce('walk');

  @override
  void onMovementBlocked(PositionComponent other, CollisionData data) {
    super.onMovementBlocked(other, data);
    
    if (data.direction == Direction.down) {
      isOnGround = true; // Aterrissou
    }
  }
}
```

### 5. Sistema Magnético
```dart
class MetalBall extends GameComponent with SimpleMovement, SimpleForces {
  
  Vector2? magnetPosition;
  
  MetalBall() {
    add(CircleHitbox(radius: 10));
    
    setupPhysics(mass: 1.2);
    enableEarthGravity();
    enableIceFriction(); // Muito escorregadio
  }

  void setMagnet(Vector2 pos) {
    magnetPosition = pos;
  }

  @override
  void update(double dt) {
    if (magnetPosition != null) {
      addMagneticForce('magnetic', magnetPosition!, 100.0);
    }
    super.update(dt);
  }
}
```

### 6. Sistema de Molas
```dart
class SpringyBall extends GameComponent with SimpleMovement, SimpleForces {
  
  Vector2? anchorPoint;
  
  SpringyBall() {
    add(CircleHitbox(radius: 8));
    
    setupPhysics(mass: 1.0, dragCoefficient: 0.02);
    enableEarthGravity();
  }

  void attachToAnchor(Vector2 anchor) {
    anchorPoint = anchor;
  }

  @override
  void update(double dt) {
    if (anchorPoint != null) {
      addSpringForce('spring', anchorPoint!, 50.0, restLength: 100.0);
    }
    super.update(dt);
  }
}
```

## 🔧 Forças Avançadas

### Extension Methods para Padrões Comuns
```dart
// Força magnética (atração)
addMagneticForce('magnet', targetPos, strength);

// Força orbital (movimento circular)
addOrbitalForce('orbit', centerPos, strength);

// Força de mola (conexão elástica)
addSpringForce('spring', anchorPos, stiffness, restLength: 100);

// Força de repulsão (empurrar para longe)
addRepulsionForce('repel', sourcePos, strength);

// Impulso temporário
addImpulse('explosion', Vector2(100, -200), duration: 0.5);
```

### Configuração de Massa
A massa afeta como as forças influenciam o objeto:

```dart
setupPhysics(mass: 0.5); // Objeto leve - mais afetado por forças
setupPhysics(mass: 2.0); // Objeto pesado - menos afetado por forças

// Exemplos:
// - Papel: massa 0.3 (muito afetado pelo vento)
// - Pessoa: massa 1.0 (padrão)
// - Carro: massa 3.0 (pouco afetado pelo vento)
```

### Resistência do Ar
```dart
setupPhysics(dragCoefficient: 0.0);   // Sem resistência (espaço)
setupPhysics(dragCoefficient: 0.005); // Pouca resistência (projéteis)
setupPhysics(dragCoefficient: 0.02);  // Resistência normal (objetos voadores)
setupPhysics(dragCoefficient: 0.1);   // Alta resistência (underwater)
```

## ⚡ Performance e Otimização

### Otimizações Automáticas
- ✅ **Forças zero são puladas** automaticamente
- ✅ **Cálculos só quando necessário** (objeto em movimento)
- ✅ **Prevenção de overflow** em velocidades extremas
- ✅ **Drag inteligente** que não reverte direção

### Quando Usar
```dart
// Use SimpleForces quando:
✅ Precisa de gravidade, vento, atrito
✅ Simulação física básica mas convincente  
✅ Projéteis, carros, personagens, etc.
✅ Performance é importante

// Use HandleForces original quando:
❓ Precisa de sistema Force2D específico
❓ Física ultra-complexa com múltiplas forças
❓ Integração com sistema de forças globais existente
```

## 🔄 Migração do HandleForces

### Antes (HandleForces)
```dart
class MyObject extends GameComponent with Movement, HandleForces {
  MyObject() {
    mass = 2.0;
    addForce(AccelerationForce2D(id: 'gravity', value: Vector2(0, 300)));
    addForce(ResistanceForce2D(id: 'friction', value: Vector2(0.1, 0.1)));
  }
}
```

### Depois (SimpleForces)
```dart
class MyObject extends GameComponent with SimpleMovement, SimpleForces {
  MyObject() {
    setupPhysics(mass: 2.0);
    setGravity(Vector2(0, 300));
    setFriction(Vector2(0.1, 0.1));
  }
}
```

## ✨ Conclusão

O `SimpleForces` oferece:
- **Física convincente** sem complexidade desnecessária
- **Setup intuitivo** com presets para cenários comuns
- **Performance otimizada** para jogos
- **Flexibilidade total** para casos customizados

**Física realística que funciona de primeira!** ⚡🎯