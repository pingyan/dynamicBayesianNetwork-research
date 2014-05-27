#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  Label.pl
#
#        USAGE:  perl Label.pl ../Trajs_trucks.txt ../sim.graph.clustering.6 trucks.sim.graph
#
#  DESCRIPTION:  the Label.pl takes the clustering results to compose the Trajs_***.labeled,txt with each line consisting of a trajectory with the first element the cluster label and all the coordinates of positions
#       
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  12/10/2007 11:44:19 AM MST
#     REVISION:  ---
#===============================================================================

#use strict;
#use warnings;
use Switch;

$file1 = shift; #trajectory file in format: 1       0309;1;18/10/2000;10:16:20;23.706222;38.003593;474059.40;4205966.80
$file2 = shift; #cluster labels

open (IN1,$file1);
@arr_traj = <IN1>; 

open (IN2,$file2);
@arr_clu = <IN2>; #the cluster labels
close IN1; 
close IN2; 

$file3 =shift; # the file containing similarity matrix 
open (SIMM, $file3);

($num_line,@simm) = <SIMM>;
close SIMM;

my @matrix = (); #store the similarity matrix
foreach $row (@simm) {

        my @tmp = split (/\s+/,$row);
        push @matrix, [@tmp];
}
#######################################
#find the center points within each cluter
#######################################
$cnt = 0;
#each array has the trajectory ids belonging to the corresponding cluster
foreach $item (@arr_clu){
        $item =~ s/\n//;

        switch($item){
                case "0" {push @arr_0, $cnt;}
                case "1" {push @arr_1, $cnt;}
                case "2" {push @arr_2, $cnt;}
                case "3" {push @arr_3, $cnt;}
                case "4" {push @arr_4, $cnt;}
                case "5" {push @arr_5, $cnt;}
                else {print "error!";}
        }#end of switch
        $cnt++;

}
$ind_0 = &center(\@arr_0);
print "the center of the first cluster is: $ind_0\n";

$ind_1 = &center(\@arr_1);
print "the center of the second cluster is: $ind_1\n";

$ind_2 = &center(\@arr_2);
print "the center of the third cluster is: $ind_2\n";

$ind_3 = &center(\@arr_3);
print "the center of the four cluster is: $ind_3\n";

$ind_4 = &center(\@arr_4);
print "the center of the five cluster is: $ind_4\n";

$ind_5 = &center(\@arr_5);
print "the center of the six cluster is: $ind_5\n";

sub center (){
        $arr_ref = shift;
        @arr = @$arr_ref;
        @sum = ();

        foreach $traj (@arr){
                $sumrow = 0;
                foreach $neib (@arr){

                        $sumrow += $matrix[$traj][$neib];
                }
                push @sum, $sumrow;
        }
        $length = @sum;
        $max = -1;
        $max_ind = $arr[0];
        for ($i =0; $i<$length; $i++){
                if ($sum[$i] > $max) {$max = $sum[$i];$max_ind = $arr[$i];}
        }
        return $max_ind;

}

###############################################
#write the sequence of positions as coordinates forming one line
#output format: Y/N(center or not) clu_label&  23.845089,38.018470,0.000 (coordinates)
###############################################
open (OUT, ">:utf8", "Trajs_labeled.txt"); 

#$length = @arr_clu;
$id=1;
$num_line = @arr_clu;
print OUT "$num_line\n"; 

$line = $arr_clu[0]; 
$line =~ s/\n$//; 
$coordinates = "$line&";

print "$coordinates"; 
foreach $position (@arr_traj){
        $position =~ s/\n$//; 
	@temp = split (/\t/,$position);
	
	$tra_id = $temp[0];
	#print "$temp[1]"; 
	@temp2 = split (/;/,$temp[1]); 
        #print "$temp2[6]"; 
	if ($tra_id eq $id) { $coordinates =  $coordinates." "."$temp2[4]".","."$temp2[5]".","."0.000"; }
        else {
        	if ($id eq $ind_0 || $id eq $ind_1 || $id eq $ind_2 || $id eq $ind_3 || $id eq $ind_4 || $id eq $ind_5) {$coordinates = "Y"." ".$coordinates; }
		else {$coordinates = "N"." ".$coordinates;} 
		print OUT "$coordinates\n";
		
		#print "$coordinates\n";
		$tmp = $arr_clu[$id];
		$tmp =~ s/\n$//;
 		$coordinates = "$tmp&"; 
		$id++; 
		$coordinates = $coordinates." "."$temp2[4]".","."$temp2[5]".","."0.000";
		
	}
}
 if ($id eq $ind_0 || $id eq $ind_1 || $id eq $ind_2 || $id eq $ind_3 || $id eq $ind_4 || $id eq $ind_5) {$coordinates = "Y"." ".$coordinates; }
 else {$coordinates = "N"." ".$coordinates;}
 print OUT "$coordinates\n";

 #print "$coordinates\n";

