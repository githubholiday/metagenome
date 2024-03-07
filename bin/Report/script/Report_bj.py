#! /usr/bin/env python3

'''
更新说明：
lihuayun(huayunli@genome.cn)
Report_V3
1.和IT协同增加了云节点192.168.1.3专门用于生成结题报告，同时直接在该节点挂在了nas/data1和本地/annoroad/
2.有了上述基础，添加了type参数(cloud or local)，并添加了子函数Generate_Report_cloud_server
3.现有nas路径下项目结题报告生成无需上传和下载时upload和其他文件的scp，大大提高了结题报告的生成速度
4.后续有其他云路径需要在云节点上生成结题报告可以考虑将路径挂载到192.168.1.3:/usr/local/file/PDFS/下

liuhuiling(huilingliu@genome.cn)
Report_V2
2018.3.28
1.解决一行有多个从report.conf读取的参数问题，刘江提供解决方案
2017.11.20
1.捕获 java.io.IOException类报错信息

Report_V2
2017.10.20
1.数据库查询效率提高
2.新生产服务器

liuhuiling(huilingliu@genome.cn)
Report_V1
2017.8.3
1.遇到表格文件中有空的单元格，输出table path:table name:等信息

liuhuiling(huilingliu@genome.cn)
Report_V1
2017.6.6
1.Table标签后面的文件不存在，报错并退出程序
2017.5.24
1.report.conf中不再读取REPORT_TYPE

liuhuiling(huilingliu@genome.cn)
2017.5.18:
1.download展示列表最大改为25
2.多图展示时可选框改为最多5图
3.可以生成pdf版结题报告

liuhuiling(huilingliu@genome.cn)
2017.5.11:
1.如果遇到生成结题报告的Java程序报错，会输出错误提示（ssh_cmd）
2.如果是scp到的路径权限问题，会输出错误提示（scp_upload）

liuhuiling(huilingliu@genome.cn)
2017.4.25:
1.增加Report.py的异常退出处理：如果Report.py运行过程中通过Ctrl+C中断,lock文件被删除

jiangdezhi(dezhijiang@genome.cn)
2017.3.31:
1. 通过P:#S,;#方式对特定段落进行加粗处理

jiangdezhi(dezhijiang@genome.cn)
2017.3.24:
1. 添加表格宽度设置，默认为600px。

jiangdezhi(dezhijiang@genome.cn)
2017.3.21:
1. 默认表格中每一个单元格字符串长度大于50字符则取前面50个字符，后面用"..."代替

jiangdezhi(dezhijiang@genome.cn)
2017.3.20:
1. 图片（Image）默认大小为300px，也可以自行设定
2. 添加表格输出列数设置：如果表格小于或等于10列，默认全部输出；否则，只输入前10列。另外，输出列数也可以自行设定，此时列数不受限制。  

jiangdezhi(dezhijiang@genome.cn)
2017.3.15:
1. 添加表格输出行数设置：如果表格小于20行，默认全部输出；否则，只输入前20行。另外，输出行数也可以自行设定，此时行数不受限制。  
2. report.conf可以自由配置，但PROJECT_NAME,PROJECT_TYPE,REPORT_DIR,SAMPLE_NUM必须要有。

'''

import argparse
import sys
import os
import re
import time
import datetime
import mysql.connector
import glob
import pexpect
from pexpect import *
import getpass
bindir = os.path.abspath(os.path.dirname(__file__))

__author__='Su Lin'
__mail__= 'linsu@annoroad.com'
__modifier__='Jiang Dezhi'
__mail__='dezhijiang@genome.com'
__modifier__='Liu Huiling'
__mail__='huilingliu@genome.com'
__modified_time__='2016.9-'
__doc__='the program is to create sql based on wed_report template file!'

pat1= 'INFO'
year = datetime.date.today().year
suffix = '_'+str(year)
#suffix = ''

class Main_Menu:
	def __init__(self):
		self.name=''
	def insert_sql(self,name,parent,order,cursor):
		sql="INSERT INTO tb_main_menu{suffix} VALUES (null,'{2}_{0}','{0}', '{1}', '{2}');".format(name,parent,order+1,suffix=suffix)
		try:
			#print(sql,'\n')
			cursor.execute(sql)
			menu_id = cursor.lastrowid
		except mysql.connector.errors.IntegrityError:
			print(name,'已经在tb_mein_menu表格中')
		#sql ="SELECT * FROM tb_main_menu WHERE menu_name='{0}'".format(name)
		return(menu_id)

class Sub_Menu:
	def __init__(self):
		self.name = ''
	def insert_sql(self,name,parent,m_order,order,cursor):
		sql="INSERT INTO tb_sub_menu{suffix} VALUES (null,'{1}','{2}_{3}_{0}', '{2}.{3}{0}', '','{3}');".format(name,parent,m_order,order,suffix=suffix)
		try:
			#print(sql,'\n')
			cursor.execute(sql)
			menu_id = cursor.lastrowid
		except mysql.connector.errors.IntegrityError:
			print('{0}.{1}{2}'.format(m_order,order,name),'已经在tb_sub_menu表格中')
		#sql ="SELECT * FROM tb_sub_menu WHERE menu_name='{1}.{2}{0}'".format(name,m_order,order)
		return(menu_id)
	def updata_content(self,sub_menu_content_dic,cursor):
		for s_menu_id in sub_menu_content_dic:
			display = ','.join(sub_menu_content_dic[s_menu_id])
			sql = "UPDATE tb_sub_menu{suffix} SET display_order='{0}' WHERE menu_id='{1}'".format(display,s_menu_id,suffix=suffix)
			#print(sql,'\n')
			cursor.execute(sql)

