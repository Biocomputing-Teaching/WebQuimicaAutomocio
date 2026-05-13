# Figures workflow

Aquest directori conté figures usades pels documents LaTeX del curs. També inclou eines per generar PNGs a partir de PDFs i per ajustar colors quan una figura necessita una versió més neta o més llegible.

## Taula de continguts

- [Dependències](#dependències)
- [Cas típic: PDF a PNG retallat](#cas-típic-pdf-a-png-retallat)
- [Mode automàtic](#mode-automàtic)
- [Mode manual](#mode-manual)
- [Exemple real: taula periòdica](#exemple-real-taula-periòdica)
- [Com inspeccionar colors](#com-inspeccionar-colors)
- [Com aclarir un color de fons](#com-aclarir-un-color-de-fons)
- [Comandes útils de verificació](#comandes-útils-de-verificació)

## Dependències

Aquest flux usa:

- `pdfinfo`
- `pdftoppm`
- `convert` d'ImageMagick
- `identify` d'ImageMagick
- `python3` per al mode automàtic de retall

## Cas típic: PDF a PNG retallat

L'script principal és:

```bash
bash trim_pdf_page_to_png.sh --help
```

Té dos modes:

1. `--auto-main`
   Detecta automàticament el rectangle principal no blanc de la pàgina. Va bé quan el PDF té marques de tall, text petit a les vores o metadades impreses que fan inútil un `trim` simple.

2. mode manual
   Permet donar els marges de retall en punts PDF, en l'ordre:
   `LEFT_PT BOTTOM_PT RIGHT_PT TOP_PT`

## Mode automàtic

Per retallar el bloc principal d'una pàgina:

```bash
bash trim_pdf_page_to_png.sh --auto-main INPUT.pdf OUTPUT.png PAGE DPI
```

Exemple:

```bash
bash trim_pdf_page_to_png.sh --auto-main \
  taula-periodica_2024-BLAU.pdf \
  TaulaPeriodica.png \
  1 600
```

Quan usar-lo:

- si la pàgina té un gran bloc central clarament delimitat
- si hi ha soroll a les vores
- si vols un resultat ràpid sense afinar marges a mà

## Mode manual

Per retallar amb marges explícits en punts PDF:

```bash
bash trim_pdf_page_to_png.sh INPUT.pdf OUTPUT.png PAGE DPI LEFT_PT BOTTOM_PT RIGHT_PT TOP_PT
```

Exemple:

```bash
bash trim_pdf_page_to_png.sh \
  taula-periodica_2024-BLAU.pdf \
  TaulaPeriodica.png \
  1 600 \
  29 10 5 29
```

Quan usar-lo:

- si ja coneixes els marges exactes
- si vols reproduïbilitat absoluta
- si el mode automàtic no detecta bé la caixa útil

## Exemple real: taula periòdica

Per a `taula-periodica_2024-BLAU.pdf` s'ha acabat usant aquest flux:

1. Generar el PNG amb el rectangle principal de la primera pàgina:

```bash
bash trim_pdf_page_to_png.sh --auto-main \
  taula-periodica_2024-BLAU.pdf \
  TaulaPeriodica.png \
  1 600
```

2. Mirar l'histograma per veure quin és el color dominant del fons:

```bash
convert TaulaPeriodica.png -format %c -depth 8 histogram:info:- | sort -nr | head
```

3. Substituir només aquest color per una versió més clara:

```bash
convert TaulaPeriodica.png \
  -fill '#677788' \
  -opaque '#505A67' \
  TaulaPeriodica.png
```

En aquest cas:

- color de fons original: `#505A67`
- color nou una mica més clar: `#677788`

## Com inspeccionar colors

Per trobar els colors més freqüents d'una figura:

```bash
convert figura.png -format %c -depth 8 histogram:info:- | sort -nr | head -n 20
```

Això és útil per:

- detectar el color dominant del fons
- veure si el fons és realment un sol color o n'hi ha diversos
- decidir si una substitució directa amb `-opaque` és suficient

## Com aclarir un color de fons

Si el fons és essencialment d'un únic color:

```bash
convert figura.png \
  -fill '#COLOR_NOU' \
  -opaque '#COLOR_ANTIC' \
  figura.png
```

Exemple:

```bash
convert TaulaPeriodica.png \
  -fill '#677788' \
  -opaque '#505A67' \
  TaulaPeriodica.png
```

Si no vols sobreescriure l'original:

```bash
convert figura.png \
  -fill '#677788' \
  -opaque '#505A67' \
  figura_clara.png
```

## Comandes útils de verificació

Per veure mida i format:

```bash
identify figura.png
```

Per renderitzar una pàgina d'un PDF a PNG sense retall encara:

```bash
pdftoppm -r 300 -f 1 -singlefile -png document.pdf /tmp/prova
identify /tmp/prova.png
```

Per provar una variant sense tocar l'original:

```bash
convert figura.png -fill '#677788' -opaque '#505A67' /tmp/figura_prova.png
```

Per obrir el resum d'ús de l'script:

```bash
bash trim_pdf_page_to_png.sh --help
```
