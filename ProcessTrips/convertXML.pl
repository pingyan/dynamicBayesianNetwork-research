#!/usr/bin/perl
$xmlfile = shift; 
$outpath = shift;

open (IN, $xmlfile) or die  "can not open";
@lines = <IN>; 
close IN; 
open (OUT, ">:utf8",$outpath) or die  "can not open";
$path = "" ;
#@paths = ();
$start = 0; 
$segment = 0; 
$num_segments = 0; 
$trip_flag = 1;
$points_flag =0; 
$segs_flag =0; 
$print_flag = 0;
    

foreach $line (@lines){
	#$line = &trim($line); 
	
	$trip_ID = ""; 
	if ($line =~ /<Points>/){
    $trip_flag = 0;
    $print_flag = 0;
    $points_flag = 1;
    $point_flag = 0;
    @points = ();      
  }
  if ($line =~ /<\/Points>/){
    $points_flag = 0;
  }
  if ($line =~ /<Segments>/){
    $segs_flag = 1;
    $seg_flag = 0;
    @segs = (); 
  }
  if ($line =~ /<\/Segments>/){
    $segs_flag = 0; 
  }
  
  if ($trip_flag eq 1){
    print OUT "$line";
  }
  if ($line =~ /<\/Trip>/){
    $trip_flag = 1;
    $print_flag = 1;
  }
  if ($print_flag eq 1){
    $size_points = @points; 
    $size_segs = @segs;
    $print_flag = 0;
          
      for ($ind = 0; $ind <$size_segs; $ind++){
      
        print OUT "<newPoint>\n";
        print OUT "$points[$ind]";
        print OUT "$segs[$ind]"; 
        print OUT "<\/newPoint>\n";
      
      }
    
  }
  if ($points_flag eq 1){
    if ($line =~ /<Point /){
  	    
  		$string = "";  
  		
      $point_flag = 1; 
    }
  	if ($point_flag eq 1 ){
      if ($line =~/<\/Point>/){
        $point_flag = 0; 
        $string = $string."<\/Point>\n";
        push @points, $string;     
        $string = ""; 
      }
      else {
        $string = $string."$line";
      }
    }
  }
  if ($segs_flag eq 1){
    if ($line =~ /<Segment/){
  	  $string = "";  
  		
      $seg_flag = 1; 
    }
  	if ($seg_flag eq 1 ){
      if ($line =~/<\/Segment>/){
        $seg_flag = 0; 
        $string = $string."<\/Segment>\n";
        push @segs, $string;     
        $string = ""; 
      }
      else {
        $string = $string."$line";
      }
    }
  }#$segs_flag eq 1
}
 
	
 
close OUT; 

sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

