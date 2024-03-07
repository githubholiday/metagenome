import sys
import argparse
import os
import numpy as np

__author__ = "liaorui"
__mail__ = "ruiliao@genome.cn"

def get_dic(file1):
	dic = {}
	spec = {}
	with open(file1,'r') as infile:
		for line in infile:
			tmp = line.strip().split("\t")
			if "|s_" in tmp[0]:
				dic[tmp[0].split("|")[-1]] = tmp[1]
				spec[tmp[0].split("|")[-1]] = tmp[0]
	infile.close()
	return dic,spec

def get_count(file1,species_dic):
	dic = {}
	with open(file1,'r') as infile:
		for line in infile:
			tmp = line.strip().split("\t")
			if tmp[0].startswith("name"):continue
			if "s_"+tmp[0] in species_dic.keys():
				dic[species_dic["s_"+tmp[0]]] = tmp[-1]
	infile.close()
	return dic

def common_dic(dic,species,out,sample):
	for i in species:
		cout = []
		for j in sample:
#			index_name = [x for x in list(dic.keys()) if j in x][0]
			index_name = [x for x in list(dic.keys()) if j == x.split(".")[0]][0]
			if i in dic[index_name].keys():
				cout.append(str(dic[index_name][i]))
			else:
				cout.append("0")
			if np.var(list(map(float,cout))) == 0 and max(list(map(float,cout))) == 0:continue
		out.write(i+"\t"+"\t".join(cout)+"\n")
	out.close()

def get_tax(dic,species,out):
	tax_list = ['d_','p_','c_','o_','f_','g_','s_']
	for i in species:
		if i in dic.keys():
			cout = dic[i].split("|")
			if len(cout) == 7:
				for j in range(len(tax_list)):
					cout[j] = cout[j].replace(tax_list[j],"")
				out.write(i+"\t"+"\t".join(cout)+"\n")
			elif len(cout)<7:
				for j in range(len(tax_list)):
					if tax_list[j] not in cout[j] and tax_list[j-1] not in cout[j]:
						cout.insert(j,"")
					elif tax_list[j] not in cout[j] and tax_list[j-1] in cout[j]:
						del cout[j]
					elif tax_list[j] in cout[j]:
						cout[j] = cout[j].replace(tax_list[j],"")
				out.write(i+"\t"+"\t".join(cout)+"\n")
			elif len(cout)>7:
				for j in range(len(tax_list)):
					if tax_list[j] not in cout[j]:
						del cout[j]
					else:
						cout[j] = cout[j].replace(tax_list[j],"")
				out.write(i+"\t"+"\t".join(cout)+"\n")
	out.close()

def get_cmp(sample,cmpfile):
	cmplist = []
	group_dic = {}
	with open(cmpfile,'r') as incmp:
		for line in incmp:
			tmp = line.strip().split("\t")
			sample_name = tmp[0]
			group_name = tmp[1]
			if sample_name not in group_dic:
				group_dic[ sample_name ] = group_name
	for sample_id in sample:
		if sample_id not in group_dic :
			print("{0} 不在 {1}中，退出".format( sample_id, cmpfile))
			sys.exit()
		else:
			cmplist.append(group_dic[sample_id])
	return cmplist

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='the input file of braken report,required ',dest='input',nargs='+',required=True)
	parser.add_argument('-e','--enput',help='the input file of braken count,norequired',dest='enput',nargs='+',required=False)
	parser.add_argument('-o','--output',help='output file,norequired',dest='out',type=argparse.FileType('w'),required=False)
	parser.add_argument('-t','--taxout',help='tax output file,norequired',dest='tax',type=argparse.FileType('w'),required=False)
	parser.add_argument('-r','--richness',help='output file of richness,norequired',dest='rich',type=argparse.FileType('w'),required=False)
	parser.add_argument('-c','--cmp',help='cmp file,norequired',dest='cmp',required=False)
	args=parser.parse_args()

	all_dic = {}
	all_spec = {}
	species = []
	sample = []
	for i in args.input:
		file_name = os.path.basename(i)
		sample.append(file_name.split(".")[0])
		all_dic[file_name],spec_dic = get_dic(i)
		all_spec.update(spec_dic)
		species.extend(list(all_dic[file_name].keys()))
	uniq_species = set(species)
	if args.out:
		args.out.write("species\t"+"\t".join(sample)+"\n")
		common_dic(all_dic,uniq_species,args.out,sample)
	if args.tax:
		tax_list = ["Domain","Phylum","Class","Order","Family","Genus","Species"]
		args.tax.write("name\t"+"\t".join(tax_list)+"\n")
		get_tax(all_spec,uniq_species,args.tax)
	if args.rich:
		args.rich.write("Sample\t"+"\t".join(sample)+"\n")
		if args.cmp:
			cmplist = get_cmp(sample,args.cmp)
			args.rich.write("Sample\t"+"\t".join(cmplist)+"\n")
		rich_dic = {}
		rich_species = []
		for i in args.enput:
			file_name = os.path.basename(i)
			rich_dic[file_name] = get_count(i,all_spec)
			rich_species.extend(list(rich_dic[file_name].keys()))
		uniq_rich_species = set(rich_species)
		common_dic(rich_dic,uniq_rich_species,args.rich,sample)

if __name__ == "__main__":
	main()
