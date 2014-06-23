#!/usr/bin/perl 
#
#
$spendingfile = shift; #stat file for every trip
$membership = shift; #cluster output 
$num_clusters = shift; 
#$out2 = shift; 
#$out3 = shift;

print "USAGE: perl profileClusterSpending.pl SpendStat.dat purchase.mat.0.clustering.3 num_clusters"; 
open (IN, $spendingfile) or die  "can not open";
( @lines) = <IN>; 

close IN; 
open (IN2, $membership) or die  "can not open";
@membership = <IN2>;
close IN2;

open (OUT, ">:utf8", "clusterProfileSpending.txt") or die  "can not open";



@top_1_cnt_hashes = ();
@perc_top_1_cnt_hashes = ();
@cnt_hashes =(); 
@perc_cnt_hashes = (); 

for ($i=0; $i<$num_clusters; $i++){#initialization of the 2-D arrays
      my %top_1_cnt_hash = ();
      my %perc_top_1_cnt_hash = ();
      my %cnt_hash =();
      my %perc_cnt_hash = ();
      my %top_1_spend_hash = ();
      my %perc_top_1_spend_hash = ();
      my %spend_hash =();
      my %perc_spend_hash = ();

      
      push @top_1_cnt_hashes, \%top_1_cnt_hash;
      push @perc_top_1_cnt_hashes, \%perc_top_1_cnt_hash;
      push @cnt_hashes, \%cnt_hash; 
      push @perc_cnt_hashes, \%perc_cnt_hash; 

      push @top_1_spend_hashes, \%top_1_spend_hash;
      push @perc_top_1_spend_hashes, \%perc_top_1_spend_hash;
      push @spend_hashes, \%spend_hash;
      push @perc_spend_hashes, \%perc_spend_hash;

}

$ind = 0;
foreach $line (@lines){
#        print "@{$length_feet[0]}\n";
#	 print "@{$length_feet[1]}\n";
	$line = &trim($line); 
	@line_split = split (/\t/,$line);
	#print "$line_split[3]\n";
	#print "$line_split[33]\n";

	@copy_line_split=@line_split;
	$size = @copy_line_split;
	$splicesize = $size-33;
	splice (@copy_line_split,33,$splicesize);
	splice (@copy_line_split,0,3);

	$string_cnt = join ("\t",@copy_line_split);
	$string_cnt = &trim($string_cnt);
	@temp_new_cnt = split (/\t/,$string_cnt);
	$size_new_cnt =@temp_new_cnt;
	print "@temp_new_cnt\n"; 

	@copy_2_line_split=@line_split;
        $splicesize_2 = 32;
        splice (@copy_2_line_split,0,$splicesize_2);
        $string_spend = join ("\t",@copy_2_line_split);
        $string_spend = &trim($string_spend);
        @temp_new_spend = split (/\t/,$string_spend);
        $size_new_spend =@temp_new_spend;
	
	$cluster = $membership[$ind++];
	$cluster = &trim($cluster);
	
	#in each cluster, the total counts of the top 1 category
	for ($i =0; $i<$size_new_cnt; $i++){
		my $ref_hash  = $top_1_cnt_hashes[$cluster];
		$top_1_cnt_hashes[$cluster] = &Increment($ref_hash, $temp_new_cnt[$i++],$temp_new_cnt[$i] ); 
		#print "$top_1_cnt_hashes[$cluster]\n";
	}
        
	#in each cluster, the totla counts for the top money spending category 
	#my $ref_hash  = $top_1_spend_hashes[$cluster];
	#$top_1_spend_hashes[$cluster] = &Increment($ref_hash, $temp_new_spend[0], 1);

	#in each cluster, the total counts for each product category
	#for ($i=0; $i<$size_new-3;$i++){
	#	my $key = $temp_new[$i++];
	#	my $incre = $temp_new[$i];
	#	$ref_hash  = $cnt_hashes[$cluster];
	#	$cnt_hashes[$cluster] = &Increment($ref_hash, $key,$incre);

	#}

	#in each cluster, the total spending for each product category
	#for ($i=0; $i<$size_new_spend;$i++){
         #       my $key = $temp_new_spend[$i++];
        #        my $incre = $temp_new_spend[$i];
        #        $ref_hash  = $spend_hashes[$cluster];
        #        $spend_hashes[$cluster] = &Increment($ref_hash, $key,$incre);
       #}


}

sub Increment (){
     my $ref= $_[0];
     my $key = $_[1];
#     print "$ref and $key\n";
     my $increment = $_[2];
     #print "$increment\n"; 
     if (exists $ref->{$key}){
     	$ref->{$key}=$ref->{$key}+$increment;
     }
     else  {$ref->{$key} = $increment;} 
     #print "$ref->{$key}\n";
     return $ref;	
}
for (my $i=0; $i<$num_clusters; $i++){
	
	my $hash_ref = $top_1_cnt_hashes[$i];
	&prOUT($hash_ref);
	print OUT "***********\n";

}
sub prOUT($) {
	my $ref =$_[0];
	print "$ref\n"; 
  	foreach $key (sort {$ref->{$b}<=>$ref->{$a} } keys(%$ref)){
		$temp = $ref->{$key}; 
		print "$temp\n"; 
      		print OUT "$key\t$temp\t";

	} 
	print OUT "\n";
}

sub trim($) {
    my $string = shift;
       $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

