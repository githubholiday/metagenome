#! /usr/bin/env python

import argparse
import sys
import os

__author__='Liu Tao'
__mail__='taoliu@annoroad.com'

def parse_file1(infile , byCol):
	name , record = []  , []
	with open(infile) as f_file:
		for line in f_file:
			line = line.rstrip()
			if byCol:
				tmp = line.split('\t' , 1 )
				name.append(tmp[0])
				record.append(tmp[1])
			else:
				if not name : 
					name = line 
				else:
					record.append(line)
	return(name , record)

def main():
	parser=argparse.ArgumentParser(
			description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='Author:\t{0}\nE-mail:\t{1}\n'.format(__author__,__mail__)
			)
	parser.add_argument('-f','--files',dest='files',help='input more than ones file',required=True,nargs='+')
	parser.add_argument('-o' , '--out', dest = 'out' , help = 'output file' , required=True)
	parser.add_argument('-t' , '--type' , dest = 'type' , help='merge by column' , action='store_false')
	args=parser.parse_args()
	
	if len(args.files)<2 :
		f_out = open(args.out  , 'w') 
		with open(args.files[0]) as f_in:
			for line in f_in:
				f_out.write(line)
		f_out.close()
	else:
		name , record = parse_file1(args.files[0] , args.type)

		for infile in args.files[1:]:
			with open(infile,'r') as f_file:
				for count, line in enumerate(f_file):
					line = line.rstrip()
					if args.type:
						tmp = line.split('\t' , 1 )
						record[count] += "\t{0}".format(tmp[1])
					else:
						if count > 0 : 
							record.append(line)
							print(record)

		with open(args.out , 'w') as f_out:
			output = ''
			if args.type:
				for i,j in enumerate(name):
					output += '{0}\t{1}\n'.format(j , record[i])
			else:
				output += "\n".join([name] + record) + "\n"
			f_out.write(output)


if __name__=='__main__':
	main()
