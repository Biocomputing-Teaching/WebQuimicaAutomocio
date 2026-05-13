# P2. Química computacional amb eChem

Objectiu: preparar una pràctica reproduïble amb eines d'eChem/VeloxChem per a la Pràctica 2 del curs.

## Estructura

- `environment-echem-macos-linux.yml`: entorn conda per provar a macOS i Linux.
- `environment-echem-windows.yml`: entorn conda equivalent per a Windows.
- `P2_echem.tex`: guió de la pràctica en PDF.
- `notebooks/`: còpies locals dels notebooks Colab d'eChem que farem servir.
- `scripts/smoke_test.py`: prova mínima local de la instal·lació.
- `scripts/download_echem_notebooks.py`: actualitza les còpies locals dels notebooks.
- `data/molecules_course.csv`: taula de 26 molècules del curs assignades als grups A-M.
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

La pràctica no ha de demanar càlculs massius. Primer l'estudiant ha de demostrar que la instal·lació funciona amb molècules petites i càlculs ràpids. Després cada grup treballa dues molècules: una de petita i una de complexitat mitjana, assignades a `data/molecules_course.csv` i al PDF de la pràctica. Les preguntes connecten càrregues atòmiques, energies d'enllaç, conformació, vibracions moleculars, orbitals moleculars i UV/vis amb els capítols del curs.

Per publicar el material de P2 a `WebQuimicaAutomocio` sense enllaçar-lo des de la portada:

```bash
make -C Pràctiques p2-web
```
