#!/usr/bin/env python3
import pandas as pd 
import os
import sys 
import re
import argparse
bindir = os.path.abspath(os.path.dirname(__file__))

__author__='Yang Zhang'
__mail__= 'yangzhang@genome.cn'
__doc__='this file is used to deal with ARDB fasta info and id2antibiotic .' 


def read_anno( anno ):
	anno_dict = {}
	with open(anno , 'r') as ANNO:
		for line in ANNO:
			tmp = line.strip().split("|")
			ARDB_ID , other = tmp[0],tmp[1]
			if "]." in other:
				other = other.replace("].","")
				annotation, species = other.split("[")[0],other.split("[")[1]
			else:
				annotation = other
				species = '-'
			anno_dict[ARDB_ID] = [annotation , species]
	return anno_dict


def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='anno.xls',dest='input',required=True)
	parser.add_argument('-a','--anno',help='id2antibiotic.xls',dest='anno',required=True)
	parser.add_argument('-o','--output',help='output file',dest='output',required=True)
	args=parser.parse_args()
	anno_dict = read_anno( args.anno )
	OUT = open(args.output , 'w')
	title = ['ARDB_ID','ARDB_type','ARDB_antibiotic','ARDB_anno','ARDB_species']
	OUT.write('\t'.join(title)+"\n")
	with open(args.input , 'r') as IN:
		for line in IN:
			if line.startswith('ref-id'):continue
			else:
				tmp = line.strip().split("\t")
				if len(tmp) == 2:tmp.append("-")
				
				if tmp[0] in anno_dict.keys():
					content = tmp + anno_dict[tmp[0]]
					OUT.write('\t'.join(content)+"\n")
				else:
					print("{0} does not have info in your anno file(-a), do not worry".format(tmp[0]))
	OUT.close()	
	print("work is done")		

if __name__=='__main__':
	main()
