#! /usr/bin/env python3
import argparse
import time
import sys
import re
import os
bindir = os.path.abspath(os.path.dirname(__file__))

__author__ = 'Liu Huiling'
__mail__ = 'huilingliu@genome.cn'
__doc__ = 'the description of program'

pat1=re.compile('^s+$')

def readConf(i_file):
	h_dict = {}
	new_index = {}
	order = 0
	for line in i_file:
		lines = line.rstrip('\n').split('\t')
		#_dict[lines[0]] = lines[1]
		for i in lines[1].split(','):
			if i == '0': continue
			h_dict[lines[0]] = lines[1]
			if not i in new_index:
				new_index[i] = order
				order +=1
			else:
				continue
	return h_dict,new_index

def blast_score(blast_result,colnm=12):#default blast result format
	s_dict = {}
	for index,info in enumerate(blast_result):
		tmp = info.rstrip('\n').split('\t')
		if re.search('::',tmp[0]):
			key = tmp[0].split('::')[1] + '\t'+tmp[1]
		else:
			key = tmp[0]+'\t'+tmp[1]
		if not key in s_dict:
			if colnm == 12:
				s_dict[key] = tmp[11] # bit_score
			else :
				s_dict[key] = tmp[colnm-2] + '|' + tmp[colnm-1] #bit_score and description together in blast result
	return s_dict

def anno_blast(query,info,score,raw_header,new_header,new_index,new_anno): #uniprot,NT,NR
	hit = '.'
	evalue = '.'
	hit_score = '.'
	description = '.'
	if info != '.':
		tmp = info.split('^')
		hit = tmp[0]
		evalue = tmp[-3]
		key = query + '\t' + hit
		if len(score[key].split('|')) == 2:
			hit_score,description = score[key].split('|')
		else :
			hit_score = score[key].split('|')[0]
			description = tmp[-2] + '^' + tmp[-1]
	for h in new_header[raw_header].split(','):
		index = new_index[h]
		if h.endswith('TopHit'):
			new_anno[index] = hit
		elif h.endswith('Score'):
			new_anno[index] = hit_score
		elif h.endswith('Evalue'):
			new_anno[index] = evalue
		elif h.endswith('Description'):
			new_anno[index] = description
		else :
			continue
	return new_anno

def anno_prodb(info,raw_header,new_header,new_index,new_anno): #pfam and eggNOG
	hit = '.'
	name = '.'
	description = '.'
	if info != '.':
		tmp = info.split('`')[0]
		hit = tmp.split('^')[0]
		len_tmp = len(tmp.split('^'))
		if len_tmp == 5 :
			name = tmp.split('^')[1]
			description = tmp.split('^')[2]
		elif len_tmp == 2 :
			description = tmp.split('^')[1]
		else :
			print('Wrong colnm for pfam or eggNOG.')
			exit()
	for h in new_header[raw_header].split(','):
		index = new_index[h]
		if h.endswith('TopHit'):
			new_anno[index] = hit
		elif h.endswith('Name'):
			new_anno[index] = name
		elif h.endswith('Description'):
			new_anno[index] = description
		else:
			continue
	return new_anno

def anno_go(info,raw_header,new_header,new_index,new_anno):

	BP,CC,MF = '','',''

	if info != '.':
		tmp = info.split('`')
		for go in tmp:
			detail = go.split('^')
			if detail[1] == 'cellular_component':
				CC += '{0}|{1};'.format(detail[0],detail[2])
			elif detail[1] == 'biological_process':
				BP += '{0}|{1};'.format(detail[0],detail[2])
			elif detail[1] == 'molecular_function':
				MF += '{0}|{1};'.format(detail[0],detail[2])
			else :
				print('Wrong class for go!')
				exit()
	BP = BP.rstrip(';')
	CC = CC.rstrip(';')
	MF = MF.rstrip(';')

	for h in new_header[raw_header].split(','):
		index = new_index[h]
		if not index in new_anno:
			new_anno[index] = ''
		if h == 'GO_cellular_component':
			new_anno[index] += CC
		elif h == 'GO_biological_process':
			new_anno[index] += BP
		elif h == 'GO_molecular_function':
			new_anno[index] += MF
	
	return new_anno

