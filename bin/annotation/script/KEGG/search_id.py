#! /usr/bin/env python3
import argparse
import sys
import os
import gzip
import re

pat1=re.compile('^\s*$')
pat2=re.compile(b'^\s*$')

__author__='Liu Tao'
__mail__= 'taoliu@annoroad.com'

def read_list(f_file,col=0):
	r_dict={}
	for line in f_file:
		if line.startswith('#') or re.search(pat1,line) :continue
		tmp=line.rstrip().split('\t')
		i=tmp[col] 
		id=re.split('[;,\s]',i.lower().rstrip())[0]
		if id == '--':continue
		#tmp=line.rstrip().split()
		if not id in r_dict:
			r_dict[id]=1
		else:
			print('{0} is repeated,please check it'.format(id),file=sys.stderr)
	return r_dict

def nm2geneid(f_file,d_dict,col,species,nm):
	r_dict={}
	for line in f_file:
		if line.startswith(b'#') or re.search(pat2,line) :continue
		tmp=line.decode().rstrip().split('\t')
		if species != None  and species != tmp[0] : continue
		for i in col[0:len(col)-1]:
			id=tmp[i]
		#print(id)
			if nm :
				id=id.lower().split(r'.')[0] ### for NM000.0 , to remove modified version
			id = id.lower()
			if id in d_dict:
			#print(id)
				if not id in r_dict:
					r_dict[id]=[]
				if not tmp[col[-1]] in r_dict[id]:
					r_dict[id].append(tmp[col[-1]])
	return r_dict

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-l','--list',dest='list',help='input list',required=True)
	parser.add_argument('-c','--col',dest='col',help='which col contains nm id in  input file',type=int,default=0)
	parser.add_argument('-r','--ref',dest='ref',help='gene2accession.gz download from ncbi',required=True)
	parser.add_argument('-f','--field',dest='field',help='which col contains nm_id and gene id',nargs='+',required=True,type=int)
	parser.add_argument('-o','--output',dest='output',help='output file',required=True,type=argparse.FileType('w'))
	parser.add_argument('-s','--species',dest='species',help='species id')
	parser.add_argument('-nm',dest='nm',help='ncbi or not,default is no ',default = 0,type =int)
	args=parser.parse_args()
	with open(args.list) as f_list:
		input_dict=read_list(f_list,args.col)
	#print(input_dict)
	#sys.exit()
	
	if args.ref.endswith('gz'):
		with gzip.open(args.ref,'rb') as f_file:
			output_dict=nm2geneid(f_file,input_dict,args.field,args.species,args.nm)
	else:
		with open(args.ref,'rb') as f_file:
			output_dict=nm2geneid(f_file,input_dict,args.field,args.species,args.nm)
	#print(output_dict)
	print('read ref finished')
	with open(args.list) as f_list:
		for line  in f_list:
			if line.startswith('#') or re.search(pat1,line) :continue
			tmp=line.rstrip().split('\t')
			i=tmp[args.col]
			id=re.split('[;,\s]',i.lower().rstrip())[0]
		#	print(id)
			if id in output_dict:
				#args.output.write('{0}\t{1}\n'.format(line.rstrip(),'|'.join(output_dict[id])))
				for kkk in output_dict[id] :
					args.output.write('{0}\t{1}\n'.format(line.rstrip(),kkk))
			else:
				args.output.write('{0}\t{1}\n'.format(line.rstrip(),'--'))

if __name__=='__main__':
	main()

