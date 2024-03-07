#! /usr/bin/env python3
import argparse
import sys
import os
import re
import time
import logging
import configparser
from analysisConf import *
bindir = os.path.abspath(os.path.dirname(__file__))

__author__='zhang yue'
__mail__= 'yuezhang@genome.cn'

pat1=re.compile('^\s+$')
now = time.strftime("%Y-%m-%d %H:%M:%S")
LOG = os.path.basename(__file__)

def my_log( level, message ) :
    logging.basicConfig(level = logging.INFO,format = '%(asctime)s - %(filename)s - %(levelname)s - %(message)s')
    logger = logging.getLogger(__name__)
    if level == 'info' :
        return logger.info( message )
    if level == 'warning' :
        return logger.warning( message )
    if level == 'debug' :
        return logger.debug( message )
    if level == 'error' :
        return logger.error( message )

def check_file_exists( *file_list ) :
    for file in file_list :
        if os.path.exists( file ) :
            my_log( 'info', 'file : {0}'.format( file ) )
        else :
            my_log( 'error', 'file is not exists : {0}'.format( file ) )

def make_dir( dir ) :
    if not os.path.exists( dir ) :
        try :
            os.makedirs( dir )
            time.sleep(1)
            my_log( 'info', 'mkdir {0} sucessful!'.format( dir) )
        except :
            my_log( 'error', 'mkdir {0} failed!'.format( dir) )
    else :
        my_log( 'info', '{0} is exist'.format( dir ) )

def myrun( cmd ) :
    if os.system( cmd ) == 0 :
        my_log( 'info', '{0} run sucessfully !'.format( cmd ) )
    else :
        my_log( 'error', '{0} run failed !'.format( cmd ) )

def main():
    parser=argparse.ArgumentParser(description=__doc__,
            formatter_class=argparse.RawDescriptionHelpFormatter,
            epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
    parser.add_argument('-c','--config',help='config file',dest='config',required=True)
    parser.add_argument('-o','--output',help='output file',dest='output',type=argparse.FileType('w'),required=True)
    parser.add_argument('-u','--upload',help='upload dir',dest='upload',required=True)
    args=parser.parse_args()

    upload = os.path.abspath(args.upload) 
    make_dir( upload )
    
    dict = read_analysisConf( args.config )
    
    ### 配置 report.conf 文件
    sample_count = len(dict['Sample'])
    out='''SAMPLE_NUM:{0}
PROJECT_NAME:{1}
PROJECT_ID:{2}
REPORT_DIR:{3}
PLATFORM:{4}
'''.format( sample_count, dict['Para']['Para_ProjectName'], dict['Para']['Para_Project'], upload, dict['Para']['Para_platform'] )
    args.output.write( out )

    ### 拷贝 common 文件夹到 upload
    #common = bindir + '/../common'
    #cmd = 'cp -rf {0} {1}'.format( common, upload )
    #myrun( cmd )
    #temp = bindir + '/../config/metagenome.template'
    #cmd2 = 'cp {0} {1}'.format(temp, upload+"/../")
    #myrun(cmd2)

if __name__ == '__main__':
    main()
