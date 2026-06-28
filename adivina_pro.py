import random

numero_secreto = random.randint(1, 20)
intentos = 0
adivinado = False

print("¡Bienvenidos a encontrar el numero ñero del una al twenty siiiiiiii taka taka.....")

while not adivinado:
    intento = int(input("tu numero, ¿ñero?:"))
    intentos = intentos + 1

    if intento == numero_secreto:
        print(f"¡felisidades has reportado al numero ñero con el ice en {intentos} intentos🇨🇴 🇲🇽 🇦🇷 🇨🇱 🇵🇪 🇪🇸 🇺🇸 🇨🇦 🇧🇷 🇫🇷 🇩🇪 🇮🇹 🇯🇵 🇰🇷 🇨🇳 🇬🇧!: ")
        adivinado = True
    elif intento < numero_secreto:
        print("!📈Más alto ")
    else:
        print("!📉Más bajo ↓")