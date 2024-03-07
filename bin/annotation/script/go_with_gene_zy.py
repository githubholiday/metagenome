#! /usr/bin/env python3
import argparse
import sys
import time
import os
import re
import pandas as pd
__author__='zhang yang'
__mail__= 'yangzhang@genome.cn'
pat1=re.compile('^\s+$')
'''
Example:
	python3 this.py -p go.path -s go.alias -c go.class -g go.list -i de.list -o out_prefix
'''
def Read_Alias(alias_file): #read the alias for go
	dict = {}
	with open(alias_file,'r') as f:
		for i,line in enumerate(f):
			tmp = line.rstrip().split('\t')
			for go in tmp[1:]:
				dict[go] = tmp[0]
	f.close()
	return dict

def Gene_in_GO(go_file,alias_dict): #find all gene in a seperate go
	warning = set()
	with open(go_file,'r') as f:
		dict = {}
		total_set = set()
		for i,line in enumerate(f):
			tmp = line.rstrip().split('\t')
			total_set.add(tmp[0])
			for go in tmp[1:]:
				if go in alias_dict:
					warning.add("{0}\treplaced by\t{1}".format(go,alias_dict[go]))
					go = alias_dict[go] #replace the alias with go exists in term.txt 
				dict.setdefault(go,set()).add(tmp[0])
	f.close()
	print ('\n'.join(warning))
	return dict,total_set

def Extend_Go(go_with_gene,go_path): 
	# 可以将所有的子ID里的基因补充到父ID的基因列表里。从而实现信息完整。
	# print(go_with_gene) 字典格式，键为GO ID，值为所有的gene
	# print(go_path) 数据框 按照BP,CC,MF分成三个框，每次分析用一个
	# print(go_with_gene)
	for i,row in go_path.iterrows(): # i, onthology; row, go in path
		row = row.dropna(axis=0,how='all')
		tmp_list = row.values.tolist()
		tmp_list.reverse() #from 0 to len(tmp_list), leaf to root
		while len(tmp_list) > 1:
			if not tmp_list[0] in  go_with_gene:
				tmp_list.remove(tmp_list[0]) #remove leaf which have no gene-annotation
				continue
			parent = tmp_list[1] #parent for leaf
			if not parent in go_with_gene : go_with_gene.setdefault(parent,set())
			go_with_gene[parent].update(go_with_gene[tmp_list[0]])
			tmp_list.remove(tmp_list[0]) #remove leaf
	# print(go_with_gene)
	return go_with_gene

def Extract_Class(class_file,info,group_name):
	Ontology = ['cellular_component','biological_process','molecular_function']
	
	info['Accession'] = info.index
	df = pd.read_csv(class_file, header = 0, index_col = None, sep="\t")
	group_df = df.groupby(df.Ontology,as_index=False)
	for name,group in group_df:
		if not name in Ontology :
			print('Illegal Ontology in class file !')
			exit()
		if name != group_name : continue
		result = pd.merge(group.loc[:,['Ontology','Term_name','Accession']], info, on='Accession', how ='inner', copy =False)
	return result

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-o','--outfile',help='outfile',dest='outfile',required=True)
	parser.add_argument('-i','--input',help='input file',dest='input')
	parser.add_argument('-p','--path',help='path file',dest='path',required=True)
	parser.add_argument('-s','--alias',help='go alias file',dest='alias',required=True)
	parser.add_argument('-c','--classify',help='go class file',dest='classify',required=True)
	args=parser.parse_args()
	
	Ontology = ['cellular_component','biological_process','molecular_function']
	# get go alias info
	go_alias_dict = Read_Alias(args.alias)

	# get N and M for go list in database
	go_with_background, total_set = Gene_in_GO(args.input,go_alias_dict) #return dict
	go_path = pd.read_csv(args.path, low_memory=False, header=None, index_col=0, sep="\t") #自动补成NA，长度最后一致。
	go_path = go_path.drop(go_path.loc[:,[1]], axis=1) #drop col1= ontology accession
	
	all_go_with_gene = pd.DataFrame()	
	group_path = go_path.groupby(go_path.index,as_index=False) #group by ontology to lower resource used
	for name,group in group_path:
		if not name in Ontology :
			print('Illegal Ontology in class file !')
			exit()
		extend_go_with_background = Extend_Go(go_with_background,group)
		print(time.ctime())
		union_keys = set(extend_go_with_background.keys())
		union_dict = {}
		for key in union_keys:
			union_dict[key] =[';'.join(extend_go_with_background[key])]
		union = pd.DataFrame.from_dict(union_dict, orient='index')
		union.columns = ['Gene']
		gene_result = Extract_Class(args.classify,union,name)
		all_go_with_gene = pd.concat([all_go_with_gene,gene_result])
	
	all_go_with_gene.to_csv(args.outfile, sep='\t',header=True, index=False)

if __name__=='__main__':
	print('Start : ',time.ctime())
	main()
	print('End : ',time.ctime())