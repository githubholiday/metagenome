#!/usr/bin/env python3
# -*- coding:utf-8 -*-
# 2021/11/04
import argparse
import os
import sys

def all_samples(u_file):
	
	samples = []
	with open( u_file ) as f :
		for line in f :
			sam = line.strip().split('\t')[3]
			if not sam in samples:
				samples.append(sam)
	return samples

def main():
	parser=argparse.ArgumentParser(description='')
	parser.add_argument('-i', '--dir', help='input work dir', required=True)
	parser.add_argument('-s', '--sample', help='input sample list', required=True)
	parser.add_argument('-ob', '--out_bin', help='output bin num stat', required=True)
	parser.add_argument('-ot', '--out_tax', help='output taxonomy stat', required=True)
	args = parser.parse_args()
	
	samples=all_samples(args.sample)
	
	out_bin_num = open( args.out_bin, 'w')
	out_bin_num.write( 'Sample\tBin_number\n' )
	
	out_bin_tax = open( args.out_tax, 'w')
	out_bin_tax.write( "sample\ttaxonomy_name\ttaxonomy_count\ttaxonomy_percent(%)\n" )
	tax_dic = {}
	for sam in samples:
		bin_file = args.dir+'/'+sam+'/genome-binning-summarizer.xls'
		if os.path.exists( bin_file ):
			bin_num = 0
			if not sam in tax_dic:
				tax_dic[sam] = []
			with open( bin_file ) as f :
				for line in f :
					if line.startswith('BinName'): continue
					if line.startswith('\n'): continue
					bin_num += 1
					if line.strip().split('\t')[11] == "NA":
						item = "NA"
					else:
						item = line.strip().split('\t')[11].split(';')[5].split('g__')[1]
					tax_dic[sam].append( item )
			out_bin_num.write( sam+'\t'+str(bin_num)+'\n' )
		else:
			continue
	out_bin_num.close()
	
	for sample in tax_dic :
		values = tax_dic[sample]
		num = len( tax_dic[sample] )
		for i in set(values):
			a_num = values.count(i)
			percent = '%.2f'%( 100*float(a_num)/int(num) )
			out_bin_tax.write( sample + '\t' + i + '\t' + str(a_num) + '\t' + str(percent) + '\n'  )
	out_bin_tax.close()


if __name__ == '__main__':
	main()
