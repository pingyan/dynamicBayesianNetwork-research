1. TrajCnt.pl

DESCRIPTION: 
There is no single identifier for different trajectories, this script actually relies on the first three attibutes: obj_ID, tra_id and time to identify different trajectories and output the number of trajectories in the datafile. 

OUTPUT: 
The number of trajectories

---------------------------------

2. TrajSplit.pl

USAGE:
First provide the datafile name with trajectories, please also provide two parameters: Sigma_x and Sigma_y to specify the size of matching region.

DESCRIPTION:
The script is growing 

The script first develops the data structure for sequences of positions belonging to individual trajectories, feed the sequences to the subroutine of LCS. The length of LCS is computed according to triangle inequality specified by Sigma_x and Sigma_y.

To following up ... 
How to print the LCS sequences - hot paths?

OUTPUT: 
The similarity matrix of sequence pairs
 
---------------------------------

3. Label.pl

USAGE: 
perl Label.pl trucks/Trajs_trucks.txt sim.graph.clustering.6 trucks.sim.graph

OUTPUT: "Trajs_labeled.txt"

DESCRIPTION:

To visualize the resutls

That is to develop .kml file for each trajectory according to its cluster label

So first the Label.pl takes the clustering results to compose the Trajs_***.labeled,txt with each line consisting of a trajectory with the first element the cluster label and all the coordinates of positions

The output is therefore ready for use to compose the .kml file

It also marks the center points in each cluster
------------------------------------

4. Mapping.pl

USAGE:
perl Mapping.pl Trajs_labeled.txt

DESCRIPTION:
compose .kml file using the output of Label.pl.
Trajectories are color coded based on the clusters they belong to


------------------------------------

5. print the longest LCS sequence

to determine the to-be-printed, we have a few choices: 
the LCS among all the sequences in a cluster (might not return anything)
the sequence represented as a center point in a cluster (which having the largest sum of similarity score?)
the LCS sequence with the biggest lenLCS (the common part of only one pair?)

we now implement the second choice first. Now modify the TrajSplit.pl to store all the pairwise LCSs. 
To locate the center point in each cluster, we can query the similarity matrix with the given clutering results (wish CLUTO tool could do the work...)

------------------------------------

6. implement k_mediod method as baseline method

 

