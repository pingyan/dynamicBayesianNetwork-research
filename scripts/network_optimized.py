#!/usr/bin/env python

import re, string, sys
import time
from priodict import priorityDictionary


class Graph:
   def __init__(self, g):
         self.g = g
   def V(self):
         return self.g.keys()
   def Adj(self,v):
         return self.g[v]
   


H = {'1': ['2','3','4','5','95','92'], '2': ['1','3','4'], '3': ['1','2'],'4': ['1','2','6'], '5': ['1','7'], '6': ['4','8'], '7': ['5', '9'],'8': ['6','11'], '9': ['11','7','16'], '10': ['11','12'], '11': ['8','14','10', '9','16'],'12': ['10','13','14'], '13': ['14','12','15'], '14': ['11','12','13'], '15': ['13', '17'],'16': ['9','11','17','18'],'17': ['15','16','18','31'], '18': ['16','17','19','24','31','61'], '19': ['18','81', '20'],'20': ['19','21'],'21': ['20','22'], '22': ['21','95'], '23': ['92'],'24': ['18','25'],'25': ['24','26'], '26': ['25','27'], '27': ['26', '95'],'28': ['61','29'],'29': ['28','30'], '30': ['29','95'], '31': ['17', '18','32','61'],'32': ['31','33','60','61'],'33': ['32','35','60','65'], '34': ['35','36'], '35': ['34','33', '37','65','68'],'36': ['34','37','38'],'37': ['71','75','35','36','39'], '38': ['36','39'], '39': ['37', '38','78','81'],'48': ['61','49'],'49': ['48','50'], '50': ['49','94'], '51': ['61', '52'],'52': ['51','53'],'53': ['52','94'], '54': ['60','55'], '55': ['54', '56'],'56': ['55','94'],'57': ['60','58'], '58': ['57','59'], '59': ['58', '94'],'60': ['32','33','61','65','54','57','62'],'61': ['18','31','32','60','28','48','51'], '62': ['60','63'], '63': ['62', '64'],'64': ['94','63','93'],'65': ['60','33','35','66'], '66': ['65','67'], '67': ['66', '93'],'68': ['35','69'],'69': ['68','70'], '70': ['69','89'], '71': ['37', '72'],'72': ['71','73'],'73': ['72','74','89'], '74': ['88','77','89','73','84','85'], '75': ['37', '76'],'76': ['75','77'],'77': ['74','76','84'], '78': ['39','79'], '79': ['80', '78'],'80': ['79','84'],'81': ['19','39','82'], '82': ['81','83'], '83': ['82', '84'],'84': ['77','80','83','85','86','74'],'85': ['74','86','84','87','88'],'86': ['84','85','87'],'87': ['88','86','85'], '88': ['87','85','89','74'],'89': ['88','74','73','70','93','90','96'],'90': ['89','93','94','91','96'],'91': ['90','93','94','95','92','96'],'92': ['96','23','91','94','95','1'],'93': ['89','67','64','94','90','91'],'94': ['91', '90','93','64','59','56','53','50','95','92'],'95': ['30', '27','22','1','92','91','94'],'96': ['89', '90','91','92']}

store = Graph(H)

#####
#####Find shortest paths from the start vertex to all vertices nearer than or equal to the end.
def Dijkstra(G,start,end=None):

	D = {}	# dictionary of final distances
	P = {}	# dictionary of predecessors
	Q = priorityDictionary()   # est.dist. of non-final vert.
	Q[start] = 0
	for v in Q:
		D[v] = Q[v]
		if v == end: break
		
		for w in G.Adj(v):
			#vwLength = D[v] + G[v][w]
			vwLength = D[v] + 1
			if w in D:
				if vwLength < D[w]:
					raise ValueError, \
  "Dijkstra: found better path to already-final vertex"
			elif w not in Q or vwLength < Q[w]:
				Q[w] = vwLength
				P[w] = v
	
	return (D,P)

DofD = {}

for item in store.V():
	D,P = Dijkstra(store,item)
	DofD[item] =D			

