"""
Parse OpenStreetMap map features.
"""

from lxml import html
from lxml.etree import tostring
import os
import requests

article_title = 'Map_Features'
file_name = article_title + '.html'
article_url = 'http://wiki.openstreetmap.org/wiki/' + article_title

if not os.path.exists(file_name):
    page = requests.get(article_url)
    text = page.text
    with open(file_name, 'w') as f:
        f.write(text.encode('utf8'))
else:
    with open(file_name, 'r') as f:
        text = f.read().decode('utf8')

tree = html.fromstring(text)
trs = tree.xpath('//tr')
print len(trs)

for tr in trs:
    tds = tr.xpath('.//td')
    if len(tds) > 3:
        key = tds[0]
        value = tds[1]
        element = tds[2]
        comment = tds[3]
        print 'key=', ''.join(key.xpath('.//text()')).strip()

# for tr in trs:
#     print td
#     td_text = td.text_content().strip()
#     if td_text:
#         print td_text
#     else:
#         print td.xpath('//a')[0].text_content()

print dir(tr)
