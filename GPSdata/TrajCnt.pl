#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  TrajCnt.pl
#
#        USAGE:  ./TrajCnt.pl GPS trace data
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

#use strict;
use warnings;

$file = shift; #GPS tracedata
open (RAWdata, $file) or die  "can not open";
#record contents {obj-id, traj-id, date(dd/mm/yyyy), time(hh:mm:ss), lat, lon, x, y}
#delimited by ";"

@records = <RAWdata>;
@diffdates = ();

$traj_id = 0; 

open (OUT, ">:utf8", "Trajs_trucks.txt");
foreach $record (@records){
	@temp = split (/;/, $record);
        $trajInd = $temp[0].$temp[1].$temp[2];
        #print OUT "$traj_id\t$record";

        my @exists = grep(/^$trajInd$/, @diffdates);
        if (!@exists) {
		push @diffdates, $trajInd;
		$traj_id++; 
		
	}
	print OUT "$traj_id\t$record";
 

}
$size = @diffdates;
print "$size";

