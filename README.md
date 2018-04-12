## UPCMapping.pl ##
USAGE: perl UPCMapping.pl UPC_trip.dat UPC_Data_20090313.txt encodedPurchase.dat UPC_Mapped.dat Zone_mapped.dat SpendStat

## profileClusterSpending.pl ###
USAGE: perl profileClusterSpending.pl SpendStat.dat purchase.mat.0.clustering.3 num_clusters

## sims.pl ##
- INPUT: the cluster label of each partial path in the testing set;  
- also given the cluster labels of each path in the training set,  
- the similaritie between testing path and training path belonging to the same cluster are computed
SAMPLE USAGE: perl sims.pl round_ind num_cluster

## support_wo_new.pl ##
print "USAGE: perl support_wo_new.pl round_ind num_cluster\n"; 

## recom.pl ## 
SAMPLE USAGE: perl recom.pl testing_paths0 training_paths0 Sim_training0.clustering.4 4 0

## hitRate.pl ##
USAGE: perl profileClusterSpending.pl UPC_mapped0 Sim_training0.clustering.4 num_clusters round_ind

## Zone_mapped.dat ##
```
Zone ID 	Product categories located at ZONE	
63	"GENERAL MERCHANDISE,NONFOOD GROCERY,"	
90	"GROCERY,SODA POP,NONFOOD GROCERY,CIGS/TOBACCO,GENERAL MERCHANDISE,"	
71	"NONFOOD GROCERY,GENERAL MERCHANDISE,"	
7	"SODA POP,GENERAL MERCHANDISE,WINE BOTTLES,"	
```

## purchase.dat ##
```
18133639_2008-05-03-12:13:29.000:	3	(208,136),6.103;(42,107),7.602;(32,160),4.962;
18133676_2008-05-03-12:13:36.000:	1	(134,44),3.148;
18133410_2008-05-03-12:20:55.000:	5	(203,131),8.186;(190,139),15.212;(194,121),10.314;(28,160),3.285;(21,95),4.57;
18133750_2008-05-03-12:25:55.000:	2	(81,131),13.245;(42,103),3.24;
18133607_2008-05-03-12:29:34.000:	2	(209,96),7.781;(28,160),31.739;
18133638_2008-05-03-12:31:08.000:	2	(122,57),61.002;(5,59),16.261;
18133169_2008-05-03-12:35:38.000:	3	(139,144),2.481;(134,44),9.283;(109,59),8.576;
```

## SpendStat.dat ##
```
1	18133639_2008-05-03-12:13:29.000:	3	6.97	DAIRY	1	GROCERY	1	PRODUCE	1	GROCERY	4.19	DAIRY	1.99	PRODUCE	0.79			
0	18133676_2008-05-03-12:13:36.000:	1	5.4	CIGS/TOBACCO	1	CIGS/TOBACCO	5.4		1813
```

## loc_purchase.dat ##
```
3639_2008-05-03-12:13:29.000:	(208,136),(42,107),(32,160),
18133676_2008-05-03-12:13:36.000:	(134,44),
18133410_2008-05-03-12:20:55.000:	(203,131),(190,139),(194,121),(28,160),(21,95),
18133750_2008-05-03-12:25:55.000:	(81,131),(42,103),
18133607_2008-05-03-12:29:34.000:	(209,96),(28,160),
```

## pathStat.txt ##
```
Trip_ID LengthInFeet    DurationInSeconds       TotalAverageSpeed
18133639_2008-05-03 12:13:29.000:       2798.66 2184    1.28144
18133676_2008-05-03 12:13:36.000:       1400.18 813     1.72224
18133410_2008-05-03 12:20:55.000:       2916.07 1623    1.79672
18133750_2008-05-03 12:25:55.000:       1750.93 987     1.77399
18133607_2008-05-03 12:29:34.000:       1654.55 920     1.79843
```							
