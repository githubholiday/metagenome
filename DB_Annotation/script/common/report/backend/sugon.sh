### html
set -e
cd ~{reportdir}
/work/share/acdgo9idhi/install/miniconda/bin/python ~{BIN}/generate_md_report/generate_md_report_EB.py -d ./ -pipeline ~{workid} -l -o html_raw.md 
perl -pe 's/^\<br\s+\/\>/\n/' html_raw.md >new.md
/work/share/acdgo9idhi/install/miniconda/bin/pandoc --standalone -c html/css/markdown.css new.md --metadata title="~{report_name}" -o "~{report_name}".tmp.html
/work/share/acdgo9idhi/install/miniconda/bin/python ~{BIN}/generate_md_report/modify_html.py -i "~{report_name}".tmp.html -o "~{report_name}".html
zip -r report.zip html upload "~{report_name}".html
