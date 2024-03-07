#! /usr/bin/env python3
import argparse
import sys
import os
import re
import datetime

bindir = os.path.abspath(os.path.dirname(__file__))
filename=os.path.basename(__file__)

__author__='tu chengfang '
__mail__= 'chengfangtu@genome.cn'


class Log():
	def __init__( self, filename, funcname = '' ):
		self.filename = filename 
		self.funcname = funcname
	def format( self, level, message ) :
		date_now = datetime.datetime.now().strftime('%Y%m%d %H:%M:%S')
		formatter = ''
		if self.funcname == '' :
			formatter = '\n{0} - {1} - {2} - {3} \n'.format( date_now, self.filename, level, message )
		else :
			
			formatter = '\n{0} - {1} - {2} -  {3} - {4}\n'.format( date_now, self.filename, self.funcname, level, message )
		return formatter
	def info( self, message ):
		formatter = self.format( 'INFO', message )
		sys.stdout.write( formatter )
	def debug( self, message ) :
		formatter = self.format( 'DEBUG', message )
		sys.stdout.write( formatter )
	def warning( self, message ) :
		formatter = self.format( 'WARNING', message )
		sys.stdout.write( formatter )
	def error( self, message ) :
		formatter = self.format( 'ERROR', message )
		sys.stderr.write( formatter )
	def critical( self, message ) :
		formatter = self.format( 'CRITICAL', message )
		sys.stderr.write( formatter )
		
def read_report( report_file ):
	line_sum = 2
	with open( report_file ) as infile:
		for line_index, line in enumerate(infile):
			tmp = line.strip().split('\t')
			if line_index == 0 :
				unmaped_reads = int(tmp[1])
			elif line_index ==1 :
				mapped_reads = int(tmp[1])
			else: continue
		total_reads = unmaped_reads+mapped_reads
		mapped_rate = 100*mapped_reads/total_reads
	return total_reads,mapped_reads,mapped_rate
				
def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-r','--report',help='kraken result report file',dest='report',required=True)
	parser.add_argument('-o','--output',help='output of result',dest='output',required=True)
	parser.add_argument('-s','--sample',help='sample name',dest='sample',required=True)
	args=parser.parse_args()
	total_reads,mapped_reads,mapped_rate = read_report(args.report)
	with open( args.output, 'w') as outfile:
		outfile.write("Sample\t"+args.sample+'\n')
		outfile.write("Total Reads\t"+str(total_reads*2)+'\n')
		outfile.write("Taxonomy Mapped Reads\t"+str(mapped_reads*2)+'\n')
		outfile.write("Taxonomy Mapped Rate(%)\t"+'{0:.2f}'.format(mapped_rate)+'\n')

if __name__ == '__main__':
	main()
