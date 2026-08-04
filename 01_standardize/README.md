## Data Standardization

The scripts in this folder accept raw data (either original raw or after pre-processing if that was necessary) and standardize it into the accepted format _required_ by downstream parts of this workflow.

### Script Explanation

1. `01-A_drive-download.r` -- Downloads data inventory and raw data files from Shared Drive
2. `01-B_std-structure.r` -- Uses the data inventory to standardize the _structure_ (i.e., rows/columns) of each river's data as well as its filename
3. `01-C_populate-inventory_variables.r` -- Uses standardized data files to extract info needed for "variables" sheet of data inventory
4. `01-D_std-contents.r` -- Standardizes the _contents_ of each river's data (e.g., unit conversions, variable name standardization)
5. `01-Z_drive-upload.r` -- Uploads products of scripts in this workflow to Shared Drive