class Third_Menu:
	def __init__(self):
		self.name = ''
	def insert_sql(self,name,parent,m_order,s_order,t_order,cursor):
		sql = "INSERT INTO tb_third_menu{suffix} VALUES (null,'{0}','{1}.{2}.{3}{4}','','{3}');".format(parent,m_order,s_order,t_order,name,suffix=suffix)
		try:
			#print(sql,'\n')
			cursor.execute(sql)
			menu_id = cursor.lastrowid
		except mysql.connector.errors.IntegrityError:
			print('{0}.{1}.{2}{3}'.format(m_order,s_order,t_order,name),'已经在tb_third_menu表格中')
		#sql = "SELECT * FROM tb_third_menu WHERE menu_name='{0}.{1}.{2}{3}'".format(m_order,s_order,t_order,name)
		return(menu_id)
	def update_content(self,third_menu_content_dic,cursor):
		for t_menu_id in third_menu_content_dic:
			display = ','.join(third_menu_content_dic[t_menu_id])
			sql = "UPDATE tb_third_menu{suffix} SET display_order='{0}' WHERE menu_id='{1}'".format(display,t_menu_id,suffix=suffix)
			#print(sql,'\n')
			cursor.execute(sql)

class Content:
	def __init__(self):
		self.names = ''
	def insert_sql(self,c,cursor):

		sql = "INSERT INTO tb_content{suffix} VALUES (null,'{0}')".format(c,suffix=suffix)
		try:
			#print(sql,'\n')
			cursor.execute(sql)
			content_id = cursor.lastrowid
		except mysql.connector.errors.IntegrityError:
			print('{0} 已经在tb_content表格中'.format(c))
		#sql = "SELECT * FROM tb_content WHERE content='{0}'".format(c)
		return(content_id)
	def delete_sql(self,content_id,cursor):
		sql = "DELETE FROM tb_content{suffix} where content_id='{0}'".format(content_id,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)

class Pic:
	def __init__(self):
		self.names = ''
	def get_pic_id(self,pic_all_flag,path,pic_name,cursor):
		file_list = sorted(glob.glob(path))
		pic_id_list = []
		pic_num = 0
		for index,file in enumerate(file_list):
			if not os.path.isfile(file):
				print('Pic',file,'not exists!')
			pic_num += 1
			if pic_num <= 6 : 
				file_name = os.path.splitext(os.path.basename(file))[0]
				sql = "INSERT INTO tb_pic{suffix} VALUES (null,'图{4} {0}','','{1}','{2}','{3}')".format(pic_name,file,file_name,str(index+1),str(pic_all_flag),suffix=suffix)
				#print(sql,'\n')
				cursor.execute(sql)
				pic_id = cursor.lastrowid
				#sql = "SELECT * FROM tb_pic WHERE pic_name='图{0} {1}'".format(str(pic_all_flag),pic_name)
				pic_id_list.append(pic_id)
		return(pic_id_list)
	def get_circle_id(self,pic_describe,circle_flag,cursor):
		sql = "INSERT INTO tb_pic{suffix} VALUES(null,'1','{0}','./html/img/circle{1}.png','','{1}')".format(pic_describe,circle_flag,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)
		circle_id = cursor.lastrowid
		#sql = "SELECT * FROM tb_pic WHERE pic_describe='{0}'".format(pic_describe)
		return(circle_id)
	def update_describe(self,pic_id_list,pic_describe,cursor):
		pic_id = pic_id_list[0]
		sql = "UPDATE tb_pic{suffix} SET pic_describe='{0}' WHERE pic_id='{1}'".format(pic_describe,pic_id,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)
	def insert_sql(self,pic_id_str,pic_in,height,cursor):
		type = 'Normal'
		if len(pic_id_str.split(','))>1:
			type='Many_pic'

		sql = "INSERT INTO tb_pic_type{suffix} VALUES(null,'{0}','{1}','{2}','{3}','1')".format(pic_id_str,pic_in,type,height,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)
		pic_type_id = cursor.lastrowid
		#sql = "SELECT * FROM tb_pic_type WHERE pic_in='{0}'".format(pic_in)
		return(pic_type_id)
	def update_pic_type(self,pic_id_str,pic_type,cursor):
		sql = "UPDATE tb_pic_type{suffix} SET pic_type='{0}' WHERE pic_ids='{1}'".format(pic_type,pic_id_str,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)

