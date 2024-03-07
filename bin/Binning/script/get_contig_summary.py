import os
import argparse

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def get_bin(infile):
	dic = {}
	with open(infile) as file1:
		for line in file1:
			if line.startswith("BinName"):continue
			tmp = line.strip().split("\t")
			dic[tmp[0]] = {}
			dic[tmp[0]]['contig'] = tmp[2].split(",")
			dic[tmp[0]]['Length'] = tmp[3].split(",")
			dic[tmp[0]]['Depth'] = tmp[4].split(",")
	file1.close()
	return dic

def get_GC(infile,contig_dic):
	seq = ""
	contig = ""
	dic = {}
	with open(infile) as file2:
		for line in file2:
			if line.startswith(">"):
				contig_name = line.strip().replace(">","")
				if len(contig) != 0:
					dic[contig] = "%.2f" %((seq.upper().count("C") + seq.upper().count("G"))/len(seq)*100)
				contig = contig_name
			else:
				seq += line.strip()
		dic[contig] = "%.2f" %((seq.upper().count("C") + seq.upper().count("G"))/len(seq)*100)
	file2.close()
	GC = []
	for i in contig_dic:
		GC.append(dic[i.strip()])
	return GC

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input',dest='input')
	parser.add_argument('-o','--out',help='out',dest='out',type=argparse.FileType('w'))
	args=parser.parse_args()
	
	dic = get_bin(args.input+"/genome-binning-summarizer.xls")
	args.out.write("Bin\tContig\tContigLengths\tContigDepths\tContigGC\n")
	for name in dic.keys():
		dic[name]["GC"] = get_GC(args.input+"/"+name+".fa",dic[name]['contig'])
		for i in range(len(dic[name]['contig'])):
			args.out.write("\t".join([name,dic[name]['contig'][i],str(dic[name]['Length'][i]),str(dic[name]['Depth'][i]),str(dic[name]['GC'][i])])+"\n")

if __name__ == "__main__":
	main()
