#!/usr/bin/env python3
"""
do something
"""
import argparse
import os
import sys
import re
import logging
import glob
from webbrowser import get
bin = os.path.abspath(os.path.dirname(__file__))
__author__='Ren Xue'
__mail__= 'xueren@genome.cn'
__date__= 'Sat 25 Jun 2022 03:22:34 PM CST'

class get_upload_from_config:
	def __init__(self, config, indir,outdir,bindir):
		self.config = config
		self.indir= indir
		self.outdir= outdir
		self.dir_order=[]
		self.config_dir=["config","config_plot","help","appendix","帮助文档","_icon"]
		self.bindir = bindir
		self.deal_all_module()
	
	def open_file(self):
		##模块中must文件有存在的，也有不存在的， 导致模块去除：模块\t文件
		warning_module_file = "{0}/warning_moudle.info".format(self.outdir)
		self.warn_file=open(warning_module_file,"w")
		self.warn_file.write("#有部分文件存在但被删除的模块\t导致模块被删除的文件\n")
		##去除的模块名称\t提示
		remove_module_file = "{0}/remove_moudle.info".format(self.outdir)
		self.rmodule = open(remove_module_file,"w")
		self.rmodule.write("#被删除的模块\t删除原因\n")
		## 模块存在，但一些文件不存在
		not_exist_file = "{0}/file_not_exist.info".format(self.outdir)
		self.not_exist = open( not_exist_file,"w")
		self.not_exist.write("#模块\t文件名称\n")
		##生成uplod 记录 file，outfile，exit_code
		upload_file = "{0}/upload.log".format(self.outdir)
		self.log = open( upload_file,"w")
		self.log.write("#文件原路径\t输出路径\t是否存在\t执行退出码\n")
		print("输出文件有:{0}\n{1}\n{2}\n{3}".format( warning_module_file,remove_module_file, not_exist_file, upload_file))


	def close_file(self):
		self.warn_file.close()
		self.rmodule.close()
		self.not_exist.close()
		self.log.close()

	def deal_all_module(self):
		self.open_file()
		module_dict=self.read_config()
		if not module_dict:
			print("upload.config 配置文件异常，没有获取到模块信息")
		self.out_module={}
		for m in module_dict:
			if not module_dict[m]:flag="YES"
			else:
				flag=self.judge_module(m,module_dict[m])
			if flag=="YES":
				self.out_module[m]=1
				self.deal_module(m,module_dict[m])
		self.close_file()
				
	def get_maindir(self,dir):
		tmp=dir.split("/")
		if not tmp[2] in self.dir_order and not tmp[2].startswith("config") and not tmp[2] in self.config_dir:
			self.dir_order.append(tmp[2])

	def read_config(self):
		modules={}
		title=""
		with open(self.config,"r") as file:
			for line in file:
				if re.search("^\s*$",line):continue
				if line.startswith("@@@@"):
					title=line.rstrip("\n").lstrip("@@@@")
					n=0
					modules[title]={}
				else:
					if title:
						modules[title][n]=line.rstrip("\n").split("\t")
						n+=1
					else:
						continue
		return modules

	def judge_module(self,name,dict):
		type0=[]
		type1=[]
		type2=[]
		type0_info=[]
		type1_info=[]
		type2_info=[]
		flag="NO"
		all_files=[]
		for i in dict:
			info = dict[i]
			infile=self.replace_stable_path(info[0])
			if  info[3]=="-1":continue
			all_files.append(info[0])
			files=glob.glob(infile)
			if files: flag="YES" 	
			if info[3]=="1" or info[3]=="2":
				type1.append(infile)
				if files:
					type1_info.append("YES")
				else:
					type1_info.append("NO")
				if info[3]=="2":
					type2.append(infile)
					if files:
						type2_info.append("YES")
					else:
						type2_info.append("NO")
		if not all_files:flag="YES"
		if flag=="NO":
			self.rmodule.write("{0}\t文件均不存在\n".format(name))
		else:
			if "NO" in type2_info:
				for n in range(len(type2_info)):
					if type2_info[n]=="NO":
						sys.stderr.write("{0}\t{1}\t重要文件不存在,请检查\n".format(name,type2[n]))
						sys.exit(1)
			if "NO" in type1_info:
				for n in range(len(type1_info)):
					if type1_info[n]=="NO":
						self.warn_file.write("{0}\t{1}\n".format(name,type1[n]))
				flag="NO"
		return flag

	def replace_stable_path(self,path):
		path=path.replace("OUTDIR",self.outdir)
		path=path.replace("BIN",self.bindir)
		pp=path.replace("INDIR",self.indir)
		return pp
	def deal_module(self,name,dict):
		for i in dict:
			info = dict[i]
			self.get_maindir(info[1])
			infile=self.replace_stable_path(info[0])
			outdir=self.replace_stable_path(info[1])
			files=glob.glob(infile)
			## 处理*
			num_star=infile.count("*")
			tt=infile.replace("*","(.*?)")
			if files:
				for f in files:
					outf=outdir
					mm=re.search(tt,f)
					if mm:
						for i in range(num_star):
							nn=i+1
							outf=outf.replace("*{0}".format(nn),mm.group(nn))
					if outf.endswith("/"):
						outf_dir=outf
					else:
						outf_dir=os.path.dirname(outf)
					os.system("mkdir -p {0}".format(outf_dir))
					if info[2]=="copy":
						result=os.system("cp -f {0} {1}".format(f,outf))
					elif info[2]=="link":
						result=os.system("ln -s {0} {1}".format(f,outf))
					self.log.write("{0}\t{1}\texist\t{2}\n".format(f,outf,result))
			else:
				self.not_exist.write("{0}\t{1}\n".format(name,info[0]))


