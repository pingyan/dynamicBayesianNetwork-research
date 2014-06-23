#!/usr/bin/perl 
##
##
print "USAGE: perl support_wo_new.pl round_ind num_cluster\n"; 

$round_ind = shift;
$num_cluster = shift; 

$trainupcMappedfile = "training_UPC_mapped_new".$round_ind; #stat file for every trip
$testupcMappedfile  = "testing_UPC_Mapped_new".$round_ind; #cluster output
$traincluster = "Sim_training".$round_ind.".clustering.".$num_cluster;
#
open (IN1, $trainupcMappedfile) or die  "can not open";
@trainupcMappedlines = <IN1>;
close IN1;

open (IN2, $testupcMappedfile) or die  "can not open";
@testupcMappedlines = <IN2>;
close IN2;

open (IN3, $traincluster) or die  "can not open";
( @trainclusters) = <IN3>;
close IN3;


@clusters = (); #array of arrays, each element is one cluster, each cluster contains transactions
for ($i=0; $i < $num_cluster; $i++){ #initialization
  @cluster = ();
  push @clusters, [@cluster];
}

my $ind =0;
#give the cluster labels of each training trip, they (transactions of each trip) are put into their corresponding groups 
foreach $trainmember (@trainclusters){
  my $trainmember = &trim($trainmember);
  my $temp = $clusters[$trainmember]; #array of path belong to one cluster 
  my $upc = $trainupcMappedlines[$ind++]; 
  $upc = &trim($upc); 
  push @{$temp}, $upc; 
  
  $clusters[$trainmember] = $temp;
}


##################################################################
################compute Hit rates #################################

$pathfilename = "testing_paths".$round_ind; #used to learn the length of each trip, and number of products to recommend 
open (IN6, $pathfilename) or die  "can not open";
( @pathslines) = <IN6>; 
close IN6;

for (my $i =1; $i<5; $i++){
  &hitRate($i);
}

