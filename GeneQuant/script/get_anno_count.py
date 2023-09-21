import os
import argparse

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"


def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input',dest='input',nargs="+")
	parser.add_argument('-o','--out',help='out',dest='out',required=True)
	args=parser.parse_args()

	all_sample = []
	all_TPM = {}
	all_gene = []
	for infile in args.input:
		all_TPM,geneList, sample = read_infile(infile, all_TPM )
		all_sample.append(sample)
		all_gene.extend(geneList)
	all_gene_set = list(set(all_gene))
	
	with open( args.out, 'w') as output:
		output.write("#Gene\t"+"\t".join(all_sample)+"\n")
		for gene_name in all_gene_set:
			cout = [gene_name]
			for sample in all_sample:
				if gene_name in all_TPM[sample].keys():
					cout.append(all_TPM[sample][gene_name])
				else:
					cout.append("0")
			if cout.count("0") == len(all_sample):continue
			output.write("\t".join(cout)+"\n")

if __name__ == "__main__":
	main()
