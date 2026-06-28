# Album escolar - produccion inicial

Este modulo deja una base para:
- Crear catalogo de jugadores a partir de fotos reales.
- Generar laminas en formato tipo mundial (5 x 7 cm aprox).
- Montar pliegos carta para impresion inkjet en papel adhesivo.
- Generar sobres (3 laminas por sobre, 1000 pesitos) con distribucion realista.

## Estructura

- `data/config_album.json`: reglas y parametros del proyecto.
- `data/laminas_jugadores.csv`: catalogo editable de jugadores.
- `scripts/01_generar_catalogo_jugadores.py`: crea el catalogo inicial desde la carpeta de fotos.
- `scripts/02_generar_laminas.py`: genera PNG de laminas.
- `scripts/03_generar_pliegos_carta.py`: arma hojas carta con laminas.
- `scripts/04_generar_sobres.py`: crea lotes de sobres y reporte CSV.

## Flujo rapido

1. Instalar dependencias:

```bash
pip install -r requirements.txt
```

2. Generar catalogo inicial (detecta fotos disponibles y faltantes):

```bash
python scripts/01_generar_catalogo_jugadores.py
```

3. Editar nombres en `data/laminas_jugadores.csv`.

4. Generar laminas:

```bash
python scripts/02_generar_laminas.py
```

5. Generar pliegos carta:

```bash
python scripts/03_generar_pliegos_carta.py
```

6. Generar lote de sobres (ejemplo: 120 sobres):

```bash
python scripts/04_generar_sobres.py --num-packs 120
```

## Notas importantes

- La rareza de Camilo Mantilla Ramirez se fuerza automaticamente a `R` cuando el nombre este escrito exactamente asi en el CSV.
- Enrique y Mario pueden quedar con estado `falta_foto` hasta que suban sus imagenes.
- Las fotos extras del album se pueden agregar en una segunda etapa (otra semana).