sub hitRate(){
my $seg = shift; 
my $seg_25 = 25*$seg; 

$clusterfilename = "cluster".$seg_25.".".$round_ind.".".$num_cluster;
#print "clusterfilename $clusterfilename\n"; 
open (IN5, $clusterfilename) or die  "can not open";
( @clusterlines) = <IN5>; 
close IN5;


$simfilename = "sim".$seg_25.".".$round_ind.".".$num_cluster;
#print "clusterfilename $clusterfilename\n"; 
open (IN7, $simfilename) or die  "can not open";
( @simlines) = <IN7>; 
close IN7;

my $cumulated_hitrate = 0; 
my $cumulated_precision = 0;
my $cumulated_F = 0;
my $ind = 0; 
my $size_target = @testupcMappedlines; 
foreach my $test (@testupcMappedlines){
  $test = &trim($test);
  my @purchasedSet = split (/\t/,$test);
  splice(@purchasedSet, 0, 1);
  my $size_purchase = @purchasedSet;
  #print "purchaseet is @purchasedSet\n"; 
  %prods_hash= %{&WeighProds($ind)};
  my $path = $pathslines[$ind++]; #path by zone id
  $path = &trim($path);
  #print "path is $path\n"; 
  my @path_split = split (/\s+/, $path);
  my $path_len = @path_split; #path length
  my $num_2_recom = int($path_len/10); # every 30 steps, we're gonna recommend 3 items. The trip's length range from 100 to 6, 7 hundrends steps  
  #print "num_2_recom is $num_2_recom\n"; 
  my @products_sorted = (); 
  foreach $key (sort hashValueDescendingNum (keys(%prods_hash))) {
   #print "\t\t$prods_hash{$key} \t\t $key\n";
   push @products_sorted, $key; 
}
   #print "@products_sorted\n";
  my $num_recommended = 0; 
  my %recom_hash = ();# put all the recommended items to a hash
  if (@products_sorted>$num_2_recom){
    for (my $k =0; $k<$num_2_recom; $k++){
      $recom_hash{$products_sorted[$k]} = 1;
    }
    $num_recommended =  $num_2_recom;
  }
  else {
    foreach my $product (@products_sorted) {
      $recom_hash{$product} =1;
      $num_recommended = @products_sorted;
    }
  }
  #for each path segment, if an item is already bought, two items of the highest association support will be recommended  

####################compute hitRate (recall)#############################

  my $count = 0; #number of items in both the purchase set and the recommendation set
  foreach my $item (@purchasedSet){
#     print "purchased item $item\n"; 
    if (exists $recom_hash{$item}){
      $count++; 
    }
  }
  #print "count is $count\n";
  if ($size_purchase == 0) {
    print "empty basket!";
    next; } 
  else{ 
    $hitRate =$count/$size_purchase; 
    #print "hitRate is $hitRate\n"; 
    $cumulated_hitrate = $cumulated_hitrate + $hitRate;
     
    if ($num_recommended == 0){
	print "num_recommended is zero\n"; 
	$precision =0;
    }
    else{
    	$precision =$count/$num_recommended; 
	#print "precision is $precision\n"; 
    }
    $cumulated_precision = $cumulated_precision + $precision;
    if ($precision == 0 || $hitRate ==0){
    	#print "precision is $precision|| hitRate is $hitRate\n";
	$Fmeasure =0; 
    }
    else {
    	$Fmeasure =2*$hitRate*$precision/($precision+$hitRate); 
    }
    $cumulated_F = $cumulated_F + $Fmeasure;
     
    #print "hitRate is $hitRate\n";  #hitRate for one path
  }
#  print "********************\n";
 } #end for each target
 #print "cumulated hitrate is $cumulated_hitrate; size_target $size_target\n"; 
my $ave_hitRate = $cumulated_hitrate/$size_target;
my $ave_precision = $cumulated_precision/$size_target; 
my $ave_F = $cumulated_F/$size_target; 

print "$ave_hitRate\n";
print "$ave_precision\n";
print "$ave_F\n";
print "***********\n";  

}#end of hitRate subroutine

####################ranking products using user-based recommendation scheme ############
sub hashValueDescendingNum {
   $prods_hash{$b} <=> $prods_hash{$a};
}

 
sub WeighProds(){
  my %prod_hash = ();
  
  my $index = shift;  
  my $cluster = $clusterlines[$index];
  $cluster = &trim($cluster);
  
  my $simline = $simlines[$index];
  $simline = &trim($simline);
  #print "simline  is $simline \n"; 
  my @sims = split (/\s+/, $simline);
  my $num_sims = @sims;
  
  my $setofTrans = $clusters[$cluster];
	my @setTrans = @{$setofTrans};
  my $size_trans =  @setTrans; 
  #print "size_trans is $size_trans\n";
  if ($size_trans != $num_sims){
    	 	print "invalid cluster size! $size_trans vs. $num_sims\n";
	     	last; 
	}
	my $cnt = 0; 
  foreach my $tran (@setTrans){
  		#print "tran is $tran\n"; 
             $sim_1 = $sims[$cnt++];
        		 my $tran = &trim($tran);
		         my @tran_arr = split (/\t/,$tran);
			 splice(@tran_arr, 0, 1); 
	           foreach $product (@tran_arr)	  {
		        #print "product is $product \n"; 
	              if (exists $prod_hash{$product}){
        	        my $prod_weight  = $prod_hash{$product};
			#print "prod_weight is $prod_weight \n"; 
                	$prod_weight = $prod_weight +$sim_1;
	                $prod_hash{$product} =$prod_weight ; 
                   
        	      }
	              else {
        	        $prod_hash{$product}=$sim_1; 
              		}
             	    }      
	}
	return \%prod_hash; 
 } 
  
  
sub two_Associated(){
  my $cluster = shift; 
  my $pro = shift; 
  print "cluster and pro is $cluster and $pro\n";
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
