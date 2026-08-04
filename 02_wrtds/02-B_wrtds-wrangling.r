## ----------------------------------------------- ##
# WRTDS Preparatory Wrangling
## ----------------------------------------------- ##
## Purpose:
# Do any pre-WRTDS wrangling necessary for subsequent 'actual' WRTDS scripts
# Any generically-useful standardization is done in the respective scripts so...
## ...these edits are useful _only_ (or at least primarily) for WRTDS

# Note this is done on a per-river basis so will create as many standard files as there were raw files
## This is _many_ files so expect the per-river operation to be quick but the total operation to be time-consuming

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse)

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# TBD ----
## ---------------------------------- ##







# End ----
