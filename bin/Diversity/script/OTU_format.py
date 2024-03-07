import sys
import argparse
import os

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def get_dic(file1):
	dic ={}
	with open(file1,'r') as infile:
		for line in infile:
			tmp = line.strip().split("\t")
			dic[tmp[0]] = tmp[1]
	return dic

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='the input file of braken report',dest='input',nargs='+',required=True)
	parser.add_argument('-e','--enput',help='the input file',dest='enput',required=True)
	parser.add_argument('-o','--output',help='output file',dest='out',type=argparse.FileType('w'),required=True)
	args=parser.parse_args()

	all_dic = {}
	for i in args.input:
		all_dic.update(get_dic(i))
	with open(args.enput,'r') as infile:
		args.out.write(infile.readline())
		for line in infile:
			tmp = line.strip().split("\t")
			if tmp[0].split("s_")[1] in all_dic.keys():
				tmp[0] = all_dic[tmp[0].split("s_")[1]]
				args.out.write("\t".join(tmp)+"\n")
	infile.close()
	args.out.close()

if __name__ == "__main__":
	main()
