#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  FindCenter.pl
#
#        USAGE:  ./FindCenter.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  12/18/2007 04:27:24 PM MST
#     REVISION:  ---
#===============================================================================

#use strict;
use warnings;
use diagnostics; 
use Switch; 

$file =shift;
open (SIMM, $file);

($num_line,@simm) = <SIMM>; 
close SIMM; 

#read similarities
@matrix = (); 
foreach $row (@simm) {

	my @tmp = split (/\s+/,$row); 
	push @matrix, [@tmp]; 
}
print "sim is $matrix[100][100]\n";

$filecluster = shift; 

open (CLUS, $filecluster);

@cluster = <CLUS>;
close CLUS;

$cnt = 0; 
#each array has the trajectory ids belonging to the corresponding cluster
foreach $item (@cluster){
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
print "the center of the first cluster is: $ind_1\n";

$ind_3 = &center(\@arr_3);
print "the center of the first cluster is: $ind_3\n";


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




