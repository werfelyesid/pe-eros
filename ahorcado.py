import random

palabras = ["esternocleidomastoideo", "papa yesid", "empapado", "ñerito", "DTMF", "terminator", "la abejita maya", "la cebolla", "lo que la mama mas teme", "maduro petro y diddy en la carsel"]

palabra_secreta = random.choice(palabras)
letras_adivinadas = []
vidas = 7
adivinada = False

print("🎯 ¡EL AHORCADO")
print(f"la palabra tiene {len(palabra_secreta)} letras\n")

while vidas > 0 and not adivinada:
    # Mostrar el estado actual de la palabra
    mostrar = ""
    for letra in palabra_secreta:
        if letra in letras_adivinadas:
            mostrar += letra + " "
        else:
            mostrar += "_ "

    print(f"Palabra: {mostrar}")
    print(f"❤️  vidas: {vidas}   |  Letras usadas: {', '.join(letras_adivinadas)}")

    intento = input("Di una letra: ").lower()

    if len(intento) != 1:
        print("⚠️  ¡UNA SOLA LETRA!'\n")
        continue

    if intento in letras_adivinadas:
        print("⚠️ ¡Ya usaste esa letra!\n")
        continue

    letras_adivinadas.append(intento)

    if intento in palabra_secreta:
        print("✅ ¡Bien! Esa letra sí está\n")
        if all(letra in letras_adivinadas for letra in palabra_secreta):
            adivinada = True
    else:
        vidas = vidas - 1
        print(f"❌ Esa letra no está. Pierdes una vida\n")

# Resultado final
print("=" * 35)
if adivinada:
    print(f" ¡GANASTE ÑERITO!LA PALABRA ERA: {palabra_secreta}")
else:
    print(f"¡PERDISTE MUERDE EL POLVO! LA PALABRA ERA: {palabra_secreta}")
print(f"usaste {len(letras_adivinadas)} intentos") 