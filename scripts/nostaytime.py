#!/usr/bin/env python

import re, string, sys

def LCS(seq1, seq2, time_seq1, time_seq_2):
#	print seq1
#	print seq2
	len_1 = len(seq1)
	#print len_1
	len_2 = len(seq2)
	L =[]
	for i in xrange(len_1+1):

		L.append([])
		for j in xrange(len_2+1):
			L[i].append(0)
	#print L
	for i in xrange(len_1-1, -1, -1):
	 for j in xrange(len_2-1, -1, -1):
	      
		
				if seq1[i]== seq2[j]: 
					L[i][j]= L[i+1][j+1]+1

				else: 
					L[i][j]= maxAB(L[i+1][j], L[i][j+1])

				j = j-1
#       		else:
#				L[i][j]= maxAB(L[i+1][j], L[i][j+1])
	
			#print ` maxAB(equal(seq1[i],seq2[j])+L[i+1][j+1],maxAB(L[i+1][j], L[i][j+1]))` +" vs " + `maxAB(L[i+1][j], L[i][j+1])`
	#for i in xrange(len_1):
	#	print L[i]
	return L[0][0]
	
   print LCS("abcdef", "acdf",[0.2, 0.3, 0.2,0.4,0.4,0.5],[0.7,0.4,0.6,0.9])