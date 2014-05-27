#!/usr/bin/perl 
#===============================================================================
#        USAGE:  ./k_medoids.pl para_k pathfile
#
#  DESCRIPTION:  k-medoids clustering algorithm to handle store spatial constraints
#       OUTPUT:  
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  08/28/2007 09:10:01 PM MST
#     REVISION:  ---
#===============================================================================

#use strict;
#use warnings;

$para_k = shift; 

#read the input containing data in the format of:N 5& 23.845089,38.018470,0.000 23.845179,38.018069,0.000 23.845530,38.018241,0.000 23.845499,38.017440,0.000 23.844780,38.015609,0.000 ...
$file = shift ; 

open(INPUT, $file);
($num_line, @trajs) = <INPUT>;
close INPUT; 

#$num_line = @trajs; # number of trajectories

###################################
#Initialization
###################################
@c = (); #cluster vector: random draw of k numbers from (1,$num_line) without replacement
for ($i =0; $i < $para_k; $i ++){
	$c[$i] = int(rand($num_line));
}
#calculate the distance matrix between each trajectory and the randomly selected centroids

@c_matrix = (); #(n by k) matrix of distances between path n and cluster centroid k

&d_matrix_centroids(\@c);

@CL = (); #(CL1, CL2, . . . CLn)= vector of cluster assignments; i.e. if CL103 = 12, path 103 is assigned to cluster 12.
$CL_ref = &cl_assign(); 
@CL = @$CL_ref; 

#print "@CL\n"; 
@CL_new = (); 

@c_new = (); # the index to the centroids 
&recalculate(\@CL); #this gives a new set of cluster assignment 
#print "old assignment @CL\n";
#print "how about new cluster assignment? @CL_new\n"; 
#now check if the clustering results is now stable 

$same = "true"; 

for ($cnt = 0; $cnt < 100; $cnt++) {
	for (my $i=0; $i<$#CL_new; $i++){
		if ($CL_new[$i] ne $CL[$i]) {
			$same = "false";
			last; 
		}
	}
        if ($same eq "false") {
                @CL = @CL_new;

                @CL_new = ();
		#print "old assignment @CL\n";
		@c_new = (); 
                &recalculate(\@CL);
		#print "how about new cluster assignment? @CL_new\n";

	}

	else {  print "how many rounds already: $cnt\n"; 
		last; 		
	}

}

#now print the final clustering assignment with the sequence of coordinates for labeled trajectories
print "how about new cluster assignment? @CL_new\n";

open (OUT, ">:utf8", "Trajs_labeled_mediods.txt");
print OUT "$num_line\n";