class Table:
	def __init__(self):
		self.names = ''
	def insert_table_content(self,path,row,col,cursor):
		if not glob.glob(path):
			print('Table',path,'not exists!')
			#os.system("rm '{0}'/lock".format(tmp_dir))
			sys.exit(1)
		file = sorted(glob.glob(path))[0]
		filein = open(file)
		table_content_id = []

		###提取col对应的列数
		lines=[]
		row_tmp,col_tmp = 0,0
		row_default,col_default= 50,10
		if not col : col = 0 #col不存在，赋值为0
		else: col = int(col) 
		if not row : row = 0 #row不存在，赋值为0
		else: row = int(row)
		for line in filein:
			row_tmp += 1 #实际行数
			arr = line.rstrip("\n").split("\t")
			col_tmp = len(arr) #实际的每行列数

			# 每一个单元格字符串长度大于50则取前面50个字符	
			for k in range(col_tmp):
				arr[k] = arr[k].replace("'","") #引起mysql导入错误 
				if len(arr[k]) > 50: arr[k] = arr[k][0:50] + "..."

			#如果col没有设定，但实际列数<=col_default,则输出所有列；如果col没有设定，但实际列数>col_default,则输出前col_default列；如果col设定，则输出col对应的列数；
			if col == 0 and col_tmp <= col_default: 
				line = line.rstrip("\n")
				col = col_tmp
			elif col == 0 and col_tmp > col_default:
				line = "\t".join(arr[0:col_default])
				col = col_default
			elif col > 0 and col_tmp<col :  #涂成芳:如果给定的列数大于表格实际列数，按照实际列数输出
				#print("Error:设置的列数大于表格中的列数")
				line = "\t".join(arr[0:col_tmp])
			elif col > 0 and col_tmp>=col :
				line = "\t".join(arr[0:col])

			#如果row没有设定，但实际行数<=row_default,则输出所有行；如果row没有设定，但实际行数>row_default,则输出前row_default行；如果row设定，则输出row对应的行数；
			if row == 0 and row_tmp > row_default: 
				row = row_default
				break
			elif row > 0 and row_tmp > row : 
				break
			lines.append(line)

		###提取row和col对应的数据	
		if not row : row = row_tmp
		if row and row>row_tmp: row=row_tmp  #涂成芳:如果row设定，但是大于实际行数，则输出实际行数
		max = 0
		if row > col : max = row
		else: max = col

		for i in range(max+1): #第一行为表头
			if i > row - 1:# row < col
				a=[]
				[ a.append("") for j in range(col) ]
				lines.append("\t".join(a))
			array = lines[i].rstrip('\n').split('\t')  
			sql = "INSERT INTO tb_table_detail{suffix} VALUES(null,'{0}','')".format('[*]'.join(array[0:col]),suffix=suffix)
			#print(sql,'\n')
			cursor.execute(sql)
			table_detail_id = cursor.lastrowid
			#sql = "SELECT * FROM tb_table_detail WHERE table_field='{0}'".format('[*]'.join(array[0:col]))
			table_content_id.append(table_detail_id)
		return(table_content_id)
	def update_content(self,table_content_id,line,cursor):
		t_content_id = table_content_id[0]
		sql = "UPDATE tb_table_detail{suffix} SET field_summary='{0}' where table_id='{1}'".format(line.rstrip('\n'),t_content_id,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)
		del table_content_id[0]
		return(table_content_id)
	def insert_table(self,table_in,table_id,table_title,table_all_flag,table_width,path,cursor):
		file = sorted(glob.glob(path))[0]
		table_id  = [str(i) for i in table_id ]
		table_id_str = ','.join(table_id)
		sql = "INSERT INTO tb_table{suffix} VALUES(null,'{0}','{1}','表{2} {3}','{4}','{5}')".format(table_in,table_id_str,str(table_all_flag),table_title,table_width,file,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)
		t_id = cursor.lastrowid
		#sql = "SELECT * FROM tb_table WHERE table_ids='{0}'".format(table_id_str)
		return(t_id)

class Download:
	def __init__(self):
		self.names = ''
	def get_file_download_path_id(self,path,cursor):
		if not glob.glob(path):
			print('Download',path,'not exists!')
		sort = 1
		file_download_path_id = []
		download_num = 0
		for file in sorted(glob.glob(path)):
			download_num += 1
			if download_num <= 25:
				sql = "INSERT INTO tb_file_download_path{suffix} VALUES(null,'{0}','{1}')".format(file,str(sort),suffix=suffix)
				#print(sql,'\n')
				cursor.execute(sql)
				download_path_id = cursor.lastrowid
				#sql = "SELECT * FROM tb_file_download_path WHERE file_down_path='{0}'".format(file)
				file_download_path_id.append(download_path_id)
				sort += 1
		return(file_download_path_id)
	def insert_file_download(self,file_download_path_id,download_in,cursor):
		sort = '1'
		file_download_path_id = [ str(i) for i in file_download_path_id]
		file_download_str = ','.join(file_download_path_id)
		sql = "INSERT INTO tb_file_download{suffix} VALUES(null,'{0}','{1}','{2}')".format(download_in,file_download_str,sort,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)
		f_download = cursor.lastrowid
		#sql = "SELECT * FROM tb_file_download WHERE file_download_ids='{0}'".format(file_download_str)
		return(f_download)

class Filter:
	def __init__(self):
		self.names = ''
	def get_filter_content_id(self,con_in,con,cursor):
		sql = "INSERT INTO tb_date_count{suffix} VALUES(null,'{0}','{1}')".format(con_in,con,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)
		filter_id = cursor.lastrowid
		#sql = "SELECT * FROM tb_date_count WHERE date_content='{0}' and date_content_detail='{1}'".format(con_in,con)
		return(filter_id)
	def insert_filter(self,filter_in,cursor):
		sql = "INSERT INTO tb_date_filter{suffix} VALUES(null,'{0}','')".format(filter_in,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)
		filter_main_id = cursor.lastrowid
		#sql = "SELECT * FROM tb_date_filter WHERE date_in='{0}'".format(filter_in)
		return(filter_main_id)
	def update_filter(self,filter_id,filter_in,filter_main_id,cursor):
		filter_id = [ str(i) for i in filter_id]
		filter_id_str = ','.join(filter_id)
		sql = "UPDATE tb_date_filter{suffix} SET date_ids='{0}' WHERE date_in='{1}' and date_id='{2}'".format(filter_id_str,filter_in,filter_main_id,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)