def anno_rename(info,raw_header,new_header,new_index,new_anno):
	
	if len(new_header[raw_header].split(',')) !=1 :
		print ('More than 1 colnm to split')
		exit()
	else:
		h = new_header[raw_header]
		index = new_index[h]
		new_anno[index] = info
	return new_anno

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter)
	parser.add_argument('-i','--input',help='input file',dest='input',type=open,required=True)
	parser.add_argument('-c','--conf',help='the header config file',dest='conf',type=open,required=True)
	parser.add_argument('-bx','--bx',help='the swiss blastx result',dest='bx',type=open,required=True)
	parser.add_argument('-bp','--bp',help='the swiss blastp result',dest='bp',type=open,required=True)
	parser.add_argument('-nt','--nt',help='the nt blast result',dest='nt',type=open,required=True)
	parser.add_argument('-nr','--nr',help='the nr blast result',dest='nr',type=open,required=True)
	parser.add_argument('-d','--des',help='the description colnm',dest='des',type=int,default=13,required=True)
	parser.add_argument('-o','--output',help='output file',dest='output',type=argparse.FileType('w'),required=True)
	args=parser.parse_args()
	
	bx_score = blast_score(blast_result=args.bx)
	bp_score = blast_score(blast_result=args.bp)
	nt_score = blast_score(blast_result=args.nt,colnm=args.des)
	nr_score = blast_score(blast_result=args.nr,colnm=args.des)
	header, new_index = readConf(args.conf)
	colnm = {}
	print(new_index)
	#print(header)
	for index,line in enumerate(args.input):
		if re.search(pat1,line):continue
		lines = line.rstrip('\n').split('\t')
		output = ''
		if index ==0 :
			for h in header:
				colnm[h] = [ index for index,item in enumerate(lines) if item == h ]
			for i in sorted(new_index.items(),key = lambda item:item[1]) :
				output += i[0] + '\t'
			args.output.write(output.rstrip('\t')+'\n')
			continue
		new_anno = {}
		for i,info in enumerate(lines):
			for h in colnm:
				if colnm[h][0] == i and h == 'sprot_Top_BLASTX_hit':
					new_anno = anno_blast(query=lines[1],info=info,score=bx_score,raw_header=h,new_header=header,new_index=new_index,new_anno=new_anno)
				elif colnm[h][0] == i and h == 'sprot_Top_BLASTP_hit':
					new_anno = anno_blast(query=lines[1],info=info,score=bp_score,raw_header=h,new_header=header,new_index=new_index,new_anno=new_anno)
				elif colnm[h][0] == i and h == 'NT_BLASTX':
					new_anno = anno_blast(query=lines[1],info=info,score=nt_score,raw_header=h,new_header=header,new_index=new_index,new_anno=new_anno)
				elif colnm[h][0] == i and h == 'NR_BLASTX':
					new_anno = anno_blast(query=lines[1],info=info,score=nr_score,raw_header=h,new_header=header,new_index=new_index,new_anno=new_anno)
				elif colnm[h][0] == i and h == 'Pfam':
					new_anno = anno_prodb(info=info,raw_header=h,new_header=header,new_index=new_index,new_anno=new_anno)
				elif colnm[h][0] == i and h == 'eggnog':
					new_anno = anno_prodb(info=info,raw_header=h,new_header=header,new_index=new_index,new_anno=new_anno)
				elif colnm[h][0] == i and h.startswith('gene_ontology'):
					new_anno = anno_go(info=info,raw_header=h,new_header=header,new_index=new_index,new_anno=new_anno)
				elif colnm[h][0] == i:
					new_anno = anno_rename(info=info,raw_header=h,new_header=header,new_index=new_index,new_anno=new_anno)
		for index in new_anno:
			if new_anno[index] == '':
				new_anno[index] = '.'
			output += '{0}\t'.format(new_anno[index])
		output.rstrip('\t')
		args.output.write(output+'\n')

if __name__ == '__main__':
	main()