for (my $i =0; $i<$num_line; $i++) {
	my @temp = split(/&/, $trajs[$i]);

	if (grep {$_ eq $i} @c_new) {
 		print OUT "Y $CL_new[$i]& $temp[1]";}
	else {print OUT "N $CL_new[$i]& $temp[1]";}
	
}
close OUT; 
sub recalculate() {

	#################################
	#calculate for the means
	##################################
	
	#kMm = (k by m) matrix of cluster means (mean position of cluster k at each of the 100 percentile locations)

	@k_matrix_x = (); 
	@k_matrix_y = (); 

	for (my $j = 0; $j<$para_k; $j++){
		for (my $i = 0; $i< 1000; $i++){
			$len_arr[$j][$i]=0; 
		}

	}
	#compute the sum, also the norm
	for (my $i=0; $i < $num_line; $i++){

		$cluster = $CL[$i]; 
		my @temp = split(/&/, $trajs[$i]); 
		my @coordinates = split (/\s+/,$temp[1]); #@coordinates = ("23.845089,38.018470,0.000", "23.845179,38.018069,0.000",... )
		my $len = @coordinates; 
		for (my $j = 0; $j< $len; $j++){
			$len_arr[$cluster][$j]++; 
			@temp_2 = split(/,/,$coordinates[$j]); #@temp_2 = ("23.845089","38.018470","0.000"); 
			if ( $k_matrix_x[$cluster][$j]>=0){
				$k_matrix_x[$cluster][$j] += $temp_2[0]; 
				#print "$k_matrix_x[$cluster][$j] += $temp_2[0]\n";
			
			}
			else {$k_matrix_x[$cluster][$j] = 0; }
			if ( $k_matrix_y[$cluster][$j]>=0){
				$k_matrix_y[$cluster][$j] += $temp_2[1]; 
			}
			else {$k_matrix_y[$cluster][$j] = 0; }

		}
	}
	#print "did i get the length arr right? $len_arr[9][1]\n"; 
	#print "how about K-matrix $k_matrix_x[2][11]\n";
        #print "how about K-matrix $k_matrix_y[10][1]\n";

	#compute the mean
	for (my $i = 0; $i<$para_k; $i++){
		for (my $j = 0; $j< 1000; $j++){
			if ($len_arr[$i][$j]>0){
				$k_matrix_x[$i][$j] = $k_matrix_x[$i][$j]/ $len_arr[$i][$j]; 
				$k_matrix_y[$i][$j] = $k_matrix_y[$i][$j]/ $len_arr[$i][$j]; 
			}
			else {last;}
		}
	}
	#print "normalized k_matrix $k_matrix_x[1][10]\n"; 
	#print "normalized k_matrix $k_matrix_y[10][1]\n";

	##################################
	#calculate the distance matrix between each trip and the means
	##################################

	@d_matrix =();

	@row = (); 
	for (my $i=0; $i<$para_k; $i++){

		@m_coor = (); 
		
		$len = $#{$k_matrix_x[$i]};# 
		#print "length of the summarized sequence$len\n"; 
		for (my $j=0; $j<$len; $j++){
			$temp_str = $k_matrix_x[$i][$j].",".$k_matrix_y[$i][$j]; 
			push @m_coor, $temp_str; 

		}
                @row = (); 
		foreach $traj (@trajs){
			@temp = split(/&/, $traj); 
			@coordinates = split (/\s+/,$temp[1]);
			$num_blinks = @coordinates;
			my $longer_ref =0; 
			my $shorter_ref =0; 
			if ($len > $num_blinks) {
				$longer_ref = \@m_coor;
				$shorter_ref = \@coordinates;
			}
			else {
				$longer_ref = \@coordinates;
				$shorter_ref = \@m_coor;
			}
			my $dis = &distance ($longer_ref, $shorter_ref);
			#print "the distance is $dis\n";  
			push (@row,$dis);
		}
		push @d_matrix, [@row]; 

	}
	##################################

	
	for (my $j=0; $j< $para_k; $j++){
		$centroid_new = 0; 
		$min_dist = $d_matrix[$j][0]; 
		for (my $i=0; $i< $num_line; $i++){
			if ($d_matrix[$j][$i] <$min_dist) {$min_dist = $d_matrix[$j][$i]; $centroid_new = $i;}
		}
		push (@c_new, $centroid_new); 
	}

	@c_matrix = ();
	&d_matrix_centroids(\@c_new);
	##################################
	#recalculate for the cluster assignment
	##################################
	$CL_new_ref =&cl_assign(); 
	@CL_new = @$CL_new_ref; 

}

##################################
#compute the distance between two paths
##################################
sub distance () {
	$l_ref = shift; 
	$s_ref = shift; 
	@l_path = @$l_ref; 
	@s_path = @$s_ref; 
	$l_len = @l_path; 
	$s_len = @s_path; 
	$dist = 0; 
	if ($s_len >0){
		$times = int($l_len/$s_len);
	 
		for ($i=0; $i<$s_len; $i++){
			$l_ind = $i*$times; 
			$l_pos = $l_path[$l_ind]; 
			$s_pos = $s_path[$i]; 
			@l_temp = split (/,/,$l_pos);
			@s_temp = split (/,/,$s_pos);
			$dist += (($l_temp[0]-$s_temp[0])**2+($l_temp[1]-$s_temp[1])**2)**0.5; 
		}
	}
	return $dist; 

}


##################################
#compute the distance matrix between each trip and the centroids
##################################

sub d_matrix_centroids(){
	$c_ref = shift; 
	@c = @$c_ref;
	foreach $c_ind (@c){
		$c_traj = $trajs[$c_ind];
		#how many blinks for each trajectory? 
		@c_temp = split(/&/, $c_traj); 
		@c_coordinates = split (/\s+/,$c_temp[1]);
		$c_num_blinks = @c_coordinates; 
		@row = (); 
		foreach $traj (@trajs){
			@temp = split(/&/, $traj); 
			@coordinates = split (/\s+/,$temp[1]);
			$num_blinks = @coordinates;
			my $longer_ref =0; 
			my $shorter_ref =0; 
			if ($c_num_blinks > $num_blinks) {
				$longer_ref = \@c_coordinates;
				$shorter_ref = \@coordinates;
			}
			else {
				$longer_ref = \@coordinates;
				$shorter_ref = \@c_coordinates;
			}
			$dis = &distance ($longer_ref, $shorter_ref); 
			#print "the distance is $dis\n";
			push (@row,$dis);
		}
		push @c_matrix, [@row]; 
	}
}

##################################
#calculate for the cluster assignment
##################################

sub cl_assign (){
	 
	@CL_tmp = ();  
	for (my $j=0; $j< $num_line; $j++){
		my $cluster_tmp = 0; 
		$min = $c_matrix[0][$j]; 
		for (my $i=0; $i< $para_k; $i++){
			if ($c_matrix[$i][$j] <$min) {$min = $c_matrix[$i][$j]; $cluster_tmp = $i;}
		}
		push (@CL_tmp, $cluster_tmp); 
	}

	$ref = \@CL_tmp;
	return $ref ; 
}
