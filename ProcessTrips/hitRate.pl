#!/usr/bin/perl 
##
##
$upcMappedfile = shift; #stat file for every trip
$membership = shift; #cluster output 
$num_clusters = shift;
$round_ind = shift; 
##$out2 = shift; 
##$out3 = shift;
#
print "USAGE: perl profileClusterSpending.pl UPC_mapped0 Sim_training0.clustering.4 num_clusters round_ind\n"; 
open (IN, $upcMappedfile) or die  "can not open";
( @lines) = <IN>; 
#
close IN; 
open (IN2, $membership) or die  "can not open";
@membership = <IN2>;
close IN2;
#
$outfilename = "support.".$round_ind.".".$num_clusters;
#
open (OUT, ">:utf8", $outfilename) or die  "can not open";
#

%hash_all = ();
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
my $testitem = "PRODUCE";
my $testcluster = 1;
my $hash_ref = $hash_all{'0'}->{'PRODUCE'};
print "$hash_ref\n"; 
 foreach $key (sort {$hash_ref->{$b}<=>$hash_ref->{$a} } keys(%$hash_ref)){
                 $temp = $hash_ref->{$key};
		# print "$temp\n";
		 print  "support $key\t$temp\n";
}
#print "support for $testitem $hash_all{"1"}->{$testitem}"
# for (my $i=0; $i<$num_clusters; $i++){
 	
# }
sub trim($) {
    my $string = shift;
           $string =~ s/^\s+//;
	       $string =~ s/\s+$//;
	           return $string;
		   }