class Result_Dir:
	''' create structure of result directory'''
	def __init__(self):
		self.names = ''
	def sql_insert(self,job_id,line,cursor):
		if line[3] == 'null': line[3] = 0
		sql="INSERT INTO tb_catalog{suffix} VALUES ({0},{1},{2},{3},'{4}','{5}');".format(line[0],line[1],line[2],line[3],line[4],line[5],suffix=suffix)
		try:
			#print(sql)
			cursor.execute(sql) 
		except mysql.connector.errors.IntegrityError:
			print(line,'已经在tb_catalog表格中')
	def get_file(self,job_id,upload_dir,cursor):
		item = {}
		item[job_id] = {}
		item_id = 0
		catalog_id = 0
		sub_catalog_id = 0
		id_name = ""
		file_name = ""
		dirs1 = glob.glob(upload_dir + "/[0-9]*")
		dirs1 = sorted(dirs1,key=lambda dir : int(dir.split("upload")[1].split("/")[1].split("_")[0]),reverse=False)
		dirs2 = glob.glob(upload_dir + "/[A-Za-z]*")
		dirs2 = sorted(dirs2)
		dirs = dirs1 + dirs2

		for dir in dirs: ###一级文件
			item_id += 1
			catalog_id = item_id
			sub_dirs = glob.glob(dir+"/*")
			dir_name = '"' + os.path.basename(dir) + '"'
			item[job_id][item_id] = ["null",job_id,str(item_id),"0",dir_name,"null"]

			for sub_dir in sorted(sub_dirs):###二级目录或文件
				item_id +=1 
				id_name = '"' + os.path.basename(sub_dir) + '"'
				if os.path.isfile(sub_dir):
					second_relative_file = '"./upload' + sub_dir.split("upload")[1] + '"'
					item[job_id][item_id] = ["null",job_id,str(item_id),int(catalog_id),id_name,second_relative_file]
				else:
					files = glob.glob(sub_dir + "/*")
					item[job_id][item_id] = ["null",job_id,str(item_id),int(catalog_id),id_name,"null"]
					sub_catalog_id = item_id

					for file in sorted(files):###三级文件
						item_id +=1;
						id_name = '"' + os.path.basename(file) + '"'
						relative_file = '"./upload' + file.split("upload")[1] + '"'
						item[job_id][item_id] = ["null",job_id,str(item_id),str(sub_catalog_id),id_name,relative_file]

		# insert into mysql 
		result = Result_Dir()
		for pro_id in item.keys():
			for it_id in item[pro_id].keys():
				#print(item[pro_id][it_id])
				result.sql_insert(job_id,item[pro_id][it_id],cursor)
	def delete_sql(self,job_id,cursor):
		sql = "DELETE FROM tb_catalog{suffix} where type_id='{0}'".format(job_id,suffix=suffix)
		#print(sql,'\n')
		cursor.execute(sql)

def Project_name(report_conf,cursor):
	conf = {}
	project_id = 'tmp_000'
	with open (report_conf,"r") as report_c:
		for line in report_c:
			line = line.rstrip('\n')
			if len(line) == 0:continue
			elif line.startswith("#"):continue
			elif line.startswith('PROJECT_NAME:'):
				project_name = line.rstrip().split(":")[1]
			elif line.startswith('PROJECT_ID:'):
				project_id = line.rstrip().split(":")[1]
			elif line.startswith('REPORT_DIR:'):
				report_dir = line.rstrip().split(":")[1]
			else:
				term = line.split(":")
				conf[term[0]] = term[1]

	# delete 项目名和项目类型相同的条目
	sql = "DELETE FROM tb_object_type{suffix} where cn_name='{0}'".format(project_name,suffix=suffix)
	print(sql,'\n')
	cursor.execute(sql)
	sql ="INSERT INTO tb_object_type{suffix} VALUES (null,'{0}','','{1}');".format(project_name,project_id,suffix=suffix)
	try:
		print(sql,'\n')
		cursor.execute(sql)
		job_id = cursor.lastrowid
	except mysql.connector.errors.IntegrityError:
		print('项目名称有重复，请重新检查，或者更换结题报告名字!')

	#sql ="SELECT * FROM tb_object_type WHERE cn_name = '{0}' ".format(project_name)
	return(job_id,project_name,report_dir,conf)

