import argparse
import sys
import os
import re
import glob
import configparser
import time
import mysql.connector
import datetime

pat1 = re.compile('^\s*$')

#from multiprocessing import Pool

__author__='Yuan Zan'
__mail__= 'zanyuan@annoroad.com'

class LIMS():
    def __init__( self, config_dic, port = 3306, charset='utf8' ):
        self.config_dic = config_dic
        usr  = self.config_dic['sql_usr']
        pwd = self.config_dic['sql_pwd']
        port = self.config_dic['sql_port']
        host = self.config_dic['sql_host']
        database = self.config_dic['sql_db']
        self.table = self.config_dic['sql_tb']
        try:
            self.cnx = mysql.connector.connect(user=usr, password=pwd, host=host, database=database, port = port, charset = charset)
            print( 'connect db {0}-{1} successed'.format(host, usr) )
            self.cursor = self.cnx.cursor()
        except mysql.connector.Error as err:
            print( 'connect db {0}-{1} failed'.format(host, usr) )
            print ( 'Error: {0}'.format( err ) )
            sys.exit(1)
        self.charset = charset
        


    def insert( self, name_list, value_list ):
        '''
        col_list: 要插入的列名list
        value_list: 要插入的值,形如[(value1.1,value1.2,...), (value2.1,value2.2,...)]
        '''
        format_value = lambda x : '"{0}"'.format(str(x))
        cmd = 'INSERT INTO {0} ( {1} ) VALUES ({2});'.format(self.table , ",".join(name_list) , ",".join( map( format_value , value_list) ))
        print(cmd)
        self.execute(cmd)

    def execute( self, cmd, times = 3 ):
        if times > 0:
            try:
                self.cursor.execute(cmd)
                if cmd.startswith( ('INSERT' ,'UPDATE' , 'DELETE')):
                    self.cnx.commit()
            except mysql.connector.Error as err:
                print ('{0} 尝试倒数第{1}次失败'.format( cmd, times ) )
                print ( 'Error: {0}'.format( err ) )
                self.execute( cmd, times-1 )
        else:
            sys.exit()

def read_config( config_file ):
    config_dic = {}
    with open( config_file, 'r') as infile:
        for line in infile:
            if re.search(pat1, line ) or line.startswith('#') : continue
            tmp = line.rstrip().split('=',1)
            target = tmp[0].rstrip(' ')
            value = tmp[1].lstrip(' ')
            if target not in config_dic :
                config_dic[ target ] = value
            else :
                print("{0} is repeat in {1}".format(target, config_file))
    return config_dic

def db_insert( project_id, pipeline_name, analysis_path, lims_db):
    name_list = ['project_id','pipeline_name','analysis_path','create_time']
    now_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    value_list = [ project_id, pipeline_name, analysis_path, now_time ]
    lims_db.insert( name_list, value_list)


def main():
    parser = argparse.ArgumentParser(description=__doc__,
             formatter_class=argparse.RawDescriptionHelpFormatter,
             epilog='author:\t{0}\nmail:\t{1}\n'.format(__author__, __mail__,))
    parser.add_argument('-p', '--project_id', help='【必需】子项目编号', dest='project_id', required = True)
    parser.add_argument('-d', '--dir', help='【必需】分析路径', dest='dir',required = True)
    parser.add_argument('-c', '--config', help='【必需】流程配置文件，主要是有数据库的配置信息', dest='config', required=True )
    args = parser.parse_args()

    config_dic = read_config( args.config )
    lims_db = LIMS( config_dic )
    db_insert( args.project_id, config_dic['pipeline_name'], args.dir, lims_db )

if __name__ == '__main__':
        main()

