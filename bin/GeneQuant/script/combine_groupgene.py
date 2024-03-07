import os
import sys
import argparse

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def gene_list(file1):
	gene = []
	with open(file1) as infile:
		for line in infile:
			tmp = line.strip().split("\t")
			gene.append(tmp[0])
	infile.close()
	num = len(set(gene))
	return num


def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input',dest='input',nargs="+")
	parser.add_argument('-c','--cmp',help='cmp',dest='cmp')
	parser.add_argument('-o','--out',help='out',dest='out',type=argparse.FileType('w'))
	args=parser.parse_args()

	cmp_dic = {}
	with open(args.cmp) as cmp:
		for line in cmp:
			if line.startswith("Sample"):continue
			tmp = line.strip().split("\t")
			cmp_dic[tmp[0]] = tmp[1]
	print(cmp_dic)
	all_gene = {}
	args.out.write("sample\tgene_number\n")
	for i in args.input:
		sample = os.path.basename(i).split(".count.txt")[0]
		print(sample)
		group = cmp_dic[sample]
		gene_num = gene_list(i)
		args.out.write("\t".join([group,str(gene_num)])+"\n")

if __name__ == "__main__":
	main()
