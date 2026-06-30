
 Listo |
| Movimiento, salto, gravedad | ✅ Listo |
| Ataque con hitbox | ✅ Listo |
| Barras de vida (ProgressBar) | ✅ Listo |
| Pinchos (daño + rebote) | ✅ Listo |
| Pociones de vida (+50 curación) | ✅ Listo |
| Sonido de golpe (golpe.wav) | ✅ Listo |
| Texto "Gana Cami" / "Gana Simón" | ✅ Listo |
| Cabeza que gira (HeadVisual) | ✅ Listo |

---

## 🎯 ETAPA 1 — SONIDOS DEL JUEGO 🎵

**Objetivo:** Poner todos los sonidos que faltan.

### ¿Qué vamos a hacer?
1. Música de fondo que suene todo el tiempo
2. Sonido cuando el jugador **salta**
3. Sonido cuando el jugador **camina/corre**
4. Sonido cuando te **pinchas** con un pincho
5. Sonido cuando **recoges** una poción
6. Sonido cuando alguien **cae al vacío**
7. Sonido de **victoria** cuando alguien gana

### ¿Cómo funciona?
Cada jugador tendrá varios `AudioStreamPlayer`, como altavoces que
guardan un sonido. Cuando algo pasa (saltar, chocar...), le decimos
al altavoz: "¡reprodúcete!".

**Archivos que necesitas:** Busca sonidos gratis en:
- https://freesound.org
- https://pixabay.com/sound-effects

Guárdalos en la carpeta `sonidos/` con estos nombres:
```
sonidos/musica_fondo.mp3
sonidos/salto.wav
sonidos/correr.wav
sonidos/pincho.wav
sonidos/pocion.wav
sonidos/caer.wav
sonidos/victoria.wav
```

---

## 🎯 ETAPA 2 — ATAQUE QUE GIRA 🔄

**Objetivo:** Que el golpe vaya hacia donde mira el personaje
(izquierda o derecha).

### ¿Qué pasa ahora?
El ataque siempre golpea hacia la **derecha** porque el `AttackArea`
está fijo en una posición.

### ¿Qué vamos a cambiar?
Cuando el jugador gira (tecla izquierda), el `AttackArea` se mueve
al otro lado automáticamente usando la variable `facing_dir` que ya existe.

### Código nuevo en cada jugador:
```gdscript
# Dentro de _try_apply_hit(), movemos el AttackArea:
$AttackArea.position.x = abs($AttackArea.position.x) * facing_dir
```

**Explicación:** `facing_dir` vale `1` (derecha) o `-1` (izquierda).
Multiplicamos la posición para que el ataque salga del lado correcto.

---

## 🎯 ETAPA 3 — ARMAS PERSONALIZADAS ⚔️

**Objetivo:** Que cada jugador pueda elegir entre 3 armas diferentes.

### Las 3 armas:
| Arma | Alcance | Daño | Forma |
|------|---------|------|-------|
| 🗡️ Espada corta | Corto | Alto (30) | Rectángulo pequeño |
| 🏹 Lanza | Medio | Medio (20) | Rectángulo largo |
| 🔨 Martillo | Largo | Bajo (10) | Rectángulo ancho |

### ¿Cómo funciona?
Creamos un script `arma.gd` que guarda los datos de cada arma
(alcance, daño, forma del CollisionShape2D).

### Pantalla de selección
Antes de pelear, aparece una pantalla donde cada jugador
elige su arma con las teclas (1, 2, 3).

---

## 🎯 ETAPA 4 — ACCESORIOS 🛡️

**Objetivo:** Poder equipar accesorios que cambian tus habilidades.

### Lista de accesorios:
| Accesorio | Efecto |
|-----------|--------|
| 🛡️ Escudo | Recibes la **mitad** de daño (×0.5) |
| 👢 Botas | Saltas **más alto** (+50% salto) |
| 🧥 Capa | Puedes **planear/volar** (gravedad reducida) |
| 🦺 Pechera | +20 de vida máxima, pero -20% velocidad |

### ¿Cómo funciona?
Cada jugador puede equipar **1 accesorio**. Los stats se modifican
al inicio de la pelea según lo que eligieron.

---

## 🎯 ETAPA 5 — ATAQUE ESPECIAL 🔥

**Objetivo:** Un ataque tipo "Kamehameha" o bola de fuego.

### ¿Cómo funciona?
- El jugador carga el ataque (mantiene la tecla de ataque)
- Suelta una **bola de energía** que viaja hacia adelante
- Si toca al otro jugador, hace **mucho daño** (50)
- Tiene **cooldown** de 5 segundos (no se puede usar todo el tiempo)

### El proyectil:
Es una escena nueva (`proyectil.tscn`) con:
- `Area2D` que detecta al enemigo
- `Sprite2D` con una bola de fuego
- Se mueve solo hacia la dirección del jugador

---

## 🎯 ETAPA 6 — MONEDAS Y TIENDA 🪙

**Objetivo:** Ganar monedas al vencer y comprar cosas.

### Monedas:
- Cada partida ganada = **+5 monedas**
- Las monedas se guardan (no se pierden al cerrar el juego)

### Tienda:
Entre partidas aparece una tienda donde compras:
| Cosa | Precio |
|------|--------|
| 🗡️ Espada corta | 10 🪙 |
| 🏹 Lanza | 10 🪙 |
| 🔨 Martillo | 10 🪙 |
| 🛡️ Escudo | 15 🪙 |
| 👢 Botas | 15 🪙 |
| 🧥 Capa | 20 🪙 |
| 🦺 Pechera | 15 🪙 |
| 🔥 Ataque de fuego | 25 🪙 |

### Guardar progreso:
Usamos un archivo `save_data.json` para que las monedas
y las armas compradas no se pierdan.

---

## 📅 ORDEN RECOMENDADO

```
Etapa 1 (Sonidos) → Etapa 2 (Ataque gira)
    ↓
Etapa 3 (Armas) → Etapa 4 (Accesorios)
    ↓
Etapa 5 (Ataque especial) → Etapa 6 (Monedas y tienda)
```

---

## 🚀 EMPECEMOS

Dime **"empecemos Etapa 1"** y te voy dando el código y las
instrucciones paso a paso en Godot 4. ¡Tú decides el ritmo, Camilo! 😄
