#!/usr/bin/env python3
# -*- coding: utf-8 -*-
'''
描述:
    用于二代生成宏基因组流程所需配置文件，该流程目前在北京238节点运行

必选参数：
    -in, --indir    [必需]分析路径，需要包含 Analysis-238,Info,Filter
	-plat,--platform[可选]平台参数，可选为Illumina 或MGI，默认为Illumina
	-p,--project    [可选]子项目编号，默认从信搜中获取
	-n,--name       [可选]任务单名称，默认从信搜中获取
	-i,--info       [可选]信息搜集表文件绝对路径，默认为 indir/Info/*info.xlsx 下的文件
	-f,--filterdir  [可选]过滤路径，默认为 indir/Filter/Filter_Result目录，目录下要么包含ANNO开头的文件夹，要么包含Analysis结构的文件夹
	-s,--statfile   [可选]过滤统计文件，默认为filterdir/STAT_result.xls文件
	-c,--config     [可选]流程配置文件，默认为 bin/config/config.txt文件
	--cuts          [可选]默认30，用于KEGG等数据库比对时fa文件切割的份数
	--ref           [可选]默认使用DNA建库目录下的参考基因组，如果未进行DNA建库，可以使用Bwa index命令自行建库，该参数提供ref.fa路径即可，但是该路径下包含ref.fa的bwa索引文件
	-r              [可选]默认不投递，是否自动投递

'''

import os
import re
import sys
import argparse
import configparser
import pandas as pd
import subprocess
import logging
import getpass
import numpy as np
import glob
import time
import datetime
bindir = os.path.abspath(os.path.dirname(__file__))
sys.path.append(bindir + '/lib')
from PipMethod import generateShell,mkdir
filename = os.path.basename(__file__)

__author__ = 'zhang yue'
__mail__ = 'yuezhang@genome.cn'
__update__ = "liaorui zhangyang"
__date__ = "2023-3-24 2023-11-23"


pat1 = re.compile('^\s*$')
pat=re.compile('^\s$')
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

class myconf(configparser.ConfigParser):

    def __init__(self, defaults=None):
        configparser.ConfigParser.__init__(
            self, defaults=None, allow_no_value=True)

    def optionxform(self, optionstr):
        return optionstr

def read_pipelineConf( config ) :
    dict = {}
    with open ( config, 'r', encoding='gbk' ) as IN :
        for line in IN :
            if line.startswith('#') or re.search( pat, line ) : continue
            key, value = line.rstrip().split('=', 1)
            res = re.match("\$\((\w+)\)", value)
            if res :
                tmp = res.group(1)
                if tmp in dict :
                    match = '$({0})'.format(tmp)
                    value = value.replace(match, dict[tmp])
                else :
                    my_log.error( '{0} is not existed, please check'.format( tmp ) )
                    sys.exit(1)
            dict[key] = value
    return dict

def check_exists(content, Type, mkdir='Y'):
    if Type == "file":
        if not os.path.isfile(content):
            logging.error('{0} not exist!\n'.format(content))
            sys.exit(1)
    elif (Type == 'dir') & (mkdir == 'Y'):
        if not os.path.exists(content):
            os.makedirs(content)
            time.sleep(2)
    elif (Type == 'dir') & (mkdir == 'F'):
        if not os.path.exists(content):
            logging.error('{0} not exist!'.format(content))
            sys.exit(1)
    else:
        pass
    return content


def default_Para(config, args):
    [config.add_section(i) for i in ['Sample', 'cmp','Para','Cuts']]
    user = getpass.getuser()
    config.set('Para', 'Para_user', user)
    config.set("Para", "Para_config", args.config)
    config.set("Para", "Para_cutf", str(args.cuts))
    config.set("Para","Para_platform", args.platform)

def default_cuts( config, args):
    for i in range(1, args.cuts+1):
        config.set("Cuts",str(i))

