import sqlite3
import sys
import os
import re
import argparse



class MySqlite():
	def __init__(self, name, db ):
		'''
	name : table name in database
	db  : pathway of database
	'''
		self.conn = sqlite3.connect(db)
		self.name = name
		self.create_table()
	
	def create_table(self):
		cmd = '''CREATE TABLE IF NOT EXISTS {0} ( 
			ID integer primary key ,
			taxid text not null,
			GCF_ID text not null,
			latin_name text not null,
			chinese_name text not null,
			kingdom text,
			phylum text,
			class_n text,
			order_n text,
			family text,
			genus text,
			species text,
			rank text ,
			other_info,
			tissue text,
			medicine text,
			introduction text ,
			insert_time text null);'''.format( self.name )
		self.execute(cmd)
		
	def insert_value(self , name_list, value_list ):
		'''
		name_list : list of column name 
		value_list : list of values
	'''
		name =  ",".join(name_list)
		format_value = lambda x : '"{0}"'.format(str(x))
		value = ",".join( map( format_value , value_list) )
		cmd = 'INSERT INTO {0} ( {1} ) VALUES ({2});'.format(self.name , name ,value)
		self.execute(cmd)

	def update_table( self , record , key , a_value ):
		'''
	record: a dict of colname and value
	key , a_value :  uesd to choose which line should be update
	'''
		cmd = 'UPDATE {0} SET '.format( self.name )
		for n in record:
			v= record[n]
			cmd += '{0}="{1}",'.format( n,v )
		cmd1 = cmd.rstrip( ',' )
		if key:
			cmd1 += ' where {0} = "{1}";'.format( key, a_value )
		self.execute( cmd1 )
			
	def select_value( self , col_list=['*'], condition=None):
		'''
		默认返回所有值
		condition = [(k1,v1),(k2,v2)]
		'''
		cmd = ''
		if len(col_list) == 1 :
			col = col_list[0]
		else :
			col = ','.join(col_list)
		cmd = 'SELECT {0} FROM {1} '.format( col, self.name )
		if condition :
			cmd += 'WHERE {1} like "{2}" '.format(self.name , condition[0][0], condition[0][1] )
			if len(condition) > 1 :
				for n,v in condition[1:]:
					cmd += 'and {0}="{1}" '.format(n, v)
		return self.execute(cmd)

	def delete_value( self , key , value ) :
		cmd = ''
		cmd = 'DELETE FROM {0} WHERE {1}="{2}"'.format( self.name , key , value )
		self.execute(cmd)
		
	def execute(self , cmd):
		if cmd.startswith( ('INSERT' ,'UPDATE' , 'DELETE')):
			self.conn.execute(cmd)
			self.conn.commit()
		elif cmd.startswith('SELECT'):
			cursor = self.conn.execute(cmd)
			return cursor.fetchall()
		else:
			self.conn.execute(cmd)
	
	def close(self):
		self.conn.close()

def main():
	parser=argparse.ArgumentParser(description='get coverage and depth')
	parser.add_argument('-i','--infile', required=True, dest='infile',help = "input file")
	parser.add_argument('-o','--outfile', required=True, dest='outfile',help = "outfile file")
	parser.add_argument('-db','--db', required=True, dest='db',help = "taxid 数据库")
	args=parser.parse_args()
	
	gcf_id_column_num = 0
	
	my_db = MySqlite( 'species_db', args.db )
	output = open(args.outfile, 'w')
	with open( args.infile, 'r') as infile :
		for line in infile :
			tmp = line.rstrip().split('\t')
			title = ['Species','Ch_Name','TaxID','Genus','Kingdom','Read']
			if line.startswith('Name') : output.write('\t'.join(title)+'\n')
			else :
				gcf_id = tmp[0]
				read_count = tmp[3]
				taxid = tmp[1]
				db_value = my_db.select_value(col_list=['*'], condition=[('taxid', taxid)])
				if len(db_value) == 0 :
					print('{0} 不在数据库中'.format( gcf_id+"+"+taxid ))
				elif len(db_value) > 1 :
					print('{0} 在数据库中有多少记录'.format(gcf_id))
					print(db_value)
				else:
					latin_name = db_value[0][3].rstrip()
					genus = db_value[0][10]
					species = db_value[0][5]
					chinese_name = db_value[0][4]
					content = [latin_name,chinese_name, taxid, genus,species,read_count]
					output.write('\t'.join(content)+'\n')

if __name__ == '__main__':
	main()
