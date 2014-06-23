#compare to the old support_w computation, this version takes a more sophisticated form using weighted product interest. 

#!/usr/bin/perl 
##
##
print "USAGE: perl support_w_new.pl round_ind num_cluster\n"; 

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
################################################
#################compute product affinity #########

my %hash_all = ();
my %hash_single =();

for (my $i=0; $i<$num_cluster; $i++){
	my %hash_A = ();
	my %hash_s = ();
	$hash_all{$i} =\%hash_A;
	$hash_single{$i} =\%hash_s;
}
#$line = "18133639_2008-05-03-12:13:29.000:       PRODUCE GROCERY DAIRY";
my $ind = 0;
foreach my $line (@trainupcMappedlines ){
	my  $cluster = $trainclusters[$ind++];
	$cluster = &trim($cluster); 
	#print "$cluster\n"; 
        my $hash_A_ref = $hash_all{$cluster};
        my $hash_single_ref = $hash_single{$cluster};
        $line = &trim($line); #18133639_2008-05-03-12:13:29.000:       PRODUCE GROCERY DAIRY
	#print "$line\n"; 
	my @line_split = split (/\t/,$line);
	my $size = @line_split; 
	#print "size is $size\n"; 
	#initializing 
  for (my $i =1; $i<$size-1;$i++){
		#print "i is $i\n";
		my $item = $line_split[$i]; 
		#print "the item is $item\n"; 
		if (exists $hash_single_ref->{$item}){
      $hash_single_ref->{$item} = $hash_single_ref->{$item}+1; 
    }
    else {$hash_single_ref->{$item}=1;}
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
     $hash_single{$cluster} = $hash_single_ref;
 }
     #compute affinity 
for (my $i=0; $i<$num_cluster; $i++){
	#print "$num_clusters\n"; 
        my $hash_A_ref = $hash_all{$i};
        my $hash_single_ref = $hash_single{$i};
        for my $key_A (keys %$hash_A_ref){
	  #print "$key_A\t"; 
         my $hash_B_ref = $hash_A_ref->{$key_A};
         for my $key_B (keys %$hash_B_ref){
	  #print "$key_B\t"; 
	  my $divider = $hash_single_ref->{$key_A}+$hash_single_ref->{$key_B}-$hash_B_ref->{$key_B};
	  my $affinity = 0; 
	  if ($divider == 0){
	  	$affinity = 0;
	  }
	 else {
          $affinity = $hash_B_ref->{$key_B}/$divider;
	  }
          #print "affinity is $affinity\n";
          $hash_B_ref->{$key_B}=$affinity; 
          }
          $hash_A_ref->{$key_A} = $hash_B_ref ;
        }
        $hash_all{$i} = $hash_A_ref;
}
=comment
my $testitem = "FRUITS";
my $testcluster = 1;

  my $hash_ref = $hash_all{'1'}->{'FRUIT'};
 
  foreach $key (sort {$hash_ref->{$b}<=>$hash_ref->{$a} } keys(%$hash_ref)){
                 $temp = $hash_ref->{$key};
		 print  "support $key\t$temp\n";
  }
 
=cut 
##################################################################
################compute Hit rates #################################
$pathfilename ="testing_paths".$round_ind; 
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
my $size_target = @testupcMappedlines ; 
foreach my $test (@testupcMappedlines ){
  $test = &trim($test);
  my @purchasedSet = split (/\t/,$test);
  splice(@purchasedSet, 0, 1);
  my $size_purchase = @purchasedSet;
  #print "purchaseet is @purchasedSet\n"; 
  my $cluster = $clusterlines[$ind];
  #print "cluster is $cluster\n"; 
  $cluster = &trim($cluster);
  #print "cluster is $cluster\n"; 
  my $path = $pathslines[$ind]; #path by zone ids
  my @path_split = split (/\s+/, $path);
  my $path_len = @path_split; #path length
  my $num_2_recom = int($path_len/15); # every 30 steps, we're gonna recommend 3 items. The trip's length range from 100 to 6, 7 hundrends steps  
  $count = 0; 
  my %recom_hash = ();# put all the recommended items to a hash
  #for each path segment, if an item is already bought, two items of the highest association support will be recommended  
  my $bought = int($seg*$size_purchase/4);
  #print "bought size is $bought; purchase sise iz  $size_purchase\n"; 
   my $temp_size = scalar keys( %recom_hash );
  if ($bought > 0 ){
  	my $i =0; 
    while (($i<$bought) && ($temp_size < $num_2_recom) ){
      $bought_pro = $purchasedSet[$i++];
      #print "bought_pro is $bought_pro\n";
      (my $asso_1, my $asso_2) = ("","");
      ($asso_1, $asso_2) = &two_Associated($cluster, $bought_pro);
      #print "asso_1 and asso_2 is $asso_1, $asso_2\n"; 
     
      if ($asso_1 ne "") {$recom_hash{$asso_1}=1;}
      $temp_size = scalar keys( %recom_hash );
      #if ($temp_size < $num_2_recom) {
      #	if ($asso_2 ne "") {$recom_hash{$asso_2}=1;}
      #}
      #$temp_size = scalar keys( %recom_hash );
    }
  }
  my $temp_size = scalar keys( %recom_hash );
    # have to know what product is purchased
    
  %prods_hash= %{&WeighProds($ind++)};
  
  my @products_sorted = (); 
  foreach $key (sort hashValueDescendingNum (keys(%prods_hash))) {
   #print "\t\t$prods_hash{$key} \t\t $key\n";
   push @products_sorted, $key; 
}
   #print "@products_sorted\n";
   $num_2_recom_new = $num_2_recom-$temp_size; 
  if (@products_sorted>$num_2_recom_new){
    for (my $k =0; $k<$num_2_recom_new; $k++){
      $recom_hash{$products_sorted[$k]} = 1;
    }
    $num_recommended =  $num_2_recom_new;
  }
  else {
    foreach my $product (@products_sorted) {
      $recom_hash{$product} =1;
      $num_recommended = @products_sorted;
    }
  }
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


sub two_Associated(){
  my $cluster = shift; 
  my $pro = shift; 
  #print "cluster and pro is $cluster and $pro\n";
  my $hash_ref = $hash_all{$cluster}->{$pro};
  my $size_asso = scalar keys(%$hash_ref);
  my @recom = ();
  
  foreach $key (sort {$hash_ref->{$b}<=>$hash_ref->{$a} } keys(%$hash_ref)){
                   $temp = $hash_ref->{$key};
		 push @recom, $key;
  }
  if ($size_asso >1){

  	return $recom[0], $recom[1];
  }
  else {
  	foreach my $temp (@recom){
		return $temp;
	}
  }
}


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
 
sub trim($) {
    my $string = shift;
           $string =~ s/^\s+//;
	       $string =~ s/\s+$//;
	           return $string;
		   }
