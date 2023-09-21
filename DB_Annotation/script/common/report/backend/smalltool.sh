##先将upload拷贝
~{bin}/others/report~{OSSUTIL} in cp "-rf upload  ~{reportdir}/upload --update"
~{PYTHON3} ~{Report_Py} -d ./ -o report.md -smalltool ~{reportdir} ~{workid}
~{bin}/others/adjust_abnormal.sh ~{reportdir}/report.md
~{bin}/others/report ~{OSSUTIL} in cp "-f report.md ~{reportdir}/report.md" 
~{bin}/others/report~{OSSUTIL} in cp "-f mapping.json ~{reportdir}/mapping.json"
~{PYTHON} ~{bin}/send_message -c ~{bin}/send_message/config.bj.smalltools.ini -t 2 -p ~{workid} -tt ~{title} >report.txt
cat report.txt 