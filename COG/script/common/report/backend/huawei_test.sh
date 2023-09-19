## 生成aliyun-test网页版
cd ~{reportdir} && ~{PYTHON3} ~{BIN}/generate_md_report/generate_md_report.py -d ./ -o report.md -pipeline ~{workid}
~{BIN}/others/adjust_abnormal.sh ~{reportdir}/report.md
sed -i 's#https://source.solargenomics.com/user#https://annoroad-cloud-test.oss-cn-beijing.aliyuncs.com/user#g' ~{reportdir}/report.md
~{PYTHON3} ~{BIN}/others/report_upload.py -i ~{reportdir} -p ~{workid} -o ~{reportdir} -place huawei
~{PYTHON}  ~{BIN}/sendmessage/sendmessage.py -c ~{BIN}/sendmessage/config.yw.test.ini -p ~{workid} -u " " -tt  ~{report_name} -n 1 -sleep 0 -t ~{product}
~{PYTHON3}  ~{BIN}/report_address.py -p ~{workid} -o ~{reportdir}/report.txt -a 1
cat ~{reportdir}/report.txt 
