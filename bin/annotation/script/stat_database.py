import argparse
import sys
import os

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"
__date__ = "20220303"

def read_file(file1):
	gene = []
	with open(file1) as infile:
		for line in infile:
			if line.startswith("Gene_ID"):continue
			tmp = line.strip().split("\t")
			gene.append(tmp[0])
	return gene

def read_fasta(file2):
	gene_all = []
	with open(file2) as infile:
		for line in infile:
			if line.startswith(">"):
				gene_all.append(line.strip().replace(">","",1))
	return gene_all

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input file',dest='input',nargs="+",required=True)
	parser.add_argument('-f','--fasta',help='all gene fasta file',dest='fasta',required=True)
	parser.add_argument('-o','--output',help='output file',dest='out',type=argparse.FileType('w'),required=True)
	parser.add_argument('-d','--database',help='database',dest='database',required=True)
	args=parser.parse_args()

	database = args.database.split(",")
	gene_all = len(set(read_fasta(args.fasta)))
	num_dic = {}
	anno_gene = []
	for i in args.input:
		file_name = [ x for x in database if x.upper() in os.path.basename(i).upper()]
		if file_name:
			gene_name = read_file(i)
			num_dic[file_name[0]] = len(set(gene_name))
			anno_gene.extend(gene_name)
	anno_gene_num = len(set(anno_gene))
	args.out.write("Database\tCount\tPercentage(%)\n")
	for i in database:
		args.out.write("\t".join([i.upper(),str(num_dic[i]),str('%.2f' %(num_dic[i]/gene_all*100))])+"\n")
	args.out.write("Total_anno\t"+str(anno_gene_num)+"\t"+str('%.2f' %(anno_gene_num/gene_all*100))+"\n")
	args.out.write("Total_gene\t"+str(gene_all)+"\t"+str('%.2f' %(gene_all/gene_all*100))+"\n")
if __name__ == "__main__":
	main()
