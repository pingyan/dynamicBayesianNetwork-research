#/usr/bin/perl 
#extract information from Segment: speed last point to current point, and speed current point to next point
#
$xmlfile = shift; 
$outpath = shift;
$out2 = shift; # file recording segment durations
#$out3 = shift;

open (IN, $xmlfile) or die  "can not open";
@lines = <IN>; 
close IN; 
open (OUT, ">:utf8",$outpath) or die  "can not open";
#open (OUT2, ">:utf8",$out2) or die  "can not open";
$path = "" ;
#@paths = ();
$start = 0; 
$segment = 0; 
$num_segments = 0; 

foreach $line (@lines){
	$line = &trim($line); 
	
	$trip_ID = ""; 
	if ($start eq 0 && $line =~ /TripID/){
		print "a new trip\n"; 
		$start = 1;
		@all_UPCs= "" ;
    @all_PointID = "";
		$num_segments = 0;
		@temp = split (/\s+/,$line);
		$trip_ID =  $temp[1]."-".$temp[2]; 
		$trip_ID =~ s/TripID=\"//;
		$trip_ID =~ s/\"//;
	  
	
		print "$trip_ID";
		print OUT "$trip_ID: "; 
#		print OUT2 "$trip_ID: ";
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
		
		push @all_PointID, $pointID; 
		push @all_UPCs, $UPC;
    print OUT2 "$UPC\t"; 
		next;
	}

	if ($pickup eq 1 && $line =~ /<\/ItemPickup>/){
		  
		  $pickup=0;
		   
	}
  if 	
  if ($start eq 1 && $line =~ /<\/Trip/){
		$start = 0;

		print OUT2 "\n"; 
		print OUT "map "$_\n", keys %{ {map {$_ => 1} @all_UPCs} }";
		$trip_ID = "";
		@all_UPCs= "" ;
    @all_PointID = "";


	}
}
 
	if ($start eq 1 && $line =~ /<Segment/){
		$segment = 1; 
		$num_segments++; 

	}
        if ($segment eq 1 &&  $line =~ /<SegDurationInSeconds/){
                $line =~ s/<SegDurationInSeconds>//;
                $line =~ s/<\/SegDurationInSeconds>//;
                $segduration = $line;
                #$segment = 0;
		print OUT2 "$segduration,";
	}
	if ($segment eq 1 &&  $line =~ /<Speed/){
		$line =~ s/<Speed>//;
		$line =~ s/<\/Speed>//;
		$x = $line; 
		$segment = 0;
		$path = $path.$x.","; 
		#print "$path\n";

	}
	if ($start eq 1 && $line =~ /<\/Trip/){
		$start = 0;
		print OUT "$path\n";
		print OUT2 "\n"; 
		#push @paths, $path; 
		$path = "";
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
