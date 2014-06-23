#!/usr/bin/perl 
#
#
$upcfile = shift; 
#$outpath = shift;# the file also show total number of purchases, and duration while picking up items
$mappingfile = shift;#shows the location of item pickup 
$zonefile = shift; 
$upc_mapped  = shift; 
$zone_mapped  = shift;
$stat = shift; 
#$out2 = shift; 
#$out3 = shift;

print "USAGE: perl UPCMapping.pl UPC_trip.dat UPC_Data_20090313.txt encodedPurchase.dat UPC_Mapped.dat Zone_mapped.dat SpendStat"; 
open (IN, $upcfile) or die  "can not open";
@lines = <IN>; 
close IN; 
open (IN1, ">:utf8",$mappingfile) or die  "can not open";
@mappinglines = <IN1>; 
close IN1; 

open (IN2, ">:utf8",$zonefile) or die  "can not open";
@zonelines = <IN2>; 
close IN2; 

open (OUT1, ">:utf8",$upc_mapped) or die "can not open";
open (OUT2, ">:utf8",$zone_mapped) or die "can not open";
open (OUT3, ">:utf8",$stat) or die "can not open";


%prod_hash = (); 
%dept_hash = (); 
%price_hash = (); 
%cnt_hash = ();
%spending_hash = ();
%zone_hash = ();
%zone_spending = ();
foreach $mappingline (@mappinglines){
	$mappingline = &trim($mappingline); 
	@temp = split (/\s+/,$mappingline);
	$UPC = $temp[0]; 
	$prod_hash{$UPC} =$temp[1];
  $dept_hash{$UPC} =$temp[2];
  $dept = $temp[2];
  if !(exists $cnt_hash{$dept}){
    $cnt_hash{$dept} = 0; 
  } 
  $price_hash{$UPC} =$temp[3];   
}

my $line_ind = 0; 
foreach $line (@lines){
	$line = &trim($line);
  $zone_line = &trim($zonelines[$line_ind++]);
  @zone_temp = split (/\t/,$zone_line);
  my $zone_ind = 0; 
	$trip_ID = ""; 
	@temp = split (/:/,$line);
	$trip_ID = $temp[0];
	print OUT1 "$trip_ID:\t";
	print OUT3 "$trip_ID:\t";
  my $total_spending =0;

  @UPCs = split (/\t/, $temp[1]);
	$sizeBasket = @UPCs;
	print OUT3 "$sizeBasket\t"; 
	foreach $upc (@UPCs){
	  my $zone = $zone_temp[$zone_ind++];    
    
    if exists $dept_hash{$upc}{
      my $dept = $dept_hash{$upc};
      my $spending = $price_hash{$UPC}; 
      $spending_hash{$dept} += $spending; #spending at each dept along one trip
      $total_spending += $spending; #total spending of one trip 
      $cnt_hash{$dept}++; #number of visits at each dept along one trip   
  	  
      #map zone and product
      if exists $zone_hash{$zone}{
	      my $zone_prod =  $zone_hash{$zone};
	      if ($zone_prod ne $dept){
	          $zone_hash{$zone}=$zone_hash{$zone}."&".$dept;
        }
	    }
	    else {$zone_hash{$zone}= $dept;}
      
      #calculate the spending at each zone
      if exists ($zone_spending{$zone}){
        $zone_spending{$zone}+= $spending; 
      }
      else {$zone_spending{$zone}=0;}
      print OUT1 "$dept\t";
    }
 
  }
  print OUT3 "$total_spending\t";
   
  my $space = 0; 
  foreach my $value (sort {$cnt_hash{$b} cmp $cnt_hash{$a} } keys %cnt_hash){
    print OUT3 "$value $cnt_hash{$value}";
    $space++; 
  }
  $space = 20-$space;
  while ($space > 0) {
    print OUT3 "\t";
    $space--;  
  }
  
  foreach my $value (sort {$spending_hash{$b} cmp $spending_hash{$a} } keys %spending_hash){
    print OUT3 "$value $spending_hash{$value}";
  }
  print OUT3 "\n";
 
  print OUT1 "\n"; 
}#end of each trip

#write zone_mapped
while( my ($k, $v) = each %zone_prod ) {
  print OUT2 "$k\t$v\n";
} 
print OUT2 "******";
while( my ($k, $v) = each %zone_spending) {
  print OUT2 "$k\t$v\n";
}


close OUT1; 
close OUT2; 
close OUT3; 

sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
