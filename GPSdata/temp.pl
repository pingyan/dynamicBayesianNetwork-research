#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  temp.pl
#
#        USAGE:  ./temp.pl 
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
#      CREATED:  01/07/2008 10:44:16 AM MST
#     REVISION:  ---
#===============================================================================

#use strict;
use warnings;

$str = "2 1 1 7 7 7 7 7 7 1 2 1 1 1 1 1 2 1 1 2 1 1 1 1 1 1 12 1 1 7 7 1 1 1 1 1 1 1 1 4 1 7 7 7 7 1 1 1 1 1 1 1 1 4 1 7 1 7 7 7 0 0 0 0 3 1 1 1 1 1 1 1 7 1 1 7 7 7 8 7 7 7 7 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 1 2 1 1 7 7 7 1 1 1 7 7 2 1 1 2 1 1 1 1 1 1 1 7 7 1 7 7 7 7 2 1 2 1 4 1 1 1 1 1 1 7 11 7 7 7 7 7 7 1 1 1 1 2 1 7 7 7 7 7 7 7 1 1 1 1 7 1 2 2 7 1 1 3 7 1 7 7 7 1
3 1 7 1 1 7 7 1 1 2 7 7 1 1 1 2 1 8 7 8 8 8 8 8 8 8 8 8 1 1 1 1 1 1 1 1 2 1 1 1
1 1 1 1 1 1 1 1 1 1 1 1 1 5 7 7 7 7 7 7 7 7 7 7 7 7 4 1 2 1 1 1 1 1 7 7 7 7 7 8
8 8 8 8 1 1 1 1 1 1 1 1 1 1"; 

$str =~ s/\n/ /;
@temp = split(/\s+/,$str); 

foreach (@temp){
	print "$_\n";
} 