class readinfo:
    info_df = pd.DataFrame()
    pair_df = pd.DataFrame()
    family_df = pd.DataFrame()

    def __init__(self, info_file, outdir, config ):
        self.info_file = info_file
        self.outdir = outdir
        self.config = config
        self.group_dict={}
        self.read_info()
        self.read_cmp()
        #self.read_genome_version()

    # 项目名称和项目编号
    def read_genome_version( self):
        df = pd.read_excel(self.info_file, sheet_name=0,index_col = 0)
        df = df.T
        self.projectName = df.loc['任务单名称'][0]
        reobj = re.compile('任务单.*')
        self.projectName = re.sub(reobj,'',self.projectName)
        self.projectName = self.projectName.rstrip('测序')
        self.projectName = self.projectName.rstrip('建库')
        self.projectName = self.projectName.rstrip('过滤')
        self.projectName += '结题报告'

        self.subproject_id=df.loc['子项目编号'][0]
    # 获得样品信息
    def project_name_deal(self):
        reobj = re.compile('任务单.*')
        self.projectName = re.sub(reobj,'',self.projectName)
        self.projectName = self.projectName.rstrip('测序')
        self.projectName = self.projectName.rstrip('建库')
        self.projectName = self.projectName.rstrip('过滤')
        self.projectName += '结题报告'

    def read_info(self):
        df = pd.read_excel(self.info_file, sheet_name=0)
        sample_start, sample_end = 0, 0
        ref = ''
        for i, row in df.iterrows():
            if row[0] == "宿主基因组版本":
                ref = str(row[1])
            if row[0] == '子项目编号':
                self.subproject_id=str(row[1])
            if row[0] == '任务单名称':
                self.projectName=str(row[1])
                self.project_name_deal()
            if row[0] == "差异比较组合":
                cmp_start = i
            if row[0] == "样品名称" and sample_start == 0:
                sample_start = i

        df = pd.read_excel(self.info_file, sheet_name=0, header=sample_start + 1)
        for i, row in df.iterrows():
            if pd.isnull(row["样品名称"]) or pd.isnull(row["样品编号"]) or pd.isnull(row["结题报告中样品名称"]):
                break
            sample_end = i

        info_df = df[[ "样品名称", "样品编号", "结题报告中样品名称", "样品描述", "分组" ]].iloc[0:sample_end+1, :]
        sample_len = len(info_df)
        sample_dup = info_df["样品名称"][info_df["样品名称"].duplicated(keep='first')]
        report_sample_dup = info_df["结题报告中样品名称"][info_df["结题报告中样品名称"].duplicated(keep='first')]
        sample_id_dup = info_df["样品编号"][info_df["样品编号"].duplicated(keep='first')]
        if sample_dup.shape[0] != 0 or report_sample_dup.shape[0] != 0 or sample_id_dup.shape[0] != 0:
            if sample_dup.shape[0] != 0:
                my_log.error('以下样品名称有重复,请修正:' + " ".join(set(sample_dup)))
            if report_sample_dup.shape[0] != 0:
                my_log.error('以下结题报告中样品名称有重复,请修正' + " ".join(set(report_sample_dup)))
            if sample_id_dup.shape[0] != 0:
                my_log.error('以下样本编号有重复,请修正' + " ".join(set(sample_id_dup)))
            sys.exit(1)

        #每个组中的样品信息,key-group,value=[样本1，样本2]
        group_Dict = {}

        for i, row in info_df.iterrows():
            for group in re.split(',|，', row['分组']):
                group_list = group.split('/')
                for each_group in group_list:
                    group_Dict.setdefault(group, []).append(row['结题报告中样品名称'])

        info_df[[ "样品名称", "样品编号", "样品描述", "结题报告中样品名称", "分组"]].to_csv(os.path.join(self.outdir, "sample.list"), sep='\t', header=False, index=None, encoding='utf-8')

        info_df[["结题报告中样品名称","分组"]].to_csv(os.path.join(self.outdir, "cmp.list"),sep='\t', header=False, index=None, encoding='utf-8')
        os.system("sed -i '1iSample\tGroup\n' {0}".format(os.path.join(self.outdir, "cmp.list")))
        self.config.set('Para', 'Para_samplenum', str(info_df.shape[0]))
        self.config.set('Para', 'Para_samplelist', os.path.join(self.outdir, "sample.list"))
        self.config.set('Para', 'Para_cmp', os.path.join(self.outdir, "cmp.list"))
        self.config.set('Para', 'Para_sample', ",".join(info_df["结题报告中样品名称"].tolist()))
        self.group_dict = {}
        for i,row in info_df[["结题报告中样品名称","分组"]].iterrows():
            sample_name,groups=row

            for group in groups.split('/'):
                group=group.strip()
                if group not in self.group_dict:
                    self.group_dict[group]= []
                self.group_dict[group].append(sample_name)

        self.sample_info = info_df
        self.ref = ref
        self.sample_len = sample_len
    def read_cmp(self):
        df = pd.read_excel(self.info_file, sheet_name=0)
        cmp_is, cmp_ie = 0, 0
        for i,row in df.iterrows():
            if row[0] == "比较组合":
                cmp_is = i
                break
        df = pd.read_excel(self.info_file, sheet_name=0,header=cmp_is+1)
        for i,row in df[["比较组合","处理组","参考组"]].iterrows():
            if pd.isnull(row["比较组合"]) or pd.isnull(row["处理组"]) or pd.isnull(row["参考组"]):
                break
            cmp_ie = i
        cmp_df = df[["比较组合","处理组","参考组"]].iloc[0:cmp_ie+1,1:]
        flag = 1
        for i,row in cmp_df.iterrows():
            if row[0] not in self.group_dict:
                my_log.error('{} 分组不存在'.format(row[0]))
            elif row[1] not in self.group_dict:
                 my_log.error('{} 分组不存在'.format(row[1]))
            else: 
                #row.append('yes')
                cmp1 = row[0]
                cmp2 = row[1]
                self.diff_analysis = "no"
                if len( self.group_dict[cmp1]) >= 3 and len( self.group_dict[cmp2])>=3 :
                    self.diff_analysis = "yes"
                    flag = 0
                else :
                    my_log.warning("比较组中的重复不超过3个，所以不进行差异分析")
                cmp_diff_dir = "{self.outdir}/../Analysis/Diff/{cmp1}_{cmp2}".format(self=self, cmp1=cmp1, cmp2=cmp2 )
                my_run("mkdir -p {0}".format( cmp_diff_dir ))
                sample_list_file = "{0}/sample.list".format( cmp_diff_dir )
                cmp_list_file = "{0}/cmp.list".format(cmp_diff_dir)
                with open( cmp_list_file, 'w') as cmp_output:
                    cmp_output.write(cmp1+'\t'+cmp2+'\n')
                with open( sample_list_file, 'w') as sample_output:
                    sample_output.write("Sample\tGroup\n")
                    for cmp1_s in self.group_dict[cmp1]:
                        value_list = [cmp1_s, cmp1]
                        sample_output.write('\t'.join(value_list)+'\n')
                    for cmp2_s in self.group_dict[cmp2]:
                        value_list = [cmp2_s, cmp2]
                        sample_output.write('\t'.join(value_list)+'\n')

                cmp_info = [ cmp1, cmp2, self.diff_analysis]
                self.config.set("cmp",'\t'.join(cmp_info))
        self.config.set("Para",'Para_Diff',self.diff_analysis)
        pipe_cmp = os.path.join(self.outdir,"cmp2.txt")
        cmp_df.to_csv(pipe_cmp,sep='\t', header=None,index=None,encoding="utf-8")
        self.config.set("Para",'Para_cmp2File',pipe_cmp)
        # 设置多组比较的部分
        df = pd.read_excel(self.info_file, sheet_name=0)
        cmp_is, cmp_ie = 0, 0
        for i,row in df.iterrows():
            if row[0] == "组合名":
                cmp_is = i
                break
        df = pd.read_excel(self.info_file, sheet_name=0,header=cmp_is+1)
        for i,row in df[["组合名","分组"]].iterrows():
            if pd.isnull(row["组合名"]) or pd.isnull(row["分组"]) :
                break
            cmp_ie = i
        cmp3_df = df[["组合名","分组"]].iloc[0:cmp_ie+1,:].dropna()
        flag = 1
        pipe_cmp3 = os.path.join(self.outdir,"cmp3.txt")
        cmp3_df.to_csv(pipe_cmp3,sep='\t', header=None,index=None,encoding="utf-8")
        self.config.set("Para",'Para_cmp3File',pipe_cmp3)

