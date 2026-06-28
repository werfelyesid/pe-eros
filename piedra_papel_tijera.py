import random

opciones = ["piedra", "papel", "tijera"]
puntos_jugador = 0
puntos_pc = 0

print("PIEDRA, PAPEL O TIJERA")
print("gana el primero que llegue a 3 puntos\n")

while puntos_jugador < 3 and puntos_pc < 3:
    print(f"marcador: tú {puntos_jugador} - {puntos_pc} PC")

    eleccion = input("elije: piedra, papel o tijera: ").lower()

    if eleccion not in opciones:
        print("❌ ¡Escribe bien ñero ¡ piedra, papel o tijera\n")
        continue

    pc = random.choice(opciones)
    print(f"la pc eligio: {pc}")

    if eleccion == pc:
        print("!Empate¡\n")
    elif (eleccion == "piedra" and pc == "tijera") or \
         (eleccion == "papel" and pc == "piedra") or \
         (eleccion == "tijera" and pc == "papel"):
        puntos_jugador += 1
        print("¡Ganaste esta ronda!\n")
    else:
        puntos_pc += 1
        print("Perdiste esta ronda!\n")

# Resultado final 
print("=" * 30)
if puntos_jugador == 3:
    print("¡Felicidades, ganaste")
else:
    print("lapc te gano muerde el polvo")
print(f"Marcador final: Tú {puntos_jugador} - {puntos_pc} PC") 