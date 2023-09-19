### html
cd ~{reportdir}
~{PYTHON} ~{BIN}/generate_md_report/generate_md_report.py -d ./ -pipeline ~{workid} -l -o html_raw.md 
~{PANDOC} -s --toc html_raw.md -o html_context.md
sed -i '/fullview/i\\\`\`\`{=html}' html_context.md
sed -i '/fullview/a\\\`\`\`' html_context.md
~{PANDOC} --self-contained -c ~{MD_CCS} html_context.md --metadata title="~{report_name}" -o "~{report_name}".html 
sed -i '/<head>/ r upload/_icon/albumSlider.html' ~{report_name}.html 

###pdf
~{PYTHON3} ~{BIN}/others/check_file.py -i ~{reportdir} -o ~{reportdir}/file.not.exist.log
~{PYTHON} ~{BIN}/generate_md_report/generate_md_report.py -d ./ -pipeline ~{workid} -l  -pdf -o pdf_raw.md 
~{PYTHON3} ~{BIN}/others/adjust_md.py -i pdf_raw.md -o pdf.md -t 1 -n ~{report_name}
~{PANDOC} pdf.md -o ~{workid}.raw.tex -s --data-dir=~{BIN}/others/config --toc --template eisvogel --toc-depth=4
~{PYTHON3} ~{BIN}/others/adjust_md.py -i ~{workid}.raw.tex -o ~{workid}.tex -t 2
~{GLIB} && ~{PDFLATEX} ~{workid}
~{GLIB} && ~{PDFLATEX} ~{workid}
mv ~{workid}.pdf ~{report_name}.pdf

