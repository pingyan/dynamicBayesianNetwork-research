#!/usr/bin/perl 
# INPUT: the cluster label of each partial path in the testing set;  
# also given the cluster labels of each path in the training set,  
# the similaritie between testing path and training path belonging to the same cluster are computed

print "SAMPLE USAGE: perl sims.pl round_ind num_cluster\n"; 
$round_ind = shift; 
$num_cluster = shift; 

$testpathfile = "testing_paths".$round_ind; #stat file for every trip
$trainpathfile = "training_paths".$round_ind;
$traincluster = "Sim_training".$round_ind.".clustering.".$num_cluster;
$sim100File ="Sim.mat.0.5";

open (IN4, $sim100File) or die  "can not open";
($header, @sim100) = <IN4>;
close IN4;

my @tosplice = @sim100;
#open (OUT2, ">:utf8",$testfilename) or die  "can not open";
$ind = $round_ind;
while ($ind <843-84){
	splice (@tosplice, $ind, 1);
	$ind = 10+$ind-1;
}
@sim_matrix =();
foreach my $line (@tosplice){
	@allsims = split(/\s+/,$line);
        push @sim_matrix, [@allsims];
}
print "sim_matrix[0][1] $sim_matrix[0][1] \n";

open (IN, $testpathfile) or die  "can not open";
( @testlines) = <IN>; 
close IN; 

open (IN1, $trainpathfile) or die  "can not open";
( @trainlines) = <IN1>;
close IN1;

open (IN3, $traincluster) or die  "can not open";
( @trainclusters) = <IN3>;
close IN3;

my $membershipFile = "cluster100".".".$round_ind.".".$num_cluster;
open (IN5, $membershipFile) or die  "can not open";
my @membership = <IN5>;
close IN5;



@indexes =();
@clusters = (); #array of arrays, each element is one cluster, each cluster contains paths
for ($i=0; $i < $num_cluster; $i++){
  @cluster = ();
  @index = (); 
  push @clusters, [@cluster];
  push @indexes, [@index];
}

my $ind =0; 
foreach $trainmember (@trainclusters){
  my $trainmember = &trim($trainmember);
  my $temp = $clusters[$trainmember]; #array of path belong to one cluster 
  my $temp_ind = $indexes[$trainmember];
  my $path = $trainlines[$ind++]; 
  push @{$temp_ind}, $ind;
  push @{$temp}, $path; 
  $clusters[$trainmember] = $temp;
  $indexes[$trainmember] = $temp_ind; 
}
$num_paths = @testlines;
my $outfilename = "sim100.".$round_ind.".".$num_cluster;
open (OUT, ">:utf8",$outfilename) or die  "can not open";
for (my $j=0; $j<$num_paths; $j++){
	#my @sim100 = ();
	my $cluster_member = $membership[$j];
   	my $setofindexes = $indexes[$cluster_member];
  	my @setIndexes = @{$setofindexes};
        my $test_ind = $j*10+$round_ind;
	foreach $myindex  (@setIndexes){
		my $mysim = $sim_matrix[$myindex][$test_ind];
		print OUT "$mysim\t";
	}
	print OUT "\n"; 
}


for (my $i=1; $i<4; $i++){
	my $parts = $i*25;
        my $membershipFile = "cluster".$parts.".".$round_ind.".".$num_cluster;
	open (IN2, $membershipFile) or die  "can not open";
	my @membership = <IN2>;
	close IN2;
	
  	my $outfilename = "sim".$parts.".".$round_ind.".".$num_cluster;
	open (OUT, ">:utf8",$outfilename) or die  "can not open";


	for (my $j=0; $j<$num_paths; $j++){
		my $testpath = $testlines[$j];
		my $testpath = &trim($testpath); 
		my @temp = split (/\s+/, $testpath);
		my $size = @temp;
		if ($size <4){print "too short!\n"; next;}
		#my @partial_path= @{&partialPath($size, $i, \@temp)};
		my $partial_path= &partialPath($size, $i, \@temp);
		my $cluster_member = $membership[$j];
		my $setofPaths = $clusters[$cluster_member];
		    #print "$setofPaths \n"; 
		my @setPaths = @{$setofPaths};
    		my $size =  @setPaths; 
    		if ($size <1){
    	 	print "invalid cluster size!\n";
	     		last; 
	  	}
    		foreach my $path (@setPaths){
        		my $path = &trim($path);
		        my @path_arr = split (/\s+/,$path);
			my $path_ref = \@path_arr;
		        my $sim = &Sim($partial_path, $path_ref);
		        print OUT "$sim\t";
		}#end of each pair of path comparison   
		print OUT "\n"; 
	}#end j from 0 to 85

	close OUT; 
}#end i from 1 to 5
    

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
