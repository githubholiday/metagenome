#!/usr/bin/python
# -*- coding: UTF-8 -*-
import argparse
import os
import sys
import re
import math
import time
######################################################################### ___  ##########################################################
__author__ = 'liaorui'
__mail__ = 'ruiliao@genome.cn'
__date__ = '2020年11月23日'
__version__ = '1.0.1'

def CheckFile(file):
	if os.path.exists(file):
		return
	else:
		print("\n错误: {} 文件不存在！\n".format(file))
		sys.exit(1)

def CheckNucSeq(ID,seq):
	for i in seq:
		if i not in ["A","T","C","G","N","a","t","c","g","n"]:
			if i in ["R","Y","M","K","S","W","H","B","V","D","N"]:
				print("警告(忽略): 简并碱基 {0} 在序列 {1} 中！\n``` ({2}) ```".format(i,ID,seq))
			else:
				print("错误: 未知字符 {0} 在序列 {1} 中！\n``` ({2}) ```".format(i,ID,seq))
				sys.exit(1)
	return(seq)


def ReadFasta(file,key):
	seq = ""
	seq_dic = {}
	ID_list = []
	for line in file:
		line = line.strip()
		if line.startswith("#") or not len(line):
			continue
		elif line.startswith(">"):
			if seq:
				seq_dic[ID] = seq
				ID_list.append(ID)
			ID = line
			seq = ""
		else:
			if key == "Nuc":
				line = CheckNucSeq(ID,line)
			elif key == "Pro":
				line = CheckProSeq(ID,line)
			seq = seq + line
	seq_dic[ID] = seq
	ID_list.append(ID)
	if len(ID_list) != len(seq_dic):
		print("错误:序列中含有重复id！")
		sys.exit(1)
	return(seq_dic,ID_list)


def GetStats(seq_dic,out_file1,out_file2,input):
	len_dic = {}
	L = 0
	min = 9999999999999
	max = 0
	for i in seq_dic:
		l = len(seq_dic[i])
		if l > max:
			max = l
			max_ID = [i[1:]]
		elif l == max:
			max_ID.append(i[1:])
		if l < min:
			min = l
			min_ID = [i[1:]]
		elif l == min:
			min_ID.append(i[1:])
		L += l
		len_dic[i[1:]] = l
	num = len(len_dic)
	mean = round(L/num,2)
	max_id = ','.join(max_ID)
	min_id = ','.join(min_ID)
	out_file1.write("Seq_Num\t{0}\nTotle_Len\t{1}\nMean_Len\t{2}\nMin_Len\t{3}\nMin_ID\t{4}\nMax_Len\t{5}\nMax_ID\t{6}\n".format(num,L,mean,min,min_id,max,max_id))
	in_file = open(input)
	dna = ''
	for line in in_file:
		if line.startswith('>'):
			id = line.strip()[1:]
		else:
			dna += line.strip()
	dna=dna.upper()
	c = dna.count('C')
	g = dna.count('G')
	n = dna.count('N')
	gc = g + c
	content =100 * gc / len(dna)
	ncontent =100 * n /len(dna)
	out_file1.write("GC_content\t{0:.2f}%\nN_content\t{1:.2f}%\n".format(content,ncontent))
	out_file2.write("seqID\tseqlength\tGC_content(%)\n")
	for i in seq_dic:
		seq = seq_dic[i].upper()
		c = seq.count('C')
		g = seq.count('G')
		gc = g + c
		GC = 100 * gc / len(seq)
		N = 100 * n /len(seq)
		length = len(seq_dic[i])
		id = i.replace(">","")
		out_file2.write("{0}\t{1}\t{2:.2f}\n".format(id,length,GC))
	out_file1.close()
	out_file2.close()



def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\nversion:\t{3}\n'.format(__author__,__mail__,__date__,__version__))
	parser.add_argument('-i',help='input file',dest='input',type=str,required=True)
	parser.add_argument('-fa',help='input file is nucleotide sequence in fasta format',dest='fasta', action='store_true')
	parser.add_argument('-stats',help='print stats of sequence',dest='stats', action='store_true')
	parser.add_argument('-o',help='output file',dest='output',type=str,required=False)
	parser.add_argument('-od',help='output file2',dest='output2',type=str,required=False)
	args=parser.parse_args()
	CheckFile(args.input)
	seq_file = open(args.input,'r')
	if not args.output and not args.outdir:
		print("\n错误: 必须指明输出文件/输出路径(参数 -o/-od )！\n")
		sys.exit(1)
	elif args.stats:
		out_file1 = open(args.output,'w')
		out_file2 = open(args.output2,'w')
		if not args.fasta and not args.fastq and not args.protein:
			print("\n错误: 必须指明输入文件类型(参数 -fa/-fq/-prot )！\n")
			sys.exit(1)
		if args.fasta:
			seq_dic,ID_list = ReadFasta(seq_file,"Nuc")
		elif args.fastq:
			seq_dic,ID_list = ReadFastq(seq_file)
		elif args.protein:
			seq_dic,ID_list = ReadFasta(seq_file,"Pro")
		GetStats(seq_dic,out_file1,out_file2,args.input)
	seq_file.close()

if __name__=="__main__":
	print('Start : ',time.ctime())
	main()
	print('End : ',time.ctime())


