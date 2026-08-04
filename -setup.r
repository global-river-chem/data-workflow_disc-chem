## ----------------------------------------------- ##
# Get Set Up
## ----------------------------------------------- ##
## Purpose:
# Centralize setup operations used by at least two other scripts for ease of access

## ---------------------------------- ##
# Make Needed 'Data' Folders ----
## ---------------------------------- ##

# Make relevant top-level folder
dir.create(file.path("data"), showWarnings = FALSE)

# Make sub-folders of 'data'
## Order of following lines is a rough match for workflow order
dir.create(file.path("data", "00_raw"), showWarnings = FALSE)
dir.create(file.path("data", "01-B_std-structure"), showWarnings = FALSE)
dir.create(file.path("data", "01-D_std-contents"), showWarnings = FALSE)
# dir.create(file.path("data", "02-B_wrtds-ready"), showWarnings = FALSE)
# dir.create(file.path("data", "02-C_wrtds-results"), showWarnings = FALSE)
# dir.create(file.path("data", "02-D_wrtds-bootstrap"), showWarnings = FALSE)

# Make a subfolder for diagnostics & tests
dir.create(file.path("data", "tests"), showWarnings = FALSE)

# Clear environment + collect garbage
rm(list = ls()); gc()

# End ----