print DofD['10']
#print DofD['15A']['20D']
def shortestPath(G,start,end):
	"""
	Find a single shortest path from the given start vertex
	to the given end vertex.
	The input has the same conventions as Dijkstra().
	The output is a list of the vertices in order along
	the shortest path.
	"""

	D,P = Dijkstra(G,start,end)
	Path = []
	while 1:
		Path.append(end)
		if end == start: break
		end = P[end]
	Path.reverse()
	return Path

def shortestPath_len(start,end):
	"""
	Find the length of a single shortest path from the given start vertex
	to the given end vertex.
	"""
	#if start in DofD:
	#	if end in DofD[start]:
	return DofD[start][end]
	#	else: 
	#		print "start end key error"+start+end
	#else: 
	#        print "start key error"+start


#print shortestPath(store, '19B','11B')
#print store.V()
#print store.Adj('21A')

#read paths from path data file

if len(sys.argv) != 3: 
        print "Usage: python network_optimized.py encodedPaths.dat net_para" 
fName = sys.argv[1]
net_para = sys.argv[2]
ALL_PATHS = []


for oneLine in open(fName,"r").readlines():
	oneLine = oneLine.strip()
	path = oneLine.split()
	ALL_PATHS.append(path)
#compare two paths for similarity score
def Sim(patha, pathb): 
	#if path1==path2:
	
#		print "true"

	#unit_start = time.clock()
	LCSlen = LCS(patha, pathb)
	if len(patha) >0 and len(pathb) >0:
		sim = (float(LCSlen**2)/(len(patha)*len(pathb)))**0.5
		
	else: 
		sim = 0
	#print sim
	#unit_end = time.clock()
	#print "Unit time elapsed = ", '%.6f'%(unit_end - unit_start), "seconds"

	return sim
	
def LCS(seq1, seq2):
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
		j = len_2-1
		while j > -1:
			#how far are nodes i and j 
			dist = shortestPath_len(seq1[i],seq2[j])
			if dist > 1:
				dist_var = dist
				while dist_var >0 and j > -1:
					dist_var =  dist_var -1
					L[i][j]= maxAB(L[i+1][j], L[i][j+1])
					j = j-1
			else: 
				temp = float(equal(seq1[i],seq2[j]))
		
				if temp==1: 
					L[i][j]= L[i+1][j+1]+1
					
				elif temp==0.5:
					L[i][j]= maxAB(temp+L[i+1][j+1],maxAB(L[i+1][j], L[i][j+1]))
				else: 
					L[i][j]= maxAB(L[i+1][j], L[i][j+1])

				j = j-1
#       		else:
#				L[i][j]= maxAB(L[i+1][j], L[i][j+1])
	
			#print ` maxAB(equal(seq1[i],seq2[j])+L[i+1][j+1],maxAB(L[i+1][j], L[i][j+1]))` +" vs " + `maxAB(L[i+1][j], L[i][j+1])`
	#for i in xrange(len_1):
	#	print L[i]
	return L[0][0]
#define equality based on network connectivity
def maxAB(int1, int2):
	if int1>int2:
		return int1
	else:
		return int2
def equal(char1, char2):

	neighbor = set(store.Adj(char1))
	
	if char1 == char2: 
		m = 1
	elif char2 in neighbor: 
		m = net_para
	else: 
		m = 0 
	return m
	

#print the smilarities as matrix for clustering
filename = "Purchase.mat."+net_para
FILE = open(filename,"wb")
FILE.write(str(len(ALL_PATHS))+"\n")
def Matrix(): 
	i = 0
	#start = time.clock()
	for path1 in ALL_PATHS:
		simMatrix.append([])
		for path2 in ALL_PATHS: 
			sim  = Sim(path1, path2)
			sim_p = '%.6f'%sim
			
			simMatrix[i].append(sim_p)
			FILE.write(sim_p+"\t")
		
		FILE.write("\n")
		i=i+1
	#end = time.clock()
	#print "Time elapsed = ", end - start, "seconds"

simMatrix = []
Matrix()

#print simMatrix
