import argparse

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='the input file',dest='input')
	parser.add_argument('-o','--output',help='output file',dest='out',type=argparse.FileType('w'))
	args=parser.parse_args()

	with open(args.input) as infile:
		for line in infile:
			new_tmp = []
			if line.startswith("#"):continue
			if line.startswith("\t"):
				args.out.write(line)
				continue
			tmp=line.lstrip().split("\t")
			if line.startswith("id"):
				new_tmp = tmp
			else:
				new_tmp.append(tmp[0])
				for i in tmp[1:]:
					new_tmp.append("%.2f" %float(i))
			args.out.write("\t".join(new_tmp)+"\n")

if __name__ == "__main__":
	main()
