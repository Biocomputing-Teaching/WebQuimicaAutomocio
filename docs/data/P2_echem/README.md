# P2. Química computacional amb eChem

Objectiu: preparar una pràctica reproduïble amb eines d'eChem/VeloxChem per a la Pràctica 2 del curs.

La pràctica parteix explícitament de l'equació de Schrödinger i de la mecànica quàntica: els notebooks d'eChem resolen aproximadament el problema electrònic de molècules reals per obtenir geometries, càrregues, energies, vibracions, orbitals i espectres.

Abans d'executar els notebooks d'eChem, s'encoratja l'estudiant a provar el notebook de LibreTexts **Particle in an Infinite Potential Box**:

<https://chem.libretexts.org/Ancillary_Materials/Interactive_Applications/Jupyter_Notebooks/Particle_in_an_Infinite_Potential_Box_(Python_Notebook)>

Aquest notebook és un sistema model senzill per veure com la resolució de l'equació de Schrödinger produeix energies quantitzades i funcions d'ona amb nodes. No forma part del lliurament, però ajuda a entendre la lògica dels càlculs computacionals que vindran després.

## Estructura

- `environment-echem-macos-linux.yml`: entorn conda per provar a macOS i Linux.
- `environment-echem-windows.yml`: entorn conda equivalent per a Windows.
- `P2_echem.tex`: guió de la pràctica en PDF.
- `notebooks/`: còpies locals dels notebooks Colab d'eChem que farem servir.
- `scripts/smoke_test.py`: prova mínima local de la instal·lació.
- `scripts/download_echem_notebooks.py`: actualitza les còpies locals dels notebooks.
- La taula de molècules de treball és al guió PDF de la pràctica. Els estudiants han de començar buscant la seva molècula a PubChem i anotant el CID, la fórmula, la massa molar i el SMILES.
- `results/`: resultats locals generats pels tests i càlculs.

## Instal·lació ràpida

### macOS i Linux

```bash
cd /path/to/QuimicaAutomocio/Pràctiques/P2
conda env create -f environment-echem-macos-linux.yml
conda activate quimica-echem
python scripts/smoke_test.py
jupyter-lab
```

### Windows

Obre **Anaconda Powershell Prompt**. No facis servir el `cmd` clàssic si no cal.

```powershell
cd C:\path\to\QuimicaAutomocio\Pràctiques\P2
conda env create -f environment-echem-windows.yml
conda activate quimica-echem
python scripts\smoke_test.py
jupyter-lab
```

Si el kernel de Jupyter es tanca a Windows per conflictes d'OpenMP, afegeix al principi del notebook:

```python
import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
```

## Estat de proves locals

- macOS arm64: provat amb `conda env create -f environment-echem-macos-linux.yml` i `python scripts/smoke_test.py`.
- Linux: pendent de provar en una màquina Linux real. Aquest Mac no té Docker ni Podman instal·lats per fer una prova ràpida en contenidor.
- Windows: pendent de provar. Les instruccions segueixen la recomanació d'eChem d'usar Anaconda Powershell Prompt.

En el Mac de prova, conda mostra l'avís `conda-content-trust (No module named 'conda.plugins.hookimpl')`, però l'entorn es crea i el test acaba amb `status: ok`.

Si l'entorn es va crear abans d'afegir la part de dihedres amb xTB i apareix l'error `XtbDriver: xtb-python is not available` o `DispersionModel: dftd4-python is not available`, actualitza'l amb:

```bash
conda activate quimica-echem
conda install -c conda-forge xtb-python dftd4-python
python scripts/smoke_test.py
```

## Notebooks de referència

Els notebooks provenen de la pàgina de Colab d'eChem:

- `AtomicCharges.ipynb`
- `BDEtohydrogen.ipynb`
- `DihedralScan.ipynb`
- `VibrationalModes.ipynb`
- `OrbitalVisualizer.ipynb`
- `UV_Vis_spectrum.ipynb`

Les còpies d'aquesta carpeta estan adaptades per a execució local. En els notebooks provinents d'eChem, la cel·la original d'instal·lació de Colab s'ha substituït per una comprovació de l'entorn. `VibrationalModes.ipynb` és un notebook propi del curs: optimitza una molècula amb xTB, calcula la Hessiana amb VeloxChem i representa dinàmicament els modes normals amb `py3Dmol`.

```bash
conda activate quimica-echem
cd /path/to/QuimicaAutomocio/Pràctiques/P2
jupyter-lab
```

Si Jupyter ja era obert abans d'activar l'entorn, tanca'l i torna'l a arrencar des del terminal amb `quimica-echem` actiu. En cas contrari, el notebook pot estar fent servir el kernel de `base`.

Pàgines de referència:

- eChem: <https://kthpanor.github.io/echem/>
- Instal·lació local: <https://kthpanor.github.io/echem/docs/install.html>
- Notebooks Colab: <https://kthpanor.github.io/echem/colab/>

Per actualitzar-los:

```bash
python scripts/download_echem_notebooks.py
```

## Criteri de disseny docent

La pràctica no ha de demanar càlculs massius. Primer l'estudiant ha de demostrar que la instal·lació funciona amb tres molècules comunes i càlculs ràpids: hidrogen, metà i benzè. Aquests tres casos donen una base compartida per parlar d'energies d'enllaç, enllaços C-H i aromaticitat. Després cada grup treballa una sola molècula de complexitat mitjana, assignada al PDF de la pràctica, i l'estudia amb totes les eines disponibles. Abans de calcular res, l'estudiant ha de buscar la molècula a PubChem, anotar CID, fórmula, massa molar i SMILES, i justificar que treballa amb l'estructura correcta. Totes les molècules mitjanes assignades tenen com a mínim un dièdric raonable perquè el notebook `DihedralScan` pugui formar part del treball.

Les preguntes connecten càrregues atòmiques, energies d'enllaç, conformació, vibracions moleculars, orbitals moleculars i UV/vis amb els capítols del curs. Quan una eina no sigui adequada per a una molècula concreta, l'estudiant ho ha de dir explícitament i respondre "si es pot" amb la molècula assignada o amb una de les molècules comunes de referència.

Per publicar el material de P2 a `WebQuimicaAutomocio` sense enllaçar-lo des de la portada:

```bash
make -C Pràctiques p2-web
```
