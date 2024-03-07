#! /usr/bin/env python3
import argparse
import sys
import os
import re
import pprint

__author__='Liu Tao'
__mail__= 'taoliu@annoroad.com'
__modifier__= 'Liuhuiling'

'''
	info in column Kegg, gene_ontology_blast and gene_ontology_pfam
'''

pat1=re.compile('^\s+$')

def output(f_file,in_dict):
	r_list=[]
	r_kegg = {}
	r_go   = {}
	for line in f_file:
		if line.startswith('#') or re.search(pat1,line):continue
		tmp=line.rstrip().split('\t')
		name = tmp[1]
		if tmp[2] != '.' :
			uniprot_id = tmp[2].split('|')[1]
			if uniprot_id in in_dict:
				if not name in r_kegg:
					r_kegg[name] = []
				for i in in_dict[uniprot_id]:
					if not i in r_kegg[name]:
						r_kegg[name].append(i)
		if tmp[11] != '.':
			gos =[i.split('^')[0] for i in  tmp[11].split('`')]
			if not name in r_go:
				r_go[name]=[]
			for i in gos:
				if not i in r_go[name]:
					r_go[name].append(i)
		else:
			pass
	return r_kegg,r_go

def readKEGG(f_file):
	r_dict={}
	for line in f_file:
		if line.startswith('#') or re.search(pat1,line):continue
		if line.startswith('geneID'):continue
		tmp=line.rstrip().split('\t')
		for i in tmp[1].split('|'):
			if re.search(pat1,i):continue
			uniprot_id = i.replace('up:','')
			if not uniprot_id in r_dict:
				r_dict[uniprot_id]=[]
			for ko in tmp[2].split('|'):
				if not ko in r_dict[uniprot_id]:
					r_dict[uniprot_id].append(ko)
	return r_dict

def getKoGo(trinotate):
	r_go = {}
	r_ko = {}
	r_gn_ko = {}
	colnm= {} 
	for index,line in enumerate(trinotate):
		if re.search(pat1,line):continue
		tmp=line.rstrip().split('\t')
		if index == 0:
			colnm['Ko'] = [index for index,item in enumerate(tmp) if item.capitalize() == 'Kegg']
			print('Ko colnm\t',colnm['Ko'])
			colnm['Go'] = ([index for index,item in enumerate(tmp) if item.startswith('gene_ontology')])
			print('Go colnm\t',colnm['Go'])
			continue
		name = tmp[1]
		
		if tmp[colnm['Ko'][0]] != '.':
			ko_anno = tmp[colnm['Ko'][0]]
			kos =[i.split(':')[1] for i in ko_anno.split('`') if i.startswith('KO:')]
			gn_kos =[':'.join(i.split(':')[1:]) for i in ko_anno.split('`') if i.startswith('KEGG:')]
			for i in kos:
				r_ko.setdefault(name,[]).append(i)
			for i in gn_kos:
				r_gn_ko.setdefault(name,[]).append(i)

		for i in colnm['Go']:
			if tmp[i] != '.':
				gos = [i.split('^')[0] for i in tmp[i].split('`')]
				for i in gos:
					r_go.setdefault(name,[]).append(i)
	return r_ko,r_gn_ko,r_go

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='trinotate.xls',dest='input',type=argparse.FileType('r'),required=True)
	#parser.add_argument('-d','--database',help='kegg database file',dest='database',type=argparse.FileType('r'),required=True)
	parser.add_argument('-p','--prefix',help='prefix file',dest='prefix',required=True)
	args=parser.parse_args()
	
	#uniprot2kegg=readKEGG(args.database)
	#kegg,go = output(args.input,uniprot2kegg)

	kegg,kegg_gnid,go = getKoGo(args.input)
	with open('{0}.kegg.list'.format(args.prefix),'w') as o_file:
		for i in kegg:
			o_file.write('{0}\t{1}\n'.format(i,"\t".join(kegg[i])))

	with open('{0}.kegg_gnid.list'.format(args.prefix),'w') as o_file:
		for i in kegg_gnid:
			o_file.write('{0}\t{1}\n'.format(i,"\t".join(kegg_gnid[i])))

	with open('{0}.go.list'.format(args.prefix),'w') as o_file:
		for i in go:
			o_file.write('{0}\t{1}\n'.format(i,"\t".join(go[i])))



if __name__=='__main__':
	main()
