#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  Mapping.pl
#
#        USAGE:  ./Mapping.pl Trajs_labeled.txt
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  12/10/2007 04:13:26 PM MST
#     REVISION:  ---
#===============================================================================

#use strict;
use warnings;
use diagnostics; 
use Switch; 

$file =shift; 
open (TRAS, $file); 

($num_tra, @trajs)  = <TRAS>;
close TRAS; 

@red = ("ffc1c1","eeb4b4","cd9b9b","8b6969","ff6a6a","ee6363","cd5555","8b3a3a","ff8247","ee7942","cd6839","8b4726","ffd39b","eec591","cdaa7d","8b7355","ffe7ba","eed8ae","cdba96","8b7e66","ffa54f","ee9a49","cd853f","8b5a2b","ff7f24","ee7621","cd661d","8b4513","ff3030","ee2c2c","cd2626","8b1a1a","ff4040","ee3b3b","cd3333","8b2323","ff8c69","ee8262","cd7054","8b4c39","ffa07a","ee9572","cd8162","8b5742","ffa500","ee9a00","cd8500","8b5a00","ff7f00","ee7600","cd6600","8b4500","ff7256","ee6a50","cd5b45","8b3e2f","ff6347","ee5c42","cd4f39","8b3626","ff4500","ee4000","cd3700","8b2500","ff0000","ee0000","cd0000","8b0000");
$red_cnt = @red; 
$red_bright ="ff0000";
 
@blue = ("836fff","7a67ee","6959cd","473c8b","4876ff","436eee","3a5fcd","27408b","0000ff","0000ee","0000cd","00008b","1e90ff","1c86ee","1874cd","104e8b","63b8ff","5cacee","4f94cd","36648b","00bfff","00b2ee","009acd","00688b","87ceff","7ec0ee","6ca6cd","4a708b","b0e2ff","a4d3ee","8db6cd","607b8b","c6e2ff","b9d3ee","9fb6cd","6c7b8b","cae1ff","bcd2ee","a2b5cd","6e7b8b","bfefff","b2dfee","9ac0cd","68838b","e0ffff","d1eeee","b4cdcd","7a8b8b","bbffff","aeeeee","96cdcd","668b8b","98f5ff","8ee5ee","7ac5cd","53868b","00f5ff","00e5ee","00c5cd","00868b","00ffff","00eeee","00cdcd","008b8b","97ffff","8deeee","79cdcd");
$blue_cnt = @blue;
$blue_bright = "0000ff";

@green = ("7fffd4","76eec6","66cdaa","458b74","c1ffc1","b4eeb4","9bcd9b","698b69","54ff9f","4eee94","43cd80","2e8b57","9aff9a","90ee90","7ccd7c","548b54","00ff7f","00ee76","00cd66","008b45","00ff00","00ee00","00cd00","008b00","7fff00","76ee00","66cd00","458b00","c0ff3e","b3ee3a","9acd32","698b22","caff70","bcee68","a2cd5a"); 
$green_bright = "FF00FF00";
$green_cnt = @green; 

@purple = ("ff1493","ee1289","cd1076","8b0a50","ff6eb4","ee6aa7","cd6090","8b3a62","ffb5c5","eea9b8","cd919e","8b636c","ffaeb9","eea2ad","cd8c95","8b5f65","ff82ab","ee799f","cd6889","8b475d","ff34b3","ee30a7","cd2990","8b1c62","ff3e96","ee3a8c","cd3278","8b2252","ff00ff","ee00ee","cd00cd","8b008b","ff83fa","ee7ae9","cd69c9","8b4789","ffbbff","eeaeee","cd96cd","8b668b","e066ff","d15fee","b452cd","7a378b","bf3eff","b23aee","9a32cd","68228b","9b30ff","912cee","7d26cd","551a8b","ab82ff","9f79ee","8968cd","5d478b"); 
$purple_cnt = @purple; 
$purple_bright = "a020f0";


