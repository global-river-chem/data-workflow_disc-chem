## Data Inventory Checks

The data inventory is _central_ to virtually all of the scripts in this repository. This is a useful structural choice but does mean that issues with the inventory can have _massive_ ramifications (the least of which is the workflow breaking).

The scripts in this folder check for completeness and correctness of the inventory.

### Script Explanation

1. `A_drive-download.r` -- Downloads data inventory
2. `B_inventory-checks.r` -- Checks each of the sheets in the inventory (note this script is highly dynamic--for now--as the actual workflow scripts evolve but should stabilize)
