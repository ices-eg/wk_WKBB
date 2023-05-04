###### Spatial Framework for WKBB

## 1. Define spatial grid extent and size fo grid cells
  ## List of grids cell size to be explored: 
    - Seabirds perspective: 
      - 0.25
      - 0.5
      - 1
      - 5
    - Fisheries perspective: 
      - 0.05 
      - 0.01 ( optional ) 
    - Common resolution: 
      - 0.25
      
## 2. Temporal resolution  

  - Year
  - Monthly aggregation 

## 3 . Fleet segment resolution
  
  - All gears 
  - Active/passive
  - Pelagic/demersal
  - Gears: Trawler, liners, gillnets, MIS (desirible buut not possible with current data)
  	- based on available data the categories:
		- bottom trawling (OTB, OTT, area 3 and green area 1 in MIS) | active | demersal | (trawl ByRas category)
		- pelagic trawl (OTM, most of MIS in area 2)  | active  | pelagic | (trawl ByRas category)
		- liners (LX ) | passive | demersal | (lines ByRas category)
		- nets (GTR ) | passive | demersal | (net ByRas category)
		- seiners (PS ) | passive | pelagic | (seiner ByRas category)
		- pots and traps (FPO) | passive | (trap ByRas category)
		- Miscellaneous (MIS) | unknown | (UNK ByRas category)

## 4. Activity indicator
  
  - Nb of vessels 
  - Fishing days
  - Total fishing days/fishing days by vessel

## 5. FISHERIES DATA PRODUCTS

  ## 5.1.1. Data product name: fish_1_1_2018_2022_neafc_0_25_year_month_gear_all_ind 
    - Special extent: All areas
    - Spatial resolution: 0.25
    - Temporal resolution: by year, month
    - Fleet resolution: by gears (level 4)
    - Activity indicator: nb vessel, fishing days by vessel, total fishing days, days of the month ratio

  ## 5.1.2. Data product name: fish_1_2_2018_2022_neafc_0_25_month_gear_days_ratio 
    - Special extent: All areas
    - Spatial resolution: 0.25
    - Temporal resolution: month
    - Fleet resolution: by gear (level 4)
    - Activity indicator: days of the month ratio -> mean()

  ## 5.1.3. Data product name: fish_1_3_2018_2022_neafc_0_25_month_gear_tot_days 
    - Special extent: All areas
    - Spatial resolution: 0.25
    - Temporal resolution: month
    - Fleet resolution: by gear (level 4)
    - Activity indicator: total fishing days -> mean()
    
  ## 5.2.1. Data product name: fish_1_1_2018_2022_neafc_0_25_year_month_byrasgear_all_ind 
    - Special extent: All areas
    - Spatial resolution: 0.25
    - Temporal resolution: by year, month
    - Fleet resolution: by gear (ByRas category)
    - Activity indicator: nb vessel, fishing days by vessel, total fishing days, days of the month ratio
   
  ## 5.2.2. Data product name: fish_2_2_2018_2022_neafc_0_25_month_byrasgear_tot_days  
    - Special extent: All areas
    - Spatial resolution: 0.25
    - Temporal resolution: month
    - Fleet resolution: by gear (ByRas category)
    - Activity indicator: total fishing days -> mean()
    
  ## 5.2.3. Data product name: fish_2_3_2018_2022_neafc_0_25_month_byrasgear_tot_hours  
    - Special extent: All areas
    - Spatial resolution: 0.25
    - Temporal resolution: month
    - Fleet resolution: by gear (ByRas category)
    - Activity indicator: total fishing hours -> mean()
