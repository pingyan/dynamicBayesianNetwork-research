#!/usr/bin/perl 
##
##
$upcMappedfile = shift; #stat file for every trip
$membership = shift; #cluster output
$target = shift;  
$spendingfile = shift; 
$num_clusters = shift;
$round_ind = shift;
 
##$out2 = shift; 
##$out3 = shift;
#
print "USAGE: perl support.pl UPC_mapped0 Sim_training0.clustering.4 testing_UPC_Mapped0 clusterProfileSpending.0.4 num_clusters round_ind\n"; 
open (IN, $upcMappedfile) or die  "can not open";
( @lines) = <IN>; 
#
close IN; 
open (IN2, $membership) or die  "can not open";
@membership = <IN2>;
close IN2;
#
open (IN3, $target) or die  "can not open";
@targets = <IN3>;
close IN3;

open (IN4, $spendingfile) or die  "can not open";
@spendings = <IN4>;
close IN4;

$outfilename = "hitRates.".$round_ind.".".$num_clusters;
#
open (OUT, ">:utf8", $outfilename) or die  "can not open";
#################################################
#################compute product support #########

my %hash_all = ();
for (my $i=0; $i<$num_clusters; $i++){
	my %hash_A = ();
	$hash_all{$i} =\%hash_A;
}
#$line = "18133639_2008-05-03-12:13:29.000:       PRODUCE GROCERY DAIRY";
my $ind = 0;
foreach my $line (@lines){
	my  $cluster = $membership[$ind++];
	$cluster = &trim($cluster); 
	print "$cluster\n"; 
        my $hash_A_ref = $hash_all{$cluster};
        $line = &trim($line); #18133639_2008-05-03-12:13:29.000:       PRODUCE GROCERY DAIRY
	#print "$line\n"; 
	my @line_split = split (/\t/,$line);
	my $size = @line_split; 
	#print "size is $size\n"; 
	for (my $i =1; $i<$size-1;$i++){
		#print "i is $i\n";
		my $item = $line_split[$i]; 
		#print "the item is $item\n"; 
		if (exists $hash_A_ref->{$item}){next; }
		else {
			my %hash_new = ();
			$hash_A_ref->{$item}=\%hash_new;
		}	
	}

	 for (my $i =1; $i<$size-1;$i++){
	                 #print "i is $i\n";
			 my $item = $line_split[$i];
	
 	   my $hash_B_ref =  $hash_A_ref->{$item};
           for (my $j = $i+1; $j<$size; $j++){      
	 my   $item_B = $line_split[$j];
	 #print "item_B $item_B\n"; 
         if (exists $hash_B_ref->{$item_B}){
          $hash_B_ref->{$item_B}=$hash_B_ref->{$item_B}+1; 
	  #print "$hash_B_ref->{$item_B}\n";	
	  }									          
          else{
        $hash_B_ref->{$item_B}=1; 
	#print "$hash_B_ref->{$item_B}\n"; 
	}
	}
    $hash_A_ref->{$item} = $hash_B_ref; 
     }
     #print "$hash_A_ref->{'PRODUCE'}->{'GROCERY'}\n";
     $hash_all{$cluster} = $hash_A_ref;
 }
#my $testitem = "PRODUCE";
#my $testcluster = 1;

#  my $hash_ref = $hash_all{'1'}->{'PRODUCE'};
 
#  foreach $key (sort {$hash_ref->{$b}<=>$hash_ref->{$a} } keys(%$hash_ref)){
#                 $temp = $hash_ref->{$key};
		 #print  "support $key\t$temp\n";
#  }

##################################################################
################compute Hit rates #################################

$pathfilename = "testing_paths".$round_ind; 
open (IN6, $pathfilename) or die  "can not open";
( @pathslines) = <IN6>; 
close IN6;

for (my $i =1; $i<5; $i++){
  &hitRate($i);
}


sub hitRate(){
my $seg = shift; 
my $seg_25 = 25*$seg; 
$clusterfilename = "cluster".$seg_25.".".$round_ind.".".$num_clusters;
open (IN5, $clusterfilename) or die  "can not open";
( @clusterlines) = <IN5>; 
close IN5;

my $ind = 0; 
foreach my $test (@targets){
  my @purchasedSet = split (/\t/,$test);
  splice(@purchasedSet, 0, 1);
  my $size_purchase = @purchasedSet;
  
  my $cluster = $clusterlines[$ind];
  my $path = $pathslines[$ind++]; #path by zone ids
  my @path_split = split (/\s+/, $path);
  my $path_len = @path_split; #path length
  my $num_2_recom = int($path_len/10); # every 30 steps, we're gonna recommend 3 items. The trip's length range from 100 to 6, 7 hundrends steps  
  
  my %recom_hash = ();# put all the recommended items to a hash
  #for each path segment, if an item is already bought, two items of the highest association support will be recommended  
  my $bought = int($seg*$size_purchase/4);
  if ($bought > 0 ){
    for (my $i=0; $i<$bought; $i++){
      $bought_pro = $purchasedSet[$i];
      ($asso_1, $asso_2) = &two_Associated($cluster, $bought_pro);
      $recom_hash{$asso_1}=1;
      $recom_hash{$asso_2}=1;      
    }
  }
  #recommend based on the top product categories in the cluster 
  my $temp_size = scalar keys( %recom_hash );
    # have to know what product is purchased  
  my $spending = $spendings[2*$cluster]; #the top purchased products
  my @spending_split = split(/\t/,$spending);
  
    for (my $i=$temp_size;$i<$num_2_recom; $i++ ){
    my $item = $spending_split[$i-$temp_size];
    $recom_hash{$item} = 1; 
  }
  
  $count = 0; #number of items in both the purchase set and the recommendation set
  foreach my $item (@purchasedSet){
    if (exists $recom_hash{$item}){
      $count++; 
    }
  }
  print "count is $count\n";
  if ($size_purchase == 0) {
    print "empty basket!";
    next; } 
  else{ 
    $hitRate =$count/$size_purchase; 
    print "hitRate is $hitRate\n";  #hitRate for one path
  }
 } #end for each target
 
}#end of subroutine

sub two_Associated(){
  my $cluster = shift; 
  my $pro = shift; 
  my $hash_ref = $hash_all{$cluster}->{$pro};
  my @recom = ();
  foreach $key (sort {$hash_ref->{$b}<=>$hash_ref->{$a} } keys(%$hash_ref)){
  #                 $temp = $hash_ref->{$key};
		 push @recom, $key;
  }
  return $recom[0], $recom[1];
}
    
sub trim($) {
    my $string = shift;
           $string =~ s/^\s+//;
	       $string =~ s/\s+$//;
	           return $string;
		   }
