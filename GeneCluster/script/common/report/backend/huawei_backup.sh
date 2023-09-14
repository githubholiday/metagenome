### 生成pdf
~{PYTHON3} ~{BIN}/others/check_file.py -i ~{reportdir} -o ~{reportdir}/file.not.exist.log
cd  ~{reportdir} && ~{PYTHON3} ~{BIN}/generate_md_report/generate_md_report.py -d ./ -pipeline ~{workid} -l -pdf -o pdf_raw.md
~{PYTHON3} ~{BIN}/others/adjust_md.py -i ~{reportdir}/pdf_raw.md -o ~{reportdir}/pdf.md -t 1 -n ~{title}
cd ~{reportdir} && ~{PANDOC} pdf.md -o ~{workid}.raw.tex -s --data-dir=~{BIN}/config --toc --template eisvogel --toc-depth=4
~{PYTHON3} ~{BIN}/others/adjust_md.py -i ~{reportdir}/~{workid}.raw.tex -o ~{reportdir}/~{workid}.tex -t 2
### Latex 生成pdf 需要至少编译2次
cd ~{reportdir} && ~{PDFLATEX} ~{reportdir}/~{workid}
cd ~{reportdir} && ~{PDFLATEX} ~{reportdir}/~{workid}
rm -rf ~{title}.pdf
cd ~{reportdir} && mv ~{workid}.pdf ~{title}.pdf
cd ~{reportdir} && rm -rf ~{workid}.raw.tex

## 生成aliyun网页版
cd ~{reportdir} && ~{PYTHON3} ~{BIN}/generate_md_report/generate_md_report.py -d ./ -o report.md -pipeline ~{workid}
~{bin}/others/adjust_abnormal.sh ~{reportdir}/report.md
sed -i 's#oss://annoroad-cloud-product/user#user#g' ~{reportdir}/report.md
~{PYTHON3} ~{BIN}/others/report_upload.py -i ~{reportdir} -p ~{workid} -o ~{reportdir} -pro -place huawei
~{PYTHON}  ~{BIN}/sendmessage/sendmessage.py -c ~{BIN}/sendmessage/config.yw.ini -p ~{workid} -u " " -tt  ~{title} -n 1 -sleep 0 -t ~{product}
~{PYTHON3}  BIN/report_address.py -p ~{workid} -o ~{reportdir}/report.txt -a 1
cat ~{reportdir}/report.txt 
