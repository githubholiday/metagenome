#!/usr/bin/env python3
"""
用于markdown 报告数据上云用

"""
import argparse
import os
import sys
import re
import logging
import getpass
import subprocess
import time
import datetime
import configparser
bin = os.path.abspath(os.path.dirname(__file__))
__author__='Ren Xue'
__mail__= 'xueren@genome.cn'
__date__= '2020年06月21日 星期日 08时50分04秒'

class OSSUTIL:
	def __init__(self,bin,place,project,outdir,direct=False):
		self.bin = bin
		#self.config_file = '{0}/.oss.{1}.config'.format(bin,place)
		#self.config = configparser.ConfigParser()
		#self.config.read(self.config_file)
		self.place = place
		self.project = project
		self.product = "oss://annoroad-cloud-product/user/report"
		self.test = "oss://annoroad-cloud-test/user/report"
		self.tmpdir = outdir
		if self.place == "bj":
			self.util = 'ssh c0803 ' + '{0}/report {0}/ossutil in '.format(bin)
			self.rmreport = 'ssh c0020 ' + '{0}/rmossreport'.format(bin)
		elif self.place == "yw":
			#self.util = '{0}/ossutil'.format(bin)
			#self.rmreport = '{0}/rmossreport2'.format(bin)
			self.util = 'ssh YW-SGE-node04 ' + '{0}/report {0}/ossutil in '.format(bin)
			self.rmreport = 'ssh YW-SGE-node04 ' + '{0}/rmossreport'.format(bin)
		else:
			self.util = '{0}/report {0}/ossutil out '.format(bin)
			self.rmreport = '{0}/rmossreport'.format(bin)
	def rm_upload (self):
		cmd = '{self.rmreport} -oss {self.bin}/ossutil -loc {self.place} -p {self.project} 1>{self.tmpdir}/upload.log 2>{self.tmpdir}/upload.log'.format(self=self)
		print(cmd)
		result = subprocess.call(cmd,shell=True)
		if result != 0:
			sys.stderr.write("upload 删除upload失败\n")

	def ls_cmd (self, file):
		#cmd='{0} -c {1} ls {2} '.format(self.util, self.config_file, file)\
		cmd = '{0} ls {1}'.format(self.util,file)
		result = subprocess.check_output(cmd,shell=True)
		if file in result.decode("utf-8"):
			return True
		else:
			return False
	def cp_cmd(self, file_up,file_down,Type="file"):
		#cmd = '{0} -c {1} cp -f {2} {3} -u >/dev/null '.format(self.util, self.config_file, file_up, file_down)
		#cmd = '{0} -c {1} cp -f {2} {3} -u --checkpoint-dir={4}/tmp 1>>{4}/upload.log 2>>{4}/upload.log'.format(self.util, self.config_file, file_up, file_down,self.tmpdir)
		cmd = '{0} cp "-f {1} {2} -u --checkpoint-dir={3}/tmp " 1>>{3}/upload.log 2>>{3}/upload.log '.format(self.util, file_up, file_down,self.tmpdir)
		if Type == "dir":
			#cmd = '{0} -c {1} cp -r {2} {3} -u >/dev/null '.format(self.util, self.config_file, file_up, file_down)
			#cmd = '{0} -c {1} cp -r {2} {3} -u --checkpoint-dir={4}/tmp 1>>{4}/upload.log 2>>{4}/upload.log '.format(self.util, self.config_file, file_up, file_down, self.tmpdir)
			cmd = '{0} cp "-r {1} {2} -u --checkpoint-dir={3}/tmp " 1>>{3}/upload.log 2>>{3}/upload.log '.format(self.util, file_up, file_down, self.tmpdir)
		print(cmd)
		result = subprocess.call(cmd,shell=True)
		if result != 0:
			sys.stderr.write("{0} 上传失败\n".format(file_up))
			sys.exit(1)
		else:
			sys.stdout.write('{0}上传完毕\n'.format(file_up))


def check_exists(content, Type, Do = 'Y'):
        if Type == "file":
                if not os.path.isfile(content):
                        sys.stdout.write('{0}文件不存在，请确认\n'.format(content))
                        sys.exit(1)
        elif (Type == 'dir') & (Do == 'Y'):
                if not os.path.exists(content):
                        os.makedirs(content)
        elif (Type == 'dir') & (Do == 'N'):
                if not os.path.exists(content):
                        sys.stdout.write('{0} 文件夹不存在，请确认\n'.format(content))
                        sys.exit(1)
        else:
                pass
        content = os.path.abspath(content)
        return content

def time_judge(time1,time2):
	d1 = datetime.datetime.strptime(time1, "%Y-%m-%d %H:%M:%S")
	d2 = datetime.datetime.strptime(time2, "%Y-%m-%d %H:%M:%S")
	inter = d2-d1
	return inter.days