def Template(template_file,job_id,conf,cursor):
	main_menu_dic = {}
	sub_menu_content_dic = {}
	third_menu_content_dic = {}
	menu_flag = ''
	m_menu_flag = 0
	s_menu_flag = 0
	t_menu_flag = 0
	pic_all_flag = 1
	table_all_flag = 1
	fastqpre_flag = 0
	circlepre_flag = 0
	pre_flag = 0
	table_index = 0
	filterpre_flag = 0
	filter_in = ""
	filter_ids = []
	filter_main_id = 0 
	for index,line in enumerate(template_file):
		if line.startswith('MainMenu'):
			main_menu_name = line.rstrip().split(':')[1]
			print("{1}\tMainMenu:{0}".format(main_menu_name,time.ctime()))
			m_menu = Main_Menu()
			m_menu_id = m_menu.insert_sql(main_menu_name,job_id,m_menu_flag,cursor)
			main_menu_dic[main_menu_name] = m_menu_id
			m_menu_flag += 1
			s_menu_flag = 1 
			t_menu_flag = 1
		elif line.startswith('SubMenu'):
			sub_menu_name = line.rstrip().split(':')[1]
			#print("{1}\tSubMenu:{0}".format(sub_menu_name,time.ctime()))
			s_menu = Sub_Menu()
			s_menu_id = s_menu.insert_sql(sub_menu_name,m_menu_id,m_menu_flag,s_menu_flag,cursor)
			s_menu_flag += 1
			t_menu_flag = 1
			menu_flag = 'sub'
		elif line.startswith('ThirdMenu'):
			third_menu_name = line.rstrip().split(':')[1]
			t_menu = Third_Menu()
			t_menu_id = t_menu.insert_sql(third_menu_name,s_menu_id,m_menu_flag,s_menu_flag-1,t_menu_flag,cursor)
			t_menu_flag += 1
			menu_flag = 'third'
		elif line.startswith('P:#'):
			content = line.strip('\n').split('#')[-1]

			reStr=""
			for j in range(content.count('$')):	 #对于一行中有多处传参进行循环替换
				for i in conf.keys():
					p='\$\(' + i + '\)'
					if re.search(p,content,re.M|re.I):
						reStr = re.sub(p,conf[i],content,re.M|re.I)
						break
				if reStr: content = reStr
			con = Content()
			if content.startswith("数据处理步骤如下"):
				filter=Filter()
				filter_in = content
				filter_main_id = filter.insert_filter(filter_in,cursor)
				continue

			###给段落添加样式
			if line.startswith('P:#S'): #段落加粗			
				content = "<strong>" + content + "</strong>"
			con_id = con.insert_sql(content,cursor)

			if menu_flag == 'sub':
				if s_menu_id not in sub_menu_content_dic:
					sub_menu_content_dic[s_menu_id] = []
				sub_menu_content_dic[s_menu_id].append('c'+str(con_id))
			if menu_flag == 'third':
				if t_menu_id not in third_menu_content_dic:
					third_menu_content_dic[t_menu_id] = []
				third_menu_content_dic[t_menu_id].append('c'+str(con_id))
		elif line.startswith('Image'):
			height = "400px"
			path,*info,pic_name = line.rstrip('\n').split(':')[1].split(',')
			if info[0] : height = str(info[0])+"px"

			con.delete_sql(con_id,cursor)
			if len(glob.glob(path))==0:
				print(path,'not exist!')
			file = Pic()
			pic_id_list = file.get_pic_id(pic_all_flag,path,pic_name,cursor)
			pic_id_str = ','.join([str(i) for i in pic_id_list])
			pic_type_id = file.insert_sql(pic_id_str,content,height,cursor)
			if menu_flag == 'sub':
				if s_menu_id not in sub_menu_content_dic:
					sub_menu_content_dic[s_menu_id] = []
				sub_menu_content_dic[s_menu_id].append('p'+str(pic_type_id))
			if menu_flag == 'third':
				if t_menu_id not in third_menu_content_dic:
					third_menu_content_dic[t_menu_id] = []
				third_menu_content_dic[t_menu_id].append('p'+str(pic_type_id))
			pic_all_flag += 1
		elif line.startswith('Table'):
			con.delete_sql(con_id,cursor)
			print(line)
			path,*info,table_title = line.rstrip('\n').split(':')[1].split(',')

			# 设置table宽度
			table_width=""
			if info[2]:
				table_width = str(info[2])+"px"

			table = Table()
			table_content_id = table.insert_table_content(path,info[0],info[1],cursor)
			table_type_id = table.insert_table(content,table_content_id,table_title,table_all_flag,table_width,path,cursor)
			table_all_flag += 1
			table_index = index
			if menu_flag == 'sub':
				if s_menu_id not in sub_menu_content_dic:
					sub_menu_content_dic[s_menu_id] = []
				sub_menu_content_dic[s_menu_id].append('t'+str(table_type_id))
			if menu_flag == 'third':
				if t_menu_id not in third_menu_content_dic:
					third_menu_content_dic[t_menu_id] = []
				third_menu_content_dic[t_menu_id].append('t'+str(table_type_id))
		elif line.startswith('PRE:') and index-table_index==1:
			pre_flag = 1
			table_content_id = table.update_content(table_content_id,"",cursor)
		elif pre_flag == 1 and not line.startswith('PRE\n'):
			if len(table_content_id) == 0:continue
			table_content_id = table.update_content(table_content_id,line,cursor)

		elif line.startswith('PRE\n'):
			pre_flag = 0 

		elif line.startswith('Excel'):
			path,*info,title = line.rstrip().split(':')[1].split(',')
			download = Download()
			file_download_path_id = download.get_file_download_path_id(path,cursor) 
			f_download = download.insert_file_download(file_download_path_id,title,cursor)
			if menu_flag == 'sub':
				if s_menu_id not in sub_menu_content_dic:
					sub_menu_content_dic[s_menu_id] = []
				sub_menu_content_dic[s_menu_id].append('d'+str(f_download))
			if menu_flag == 'third':
				if t_menu_id not in third_menu_content_dic:
					third_menu_content_dic[t_menu_id] = []
				third_menu_content_dic[t_menu_id].append('d'+str(f_download))
		elif line.startswith('FastqPRE:'):
			fastqpre = ''
			fastqpre_flag = 1
		elif fastqpre_flag >=1 and not line.startswith('FastqPRE\n'):
			line = '）'.join(line.rstrip('\n').split('）')[1:])
			fastqpre += "（{0}）[{1}],".format(str(fastqpre_flag),line)
			fastqpre_flag += 1
		elif line.startswith('FastqPRE\n'):
			fastqpre_flag = 0
			con.delete_sql(con_id,cursor)
			file.update_describe(pic_id_list,fastqpre,cursor)
			file.update_pic_type(pic_id_str,'FASTQ',cursor)
		elif line.startswith('CirclePRE:\n'):
			circlepre_flag = 1
			circle_pic_ids = []
		elif circlepre_flag == 1 and not line.startswith('CirclePRE\n'):
			file = Pic()
			circlepre_sort_flag = line.split('）')[0].split('（')[1]
			circle_pic_id = file.get_circle_id(line.rstrip('\n'),circlepre_sort_flag,cursor)
			circle_pic_ids.append(str(circle_pic_id))
		elif line.startswith('CirclePRE\n'):
			con.delete_sql(con_id,cursor)
			circle_pic_ids = ','.join(circle_pic_ids)
			circlepre_flag = 0
			circle_id = file.insert_sql(circle_pic_ids,content,"",cursor)
			file.update_pic_type(circle_pic_ids,'Circle3',cursor)
			if menu_flag == 'sub':
				if s_menu_id not in sub_menu_content_dic:
					sub_menu_content_dic[s_menu_id] = []
				sub_menu_content_dic[s_menu_id].append('p'+str(circle_id))
			if menu_flag == 'third':
				if t_menu_id not in third_menu_content_dic:
					third_menu_content_dic[t_menu_id] = []
				third_menu_content_dic[t_menu_id].append('p'+str(circle_id))
		elif line.startswith('FilterPRE:\n'):
			filterpre_flag = 1
			if menu_flag == 'sub':
				if s_menu_id not in sub_menu_content_dic:
					sub_menu_content_dic[s_menu_id] = []
				sub_menu_content_dic[s_menu_id].append('f'+str(filter_main_id))
			if menu_flag == 'third':
				if t_menu_id not in third_menu_content_dic:
					third_menu_content_dic[t_menu_id] = []
				third_menu_content_dic[t_menu_id].append('f'+str(filter_main_id))
		elif filterpre_flag >=1 and not line.startswith('FilterPRE\n'):
			all = line.rstrip('\n').split('）')[1].split('（')
			###判读是否有content_detail
			if len(all) == 2:
				content,content_detail = all[0],all[1]
			elif len(all) == 1:
				content = all[0]
				content_detail = ""
			###content_detail存在，则在两边加括号
			if content_detail :
				content_detail = "（" + content_detail + "）"

			filter_id = filter.get_filter_content_id(content,content_detail,cursor)
			filter_ids.append(filter_id)
			filterpre_flag += 1
		elif line.startswith('FilterPRE\n'):
			filterpre_flag = 0
			filter.update_filter(filter_ids,filter_in,filter_main_id,cursor)

		elif line.startswith('ShowDir:'):
			sql = "SELECT * FROM tb_catalog{suffix} WHERE type_id='{0}' AND father_id=0".format(job_id,suffix=suffix)
			#sql = "SELECT * FROM tb_catalog{suffix} WHERE type_id='{0}' AND father_id is null".format(job_id,suffix=suffix)
			#print(sql,'\n')
			cursor.execute(sql)
			result = cursor.fetchall()
			for line in result:
				if s_menu_id not in sub_menu_content_dic:
					sub_menu_content_dic[s_menu_id] = []
				sub_menu_content_dic[s_menu_id].append('r'+str(line[0]))

		else:continue
	return(sub_menu_content_dic,third_menu_content_dic)
	#s_menu.updata_content(sub_menu_content_dic,cursor) 
	#t_menu.update_content(third_menu_content_dic,cursor)

