"""
Parse OpenStreetMap map features.
"""

from lxml import html
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
tds = tree.xpath('//td')

for td in tds:
    print td
    print td.text
    print td.items()
    print td.body

print dir(td)
