import pandas as pd
# import numpy as np
import requests
from bs4 import BeautifulSoup
import time
import re
ACC_CAZY = pd.read_csv('./cazy_data.txt',header=None,sep='\t')

CAZY_set = set(ACC_CAZY[0])
headers = {
    'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36'
    }
OUT = open('./Activity.xls','w')
for id in CAZY_set:
    url = 'http://www.cazy.org/{}.html'.format(id)
    print(id)
    data = requests.get(url,headers=headers)
    html = data.content.decode('utf-8')
    soup = BeautifulSoup(html, 'html.parser')
    
    if len(soup.tr.td.contents)==0:
        print(id,'is none in Activities_in_Family')
        continue
    con = soup.tr.td.contents
    con = [str(i) for i in con]
    pattern = re.compile(r'<[^>]+>',re.S)
    con = [pattern.sub('', i) for i in con]
    Activities_in_Family = ''.join(con)
    if id[2]=='M':
        Class=id[:3]
    else:
        Class=id[:2]
    frame = [id,Class,Activities_in_Family]
    OUT.write('\t'.join(frame)+"\n")
    time.sleep(3)
OUT.close()    