def InsertUser(user,job_id,cursor):
	## tb_user has only one term where loginname = admin
	sql = "SELECT * FROM tb_user WHERE loginname='{0}'".format(user)
	#print(sql,'\n')
	cursor.execute(sql)
	result = cursor.fetchall()
	user_id = result[0][0]
	sql = "INSERT INTO tb_user_object{suffix} VALUES(null,'{0}','{1}')".format(user_id,job_id,suffix=suffix)
	#print(sql,'\n')
	cursor.execute(sql)

def Delete_tables(job_id,cursor):
	sql= "DELETE FROM tb_main_menu{suffix} where type_id='{0}'".format(job_id,suffix=suffix)
	print(sql,'\n')
	cursor.execute(sql)

def ssh_cmd(ip, user, passwd, cmd):
	ssh = pexpect.spawn('ssh %s@%s "%s"' % (user, ip, cmd),timeout=None)
	try:
		i = ssh.expect(['password: ', 'continue connecting (yes/no)?'],timeout=None)
		if i == 0 :
			ssh.sendline(passwd)
		elif i == 1:
			ssh.sendline('yes\n')
			ssh.expect('password: ',timeout=None)
			ssh.sendline(passwd)
		r=ssh.read()
		#print(str(r))
		if re.search("mkdir",cmd):
			print ("The directory has been created successfully!\n")
		else :
			feedback = r.decode('utf-8').split('\r\n')
			count = 0
			for info in feedback:
				if info.startswith('empty file:') or info.startswith('error path:'):
					print(info+'\n')
					sys.exit(1)
				elif info.startswith('Exception') or info.startswith('Error'):
					print (info+'\n')
					sys.exit(1)
				elif info.startswith('table') or info.startswith('picIds'):
					print ('\n{0}\n'.format(info))
					count +=1
				elif info.startswith('java.io.IOException'):
					print ('\n{0}\n'.format(info))
					count +=1
				else :
					continue
			if count==0 : print ("The Report has been generated successfully!\n")
			else : print ("Sorry, the Report has not been generated!\n")
	except pexpect.EOF:
		print ("EOF, Failed to generate report!\n")
		ssh.close()
	except pexpect.TIMEOUT:
		print ("TIMEOUT,Failed to generate report!\n")
		ssh.close()

