import os
import argparse

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def get_dic(file1):
	dic = {}
	with open(file1,'r') as infile:
		for line in infile:
			tmp = line.strip().split("\t")
			if tmp[0].startswith("name"):continue
			dic[tmp[0]] = tmp[-1]
	infile.close()
	return dic

def get_species(infile1):
	species = {}
	with open(sys.argv[1],'r') as infile1:
		for line in infile1:
			tmp = line.strip().split("\t")
			species[tmp[0].split("|")[-1]] = tmp[0]
	infile1.close()
	return species

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='the input file of braken report',dest='input',nargs='+')
	parser.add_argument('-o','--output',help='output file',dest='out',type=argparse.FileType('w'))
	parser.add_argument('-s','--sample',help='sample name,seq with ,',dest='sample')
	args=parser.parse_args()

	all_dic = {}
	species = []
	for i in args.input:
		file_name = os.path.basename(i)
		all_dic[file_name] = get_dic(i)
		species.extend(list(all_dic[file_name].keys()))
	sample = args.sample.split(',')
	uniq_species = set(species)
	dic_sample = list(all_dic.keys())
	args.out.write("species\t"+"\t".join(sample)+"\n")
	for j in uniq_species:
		cout = []
		for i in sample:
			index_name = [x for x in dic_sample if i in x][0]
			if j in all_dic[index_name].keys():
				cout.append(str(all_dic[index_name][j]))
			else:
				cout.append("0.00000")
		if len(set(cout)) == 1 and list(set(cout))[0] == "0.00000":continue
		args.out.write(j+"\t"+"\t".join(cout)+"\n")

if __name__ == "__main__":
	main()
