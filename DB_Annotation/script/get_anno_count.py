'''
将注释结果按照样本计算每个条目的丰度值
'''

import os
import argparse

__author__ = "chengfangtu"
__mail__ = ""

def read_anno( anno_file, col=1 ):
	anno_dict = {}
	with open( anno_file, 'r' ) as anno:
		for line in anno:
			tmp = line.strip().split("\t")
			gene = tmp[0]
			anno_id = tmp[col]
			if gene not in anno_dict :
				anno_dict[gene] = ''
			anno_dict[gene] = anno_id
			#if anno_id not in anno_dict :
				#anno_dict[anno_id] = []
			#anno_dict[anno_id].append(gene)
	return anno_dict
			

def get_anno_count( count_file, anno_dict):
	
	anno_count_dict = {}
	sample_list = []
	with open(count_file, 'r') as infile:
		for line in infile:
			tmp = line.strip().split("\t")
			if line.startswith("#"):
				sample_list = tmp[1:]
				continue
			gene = tmp[0]
			count_list = tmp[1:]
			for i in range(len(count_list)):
				sample = sample_list[i]
				count = count_list[i]
				if gene not in anno_dict:
					continue
				anno_id = anno_dict[gene]
				if anno_id not in anno_count_dict:
					anno_count_dict[anno_id] = {}
				if sample not in anno_count_dict[anno_id]:
					anno_count_dict[anno_id][sample] = 0
				anno_count_dict[anno_id][sample] += float(count)
	return anno_count_dict, sample_list 

def write_anno_count( anno_count_dict, sample_list, output ):
	with open(output, 'w') as outfile:
		outfile.write("#Anno\t"+"\t".join(sample_list)+"\n")
		for anno_id in anno_count_dict:
			cout = [anno_id]
			for sample in sample_list:
				if sample in anno_count_dict[anno_id]:
					anno_count = str(anno_count_dict[anno_id][sample])
					cout.append(anno_count)
				else:
					cout.append("0")
			outfile.write("\t".join(cout)+"\n")

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-a','--anno',help='anno file',dest='anno')
	parser.add_argument('-c','--count',help='gene count file of all sample',dest='count',required=True)
	parser.add_argument('-col','--col',help='the col of anno in anno file',dest='count',required=True)
	parser.add_argument('-o','--output',help='output of anno count',dest='output',required=True)
	args=parser.parse_args()

	gene_anno_dict = read_anno(args.anno, 1)
	anno_count_dict, sample_list = get_anno_count(args.count, gene_anno_dict)
	write_anno_count(anno_count_dict, sample_list, args.output)
	

if __name__ == "__main__":
	main()