@black = ("0000000","030303","030303","050505","050505","080808","080808","0a0a0a","0a0a0a","0d0d0d","0d0d0d","0f0f0f","0f0f0f","121212","121212","141414","141414","171717","171717","1a1a1a","1a1a1a","1c1c1c","1c1c1c","1f1f1f","1f1f1f","212121","212121","242424","242424","262626","262626","292929","292929","2b2b2b","2b2b2b","2e2e2e","2e2e2e","303030","303030","333333","333333","363636","363636","383838","383838","3b3b3b","3b3b3b","3d3d3d","3d3d3d","404040","404040","424242","424242","454545","454545","474747","474747","4a4a4a","4a4a4a","4d4d4d");
$black_cnt = @black;
$black_pure = "0000000";

@grey = ("707070","707070","737373","737373","757575","757575","787878","787878","7a7a7a","7a7a7a","7d7d7d","7d7d7d","7f7f7f","7f7f7f","828282","828282","858585","858585","878787","878787","8a8a8a","8a8a8a","8c8c8c","8c8c8c","8f8f8f","8f8f8f","919191","919191","949494","949494","969696","969696","999999","999999","9c9c9c","9c9c9c","9e9e9e","9e9e9e","a1a1a1","a1a1a1","a3a3a3","a3a3a3","a6a6a6","a6a6a6","a8a8a8","a8a8a8","ababab","ababab","adadad","adadad","b0b0b0","b0b0b0","b3b3b3","b3b3b3","b5b5b5","b5b5b5","b8b8b8","b8b8b8","bababa","bababa","bdbdbd","bdbdbd","bfbfbf","bfbfbf","c2c2c2","c2c2c2","c4c4c4","c4c4c4","c7c7c7","c7c7c7","c9c9c9","c9c9c9","cccccc","cccccc","cfcfcf","cfcfcf","d1d1d1","d1d1d1","d4d4d4","d4d4d4","d6d6d6","d6d6d6","d9d9d9","d9d9d9","dbdbdb","dbdbdb","dedede","dedede","e0e0e0","e0e0e0"); 
$grey_cnt = @grey;  
$yellow_pure = "ffff00";

$header = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://earth.google.com/kml/2.0\">
<Document>
<name>Trajectories of trucks</name>";

$footer ="</Document>
</kml>";

open (OUT, ">:utf8", "traj_truck_medoids.kml") or die "cannot open file!";



print OUT "$header\n";
$cnt = 0;  
foreach $traj (@trajs) {
	$cnt++; 
	#print "$traj"; 
	@temp = split (/& /, $traj); 
        $coordinates = $temp[1];
	#print $coordinates;
	#$cluster = $temp[0];
	($center, $cluster) = split (/\s+/,$temp[0]); 
        
	$width = 0;
	if ($center eq "Y"){$width = 4;}
	 
	$color = "FF".&findcolor($cluster); 
	print OUT "<Folder>\n<name> cluster_$cluster </name>\n<Placemark>\n<name> traj_$cnt </name>\n<Style>\n<LineStyle>\n<color>$color</color>\n<width>$width</width>\n</LineStyle>\n</Style>\n<LineString>\n<tessellate>1</tessellate>\n<coordinates>$coordinates</coordinates>\n</LineString>\n</Placemark>\n</Folder>\n"; 

}

print OUT "$footer\n";

sub findcolor(){

	my $cluster =shift; 
	switch($cluster){
		case "0" {$ind = rand()*$red_cnt; return $red[$ind];}
		#case "0" {return $red_bright;}
		case "1" {$ind = rand()*$blue_cnt; return $blue[$ind];}
		#case "1" {return $blue_bright;}
		case "2" {$ind = rand()*$green_cnt; return $green[$ind];}
		#case "2" {return $green_bright;}
		case "3" {$ind = rand()*$purple_cnt; return $purple[$ind];}
		#case "3" {return $purple_bright;}
		case "4" {$ind = rand()*$black_cnt; return $black[$ind];}
		#case "4" {return $black_pure;}
		case "5" {$ind = rand()*$grey_cnt; return $grey[$ind];}
		#case "5" {return $yellow_pure;}
		else {print "error!";}
	}#end of switch
}
