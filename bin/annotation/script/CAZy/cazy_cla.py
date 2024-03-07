import argparse

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def readfile(file1):
	dic = {'PL':[],'GT':[],'GH':[],'CE':[],'CBM':[],'AA':[]}
	with open(file1) as infile:
		for line in infile:
			tmp = line.strip().split("\t")
			for i in list(dic.keys()):
				if tmp[1].startswith(i):
					dic[i].append(tmp[0])
	return dic

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input file',dest='input',required=True)
	parser.add_argument('-o','--output',help='pathway file',dest='out',type=argparse.FileType('w'),required=False)
	args=parser.parse_args()

	class_dic = {'SLH':'Surface Layer Homology','PL':'Polysaccharide Lyases','GT':'GlycosylTransferases','GH':'Glycoside Hydrolases','CE':'Carbohydrate Esterases','CBM':'Carbohydrate-Binding Modules','AA':'Auxiliay Activities'}
	dic = readfile(args.input)
	args.out.write("class\tfunction\tnumber\tgene\n")
	for cla in list(dic.keys()):
		args.out.write(cla+"\t"+class_dic[cla]+"\t"+str(len(set(dic[cla])))+"\t"+",".join(list(set(dic[cla])))+"\n")

if __name__ == "__main__":
	main()