def get_clean_dir(filterdir):
    if not os.path.exists( filterdir ) :
        my_log.info("{0} 路径不存在".format( filterdir))
        sys.exit(1)
    cleandir = glob.glob("{0}/Analysis/*/filter/clean/".format(filterdir))
    if len(cleandir) == 0 :
        cleandir2 = glob.glob("{0}/*/Cleandata/".format(filterdir))
        if len(cleandir2) == 0:
            my_log.error("目录结构既不是Analysis也不是CleanData模式，退出")
            sys.exit(1)
        elif len(cleandir2) == 1 :
            my_log.info("过滤数据路径为 {0}".format(cleandir2[0]))
            return cleandir2[0]+"/sample"
        else :
            my_log.error("多个ANNO开头的目录,请保留一个")
            sys.exit(1)
    else:
        return "{0}/Analysis/sample/filter/clean/".format(filterdir)

def my_run( cmd, promt=True ):
    if os.system(cmd) == 0 :
        if promt:
            my_log.info('cmd:{0},成功'.format(cmd))
    else:
        if promt:
            my_log.error('cmd:{0},失败'.format(cmd))

def check_and_rename(sample_info, filterdir, resultdir, config ):
    if os.path.exists(resultdir+"/QC/filter"):
        my_log.info("目录下存在数据，正在删除重新连接 {0}/QC/filter/".format(resultdir))
        os.system("rm {0}/QC/filter/*".format(resultdir))
    else:
        check_exists( os.path.join( resultdir, "QC" ), "dir" )
    sample_dict = {}
    for i, row in sample_info.iterrows():
        sample_name = row["结题报告中样品名称"]
        sample_id = row["样品名称"]

        sample_dict[str(sample_id)] = [ sample_name ]
    sample_list = []
    cleandir = get_clean_dir( filterdir )

    redir = os.path.join( resultdir, "QC", "filter" )
    check_exists( os.path.join( resultdir, "QC", "filter" ), "dir" )
    for sample in sample_dict:
        sample_clean_dir = cleandir.replace('sample', sample)
        tmp = sample_dict[sample]
        report_sample_name = sample_dict[sample][0]
        clean_fq = '{0}/{1}_R1.fq.gz'.format(sample_clean_dir,sample)
        if not  os.path.exists( clean_fq ):
            my_log.error("{0} 数据不存在，请核实".format(clean_fq))
            sys.exit(1)
        R1_cmd = "ln -s {0}/{1}_R1.fq.gz {2}/{3}_R1.fq.gz".format(sample_clean_dir,sample,redir,report_sample_name)
        R2_cmd = "ln -s {0}/{1}_R2.fq.gz {2}/{3}_R2.fq.gz".format(sample_clean_dir,sample,redir,report_sample_name)
        my_run(R1_cmd, False)
        my_run(R2_cmd, False)
        if not report_sample_name in sample_list :
            tmp.extend(["{0}/{1}_R1.fq.gz".format(redir,report_sample_name),"{0}/{1}_R2.fq.gz".format(redir,report_sample_name)])
            config.set("Sample", '\t'.join(tmp))
            sample_list.append( report_sample_name )

    return os.path.join( resultdir, "QC")

