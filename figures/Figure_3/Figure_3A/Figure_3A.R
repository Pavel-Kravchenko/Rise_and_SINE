# PWM was obtained from https://hugheslab.ccbr.utoronto.ca/supplementary-data/homeodomains1/pwm_all_102107.txt (pwm_all_102107_obtained_from_Berger_et_al_Cell_2008.txt)

library(archR)
library(Biostrings)
library(rtfbs)
library(DiffLogo)
library(PWMEnrich)

pwm = getPwmFromFile("./Obox3_table.pwm")
rownames(pwm) = c("A", "C", "G", "T")

plot_ggseqlogo(
  pwm_mat = reverseComplement(pwm),
  method = "bits",
  pos_lab = NULL,
  pdf_name = NULL,
  bits_yax = "full",
  fixed_coord = FALSE
)

# Export as .pdf
