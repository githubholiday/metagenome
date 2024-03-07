#!/usr/bin/env python3
import pandas as pd 
import os
import sys 
import re
import argparse
bindir = os.path.abspath(os.path.dirname(__file__))

__author__='Yang Zhang'
__mail__= 'yangzhang@genome.cn'
__doc__='this file is used to deal with CAZy info and hmmscan result.' 


def read_anno( anno ):
	anno_dict = {}
	with open(anno , 'r') as ANNO:
		for line in ANNO:
			tmp = line.strip().split("\t")
			try:
				id , Class , activity = tmp[0],tmp[1],tmp[2]
				anno_dict[id] = [Class , activity]
			except:
				print(tmp)
				exit(1)
	return anno_dict


def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='CAZyme.annot.stringent',dest='input',required=True)
	parser.add_argument('-a','--anno',help='Activities.xls',dest='anno',required=True)
	parser.add_argument('-o','--output',help='output file',dest='output',required=True)
	args=parser.parse_args()
	anno_dict = read_anno( args.anno )
	OUT = open(args.output , 'w')
	title = ['GENE','CAZy_id','CAZy_class','CAZy_Activities_in_Family']
	OUT.write('\t'.join(title)+"\n")
	with open(args.input , 'r') as IN:
		for line in IN:
			tmp = line.strip().split("\t")
			ID = tmp[0].replace('.hmm','')
			GENE = tmp[2]
			if ID in anno_dict.keys():
				content = [GENE,ID] + anno_dict[ID]
				OUT.write('\t'.join(content)+"\n")
			else:
				print("{0} does not have info in your anno file(-a), do not worry".format(ID))
	OUT.close()	
	print("work is done")		

if __name__=='__main__':
	main()
