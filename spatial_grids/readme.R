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
		- bottom trawling (OTB, OTT, area 3 and green area 1 in MIS) | active | demersal | (OT ByRa category)
		- pelagic trawl (OTM, most of MIS in area 2)  | active  | pelagic | (OT ByRa category)
		- liners (LX ) | passive | demersal 
		- nets (GTR ) | passive | demersal
		- seiners (PS ) | passive | pelagic
		- pots and traps (FPO) | passive 

## 4. Activity indicator
  
  - Nb of vessels 
  - Fishing days
  - Total fishing days/fishing days by vessel

## 5. FISHERIES DATA PRODUCTS

  ## 5.1.1. Data product name: fish_2021_area2_0_25_year_all 
    - Special extent: All areas
    - Spatial resolution: 0.25
    - Temporal resolution: by year, month
    - Fleet resolution: by gears 
    - Activity indicator: nb vessel, fishing days by vessel, total fishing days

  ## 5.1.2. Data product name: fish_2_2021_area2_0_25_month_all 
    - Special extent: Area 2
    - Spatial resolution: 0.25
    - Temporal resolution: month
    - Fleet resolution: by gear
    - Activity indicator: nb vessel, fishing days by vessel, total fishing days -> mean()
	
