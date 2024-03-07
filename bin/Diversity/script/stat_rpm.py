#! /usr/bin/env python3
import argparse
import sys
import os
import re
import datetime
import pandas as pd

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
		
		
def get_map( report_file ):
	mapping_reads = 0
	mapping_human_reads = 0
	flag = 0 
	with open( report_file , 'r') as infile :
		for line_index, line in enumerate(infile) :
			if flag == 2 : continue
			tmp = line.rstrip().split('\t')
			rate = tmp[0]
			reads = int(tmp[1])
			name = tmp[5].replace(" ","")
			if name == 'root' :
				mapping_reads = reads
				flag += 1
			if name == 'Homosapiens':
				mapping_human_reads = reads
				flag += 1
	mapping_other_reads = mapping_reads - mapping_human_reads
	return mapping_reads, mapping_human_reads, mapping_other_reads

def write_map( sample, outdir, total_reads, mapping_human,mapping_db ):
	outfile = '{0}/{1}.mapping.stat.xls'.format(outdir, sample) 
	with open(outfile, 'w') as output :
		output.write("Sample\t"+sample+'\n')
		output.write('Mapping Reads Number\t'+str(total_reads)+'\n')
		output.write('Mapping Human Reads Number\t'+str(mapping_human)+'\n')
		output.write('Mapping DB Reads Number\t'+str(mapping_db))
		
def rebuild_count( count_file ):
	new_header = ['Name','ID','taxonomy_lvl','Map_Reads_1','added_reads','Map_Reads','fraction_total_reads']
	df = pd.read_csv( count_file,sep='\t' )
	df.columns = new_header
	total_reads = df['Map_Reads'].sum()
	try :
		mapping_human = df[df.Name=='Homo sapiens']['Map_Reads'].values[0]
	except:
		mapping_human = 0
	mapping_db = total_reads - mapping_human#.values[0]
	print(type(mapping_db))
	print(mapping_db)
	df = df.drop(df[df.Name=='Homo sapiens'].index)
	#print(df.Name)
	df_subset = df[['Name',"ID",'Map_Reads']]
	rpm = df_subset['Map_Reads'].apply( lambda x : format(x*1000000/mapping_db,'0,.2f'))
	df_subset.insert(2,"RPM",rpm)
	df_subset = df_subset.sort_values(by=["Map_Reads"],ascending=False)
	return df_subset,total_reads, mapping_human,mapping_db
	
def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	#parser.add_argument('-r','--report_file',help='kraken.report file',dest='report_file',required=True)
	parser.add_argument('-c','--count_file',help='braken.count file',dest='count_file',required=True)
	parser.add_argument('-o','--outdir',help='the dir of output',dest='outdir',required=True)
	parser.add_argument('-s','--sample',help='sample name',dest='sample',required=True)
	args=parser.parse_args()
	#mapping_reads, mapping_human_reads, mapping_other_reads = get_map(args.report_file)
	#write_map( args.sample, args.outdir, total_reads, mapping_human,mapping_db)
	df_subset,total_reads, mapping_human,mapping_db = rebuild_count( args.count_file )
	write_map( args.sample, args.outdir, total_reads, mapping_human,mapping_db)
	count_output = '{0}/{1}.count.xls'.format( args.outdir, args.sample )
	df_subset.to_csv( count_output, header=True,index=False, sep='\t')




if __name__ == '__main__':
	main()
