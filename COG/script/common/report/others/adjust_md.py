#!/usr/bin/env python3
"""
type 1 ：调整生成pdf的makedown，主要是满足pandoc需求
type 2 ：调整pandoc 生成的tex，以满足pdf生成
"""
import argparse
import os
import sys
import re
import logging
import time
script = os.path.abspath(os.path.dirname(__file__))
bin=os.path.abspath(os.path.dirname(script))
__author__='Ren Xue'
__mail__= 'xueren@genome.cn'
__date__= '2021年05月07日 星期五 11时27分50秒'

def md_head(title,date):
	head='''
---
title: {0}
date: {1}
titlepage: true,
toc-own-page: true,
caption-justification: centering
header-left: "安诺优达|安诺基因"
header-center:
header-right: "www.genome.cn"
titlepage-rule-color: "3399ff"
---

	'''.format(title,date)
	return head

def tex_page(title_info,date,wave):
	tex_info='''
{{
  \\begin{{center}}
  \\setstretch{{1.4}}
  \\vfill
{0}
     \\vskip 2em
  \\noindent {{\\Large \\textsf{{}}}}
  \\includegraphics[width=80mm]{{{2}}}
  \\vfill
  \\end{{center}}
}}

\\noindent
\\begin{{center}}
\\noindent {{\Large \\textbf{{\\textsf{{{1}}}}}}}
\\end{{center}}

'''.format(title_info,date,wave)

	return 	tex_info



def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter,epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-o','--outfile',help='outfile name',dest='outfile',type=str,required=True)
	parser.add_argument('-i','--infile',help='infile name',dest='infile',type=str,required=True)
	parser.add_argument('-t','--type',help='type',dest='type',type=str,choices=["1","2","3"],required=True)
	parser.add_argument('-n','--name',help='report name',dest='name',type=str,default="结题报告")
	parser.add_argument('-logo','--logo',help='report name',dest='logo',type=str,default='{0}/others/config/annoroad.png'.format(bin))
	parser.add_argument('-wave','--wave',help='report name',dest='wave',type=str,default='{0}/others/config/wave.png'.format(bin))
	args=parser.parse_args()
	now=time.strftime('%Y-%m-%d', time.localtime())
	out=open(args.outfile,"w")
	if args.type=="1":		
		head_info=md_head(args.name,now)
		out.write(head_info)
		with open(args.infile,"r") as file:
			image_info=""
			for line in file:
				if line.startswith("&emsp;&emsp;"):
					line=line.replace("&emsp;&emsp;","hspace")
				if line.startswith("##"):
					line=line.replace("##","#")               
				if line.startswith("<div><img"):
					info=re.search('.*src="(.*)".*style=.*',line)
					image_info=info.group(1)
					continue
				if line.startswith("<center>图"):
					title=re.search('<center>图\d+ (.*)</center>',line)
					tt=title.group(1)
					out.write("\n\n![{0}]({1})\n".format(tt,image_info))
					continue
				if "下载链接" in line: continue
				if line.startswith("<center>表"):continue							
				line='{0}  \n'.format(line.rstrip("\n"))
				out.write(line)
	elif args.type=="2":
		tag=0
		title_line=""
		with open(args.infile,"r") as file:
			for line in file:
				if line.startswith("hspace"):
					line=line.replace("hspace","\hspace{2em}")
				if line.startswith("]{scrartcl}"):
					a="{0}\\usepackage{{CJKutf8}}\n".format(line)
					out.write("{0}\\usepackage{{CJKutf8}}\n".format(line))
					continue
				if line.startswith("\\usepackage{fancyhdr}"):
					out.write("{0}\\begin{{document}}\n\\begin{{CJK}}{{UTF8}}{{gbsn}}\n".format(line))
					continue
				if "lfoot" in line:
					out.write("  \\lfoot[]{}\n")
					continue
				if "rfoot" in line:
					out.write("  \\rfoot[]{}\n")
					continue
				if "cfoot" in line:
					out.write("  \\cfoot[]{\\thepage}\n")
					continue
				if line.startswith("\\begin{document}"):
					continue
				if "3399ff" in line:
					name="\\includegraphics[width=55mm]{{{0}}}".format(args.logo)
					out.write("{0}\\par\n\\noindent\n{1}".format(line,name))
					tag=1
					continue
				if "huge" in line:
					title_info=line.rstrip("\n").replace("huge","Huge")
					continue
				if  line.startswith("\\end{flushleft}"):
					tag=0
					tex_info=tex_page(title_info,now,args.wave)
					out.write("{0}\\par\n\\noindent\n{1}".format(tex_info,line))
					continue
				if tag ==1:continue
				if line.startswith("\\end{document}"):
					out.write("\\end{{CJK}}\n{0}".format(line))
					continue
				out.write(line)			

	out.close()	

	

if __name__=="__main__":
	main()
