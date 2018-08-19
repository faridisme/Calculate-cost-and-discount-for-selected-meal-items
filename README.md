BACKGROUND

1. In this cafe, customer picks up items first and the receipt is calculated subsequently; 
2. Scan meal items for calculation of discount if eligible.  
3. As there can be a wide variation in costs for the same food type, only items below the reasonable cost for that food type is eligible for discounts. 
    For example, Mee Siam comes in Economy ($3), Standard ($4)  and Premium ($5). Only Economy and Standard is eligible for discount.

DESCRIPTION OF APP
1. The left-most panel lists the different menu items.  
2. Once menu items are selected, scan items by entering the item code into the scan forms in the middle panel.    
   a) Item codes within a scan form should be delimited by comma "," (or semicolon ";" or plus symbol "+");    
   b) For accurate subsidy calculation, scan set items (e.g. Nasi Lemak) based on meal sets, i.e. same nasi lemak set within same scan and different nasi lemak sets in different scans. 
3. Receipt and breakdown is updated in the right most column.  

UNDERLYING DATA

Masterlist.csv
Master list of items with their costs is found in Masterlist.csv. 
The contents of the master list appears in the left-most panel of the app.  

Foodgroupings.csv
For each food, a reasonable cost cut-off has been determined to facilitate discount for eligible customers. 
When Food cost exceeds the reasonable cost cut-off, no subsidy is given.
