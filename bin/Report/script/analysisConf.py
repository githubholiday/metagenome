#! /usr/bin/env python3
import re
import time
import sys
pat=re.compile('^\s$')
pat2 = re.compile('\[(\S+)\]')

date_now = time.strftime("%Y-%m-%d %H:%M:%S")

__author__='zhang yue'
__mail__= 'yuezhang@genome.cn'

def read_analysisConf( config ) :
    dict = {}
    header = ''
    with open ( config, 'r' ) as IN :
        for line in IN :
            if line.startswith('#') or re.search( pat, line ) : continue
            if line.startswith('[') :
                match = pat2.search(line)
                if match :
                    header = match.group(1)
                    dict[header] = {}
            else :
                if header == 'Para':
                    key, value = line.replace(' ', '').rstrip().split('=')
                    dict[header][key] = value
                else :
                    list = line.rstrip().split('\t')
                    num = len( dict[header] )
                    dict[header][num] = list
    return dict

def read_pipelineConf( config ) :
    dict = {}
    with open ( config, 'r' ) as IN :
        for line in IN :
            if line.startswith('#') or re.search( pat, line ) : continue
            key, value = line.rstrip().split('=')
            res = re.match("\$\((\w+)\)", value)
            if res :
                tmp = res.group(1)
                #print (tmp)
                if tmp in dict :
                    match = '$({0})'.format(tmp)
                    value = value.replace(match, dict[tmp])
                else :
                    sys.stderr.write( '\n{0} - read_pipelineConf - ERRPR - {1} is not existed, please check'.format( date_now, tmp ) )
                    sys.exit(1)
            dict[key] = value
    return dict
