"""
Parse OpenStreetMap map features.
"""

import csv
from lxml import html
import os

import requests

article_title = 'RU:Map_Features'
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

csv_writer = csv.writer(open('map_features.csv', 'w'))

for tr in trs:
    tds = tr.xpath('.//td')
    if len(tds) > 3:
        key = tds[0]
        key = ''.join(key.xpath('.//text()')).strip()
        value = tds[1]
        value = value.text_content().strip().encode('utf8')
        comment = tds[3]
        comment = comment.text_content().strip().encode('utf8')
        print '--------'
        print 'key=', key
        print 'value=', value
        print 'comment=', comment
        csv_writer.writerow((key, value, comment))
