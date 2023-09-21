#!/usr/bin/env python3
"""
do something 
"""
import argparse
import os
import sys
import re
import logging
bin = os.path.abspath(os.path.dirname(__file__))
__author__='Ren Xue'
__mail__= 'xueren@genome.cn'
__date__= 'Wed 05 Aug 2020 09:22:30 AM CST'


def get_machine(machine_dict,cpu,memory):
	cpu_list=[float(machine_dict[x][0]) for x in machine_dict]
	cpu_list.sort()
	cpu_new = 0
	mem_new = 0
	for i in cpu_list:
		if float(cpu) >i:continue
		elif float(cpu) <=i:
			cpu_new = i
			break
	if cpu_new == 0: cpu_new=cpu_list[-1]
	mem_list=[]
	for m in machine_dict:
		if float(machine_dict[m][0]) == cpu_new:
			mem_list.append(float(machine_dict[m][1]))
	mem_list.sort()
	for j in mem_list:
		if float(memory) > j:continue
		elif float(memory) <=j:
			mem_new = j
			break
	if mem_new == 0:mem_new=mem_list[-1]
	for m in machine_dict:
		if float(machine_dict[m][0]) == cpu_new and float(machine_dict[m][1]) == mem_new:
			return m

def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter,epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-o','--outfile',help='outfile name',dest='outfile',type=str,default="report.txt")
	parser.add_argument('-mc','--machine',help='machine info',dest='machine',type=str,default='{0}/config.ini'.format(bin))
	parser.add_argument('-i','--inputfile',help='input file size,G',dest='input',type=str,required=True)
	parser.add_argument('-dfs','--default_filesize',help='default file size,G',dest='dfs',type=str,required=True)
	parser.add_argument('-dre','--default_rescoure',help='default cpu,memory',dest='dfr',type=str,required=True)
	parser.add_argument('-e','--exp',help='express:x表示默认文件大小，y表示输入文件大小，用x和y的关系表示倍数比如y/x',dest='express',type=str,default='1,y/x')
	parser.add_argument('-max','--max_resource',help='最大资源: cpu:memory,memory',dest='max_r',type=str,default='16,128')

	args=parser.parse_args()
	input_size = os.path.getsize(args.input)
	##单位统一按G
	input_fs = str(float(input_size)/1000/1000/1000)
	print("input size:{0} GB".format(input_fs))

	## 计算
	default_fs =args.dfs
	default_re = args.dfr
	cpu,mem = default_re.split(",")
	ct,mt = args.express.split(",")

	cpu_new = ct.replace("x",default_fs)
	cpu_new = cpu_new.replace("y",input_fs)
	cpu_new= float(cpu)*float(eval(cpu_new))

	mem_new = mt.replace("x",default_fs)
	mem_new = mem_new.replace("y",input_fs)
	mem_new = float(mem)*float(eval(mem_new))

	#判断最大值
	cm,mm = args.max_r.split(",")
	if cpu_new >= float(cm):
		cpu_new = int(cm)
	if mem_new >= float(mm):
		mem_new = float(mm)
	#判断最小值
	if cpu_new < float(cpu):
		cpu_new = int(cpu)
	if mem_new < float(mem):
		mem_new = mem

	cpu_new = int(cpu_new)
	mem_new = int(mem_new)

	machines={}
	machine="bcs.es.c.large"
	with open(args.machine,'r') as lines:
		for line in lines:
			if line.startswith("#"):continue
			tmp=line.rstrip("\n").split("\t")
			machines[tmp[0]]=[tmp[1],tmp[2],tmp[3]]
	machine=get_machine(machines,cpu_new,mem_new)
	price = machines[machine][2]
	out=open(args.outfile,"w")
	out.write("machine\tOnDemand {0} img-ubuntu-vpc\n".format(machine))
	out.write("cpu\t{0}\n".format(cpu_new))
	out.write("memory\t{0} GB\n".format(mem_new))
	out.write("price\t{0}元/核/小时\n".format(price))
	out.close()
if __name__=="__main__":
	main()
