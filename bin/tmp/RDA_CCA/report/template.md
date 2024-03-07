@@@@RDA/CCA
### RDA/CCA分析
RDA分析(Redundancy analysis)，即冗余分析。CCA分析(Canonical Correspondence analysis)，即典范对应分析。两者都是基于对应分析（correspondence analysis, CA）发展而来的一种排序方法，将对应分析与多元回归分析相结合，每一步计算均与环境因子进行回归，又称多元直接梯度分析。RDA分析基于线性模型，CCA分析基于单峰模型，主要用来反映菌群或样品与环境因子之间的关系。
RDA或CCA模型的选择原则：先用物种丰度数据做DCA分析，看分析结果中Lengths of gradient 的第一轴的大小，如果大于4.0，就应该选CCA，如果3.0-4.0之间，选RDA和CCA均可，如果小于3.0，RDA的结果要好于CCA。
使用R包vegan进行RDA或者CCA分析，并使用ggplot2作图。结果中进行了样品间种水平的物种多样性RDA/CCA分析，分析结果如下：
![RDA_CCA分析图]{{image_RDA_CCA}}
（1）环境向量的长度表示样方物种的分布与该环境因子相关性的大小，长度越长，相关性越大；
（2）环境向量与约束轴夹角的大小表示环境因子与约束轴相关性的大小，夹角小说明关系密切，若正交则不相关；
（3）样本点与箭头距离越近，该环境因子对样本的作用越强；
（4）样本位于箭头同方向，表示环境因子与样本物种群落的变化正相关，样本位于箭头的反方向，表示环境因子与样本物种群落的变化负相关。

### 参考文献
T Wu, E Hu, S Xu, M Chen, P Guo, Z Dai, T Feng, L Zhou, W Tang, L Zhan, X Fu, S Liu, X Bo, and G Yu. clusterProfiler 4.0: A universal enrichment tool for interpreting omics data. The Innovation. 2021, 2(3):100141
