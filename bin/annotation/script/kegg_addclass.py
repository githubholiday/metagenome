import argparse
import numpy as np

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def read_file(file1,col):
	path = []
	with open(file1) as infile:
		for line in infile:
			if line.startswith("Gene_ID"):continue
			tmp = line.strip().split("\t")
			if col == "path":
				path.append(tmp)
			else:
				path.append(tmp[0])
	return path

def ko_list(file2):
	dic = {}
	with open(file2) as infile:
		for line in infile:
			tmp = line.strip().split("\t")
			dic[tmp[0]] = tmp
	infile.close()
	return dic

def ko_num(ko_dic,path,gene_num):
	'''
	ko_dic:key map,value :[map,second,first ,range]
	gene_num：uniq后的基因数
	'''
	dic = {"A":{},"B":{},"C":{},"D":{},"E":{},"F":{}}
	for i in path:
		gene= i[0]
		k_id = i[1]
		map_id = i[2]
		pathway = i[3]
		if map_id in ko_dic and pathway == ko_dic[map_id][1]:
			range_id = ko_dic[map_id][3]
			if map_id in dic[ range_id]:
				dic[range_id][map_id].append( gene )
			else:
				dic[range_id][map_id] = [ gene ]
	ko_cla = []
	#对每个等级进行循环
	for i in dic:
		map_info = dic[i] #map_id:gene
		ko_cla.extend(ko_class(map_info,ko_dic,gene_num,i))
	
	return ko_cla

def ko_class(ko_num_dic,ko_dic,gene_num,cla):
	'''
	ko_num_dic:key map_id;value:gene名
	ko_dic:key map,value :[map,second,first ,range]
	gene_num :基因综述
	cla:KEGG 通路大类，A，B，C,D……
	'''
	dic = []
	if len(list(ko_num_dic)) <= 10:
		for map_id in ko_num_dic:
			map_info_list = ko_dic[map_id]
			pathway_first = map_info_list[2]
			pathway_second = map_info_list[1]  
			map_gene_num = str(len(set(ko_num_dic[map_id]))) #每个map中的基因数量

			dic.append([cla, pathway_first,pathway_second ,str(len(set(ko_num_dic[map_id]))),"%.2f%%"%(len(set(ko_num_dic[map_id]))/gene_num*100)])
	else:
		ko_name,ko_num = [],[]
		for i in ko_num_dic.keys():
			if len(ko_name) <= 10:
				ko_name.append(i)
				ko_num.append(len(set(ko_num_dic[i])))
			else:
				if len(set(ko_num_dic[i])) > min(ko_num):
					index_num = ko_num.index(min(ko_num))
					ko_name[index_num] = i
					ko_num[index_num] = len(set(ko_num_dic[i]))
		for i in ko_name:
			dic.append([cla,ko_dic[i][2],ko_dic[i][1],str(len(set(ko_num_dic[i]))),"%.2f%%"%(len(set(ko_num_dic[i]))/gene_num*100)])
	return dic

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='the input file of pathway',dest='input',nargs="+",required=True)
	parser.add_argument('-e','--enput',help='the input file of ko',dest='enput',nargs="+",required=True)
	parser.add_argument('-d','--drawout',help='kofile for draw',dest='dr',type=argparse.FileType('w'),required=False)
	parser.add_argument('-l','--kolist',help='ko list file',dest='li',required=False)
	args=parser.parse_args()

	path_dic,gene_all = [],[]
	for i in args.input:
		path_dic.extend(read_file(i,"path"))
	for i in args.enput:
		gene_all.extend(read_file(i,"gene"))
	gene_num = len(set(gene_all))
	print(gene_num)
	if args.dr:
		args.dr.write("Class\tClassification\tGroup\tValue\tPercent\n")
		ko_dic = ko_list(args.li)
		ko_cla = ko_num(ko_dic,path_dic,gene_num)
		for i in ko_cla:
			args.dr.write("\t".join(i)+"\n")

if __name__ == "__main__":
	main()
