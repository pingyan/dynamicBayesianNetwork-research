#!/usr/bin/perl 
#
#
$xmlfile = shift; 
$outpath = shift;
#$out2 = shift; 
#$out3 = shift;

open (IN, $xmlfile) or die  "can not open";
@lines = <IN>; 
close IN; 
open (OUT, ">:utf8",$outpath) or die  "can not open";

$path = "" ;
#@paths = ();
$start = 0; 
$point = 0; 
print OUT "Trip_ID\tLengthInFeet\tDurationInSeconds\tTotalAverageSpeed\n"; 
foreach $line (@lines){
	$line = &trim($line); 
	
	$trip_ID = ""; 
	if ($start eq 0 && $line =~ /TripID/){
		print "a new trip\n"; 
		$start = 1;
		@temp = split (/\s+/,$line);
		$trip_ID = $temp[1]."-".$temp[2];
		$trip_ID =~ s/TripID=\"//;
		$trip_ID =~ s/\"//;
		print "$trip_ID";
		print OUT "$trip_ID:\t"; 
	}
	if ($start eq 1 && $line =~ /<LengthInFeet/){
		$line =~ s/<LengthInFeet>//; 
		$line =~ s/<\/LengthInFeet>//;
		$LengthInFeet = $line; 
		print OUT "$LengthInFeet\t"; 
	}
 	if ($start eq 1 && $line =~ /<DurationInSeconds/){
                $line =~ s/<DurationInSeconds>//;
                $line =~ s/<\/DurationInSeconds>//;
                $DurationInSeconds = $line;
                print OUT "$DurationInSeconds\t";
        }
	if ($start eq 1 && $line =~ /<TotalAverageSpeed/){
                $line =~ s/<TotalAverageSpeed>//;
                $line =~ s/<\/TotalAverageSpeed>//;
                $TotalAverageSpeed = $line;
                print OUT "$TotalAverageSpeed\n";
	}


	if ($start eq 1 && $line =~ /<\/Trip/){
		$start = 0;
		#print OUT "$path\n";
		#push @paths, $path; 
		#$path = "";
		$trip_ID = "";

	}
}
 
close OUT; 
sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
