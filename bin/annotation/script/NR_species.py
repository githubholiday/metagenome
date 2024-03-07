import os
import argparse

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def get_file(file1,top):
	dic = {}
	top_species,top_num = [],[]
	with open(file1) as infile:
		for line in infile:
			if line.startswith("#"):continue
			tmp = line.strip().split("\t")
			if len(top_species) < top:
				top_species.append(tmp[0])
				top_num.append(tmp[1])
			else:
				if tmp[1] > max(top_num):
					min_num = top_num.index(min(top_num))
					top_species[min_num] = tmp[0]
					top_num[min_num] = tmp[1]
	infile.close()
	return top_species,top_num

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='the input file of species',dest='input',nargs='+',required=True)
	parser.add_argument('-o','--output',help='output file',dest='out',type=argparse.FileType('w'),required=True)
	parser.add_argument('-t','--top',help='top number',dest='top',required=True)
	parser.add_argument('-c','--class',help='class of species,choose from ["Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species"]',dest='cla',required=False)
	args=parser.parse_args()
	
	args.out.write("sample\ttaxonomy_name\ttaxonomy_count\n")
	for file in args.input:
		sample = os.path.basename(file).split(".")[0]
		top_species,top_num = get_file(file,int(args.top))
		for i in range(len(top_species)):
			args.out.write("\t".join([sample,top_species[i],str(top_num[i])])+"\n")

if __name__ == "__main__":
	main()