def read_ref_conf( species_config):
    config = myconf()
    config.read( species_config )
    ref = config['Para']['Para_ref']
    return ref

class generate_pipeline_qsub:
    def __init__(self, python3, pipeline_generate,pipe_type,config_file,sub_project_id,outdir,pipeline_config_file,pipelineDir):
        self.work_shell = None
        self.python3 = python3
        self.pipeline_generate = pipeline_generate
        self.pipe_type = pipe_type
        self.config_file = config_file
        self.sub_project_id = sub_project_id
        self.pipeline_config_file = pipeline_config_file
        self.pipelineDir = pipelineDir
        self.outdir = outdir
        #self.generate_pipeline()

    def generate_pipeline(self):
        work_shell = os.path.join(self.outdir,'{0}_{1}_qsub_sge.sh'.format(self.pipe_type,self.sub_project_id))
        self.work_shell = work_shell
        self.pipeline_config_file = os.path.abspath(self.pipeline_config_file)
        mkdir(['{0}/Analysis'.format(self.outdir)])
        content = "{0} {1} -i {2} -o {3}/pipeline && \\\n".format(self.python3,self.pipeline_generate,self.pipeline_config_file,self.outdir)
        content += "sleep 30s && \\\n"
        content += "{0} {1}/pipeline/pipeline.py -i {2} -j {3}_{5} -b {4} -o {1}/Analysis -name {3}_{5} -c  -r".format(self.python3,self.outdir,self.config_file,self.sub_project_id,self.pipelineDir,self.pipe_type)
        generateShell(work_shell,content)

