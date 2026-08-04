## ----------------------------------------------- ##
# Standardize Raw Data _Contents_
## ----------------------------------------------- ##
## Purpose:
# Accept data with proper structure and standardize contents (e.g., unit conversions, variable standardization)
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
