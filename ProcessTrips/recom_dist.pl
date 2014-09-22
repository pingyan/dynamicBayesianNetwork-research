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

$DijkstraDistfile  = "baseDijkstra.dat"; 
open (IN0, $DijkstraDistfile) or die  "can not open";
( @lines) = <IN0>;
close IN0;
my %H =(); 

foreach $line (@lines){
	my @nodes =split(/\t/,$line);
	my $node_1 = $nodes[0];
	my $node_2 = $nodes[1];
	my $value = $nodes[2];
	if (exists $H{$node_1}) {
		my $H_2_temp = $H{$node_1};
		if (!exists $H_2_temp->{$node_2} ){
			 $H_2_temp->{$node_2} = $value;
		}
	}
	else {
		my %H_2=();
		$H_2{$node_2} = $value;
		$H{$node_1} = \%H_2; 
	}
}

print "$H{5}->{13}";

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
  my $member = &trim($member);
  my $temp = $clusters[$member]; #array of path belong to one cluster 
  my $path = $trainlines[$ind++]; 
  push @{$temp}, $path; 
  $clusters[$member] = $temp;
}
#print $clusters[0][0];
#open (OUT, ">:utf8", "clusterProfiles.txt") or die  "can not open";
#
my $outfilename = "cluster_dist_25.".$round_ind.".".$way;
open (OUT25, ">:utf8",$outfilename) or die  "can not open";
my $simfilename = "sim_dist_25.".$round_ind.".".$way;
open (SIM25, ">:utf8",$simfilename) or die  "can not open";


foreach my $testpath (@testlines){
	my $testpath = &trim($testpath); 
	my @temp = split (/\s+/, $testpath);
	my $size = @temp; 
	if ($size <4){print "too short!\n"; next;}
	my @path25= @{&partialPath($size, 1, \@temp)};
	#print "partial path 25 is @path25\n"; 
	(my $cluster, my $mysims_ref) = &findCluster(\@path25);
        my @mysims = @{$mysims_ref};
        foreach $mysim (@mysims){
                print SIM25 "$mysim\t";
		}
	print SIM25 "\n";

	print OUT25 $cluster;
	print OUT25 "\n";
	#close OUT25;
  	#print "cluster is $cluster\n";
}
close OUT25;
close SIM25; 

my $outfilename = "cluster_dist_50.".$round_ind.".".$way;
open (OUT50, ">:utf8",$outfilename) or die  "can not open";
my $simfilename = "sim_dist_50.".$round_ind.".".$way;
open (SIM50, ">:utf8",$simfilename) or die  "can not open";

foreach my $testpath (@testlines){
	#print "$testpath\n"; 
	my @sims = ();
	my $testpath = &trim($testpath); 
	my	@temp = split (/\s+/, $testpath);
	my $size = @temp; 
	if ($size <4){print "too short!\n"; next;}
	my @path50= @{&partialPath($size, 2, \@temp)};
        #print "partial path 50 is @path50\n";
	(my $cluster,my $mysims_ref) = &findCluster(\@path50);
	
	@mysims = @{$mysims_ref};
	
	foreach $mysim (@mysims){
       		print SIM50 "$mysim\t";
        }
	print SIM50 "\n";

	
	print OUT50 $cluster;
	print OUT50 "\n";
	#print "cluster is $cluster\n";

}
close OUT50;
close SIM50;

my $outfilename = "cluster_dist_75.".$round_ind.".".$way;
open (OUT75, ">:utf8",$outfilename) or die  "can not open";
my $simfilename = "sim_dist_75.".$round_ind.".".$way;
open (SIM75, ">:utf8",$simfilename) or die  "can not open";

foreach my $testpath (@testlines){
	#print "$testpath\n"; 
	my @mysims =();
	my $testpath = &trim($testpath); 
	my @temp = split (/\s+/, $testpath);
	my $size = @temp; 
	if ($size <4){print "too short!\n"; next;}
	my @path75 =@{&partialPath($size, 3, \@temp)};
	#print "partial path 75 is @path75\n"; 

	(my $cluster, my $mysims_ref) = &findCluster(\@path75);
	@mysims = @{$mysims_ref};
	foreach $mysim (@mysims){
	      print SIM75 "$mysim\t";
	}
	print SIM75 "\n";
	
	print OUT75 $cluster;
	print OUT75 "\n";
	#print "cluster is $cluster\n";

}
close OUT75;
close SIM75;

my $outfilename = "cluster_dist_100.".$round_ind.".".$way;
open (OUT100, ">:utf8",$outfilename) or die  "can not open";
my $simfilename = "sim_dist_100.".$round_ind.".".$way;
open (SIM100, ">:utf8",$simfilename) or die  "can not open";
foreach my $testpath (@testlines){
	#print "$testpath\n"; 
	my @mysims =();
	my $testpath = &trim($testpath); 
	my @temp = split (/\s+/, $testpath);
	#print "whole paht is @temp\n"; 
	my $size = @temp; 
	(my $cluster, my $mysims_ref)= &findCluster(\@temp);
	@mysims = @{$mysims_ref};
	foreach $mysim (@mysims){
		print SIM100 "$mysim\t";
	}
	print SIM100 "\n";
	 print OUT100 $cluster;
	 print OUT100 "\n";
	 #print "cluster is $cluster\n";


}
close OUT100;
close SIM100;


sub findCluster(){
  my @sims = (); 
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
    ($sim,$sims_ref) = &simSum($testpath, $setofPaths);
    $sim = $sim/$size; 
    #print "$sim\n";
    
    if ($sim > $simMax){
      $simMax = $sim; 
      $targetCluster = $i;
      @sims = @{$sims_ref};
    }   
  } 
  return ($targetCluster, \@sims);
}
sub simSum {
  my @sims_temp = ();
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
    push @sims_temp, $sim; 
    #print "sim $sim\n"; 
    $simSum = $simSum +$sim; 
  }
  return ($simSum, \@sims_temp);
}

sub partialPath(){
	my $size = shift;
	my $ind = shift;
	my $array_ref = shift; 
	my $end = int($size*($ind/4));
	my @new = ();
	for ($i =0; $i<$end; $i++){
		push @new, $array_ref->[$i];
	}
	return \@new; 
}

sub Sim(){

        $patha = shift;
        $pathb = shift; 
	#print "LCSlen $LCSlen\n"; 
        my @patha = @{$patha};
        my @pathb = @{$pathb};
	%count = ();
        my $len_l = @patha; 
        my $len_s = @pathb;
	#my $len_s = $len_b;
	#my $len_l = $len_a;
	if ($len_l < $len_s){
		$len_tmp = $len_l; 
		$len_l = $len_s;
		$len_s = $len_tmp;
		@temp = @patha;
		@patha = @pathb;
		@pathb = @temp;
	}
	my $dist = 0;
	my $times = 0;
	if ($len_s>0){
	     $times = int($len_l/$len_s);}
        for (my $i=0; $i< $len_s; $i++ ){
	     $l_ind = $i*$times;
	     $pos_l = $patha[$l_ind];
	     $pos_s = $pathb[$i];
	     $dist = $dist + $H{$pos_l}->{$pos_s};
	}
	my $sim = 0; 
        if ($dist >0){
		$sim = 100* (1/$dist); 
	}
        else {$sim = 1; }
	#print "sim $sim\n";
        return $sim;
}
 
=comment
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
=cut
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
