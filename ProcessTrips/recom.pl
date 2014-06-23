#!/usr/bin/perl 
#
#
$testpathfile = shift; #stat file for every trip
$trainpathfile = shift; 
$membership = shift; #cluster output 
$num_clusters = shift; 
#$out2 = shift; 
#$out3 = shift;
$round_ind = shift;
$way = $num_clusters; #how many clusters

print "SAMPLE USAGE: perl recom.pl testing_paths0 training_paths0 Sim_training0.clustering.4 4 0\n"; 
open (IN, $testpathfile) or die  "can not open";
( @testlines) = <IN>; 
close IN; 

open (IN1, $trainpathfile) or die  "can not open";
( @trainlines) = <IN1>;
close IN1;

open (IN2, $membership) or die  "can not open";
@membership = <IN2>;
close IN2;

@clusters = (); #array of arrays, each element is one cluster, each cluster contains paths
for ($i=0; $i < $num_clusters; $i++){
  @cluster = ();
  push @clusters, [@cluster];
}
my $ind =0; 
foreach $member (@membership){
  $member = &trim($member);
  $temp = $clusters[$member]; #array of path belong to one cluster 
  my $path = $trainlines[$ind++]; 
  push @{$temp}, $path; 
  $clusters[$member] = $temp;
}
#print $clusters[0][0];
#open (OUT, ">:utf8", "clusterProfiles.txt") or die  "can not open";
#
my $outfilename = "cluster25.".$round_ind.".".$way;
open (OUT25, ">:utf8",$outfilename) or die  "can not open";

foreach $testpath (@testlines){
	#print "$testpath\n"; 
	$testpath = &trim($testpath); 
	@temp = split (/\s+/, $testpath);
	$size = @temp; 
	if ($size <4){print "too short!\n"; next;}
	@path25= @{&partialPath($size, 1, \@temp)};

	my $cluster = &findCluster(\@path25);
	print OUT25 $cluster;
	print OUT25 "\n";
	#close OUT25;
  	print "cluster is $cluster\n";
}
close OUT25;

my $outfilename = "cluster50.".$round_ind.".".$way;
open (OUT50, ">:utf8",$outfilename) or die  "can not open";


foreach $testpath (@testlines){
	#print "$testpath\n"; 
	$testpath = &trim($testpath); 
	@temp = split (/\s+/, $testpath);
	$size = @temp; 
	if ($size <4){print "too short!\n"; next;}
	@path50= @{&partialPath($size, 2, \@temp)};
        #print "partial path is @path25\n";
	my $cluster = &findCluster(\@path50);
	print OUT50 $cluster;
	print OUT50 "\n";
	print "cluster is $cluster\n";

}
close OUT50;

my $outfilename = "cluster75.".$round_ind.".".$way;
open (OUT75, ">:utf8",$outfilename) or die  "can not open";

foreach $testpath (@testlines){
	#print "$testpath\n"; 
	$testpath = &trim($testpath); 
	@temp = split (/\s+/, $testpath);
	$size = @temp; 
	if ($size <4){print "too short!\n"; next;}
	@path75 =@{&partialPath($size, 3, \@temp)};
#	print "partial path is @path25\n"; 

	my $cluster = &findCluster(\@path75);
	print OUT75 $cluster;
	print OUT75 "\n";
	print "cluster is $cluster\n";

}
close OUT75;

my $outfilename = "cluster100.".$round_ind.".".$way;
open (OUT100, ">:utf8",$outfilename) or die  "can not open";
foreach $testpath (@testlines){
	#print "$testpath\n"; 
	$testpath = &trim($testpath); 
	@temp = split (/\s+/, $testpath);
	$size = @temp; 
	my $cluster = &findCluster(\@temp);
	 print OUT100 $cluster;
	 print OUT100 "\n";
	 print "cluster is $cluster\n";


}
close OUT100;


sub findCluster(){
  $testpath = shift;
  $targetCluster = 0; 
  $simMax = 0;
  for (my $i =0; $i< $num_clusters; $i++){
    $setofPaths = $clusters[$i];
    #print "$setofPaths \n"; 
   my @setPaths = @{$setofPaths};
   my    $size =  @setPaths; 
   if ($size <1){
   	print "invalid cluster size!\n";
	last; 
	}
#	print "size is $size\n"; 
    $sim = &simSum($testpath, $setofPaths);
    $sim = $sim/$size; 
    #print "$sim\n";
    
    if ($sim > $simMax){
      $simMax = $sim; 
      $targetCluster = $i;
    }   
  } 
  return $targetCluster;
}
sub simSum {
  my $testpath = shift;
  my $paths = shift;
  @setofPaths = @{$paths};
#  print "@setofPaths \n";
  my  $simSum = 0; 
  foreach $path (@setofPaths){
    $path = &trim($path);
    @path_arr = split (/\s+/,$path);
    $path_ref = \@path_arr;
    my $sim = &Sim($testpath, $path_ref);
    #print "sim $sim\n"; 
    $simSum = $simSum +$sim; 
  }
  return $simSum;
}

sub partialPath(){
	my $size = shift;
	my $ind = shift;
	my $array_ref = shift; 
	my $end = int($size*($ind/4));
	for ($i =0; $i<$end; $i++){
		push @new, $array_ref->[$i];
	}
	return \@new; 
}

sub Sim(){
        $patha = shift;
        $pathb = shift; 
        my $LCSlen = &LCS($patha, $pathb);
	#print "LCSlen $LCSlen\n"; 
        my @patha = @{$patha};
        my @pathb = @{$pathb};
        my $len_a = @patha; 
        my $len_b = @pathb;
	my $sim = 0; 
        if  (($len_a>0) && ($len_b >0)){
           $sim = ($LCSlen**2/($len_a*$len_b))**0.5;
        }
        else {$sim = 0; }
	#print "sim $sim\n";
        return $sim;
}
sub LCS(){
        $seq1 =shift;
        $seq2 =shift;
        @path1 = @{$seq1};
        @path2 = @{$seq2};
        $len_1 = @path1;
        $len_2 = @path2;
        @L =(); 
        for(my $i = 0; $i<$len_1+1 ; $i++){
          my @row = (); 
          for ($j = 0; $j <$len_2+1 ; $j++){
            push @row, 0; 
          }
          push @L, [@row]; 
        }
	#print $L[0][0];
        for (my $i = $len_1-1; $i>-1; $i--){
          for (my $j = $len_2-1; $j>-1; $j--){
            $temp = &equal($path1[$i],$path2[$j]);
            if ($temp == 1){
              $L[$i][$j] =$L[$i+1][$j+1]+1; 
            }  
            elsif ($temp == 0.5){
              $L[$i][$j]= &maxAB($temp+$L[$i+1][$j+1],&maxAB($L[$i+1][$j], $L[$i][$j+1]));
            
            }
            else {
              $L[$i][$j]= &maxAB($L[$i+1][$j], $L[$i][$j+1]);
            }
          }
        }
  return $L[0][0];        
}

sub maxAB(){
        $int1 = shift; 
        $int2 = shift;
        if ($int1>$int2){
                return $int1;
        }
        else{
                return $int2;
        }
}
sub equal(){
        $char1 = shift; 
        $char2 = shift; 
        my $m = 0;
        if ($char1 eq $char2){
                $m = 1;
	}
        else{
                $m = 0;
                }
        return $m;
}


sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
