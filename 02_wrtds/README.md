## WRTDS (Weighted Regressions on Time, Discharge, and Season)

The scripts in this folder _standardized_ data (both structure and contents) and perform WRTDS where possible. WRTDS requires a certain number of consecutive years as well as both discharge and (at least one) chemical information.

### Script Explanation

1. `02-A_drive-download.r` -- Downloads data inventory and standardized data files from Shared Drive
2. `02-B_wrtds-wrangling.r` -- Does all WRTDS-specific wrangling
3. `02-C_wrtds-actual.r` -- Performs core WRTDS workflow
4. `02-D_wrtds-bootstrap.r` -- Peforms bootstrapping variant of WRTDS workflow
5. `02-Z_drive-upload.r` -- Uploads products of scripts in this workflow to Shared Drive
