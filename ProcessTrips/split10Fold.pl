#!/usr/bin/perl
####
$pathfile = shift;
$simfile = shift; 
$UPCMappedfile = shift; 

print "USAGE: perl split10Fold.pl encodedPaths.dat Sim.mat.0.5  UPC_Mapped.dat"; 
open (PIN, $pathfile) or die  "can not open";
@pathlines = <PIN>;
close PIN;

open (SIN, $simfile) or die  "can not open";
@simlines = <SIN>;
close SIN;

open (UPCIN, $UPCMappedfile) or die  "can not open";
@UPCMappedlines = <UPCIN>;
close UPCIN;

for ($i =0; $i<10; $i++){
  $testfilename  = "testing_paths".$i;
  open (OUT, ">:utf8",$testfilename) or die  "can not open";
  $ind = $i; 
  while ($ind <843){
    print OUT $pathlines[$ind];
    $ind = 10+$ind;
  }
  close OUT;
}

for ($i =0; $i<10; $i++){
  $UPCMappedfilename  = "testing_UPC_Mapped".$i;
  open (OUT, ">:utf8",$UPCMappedfilename) or die  "can not open";
  $ind = $i; 
  while ($ind <843){
    splice (@UPCMappedlines, $ind, 1);
    $ind = 10+$ind;
  }
  foreach $UPCMapped (@UPCMappedlines){
    print OUT "$UPCMapped\n";
  }
  close OUT;
}

for ($i =0; $i<10; $i++){
  $Simfilename  = "Sim_training".$i;
  open (OUT, ">:utf8",$Simfilename) or die  "can not open";
  $ind = $i; 
  while ($ind <843){
    splice (@simlines, $ind, 1);
    $ind = 10+$ind;
  }
  foreach $simline (@simlines){
    @temp= split (/\t/, $simline);
    $ind = $i; 
    while ($ind <843){
      splice (@temp, $ind, 1);
      $ind = 10+$ind;
    }
    foreach $item @temp{
      print OUT "$item\t";
    }
    print OUT "\n";
    
  close OUT;
}


sub trim($) {
    my $string = shift;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

