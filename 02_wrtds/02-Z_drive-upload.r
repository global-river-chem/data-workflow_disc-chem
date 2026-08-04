## ----------------------------------------------- ##
# Upload WRTDS Outputs
## ----------------------------------------------- ##
## Purpose:
# Uploads outputs files to Drive
# If file is in Drive already, defaults to not overwriting (to save computing time)
# If re-upload of one/few files is desired, delete them in the Drive rather than changing the 'update_drive' object
## Because changing that object will make _all_ files overwrite which will be _immensely_ time-consuming

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, readxl, googledrive)

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Identify Drive Destinations ----
## ---------------------------------- ##

# Read in the inventory
invent_v01 <- readxl::read_excel(path = file.path("data", "data-inventory.xlsx"), sheet = "rivers")

# Check structure
dplyr::glimpse(invent_v01)



## ---------------------------------- ##
# Export Standard Files to Drive ----
## ---------------------------------- ##

# Should files in Drive be replaced with local files?
update_drive <- FALSE

# Identify local files


# Export them to the relevant Drive folder



# End ----
