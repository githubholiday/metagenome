#! /usr/bin/env python3
import argparse
import sys
import time
import os
import re
import pandas as pd
__author__='zhang yang'
__mail__= 'yangzhang@genome.cn'



def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-o','--output',help='output file',dest='output',required=True)
	parser.add_argument('-i','--input',help='input file',dest='input')
	parser.add_argument('-t','--TPM',help='tpm file',dest='tpm',required=True)
	args=parser.parse_args()
	# 读取tpm文件
	TPM = pd.read_csv(args.tpm, low_memory=False, index_col=0, sep="\t")
	IN = pd.read_csv(args.input, sep="\t")
	row_len = len(IN)
	all_result = pd.DataFrame()
	for i in range(row_len):
		genes = IN['Gene'].iloc[i]
		gene = genes.split(";")
		tmp_df = TPM.loc[gene,:]
		tmp_df2 = tmp_df.apply(lambda x: x.sum()).to_frame()
		all_result = pd.concat([all_result,tmp_df2.T])
	all_result.index = range(len(all_result))
	all_result['Accession'] = IN['Accession']
	final_df = pd.merge(IN,all_result,how='inner',on='Accession')
	final_df.to_csv(args.output,sep='\t',header=True, index=False)

if __name__=='__main__':
	print('Start : ',time.ctime())
	main()
	print('End : ',time.ctime())