def scp_upload(cmd, passwd, project_name):
	scp = pexpect.spawn(cmd,timeout=None)
	print ("-- {0} --".format(cmd))
	try:
		i = scp.expect(['password: ', 'continue connecting (yes/no)?'],timeout=None)
		if i == 0 :
			scp.sendline(passwd)
		elif i == 1:
			scp.sendline('yes\n')
			scp.expect('password: ',timeout=None)
			scp.sendline(passwd)
		r = scp.read()
		
		if re.search('Permission denied',str(r)):
			print("Permission denied for scp, check your REPORT_DIR in config file")
			scp.close()
		else:
			print ("The upload directory has been copyed successfully!\n")
	except pexpect.EOF:
		print ("EOF, Failed to copy upload directory!\n")
		scp.close()
	except pexpect.TIMEOUT:
		print ("TIMEOUT,Failed to copy upload directory!\n")
		scp.close()

def Generate_Report_cloud_server(job_id,report_dir,project_name,type):
	report_dir = report_dir.replace("upload","")
	hosts="192.168.1.3"
	cloud_report_dir = "/usr/local/file/PDFS" + report_dir
	cmd_rm_html = "rm -rf {0}/html".format(cloud_report_dir)
	cmd_html = "/usr/java/jdk1.6.0_45/bin/java -jar /usr/local/apache-tomcat-7.0.56/webapps/JTreport.jar {year} h {job_id} {report_dir}".format(year=year,job_id=str(job_id),report_dir=report_dir)
	cmd_pdf = "/usr/java/jdk1.6.0_45/bin/java -jar /usr/local/apache-tomcat-7.0.56/webapps/JTreport.jar {year} p {job_id} {report_dir}".format(year=year,job_id=str(job_id),report_dir=report_dir)
	cmd_ln_html = "cp -r /usr/local/public_html/html/html {0}".format(cloud_report_dir)
	cmd = '{0} && {1} && {2} && {3}'.format(cmd_rm_html, cmd_pdf, cmd_html, cmd_ln_html)
	##Generate PDF && HTML
	user = getpass.getuser()
	ip = hosts
	#os.system(cmd)
	rm_condition = os.system(cmd_rm_html)
	if rm_condition != 0:
		print("删除报告文件夹/html目录失败，请检查report.conf中给出的路径是否正确！")
		exit()
	pdf_condition = os.system(cmd_pdf)
	if rm_condition != 0:
		print("生成PDF失败，请检查输入文件！")
		exit()
	html_condition = os.system(cmd_html)
	if rm_condition != 0:
		print("生成HTML失败，请检查输入文件！")
		exit()
	ln_html_condition = os.system(cmd_ln_html)
	if rm_condition != 0:
		print("拷贝公共html文件夹失败，请检查report.conf中给出的路径是否正确！")
		exit()
	print(user+":少侠！您要的结题报告已生成，请仔细审核后交付！")



