#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  TrajSplit.pl
#
#        USAGE:  ./TrajSplit.pl GPS trace data
#
#  DESCRIPTION:  The trajectory number is not correct, we need to manually identify trajectories from the GPS trace data, assuming data records having close timestamp being in one trajectory. The output shows the number of trajectories
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  11/29/2007 10:48:04 PM MST
#     REVISION:  ---
#===============================================================================
use diagnostics;
#use strict;
use warnings;
use HTTP::Date; 

$numArgs = $#ARGV + 1;
if ($numArgs != 3) {
	print "USAGE: First provide the trajectory file name, please also provide two parameters: Sigma_x and Sigma_y to specify the size of matching region\n";
	exit;
}
$sigma_x = $ARGV[1];
$sigma_y = $ARGV[2];


$file = $ARGV[0]; #GPS tracedata
open (RAWdata, $file) or die  "can not open";
#record contents {obj-id, traj-id, date(dd/mm/yyyy), time(hh:mm:ss), lat, lon, x, y}
#delimited by ";"

@records = <RAWdata>;

#initializing
@temp = split (/;/, $records[0]);#the first line
@diffdates = ();
$trajInd = $temp[0].$temp[1].$temp[2];
push @diffdates, $trajInd;

#put the trajectories into 2_D arrays
@trajs_x = ();  #array of trajectories
@trajs_y = (); 
@trajs_time = (); 


@traj_x = (); #array of coordinates belonging to one trajectory
@traj_y = (); 
@traj_time = (); 

foreach $record (@records){
        $record =~ s/\n$//;
	@temp = split (/;/, $record);
	
	$time= "$temp[2]"." "."$temp[3]";
	$time = str2time($time);
	
	$trajInd = $temp[0].$temp[1].$temp[2];
	#print "$trajInd\n";
	my @exists = grep(/^$trajInd$/, @diffdates);
	if (!@exists) {
		#foreach (@traj_x){print "$_\t"; }
		push @trajs_x, [ @traj_x ];
		push @trajs_y, [ @traj_y ];
		push @trajs_time, [ @traj_time ];
		
		@traj_x  = (); 
		@traj_y  = (); 
		@traj_time = (); 

		push @diffdates, $trajInd;
	}
	else {   
		push @traj_x, $temp[6];
		push @traj_y, $temp[7];
		push @traj_time, $time; 
		
	}
}
#the last trajectory

push @trajs_x, [ @traj_x ];
push @trajs_y, [ @traj_y ];
push @trajs_time, [ @traj_time ];

@traj_x  = (); 
@traj_y  = (); 
@traj_time = (); 


#$numb_traj= @trajs_x; 
#$numb_traj_2= @trajs_y; 
#$numb_traj_3= @trajs_time; 


$size = @diffdates;
print "$size\n";
#@temparr = @{$trajs_x[34]};
#foreach (@temparr){print "$_\t"; }
close (Rawdata);

$output ="sim.mat";
open (SIMOUT, ">:utf8",$output) or die "Can not open file!";

print SIMOUT "$size\n";

#compute the pairwise similarity and put them into a matrix, note that the matrix is symmetric
@SimMatrix =(); 
for ($tra_i=0;$tra_i<$size; $tra_i++){
	for ($tra_j=$tra_i;$tra_j<$size; $tra_j++){
		my $lcs = &LCS_length($trajs_x[$tra_i],$trajs_y[$tra_i],$trajs_x[$tra_j],$trajs_y[$tra_j]);#$trajs_y[$tra_j] is not an array but an array ref
		print "the lcs is $lcs\n";
		#normalizing
 		$i_len = @{$trajs_x[$tra_i]};
		$j_len = @{$trajs_x[$tra_j]};
                
                if ($i_len>0 && $j_len>0){
			$lcs = ($lcs**2/($i_len*$j_len))**0.5;
			$SimMatrix[$tra_i][$tra_j] = $lcs; # The matrix is symmetric M[i][j] = M[j][i] 
			$SimMatrix[$tra_j][$tra_i] = $lcs;
		}
		else {
			$SimMatrix[$tra_i][$tra_j] = 0; 
			$SimMatrix[$tra_j][$tra_i] = 0;
			#print "empty trajectory \n";
			#print SIMOUT "0\t";
		}
	}
	
	#print SIMOUT "\n";
}

#print the similarity matrix into output file
for (my $tra_i=0;$tra_i<$size; $tra_i++){
        for (my $tra_j=0;$tra_j<$size; $tra_j++){
		print SIMOUT "$SimMatrix[$tra_i][$tra_j]\t";
	}
 print SIMOUT "\n";
}
#free the space
@SimMatrix = (); 
close SIMOUT; 


#returns the bigger one among two numbers
sub maxAB(){
	my @records = sort { $a <=> $b } @_; 
        #print "$records[1]\n"; 
	return $records[1];
}

#checks if two positions can be viewed as a match, return 1 if YES; otherwise 0
sub equality (){#take four real numbers(coordinates of two positions) as parameters 
	  
	if (abs($_[0]-$_[2])<=$sigma_x && abs($_[1]-$_[3])<=$sigma_y){
		return 1;
	}
	else { return 0;}
}

#############The length of LCS###############
#the subroutine takes four arrays: trajs_x[i], trajs_y[i], trajs_x[j], trajs_x[j] as parameters 
#usage:&LCS_length(\@trajs_x[i], \@trajs_y[i], \@trajs_x[j], \@trajs_x[j]); 
sub LCS_length(){
	#initialize a 2_D array for dynamic programing required 
	@L = (); 
	@traj_i_x = @{$_[0]}; #array ref, the @ identifier is used to dereference the array ref
	@traj_i_y = @{$_[1]}; #array ref
	@traj_j_x = @{$_[2]}; #array ref
	@traj_j_y = @{$_[3]}; #array ref
	
	$length_i = @traj_i_x;
	$length_j = @traj_j_x;
	print "length_i and length_j: $length_i & $length_j\n"; 
	for ($i=0; $i<$length_i; $i++){ $L[$i][$length_j] = 0 ; }
	for ($j=0; $j<$length_j; $j++){ $L[$length_i][$j] = 0 ; }

	$L[$length_i][$length_j] = 0; #the matrix has the number of matches for the moment w
	for (my $i_ind = $length_i-1; $i_ind >= 0; $i_ind--){
		    for (my $j_ind = $length_j-1; $j_ind >= 0; $j_ind--)

		    {
			#if (($traj_i_x[$i_ind]==0) || ($traj_i_y[$i_ind] ==0) || ($traj_j_x[$j_ind]==0) || ($traj_j_y[$j_ind]==0)){
			#	$L[$i_ind][$j_ind] = 0;
			#}
			if (&equality($traj_i_x[$i_ind],$traj_i_y[$i_ind],$traj_j_x[$j_ind],$traj_j_y[$j_ind])) {
				$L[$i_ind][$j_ind] = 1 + $L[$i_ind+1][$j_ind+1];
 				#last; # here the loop should not be simply broken like this  upon a match, as the statement in else as below need to be executed for the rest of nonmatch
			}
			else {
				$L[$i_ind][$j_ind] = &maxAB($L[$i_ind+1][$j_ind], $L[$i_ind][$j_ind+1]);
			}
		    }
	}

	return $L[0][0];

	@L = (); 
        @traj_i_x = ();
	@traj_i_y = (); 
	@traj_j_x = ();
	@traj_j_y = (); 	
}#http://www.ics.uci.edu/~eppstein/161/960229.html
