### 模块： mk_DE

*模块功能：
*模块版本：v1.0.0
*邮箱： yangzhang@genome.cn

### 使用示例及参数说明：

Usage: DE_wilcox和DE_metastat为两组比较；DE_ANOVA为多组比较
	 make -f mk_DE qiimeFile= groupFile= cmpFile= outdir= config= DE_wilcox 
	 make -f mk_DE qiimeFile= groupFile= cmpFile= outdir= config= DE_ANOVA 
	 make -f mk_DE qiimeFile= groupFile= cmpFile= outdir= diff_on=yes cmp1=T cmp2=M LDA=2 config= DE_LEfSe
参数说明：
	 config: [文件|可选]  模块配置文件，和软件相关参数，默认为.//config/config.txt 
	 qiimeFile: [文件|必需]  物种丰度文件
	 groupFile: [文件|必需]  样本和分组对应文件，Sample tab Group
	 cmpFile: [文件|必需]  比较组合文件，如果是两两比较，则用tab分隔两列即可；如果是三组及以上，需要给组名 tab A B C D，用空格分隔多组
	 outdir: [路径|必需]  分析结果输出路径 
	 diff_on: [字符|必需]  是否进行LEfSe差异分析 
	 cmp1/cmp2: [字符|必需]  比较组，不区分实验组和对照组。目前只支持两个组，如果要做多组的结果，那么需要自行调整输入的文件，详情百度 
	 LDA: [字符|必需]  筛选结果的LDA阈值

### 输入文件示例
见test/input/
.
├── cmp.list              Sample和Group对应关系的groupFile文件
├── cmpM.txt              多组比较的cmpFile文件
├── cmp.txt               两两比较的cmpFile文件
└── merge.qiime.xls       物种丰度文件

### 运行环境及软件：
	北京238,R(doBy),python3(json,configparser,glob,datetime,argparse)

### 资源消耗及运行时长
	DE：24个样本
	申请CPU：1
	申请内存：3G
	实际内存：2.944GB
	运行时长：1 h

### 输出文件示例
.
├── ANOVA_Group1.xls
├── ANOVA_Group2.xls
├── metastat.xls
├── T_M
│   ├── biomarkers.zip
│   ├── T_M.diff.group.xls
│   ├── T_M.lefse.in
│   ├── T_M.lefse.lda2.pdf
│   ├── T_M.lefse.lda2.png
│   ├── T_M.lefse.lda2.res
│   ├── T_M.lefse.lda2.res.txt -> T_M.lefse.lda2.res
│   └── T_M.lefse.lda2.significant.res
├── wilcox_B_M.xls
├── wilcox_DT_B.xls
├── wilcox_DT_M.xls
├── wilcox_DT_T.xls
├── wilcox_T_B.xls
└── wilcox_T_M.xls

重要结果说明见script/readme.doc
### 注意事项

