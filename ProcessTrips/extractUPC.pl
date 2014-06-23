#!/usr/bin/perl 
#
#
$xmlfile = shift; 
#$outpath = shift;# the file also show total number of purchases, and duration while picking up items
$UPCfile = shift;#shows the location of item pickup 
$UPC_trip_file  = shift; 
#$out2 = shift; 
#$out3 = shift;

print "USAGE: perl extractUPC.pl trips.xml UPC_unique.dat UPC_trip.dat"; 
open (IN, $xmlfile) or die  "can not open";
@lines = <IN>; 
close IN; 
open (OUT, ">:utf8",$UPCfile) or die  "can not open";
open (OUT2, ">:utf8",$UPC_trip_file) or die "can not open";

@all_UPCs= "" ;
@all_PointID = "";
$num_items = 0; 
#@paths = ();
$start = 0; 

foreach $line (@lines){
	$line = &trim($line); 
	$trip_ID = ""; 
	if ($start eq 0 && $line =~ /TripID/){
#		print "a new trip\n"; 
		$start = 1;
		@temp = split (/\s+/,$line);
		$trip_ID = $temp[1]."-".$temp[2];
		$trip_ID =~ s/TripID=\"//;
		$trip_ID =~ s/\"//;
		#print OUT "$trip_ID:\t"; 
		print OUT2 "$trip_ID:\t";
	}
	if ($start eq 1 && $line =~ /ItemPickups/){
		$pickup = 1;
	}
	if ($pickup eq 1 && $line =~/<ItemPickup/){
		@temp =split (/UPC=\"/,$line );
		$temp2 = $temp[1];
		@temp3 = split (/\"/,$temp2);
		$UPC= $temp3[0];
		$PointIDstring = $temp3[1];
		@temp =split (/PointID=\"/,$PointIDstring);
		$temp2 = $temp[1];
		@temp3 = split (/\"/,$temp2);
		$pointID= $temp3[0];
		push @all_UPCs, $UPC;
		push @all_PointID, $pointID; 
    print OUT2 "$UPC\t"; 
		next;
	}

	if ($pickup eq 1 && $line =~ /<\/ItemPickup>/){
		  $pickup=0;
		   
	}
	
	
	if ($start eq 1 && $line =~ /<\/Trip/){
		$start = 0;
		print OUT2 "\n"; 
		print OUT "map "$_\n", keys %{ {map {$_ => 1} @all_UPCs} }";
		$trip_ID = "";

	}
}
 
close OUT; 
close OUT2; 
sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
