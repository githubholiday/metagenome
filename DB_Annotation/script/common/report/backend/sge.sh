### html
set -e
cd ~{reportdir}
~{PYTHON} ~{BIN}/generate_md_report/generate_md_report.py -d ./ -pipeline ~{workid} -l -o html_raw.md 
sed -i 's/^#/\\br\n\n/g' html_raw.md 
~{PANDOC} -s --toc html_raw.md -o html_context.md 
sed -i '/fullview/i\```{=html}' html_context.md
sed -i '/fullview/a\```' html_context.md
~{PANDOC} --self-contained -c ~{MD_CCS} html_context.md --metadata title="~{report_name}" -o "~{report_name}".html 
sed -i '/<head>/ r upload/_icon/albumSlider.html' ~{report_name}.html 

