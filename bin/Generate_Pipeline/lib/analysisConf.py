#!/usr/bin/env python3
'''
Information:
        this script is method used for Pipline.
Function:
        1) generateShell
        2) decorateShell
        3) myconf (read ini)
        4) mkdir
usage:
        sys.path.append(os.path.dirname(sys.argv[0]) + '/../lib')
        from PipMethod import mkdir
        from PipMethod import generateShell
        from PipMethod import myconf 
Modify Date:
        2015-09-26
'''
import argparse
import sys
import os
import re
import glob
import configparser
import time
import mysql

pat1 = re.compile('^\s*$')

#from multiprocessing import Pool

__author__='Yuan Zan'
__mail__= 'zanyuan@annoroad.com'


def generateShell(shell, content, finish_string="Live_long_and_prosper"):
    shell = str(shell)
    for file in glob.glob(shell + '.*'):
        os.remove(file)
    f=open(shell,'w')
    f.write('#!/bin/bash\n')
    #f.write('echo ==========start at : `date` ==========\n')
    #f.write(content + ' && ' + '\\\n')
    f.write(content + '\n')
    #f.write('echo ==========end at : `date` ========== && \\\n')
    #f.write('echo ' + finish_string + ' 1>&2 && \\\n')
    #f.write('echo ' + finish_string + ' > ' + shell + '.sign\n')
    f.close()

def decorateShell(shell, finish_string="Live_long_and_prosper"):
    shell = str(shell)
    for file in glob.glob(shell + '.*'):
        os.remove(file)
    cmd = 'cat ' + shell
    content = os.popen(cmd).read().rstrip()
    f=open(shell,'w')
    f.write('#!/bin/bash\n')
    f.write('echo ==========start at : `date` ==========\n')
    f.write(content + ' && ' + '\\\n')
    f.write('echo ==========end at : `date` ========== && \\\n')
    f.write('echo ' + finish_string + ' 1>&2 && \\\n')
    f.write('echo ' + finish_string + ' > ' + shell + '.sign\n')
    f.close()

class myconf(configparser.ConfigParser):
    def __init__(self,defaults=None):
        configparser.ConfigParser.__init__(self,defaults=None,allow_no_value=True)
    def optionxform(self, optionstr):
        return optionstr
    
def mkdir(inDirs):
    for i in inDirs:
        if os.path.exists(i) == False:
            os.makedirs(i)

class LIMS():
    def __init__( self, config_file, port = 3306, charset='utf8' ):
        self.config_file = config_file
        self.config_dic = self.read_config( )
        usr  = self.config_dic['sql_usr']
        pwd = self.config_dic['sql_pwd']
        port = self.config_dic['sql_port']
        host = self.config_dic['sql_host']
        database = self.config_dic['sql_db']
        table = self.config_dic['sql_tb']
        try:
            self.cnx = mysql.connector.connect(user=usr, password=pwd, host=host, database=database, port = port, charset = charset)
            print( 'connect db {0}-{1} successed'.format(host, usr) )
            self.cursor = self.cnx.cursor()
        except mysql.connector.Error as err:
            print( 'connect db {0}-{1} failed'.format(host, usr) )
            print ( 'Error: {0}'.format( err ) )
            sys.exit(1)
        self.charset = charset
        
    def read_config(self):
        config_dic = {}
        with open(self.config_file, 'r') as infile:
            for line in infile:
                if re.search(pat1, line ) or line.startswith('#') : continue
                tmp = line.rstrip().split('=',1)
                target = tmp[0].rstrip(' ')
                value = tmp[1].lstrip(' ')
                if target not in config_dic :
                    config_dic[ target ] = value
                else :
                    print("{0} is repeat in {1}".format(target, self.config_file))
        return config_dic

    def insert( self, table_name, name_list, value_list ):
        '''
        col_list: 要插入的列名list
        value_list: 要插入的值,形如[(value1.1,value1.2,...), (value2.1,value2.2,...)]
        '''
        format_value = lambda x : '"{0}"'.format(str(x))
        cmd = 'INSERT INTO {0} ( {1} ) VALUES ({2});'.format(table_name , ",".join(name_list) , ",".join( map( format_value , value_list) ))
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
            self.close()
            sys.exit()


if __name__ == '__main__':
        main()
