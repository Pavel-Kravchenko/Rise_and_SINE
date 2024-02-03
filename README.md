# Rise and SINE

The repository contains scripts for the analysis and plot generation for
"Mechanisms of zygotic genome activation in totipotent mammalian embryos" Pavel Kravchenko and Kikue Tachibana. _Nat. Rev. Mol. Cell Biol_ (2024).

0. RNA-Seq data loading and processing - ```sbatch_scripts```
1. RNA-Seq analysis and figures generation (Figure 3, 4, S1A) - ```RNA_Seq_analysis_and_figures.Rmd```
2. Figure S1B generation - ```./Figures/Figure_S1/Figure_S1B/Figure_S1B.ipynb```
3. Figure S2 generation - ```./Figures/Figure_S2/Figure_S2.ipynb```
4. Figure S3 generation - ```./Figures/Figure_S3/Figure_S3.ipynb```

Pan-ZGA lists of different degrees can be found in the ```pan_ZGA_lists``` directory.

## Before you start

Make sure that you have installed:
<ul>
<li>Python 3.7 (or upper) https://www.python.org/
<li>R 4.2.1 (or upper) and RStudio https://posit.co/download/rstudio-desktop/
</ul>

Please use the provided ```environment_py37.yaml``` and ```R_sessioninfo.txt``` to match the environment

## Getting started

First of all, you have to ```clone``` this directory</br></br>
```git clone https://github.com/Pavel-Kravchenko/Rise_and_SINE/```</br></br>
Then ```cd``` in Rise_and_SINE </br></br>
```cd Rise_and_SINE```</br></br>
