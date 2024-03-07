#!/usr/bin/env python3
import pandas as pd 
from pandas import Series
import os
import sys 
import re
import argparse
bindir = os.path.abspath(os.path.dirname(__file__))

__author__='Yang Zhang'
__mail__= 'yangzhang@genome.cn'
__doc__='this file is used to deal with blast result and ID2antibiotic .' 



def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='anno.xls',dest='input',required=True)
	parser.add_argument('-a','--anno',help='id2antibiotic.xls',dest='anno',required=True)
	parser.add_argument('-o','--output',help='output file',dest='output',required=True)
	args=parser.parse_args()
	Anno = pd.read_csv(args.anno , sep='\t')
	Input = pd.read_csv(args.input , sep='\t')
	def Split(x):
		x = x.tolist()
		x = [i.split("|")[0] for i in x]
		return Series(x)
	Input.iloc[:,[1]] = Input.iloc[:,[1]].apply(Split,axis=1)
	Input = Input.iloc[:,[0,1]]
	Input.columns = ['Gene_ID','ARDB_ID']
	ARDB_annotation = pd.merge(Input,Anno,on='ARDB_ID',how='inner')
	ARDB_annotation.to_csv(args.output , sep='\t' , index=0)

	print("work is done")		

if __name__=='__main__':
	main()