def main():
	parser=argparse.ArgumentParser(description=__doc__,formatter_class=argparse.RawDescriptionHelpFormatter,epilog='author:\t{0}\nmail:\t{1}\ndate:\t{2}\n'.format(__author__,__mail__,__date__))
	parser.add_argument('-o','--outdir',help='输出路径，默认当前路径，上传成功会生成upload_finish.log, 所以输出路径必须有可写权限',dest='outdir',type=str)
	parser.add_argument('-i','--indir',help='indir路径，下面必须有upload，report.md, mapping.json',dest='indir',type=str,required=True)
	parser.add_argument('-p','--project',help='子项目编号',dest='project',type=str,required=True)
	parser.add_argument('-pro','--product',help='加上该参数就会传到正式版bucket，不加就是测试版',dest='product',action='store_true')
	parser.add_argument('-direct','--direct',help='如果不需要切换节点或者选择直传，请加上这个参数',dest='direct',action='store_true')
	parser.add_argument('-result','--result',help='是否需要上传upload.zip',dest='result',action='store_true')
	parser.add_argument('-place','--place',help='地点，bj or yw，默认bj',dest='place',default='bj',choices=["bj","yw","huawei"])
	args=parser.parse_args()

	sys.stdout.write("########## 报告上云开始解析~\n")
	# 判断用户
	#user = getpass.getuser()
	local_time = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
	# 判断输出路径
	outdir = os.getcwd()
	if args.outdir:
		outdir = check_exists(args.outdir,"dir","Y")
	# 判断输入
	upload = check_exists('{0}/upload'.format(args.indir),"dir","N")
	report_md = check_exists('{0}/report.md'.format(args.indir),"file")
	mapping_json = check_exists('{0}/mapping.json'.format(args.indir),"file")
	result=""
	if args.result:
		result = check_exists('{0}/upload.zip'.format(args.indir),"file")
	#是否直传，直传是已经切换节点，或者就在云节点
	if args.direct:
		oss = OSSUTIL(bin,args.place,args.project,outdir,True)
	else:
		oss = OSSUTIL(bin,args.place,args.project,outdir,False)
	oss_dir = oss.test
	#判断是否是正式版：
	if args.product:
		oss_dir = oss.product
	yundir='{0}/{1}/'.format(oss_dir,args.project)
	yun_upload = '{0}/{1}/upload'.format(oss_dir,args.project)
	yun_report_md = '{0}/{1}/report.md'.format(oss_dir,args.project)
	yun_mapping_json = '{0}/{1}/mapping.json'.format(oss_dir,args.project)
	yun_result='{0}/{1}/upload.zip'.format(oss_dir,args.project)

	#判断是否是正式版：
	if args.product:
		oss_dir = oss.product
	# 判断云上日志文件是否存在
	yun_log = '{0}/{1}/report_upload.log'.format(oss_dir,args.project)
	local_log = '{0}/report_upload.log'.format(outdir)
	report_log = configparser.ConfigParser()
	finish_log = '{0}/upload_finished.log'.format(outdir)
	if os.path.isfile(finish_log):
		os.system('rm -r {0}'.format(finish_log))
	if oss.ls_cmd(yun_log):
		sys.stdout.write("########## 开始检查云上日志~\n")
		oss.cp_cmd(yun_log,local_log)
		report_log.read(local_log,encoding="utf-8")
		#log_user = report_log.get('info','user')
		#判断用户是否正确
		#if user !='admin-sci' and log_user != user:
		#	sys.stderr.write("报告首次上传人是{0}，本次是{1}，您没有权限\n".format(log_user,log_user))
		#	sys.exit(1)	
		#判断 正式版日期限制		
		#if args.product and user !='admin-sci':
		start_time = report_log.get('info','start')
		time_inter = time_judge(start_time,local_time)
		if int(time_inter)   >14: 
			sys.stderr.write("云上正式版报告从第一次上传开始，已经存在{0}天,大于14天，如需更新，请联系相关主管说明更新原因，找任雪\n".format(time_inter))
			sys.exit(1)	
		if os.path.isfile(local_log):
			os.system('rm -r {0}'.format(local_log))
	
		sys.stdout.write("########## 云上报告已存在，您将进行更新操作，请谨慎~~~\n")
		oss.rm_upload()
		oss.cp_cmd(upload, yun_upload,"dir")
		oss.cp_cmd(report_md, yun_report_md) 
		oss.cp_cmd(mapping_json, yun_mapping_json)
		num=3
		if args.result:
			oss.cp_cmd(result, yun_result)
			num=4
		times = report_log['info']['times']
		times = str(int(times)+1)
		os.system(' echo "{3}种文件上云成功， 这是该项目第{0}次上云\n云上路径为：{2}\n" >{1}/upload_finished.log'.format(times,outdir,yundir,num))
		report_log.set("info","times",times)
		report_log.set("times",times,local_time)
		report_log.set("times",times,local_time)
	else:
		num=3
		oss.cp_cmd(upload, yun_upload,"dir")
		oss.cp_cmd(report_md, yun_report_md) 
		oss.cp_cmd(mapping_json, yun_mapping_json)
		if args.result:
			oss.cp_cmd(result, yun_result)
			num=4
		os.system('echo "{2}种文件上云成功， 这是该项目第1次上云\n云上路径为：{1}\n" >{0}/upload_finished.log'.format(outdir,yundir,num))
		report_log.add_section('info')
		#report_log.set("info","user",user)
		report_log.set("info","times","1")
		report_log.set("info","start",local_time)
		report_log.add_section('times')
		report_log.set("times","1",local_time)

	#日志文件输出
	with open(local_log, 'w') as configfile:
		report_log.write(configfile)
	oss.cp_cmd(local_log,yun_log)
	os.system('rm -r {0}'.format(local_log))
	sys.stdout.write("########## 报告上云完成~\n")

if __name__=="__main__":
	main()
