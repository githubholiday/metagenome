### 模块： mk_beta

*模块功能：
*模块版本：v1.0.0
*邮箱： yangzhang@genome.cn

### 使用示例及参数说明：

Usage:
	 Beta_qiime: 使用qiime计算beta多样性
	 NMDS:做NMDS分析
	 PCA:PCA分析
	 PCoA:PCoA分析

 Usage-Beta_qiime:
	 make -f config= qza_file= method= outdir= Beta_qiime
	参数说明:
	 config: [文件|可选]模块配置文件，和软件相关参数，默认为/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/RD_Group/yangzhang/module/r-16s/beta//config/config.txt 
	 qza_file: [文件|必需]所有样本物种丰度qza文件
	 method: [字符|必需]beta距离计算方法,可选[braycurtis,jaccard]
	 outdir: [目录|必需]输出目录，输出目录下输出 beta_qiime_.xls,beta_qiime_.heatmap.pdf,beta_qiime_.heatmap.png

Usage-NMDS/PCA/PCoA:
	 make -f config= infile= cmp= outdir= prefix= method= NMDS
	参数说明:
	 config: [文件|可选]模块配置文件，和软件相关参数，默认为/annoroad/data1/bioinfo/PROJECT/RD/Cooperation/RD_Group/yangzhang/module/r-16s/beta//config/config.txt 
	 infile: [文件|必需]所有样本物种丰度合并文件
	 cmp: [字符|必需]样本和组对应关系文件,第一列为样本(Sample),第二列为组名(Group),表头字母大小写也要一致
	 outdir: [目录|必需]输出目录,输出目录下输出图、坐标文件、特征值文件
	 prefix: [文件|必需]输出文件前缀，prefix.pdf,prefix.png
	 method: [文件|必需]beta距离计算方法,可选[bray,jaccard]

### 输入文件示例

test/input/
├── cmp.list
├── merge.species.xls

### 运行环境及软件：
	北京238( R python qiime2)

### 资源消耗及运行时长
	1cpu 1G 5min

### 输出文件示例
.
├── NMDS
│   ├── Group_NMDS_bray.coordinate.xls
│   ├── Group_NMDS_bray.pdf
│   └── Group_NMDS_bray.png
├── PCA
│   ├── Group_individual_dim1_dim2_ellipses.pdf
│   ├── Group_individual_dim1_dim2_ellipses.png
│   ├── Group_PCA.3d.pdf
│   ├── Group_PCA.3d.png
│   ├── Group_PCA_coordinate.xls
│   ├── Group_PCA_summary.xls
│   ├── Group_PCA_variable_dim1_dim2_cos2.pdf
│   ├── Group_PCA_variable_dim1_dim2_cos2.png
│   ├── Group_PCA_variable_dim1_dim2.pdf
│   ├── Group_PCA_variable_dim1_dim2.png
│   ├── Group_Variable_gene_contrib.xls
│   ├── Group_Variable_gene_cos2.xls
│   ├── Rplots.pdf
│   └── Rplots.png
└── PCoA
    ├── Group_PCoA_bray.coordinate.xls
    ├── Group_PCoA_bray.pdf
    ├── Group_PCoA_bray.png
    └── Group_PCoA_bray.summary.xls

主要结果文件说明：
见script/readme.doc
### 注意事项