def Generate_Report(job_id,report_dir,project_name,type):
	cmd_mkdir = "rm -rf /usr/local/file/*S/{0} && mkdir -p /usr/local/file/HTMLS/{0}/ && mkdir -p /usr/local/file/PDFS/{0}".format(project_name)
	cmd_html = "/usr/java/jdk1.6.0_45/bin/java -jar /usr/local/apache-tomcat-7.0.56/webapps/JTreport.jar {year} h {job_id}".format(year=year,job_id=str(job_id)) 
	cmd_pdf = "/usr/java/jdk1.6.0_45/bin/java -jar /usr/local/apache-tomcat-7.0.56/webapps/JTreport.jar {year} p {job_id}".format(year=year,job_id=str(job_id)) 
	cmd_ln_upload = 'ln -s /usr/local/file/PDFS/{0}/upload /usr/local/file/HTMLS/{0}/upload'.format(project_name)
	cmd_ln_html = "ln -s /usr/local/public_html/html /usr/local/file/HTMLS/{0}".format(project_name) 
	cmd = cmd_pdf + " && "+ cmd_html + " && " + cmd_ln_upload + " && " + cmd_ln_html
	#cmd = '{0} && {1} && {2}'.format(cmd_pdf, cmd_html, cmd_ln_html)
	#hosts = "192.168.60.185:root:Ann0road" 
	#hosts = "192.168.13.12:root:123456a" 
	if type == "local":
		hosts = "192.168.60.189:root:123456a"
	elif type == "cloud":
		hosts = "192.168.1.3:root:123456a"
	report_dir = os.path.dirname(report_dir)
	for host in hosts.split("\n"):
		if host:
			ip, user, passwd = host.split(":")
			##mkdir PDFS && HTMLS
			print ("-- %s run: %s --" % (ip, cmd_mkdir))
			ssh_cmd(ip, user, passwd, cmd_mkdir)
			## upload dir to server
			cmd_upload = 'scp -r {0}/upload {1}@{2}:/usr/local/file/PDFS/{3}'.format(report_dir,user,ip,project_name)
			scp_upload(cmd_upload,passwd,project_name)
			print('{0}\tScp upload Finished\n '.format(time.ctime()))
			
			##Generate PDF && HTML
			print ("-- %s run: %s --" % (ip, cmd))
			ssh_cmd(ip, user, passwd, cmd)
			print('{0}\tGenerate reports Finished\n'.format(time.ctime()))
			
			### download report.html from server to local
			cmd_download = 'scp {0}@{1}:/usr/local/file/HTMLS/{2}/{2}.html {3}'.format(user,ip,project_name,report_dir)
			scp_upload(cmd_download,passwd,project_name)
			### download report.pdf from server to local
			cmd_download = 'scp {0}@{1}:/usr/local/file/PDFS/{2}/{2}.pdf {3}'.format(user,ip,project_name,report_dir)
			scp_upload(cmd_download,passwd,project_name)
			print('{0}\tDownload reports Finished\n'.format(time.ctime()))
			
			cmd = 'cp -r {0}/html {1}'.format(bindir,report_dir)
			if os.path.isdir('{0}/html'.format(bindir)):
				os.system(cmd)
			else :
				print('No html_dir for {0}.html !'.format(project_name))

def main():
	parser=argparse.ArgumentParser(description=__doc__,
			formatter_class=argparse.RawDescriptionHelpFormatter,
			epilog='author:\t{0}\nmail:\t{1}'.format(__author__,__mail__))
	parser.add_argument('-i','--input',help='input template file',dest='input',type=open,required=True)
	parser.add_argument('-c','--config',help='input report config file',required=True)
	parser.add_argument('-u','--user',help='user name',required=True)
	parser.add_argument('-t','--type',help='server type',required=False,default="cloud")
	args=parser.parse_args()

	indir = os.path.dirname(os.path.abspath(args.input.name))
	os.chdir(indir)
	if args.type == "cloud":
		dbconfig = {
			'host':'192.168.169.46',
			'port':'3306',
			'user':'kreport',
			'passwd':'kreport@20180807',
			'db':'knotreports_rds',
			'pool_name':'knot_pool',
			'pool_size':30,
			'connect_timeout': 100,
		}
		tmp_conf = args.config+".tmp"
		with open(args.config,"r")as ic, open(tmp_conf,"w")as oc:
			for line in ic:
				if line.startswith("REPORT_DIR"):
					#newline = "REPORT_DIR" + ":" + "/usr/local/file/FDFS" + line.split(":")[1]
					newline = line
					oc.write(newline+"\n")
				else:
					oc.write(line+"\n")
	elif args.type == "local":
		dbconfig = {
			'host':'192.168.60.220',
			'port':'3306',
			'user':'kreport',
			'passwd':'kreport@20180807',
			'db':'knotreports_new',
			'pool_name':'knot_pool',
			'pool_size':30,
			'connect_timeout': 100,
		}
		tmp_conf = args.config
	else:
		print("报告服务器类型（-t）输入有误，请检查参数！！！")
		exit()
	# pool_size: 0~32
	conn = mysql.connector.connect(**dbconfig)
	#conn = mysql.connector.connect(host='192.168.60.97', user='root',passwd='annoroad',db='knotreports')
	cursor = conn.cursor()

	job_id,project_name,report_dir,conf = Project_name(tmp_conf,cursor)
	
	print("My ID is {0}".format(job_id))
	
	Delete_tables(job_id,cursor)
	InsertUser(args.user,job_id,cursor)

	print('{0}\tIndex files'.format(time.ctime()))
	result_dir = Result_Dir()
	result_dir.delete_sql(job_id,cursor)
	result_dir.get_file(job_id,report_dir,cursor)

	sub_menu_content_dic,third_menu_content_dic=Template(args.input,job_id,conf,cursor)

	s_menu = Sub_Menu()
	t_menu = Third_Menu()
	s_menu.updata_content(sub_menu_content_dic,cursor)
	t_menu.update_content(third_menu_content_dic,cursor)

	###关闭连接 
	cursor.execute('commit')
	conn.close()
	print('{0}\tMysql Finished\n'.format(time.ctime()))

	###generate report
	if args.type == "local":
		Generate_Report(job_id,report_dir,project_name,args.type)
	elif args.type == "cloud":
		Generate_Report_cloud_server(job_id,report_dir,project_name,args.type)

if __name__ == '__main__':
	print('Start : ',time.ctime())
	try:
		main()
	except KeyboardInterrupt:
		print ("You Killed the progress!")
	except (Exception) as e :
		print (e)
	print('End : ',time.ctime())
