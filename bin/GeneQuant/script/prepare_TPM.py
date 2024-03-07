import os
import argparse

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def readfile(file1):
	dic = {}
	gene = []
	with open(file1) as infile:
		for line in infile:
			if line.startswith("Name"):continue
			tmp = line.strip().split("\t")
			dic[tmp[0]] = str(tmp[1])
			gene.append(tmp[0])
	return dic,gene

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input',dest='input',nargs="+")
	parser.add_argument('-o','--out',help='out',dest='out',type=argparse.FileType('w'))
	args=parser.parse_args()

	all_sample = []
	all_TPM = {}
	gene = []
	for name in args.input:
		sample = os.path.basename(name).split(".")[0]
		all_sample.append(sample)
		all_TPM[sample],ge = readfile(name)
		gene.extend(ge)
	gene = list(set(gene))
	print(all_sample)
	args.out.write("gene\t"+"\t".join(all_sample)+"\n")
	for gene_name in gene:
		cout = [gene_name]
		for sample in all_sample:
			if gene_name in all_TPM[sample].keys():
				cout.append(all_TPM[sample][gene_name])
			else:
				cout.append("0")
		if cout.count("0") == len(all_sample):continue
		args.out.write("\t".join(cout)+"\n")

if __name__ == "__main__":
	main()
