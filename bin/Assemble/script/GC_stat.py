#!/usr/bin/evn python3
######################################################################### import ##########################################################
import argparse
import os
import sys
######################################################################### ___  ##########################################################
__doc__ = ''
__author__ = 'Liu Jiang'
__mail__ = 'jiangliu@genome.cn'
__date__ = '2018年09月27日 星期四 15时39分48秒'
__version__ = '1.0.0'
######################################################################### main ############################################################
def CheckFile(file):
	if os.path.exists(file):
		return
	else:
		print("Error: {0} does not exist!".format(file))
		sys.exit(1)

def BaseStat(file):
	a_n , t_n , c_n , g_n , n_n = 0 , 0 , 0 , 0 , 0
	for line in file:
		if line.startswith(">"):continue
		line = line.strip()
		for i in line:
			if i in ["a","A"]:
				a_n += 1
			elif i in ["t","T"]:
				t_n += 1
			elif i in ["c","C"]:
				c_n += 1
			elif i in ["g","G"]:
				g_n += 1
			elif i in ["n","N"]:
				n_n += 1
	return(a_n,t_n,c_n,g_n,n_n)

def main():
	parser=argparse.ArgumentParser(description=__doc__,
		formatter_class=argparse.RawDescriptionHelpFormatter,
		epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\nversion:\t{3}'.format(__author__,__mail__,__date__,__version__))
	parser.add_argument('-i',help='fasta file',dest='input',type=str,required=True)
	parser.add_argument('-o',help='output file',dest='output',type=str,required=True)
	args=parser.parse_args()
	CheckFile(args.input)
	with open(args.input,'r') as file:
		a_n,t_n,c_n,g_n,n_n = BaseStat(file)
	gc_n = g_n + c_n
	all_n = a_n + t_n + c_n + g_n + n_n
	a_p = a_n / all_n * 100
	t_p = t_n / all_n * 100
	c_p = c_n / all_n * 100
	g_p = g_n / all_n * 100
	n_p = n_n / all_n * 100
	gc_p = gc_n / all_n * 100
	with open(args.output,'w') as OUT:
		OUT.write("Iterms\tNumber\tPercent (%)\n")
		OUT.write("{0}\t{1}\t{2}%\n".format("A",format(a_n,","),round(a_p,2)))
		OUT.write("{0}\t{1}\t{2}%\n".format("T",format(t_n,","),round(t_p,2)))
		OUT.write("{0}\t{1}\t{2}%\n".format("C",format(c_n,","),round(c_p,2)))
		OUT.write("{0}\t{1}\t{2}%\n".format("G",format(g_n,","),round(g_p,2)))
		OUT.write("{0}\t{1}\t{2}%\n".format("N",format(n_n,","),round(n_p,2)))
		OUT.write("{0}\t{1}\t{2}%\n".format("GC",format(gc_n,","),round(gc_p,2)))
		OUT.write("{0}\t{1}\t{2}\n".format("Total Genome base",format(all_n,","),"-"))

if __name__=="__main__":
	main()