def main():
    parser = argparse.ArgumentParser(description=__doc__,
             formatter_class=argparse.RawDescriptionHelpFormatter,
             epilog='author:\t{0}\nmail:\t{1}\nupdate:\t{2}\ndate:\t{3}'.format(__author__, __mail__,__update__,__date__))
    parser.add_argument('-in', '--indir', help='【必需】输入和输出路径', dest='indir', required = True)
    parser.add_argument('-plat', '--platform', help='【必需】测序平台:MGI or Illumina,原先用于报告，现在没用了', dest='platform', required=False, default='Illumina' )
    parser.add_argument('-p', '--project_id', help='【可选】子项目编号', dest='project_id')
    parser.add_argument('-py', '--python3', help='【可选】python3路径', dest='python3',default='/annoroad/data1/software/bin/miniconda/envs/python3_base/bin/python3')
    parser.add_argument('-pg','--pipeline_generate',help='【可选】path of pipeline_generate.py',dest='pipeline_generate',type=str,default='/annoroad/data1/software/bin/pipeline_generate/bin/current/pipeline_generate.py')
    parser.add_argument('-n', '--name', help='【可选】任务单名称', dest='name', required=False )
    parser.add_argument('-i', '--infofile', help='【可选】info文件', dest='infofile', required=False)
    parser.add_argument('-f', '--filterdir', help='【可选】质控下机数据，给到Filter_Result', dest='filterdir')
    parser.add_argument('-s', '--statfile', help='【可选】过滤中的Stat_Result.xls文件', dest='statfile')
    parser.add_argument('-c', '--config', help='【可选】流程的config文件', dest='config', default=os.path.abspath('{0}/../../config/config.txt'.format(bindir)))
    parser.add_argument('--cuts', help='做KEGG和SwissProt数据库注释时，fa切割份数', dest='cuts',type=int, default=30)
    parser.add_argument('-ref', help='ref fa', dest='ref')
    parser.add_argument('-t','--type', help='【可选】流程类型，默认NGS_Metagenome', dest='type',default='NGS_Metagenome')
    parser.add_argument('-r', '--run', help='auto qsub or not', action='store_true')
    parser.add_argument('-pipd','--pipelineDir',help='pipeline_bin',dest='pipelineDir',type=str,default='{0}/../bin'.format(bindir))
    args = parser.parse_args()
    pipeline_name = 'NGS_Metagenome'

    # set the logging
    logging.basicConfig(level=logging.DEBUG, format="%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s - %(message)s")

    outdir= '{0}/Analysis-238/'.format( args.indir )
    info_dir = '{0}/info'.format( args.indir )
    filter_dir = '{0}/Filter/Filter_Result'.format( args.indir )
    
    result_dir = '{0}/Analysis'.format( outdir )
    prepare_dir = '{0}/prepare'.format( outdir )
    analysis_config = '{0}/config.ini'.format( prepare_dir )
    args.config = os.path.abspath(args.config)
    ##如果提供了过滤路径或者统计文件，使用提供的 
    if args.filterdir :
        filter_dir = args.filterdir
    stat_file = '{0}/STAT_result.xls'.format( filter_dir)

    if args.statfile :
        stat_file = args.statfile

    if not os.path.exists( stat_file ):
        my_log.error("{0} 文件不存在".format( stat_file))
    ## 
        
    #信搜判断，以_info.xls结尾
    info_file_list = glob.glob('{0}/*_info.xls*'.format( info_dir ))
    if len(info_file_list) == 1 :
        info_file = info_file_list[0]
        my_log.info("信息搜集表为 {0}".format( info_file ))
    elif len(info_file_list) == 0:
        my_log.error("info 目录下没有信息搜集表，请查看是否不是以 _info.xlsx结尾")
        sys.exit(1)
    else:
        my_log.error("info 目录下有多个信息搜集表，请删除")
        sys.exit(1)
    
    # 判断文件
    PreDir = check_exists( prepare_dir, "dir")
    ResultDir = check_exists( result_dir, "dir")

    # 读取config信息
    pipe_config_dict = read_pipelineConf(args.config)
    
    # 初始化config
    config = myconf()
    default_Para(config, args)
    # 读取信息收集表
    Info = readinfo( info_file, PreDir, config )
   
    exclude = []
    if Info.ref != 'nan':
        if args.ref :
            ref_path = args.ref
        else:
            ref = glob.glob("{0}/{1}*.txt".format(pipe_config_dict['ref_db'],Info.ref))
            if ref:
                ref_path = read_ref_conf(ref[0])
            else:
                my_log.error("宿主基因组版本{0}，没有建bwa库，烦请进行确认".format(Info.ref))
                sys.exit(1)
        config.set("Para","Para_ref",ref_path)
        my_log.info("该项目的宿主基因组为:{0}".format( ref_path ))
    else:
        my_log.info("没有提供参考基因组信息，则默认为无宿主")
        config.set("Para","Para_ref",'no_ref')
    #不进行差异比较组分析
    all_job_config = '{0}/../../config/job_config.txt'.format(bindir)
    my_log.info("该项目调用的job_config为: {0}".format( all_job_config ))
    job_config = '{0}/job_config.txt'.format(PreDir)
    cp_cmd = 'cp {0} {1}'.format(all_job_config, job_config )
    if os.system( cp_cmd ) == 0:
        my_log.info("项目job_config文件:{0}".format( job_config ))
    
    Original_BAM = check_and_rename( Info.sample_info, filter_dir, ResultDir, config )
    config.set("Para", "Para_prepare", PreDir)
    config.set("Para", "Para_cleandir", ResultDir+"/QC/filter/")
    config.set("Para", "Para_filterdir",filter_dir)
    config.set("Para","Para_filter_stat",stat_file)
    config.set("Para","Para_analysis_config", analysis_config)
    default_cuts( config, args )

    if args.name :
        project_name = args.name
    else :
        project_name = Info.projectName
        
    if args.project_id:
        sub_project_id = args.project_id
    else:
        sub_project_id = Info.subproject_id

    config.set("Para", "Para_ProjectName", project_name)
    config.set("Para", "Para_Project", sub_project_id)
    if Info.sample_len <30:
        config.set("Para","Para_gene_min_len","200")
    elif Info.sample_len <=60:
        config.set("Para","Para_gene_min_len","500")
    else:
        print("your sample len is larger than 60, so stop !")
        sys.exit(1)
    # 生成config.ini
    config.write(open(analysis_config, "w"))
    print(analysis_config)
    # 生成流程
    #qsub_shell = generate_pip(job_config, PreDir, ResultDir, bindir, sub_project_id, pipe_config_dict)
    pip_qsub = generate_pipeline_qsub(args.python3, args.pipeline_generate,args.type,analysis_config,sub_project_id,outdir,all_job_config,args.pipelineDir)
    pip_qsub.generate_pipeline()
    # 是否投递
    if args.run:
        cmd = ('sh {0}'.format(pip_qsub.work_shell))
        os.system(cmd)


if __name__ == "__main__":
    my_log = Log(filename)
    main()
