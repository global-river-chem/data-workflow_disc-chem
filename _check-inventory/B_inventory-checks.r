## ----------------------------------------------- ##
# Check Inventory
## ----------------------------------------------- ##
## Purpose:
# Make sure the various sheets of the data inventory are complete & usable by other workflow scripts

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, readxl)

# Clear environment + collect garbage
rm(list = ls()); gc()

# Read in the inventory
invent_v01 <- readxl::read_excel(path = file.path("data", "data-inventory.xlsx"), sheet = "rivers")

# Check structure
dplyr::glimpse(invent_v01)

## ---------------------------------- ##
# TBD ----
## ---------------------------------- ##





# End ----
