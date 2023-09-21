## 生成aliyun网页版
#### 调整报告模板
sed -e
echo  "change raw tempalte and json to new tempalte and json based on upload files"`date`
~{PYTHON3} ~{BIN}/others/adjust_template.py -it ~{reportdir}/template.raw.md -ij ~{reportdir}/input.raw.json -ot ~{reportdir}/template.md -oj ~{reportdir}/input.json -u ~{reportdir}

#### 生成pdf报告
cd ~{reportdir}
~{PYTHON3} ~{BIN}/generate_md_report/generate_md_report.py -d ./ -pipeline ~{workid} -l  -pdf -o pdf_raw.md
~{PYTHON3} ~{BIN}/others/adjust_md.py -i pdf_raw.md -o pdf.md -t 1 -n ~{report_name}
~{PANDOC} pdf.md -o ~{workid}.raw.tex -s --data-dir=~{BIN}/others/config --toc --template eisvogel --toc-depth=4
~{PYTHON3} ~{BIN}/others/adjust_md.py -i ~{workid}.raw.tex -o ~{workid}.tex -t 2
~{PDFLATEX} ~{workid}
~{PDFLATEX} ~{workid}
mv ~{workid}.pdf ~{report_name}.pdf
zip -r upload.zip upload ~{report_name}.pdf 

#### 生成网页版报告模板
cd ~{reportdir} && ~{PYTHON3} ~{BIN}/generate_md_report/generate_md_report.py -d ./ -o report.md -pipeline ~{workid}
~{bin}/others/adjust_abnormal.sh ~{reportdir}/report.md
~{PYTHON3} ~{BIN}/others/report_upload.py -i ~{reportdir} -p ~{workid} -o ~{reportdir} -pro -place huawei -result
~{PYTHON}  ~{BIN}/sendmessage/sendmessage.py -c ~{BIN}/sendmessage/config.yw.product.ini -p ~{workid} -u " " -tt  ~{report_name} -n 1 -sleep 0 -t ~{product} 
~{PYTHON3}  ~{BIN}/others/report_address.py -p ~{workid} -o ~{reportdir}/report.txt -a 1
cat ~{reportdir}/report.txt