def read_template(template,outfile,module):
	out=open(outfile,"w")
	with open(template,"r") as file:
		title=""
		for line in file:
			if line.strip().startswith("@@@@"):
				title=line.strip().lstrip("@@@@")
			if title in module:
				out.write(line)
	out.close()


def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter,epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-o','--outdir',help='outdir',dest='outdir',type=str,required=True)
	parser.add_argument('-c','--config',help='config file',dest='config',type=str,required=True)
	parser.add_argument('-t','--template',help='template ',dest='template',type=str)
	parser.add_argument('-ot','--out_template',help='out template ',dest='out_template',type=str)
	parser.add_argument('-i','--indir',help='indir',dest='indir',type=str,required=True)
	parser.add_argument('-b','--bin',help='bindir',dest='bindir',type=str,default=bin)
	parser.add_argument('-n','--number',help='whether to add number to maindir' ,dest='number',action='store_true')
	args=parser.parse_args()
	bindir=os.path.abspath(args.bindir)
	indir=os.path.abspath(args.indir)
	if not os.path.exists(indir):
		sys.stderr.write("-i {0} not exists!\n")
		sys.exit(1)
	outdir=os.path.abspath(args.outdir)
	upload="{0}/upload".format(outdir)
	sys.stdout.write("##### INFO-分析开始\n")
	if os.path.exists(upload):
		os.system("rm -rf {0}".format(upload))
		sys.stdout.write("##### INFO-删除旧的upload文件夹\n")

	get_upload=get_upload_from_config(args.config, indir,outdir,bindir)
	if args.template:
		sys.stdout.write("##### INFO-开始提取模板\n")
		out_template='{0}/template.new'.format(outdir)
		sys.stdout.write("输出文件为:{0}".format( out_template ))
		keep_module=get_upload.out_module
		if args.out_template:
			out_template=args.out_template
		read_template(args.template,out_template,keep_module)
	if args.number:
		dir_order=get_upload.dir_order
		for n in range(len(dir_order)):
			os.system("cd {2}/upload/ && mv {0} {1}_{0}".format(dir_order[n],n+1,outdir))
	sys.stdout.write("##### INFO-分析结束\n")

if __name__=="__main__":
	main()

