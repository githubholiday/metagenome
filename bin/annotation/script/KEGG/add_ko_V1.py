#! /usr/bin/env python3
'''
this file is used to append annotation from file2  for specified col in file1. if id in file1 is not existed in file2, then this id have no annation.
example:
	python3 add_annotation.py -i /annoroad/bioinfo/PROJECT/Commercial/Cooperation/NGS3361_popS/3361_2/liutao/Analysis/cmp/cuffdiff/A_B/DE_A_B.xls -ic 2 -a /annoroad/bioinfo/PMO/share/database/pop/annotation/database/annotation/Ptrichocarpa_210_defline.txt -ac 0 1 -o test
'''
import argparse
import sys
import os
import re

__author__='Liu Tao'
__mail__= 'taoliu@annoroad.com'
__modifier='Liu Huiling'

'''
	add detailed expression about KO and map
'''
pat1=re.compile('^\s+$')

def read_annotation(f_file,col):
	r_dict = {}
	r_list = []
	for line in f_file:
		if line.startswith('#') or re.search(pat1,line):continue
		tmp=line.rstrip().split('\t')
		id = tmp[col[0]].rsplit('.',1)[0]
		if not id in r_dict:
			r_dict[id] = tmp[1:] 
			for i in tmp[1:]:
				r_list.append(i)
	r_list = set(r_list)
	return r_dict,r_list

def append_annotation(i_file,col,ko_id,o_file,symbols,ko2map,ko_desc):
	for line in i_file:
		if line.startswith('#') or re.search(pat1,line):
			o_file.write('{0}\t{1}\t{2}\n'.format(line.rstrip(),'KO','Map'))
			continue
		if line.startswith('ID'):
			o_file.write('{0}\t{1}\t{2}\n'.format(line.rstrip(),'KO','Map'))
			continue
		tmp=line.rstrip().split('\t')
		gene = tmp[col]
		anno = [symbols]
		ko_and_desc = []
		map_and_desc = []
		if gene in ko_id:
			for ko in ko_id[gene]:
				if ko in ko_desc:
					ko_and_desc.append('{0}'.format(ko_desc[ko]))
				if ko in ko2map:
					for map in ko2map[ko]:
						map_and_desc.append('{0}'.format(map))
		
		if len(ko_and_desc) == 0:
			ko_and_desc = anno
		if len(map_and_desc) == 0:
			map_and_desc = anno
		o_file.write('{0}\t{1}\t{2}\n'.format('\t'.join(tmp),';'.join(ko_and_desc),';'.join(map_and_desc)))

def read_ko2map(f_file,map_desc,ko_list):
	d_ko2maps={}
	for line in f_file:
		if line.startswith('#') or re.search(pat1,line):continue
		tmp = line.rstrip().split('\t')
		kos , maps =tmp[2],tmp[3]
		if maps == '--': continue 
		for ko in kos.split('|'):
			if not ko in ko_list:
				continue
			if not ko in d_ko2maps:
				d_ko2maps[ko] = []
			for map in maps.split('|') :
				if  map in map_desc and not map_desc[map] in d_ko2maps[ko]:
					d_ko2maps[ko].append(map_desc[map])
	return d_ko2maps

def read_desc(f_file):
	record={}
	for line in f_file:
		if line.startswith('#') or re.search(pat1,line):continue
		tmp = line.rstrip().split('\t')
		id, desc = tmp[0].split(':')[1], tmp[1]
		if not id in record :
			record[id] = id+'|'+desc
		else:
			print('{0} is repeat'.format(id))
	return record

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input file',dest='input',type=open,required=True)
	parser.add_argument('-ic','--col',help='id col in file1',dest='col',type=int,default=0)
	parser.add_argument('-a','--annotation',help='ko id in kegg annotation extract from trinotate',dest='anno',type=open,required=True)
	parser.add_argument('-ac','--ancol',help='id col and annotation col in file2',dest='acol',nargs='+',type=int,required=True)
	#parser.add_argument('-g','--gnid',help='gnid in kegg annotation extract from trinotate',dest='gnid',type=open,required=True)
	parser.add_argument('-o','--output',help='output file',dest='output',type=argparse.FileType('w'),required=True)
	parser.add_argument('-m','--map',help='ko2map file',dest='map',default='/annogene/cloud/bioinfo/PMO/yuezhang/pipeline/MetaGenomes/bin/software/product/Annotation/script/KEGG/kegg.list',type=open)
	parser.add_argument('-k','--ko',help='ko name list',dest='ko',default='/annogene/cloud/bioinfo/PMO/yuezhang/pipeline/MetaGenomes/bin/software/product/Annotation/script/KEGG/ko.list',type=open)
	parser.add_argument('-n','--name',help='map name list',dest='name',default='/annogene/cloud/bioinfo/PMO/yuezhang/pipeline/MetaGenomes/bin/software/product/Annotation/script/KEGG/pathway.list',type=open)
	parser.add_argument('-unknown',help='unknown symbol',dest='unknown',default='.')
	args=parser.parse_args()

	ko_id,ko_list = read_annotation(args.anno,args.acol)
	#kegg_id = read_annotation(args.gnid,args.acol)
	
	ko_desc = read_desc(f_file=args.ko)
	map_desc = read_desc(f_file=args.name)
	print('got description for ko and map.')

	ko2map = read_ko2map(args.map,map_desc,ko_list)
	print('got map for ko.' )

	append_annotation(i_file=args.input,col=args.col,ko_id=ko_id,o_file=args.output,symbols=args.unknown,ko2map=ko2map,ko_desc=ko_desc)

if __name__=='__main__':
	main()

