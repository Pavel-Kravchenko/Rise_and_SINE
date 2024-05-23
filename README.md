# Rise and SINE

The repository contains scripts for the analysis and plot generation for
"Rise and SINE: roles of transcription factors and retrotransposable elements in zygotic genome activation of mammalian embryos" Pavel Kravchenko and Kikue Tachibana. (2024).

0. RNA-seq data loading and processing - ```sbatch_scripts```
1. RNA-seq analysis and figures generation (Figures S1 A and C) - ```RNA_seq_analysis_and_figures.Rmd```
2. Figure S1D1 generation - ```./Figures/Figure_S1/Figure_S1D1/Figure_S1D1.ipynb```
3. Figures S1D 2 and 3 generation - ```./Figures/Figure_S1/Figure_S1D23/Figure_S1D23.ipynb```
4. Figures S1 E and F generation - ```./Figures/Figure_S1/Figure_S1_E_and_F.ipynb```

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
