"""
Prepare translation.json.

Structure of json:

    key:
        value:
            translation:
                en:
                ru:
"""

import json
from collections import defaultdict
import csv

LANG_CODES = ('en', 'ru')
FILE_NAME_TEMPLATE = 'map_features_{}.csv'


translation_dict = defaultdict(lambda: defaultdict(lambda: defaultdict(dict)))

for code in LANG_CODES:
    filename = FILE_NAME_TEMPLATE.format(code)
    with open(filename) as f:
        reader = csv.reader(f)
        columns = reader.next()
        for row in reader:
            row_dict = dict(zip(columns, row))
            if row_dict.get('translation'):
                translation_dict[
                    row_dict['key']][
                    row_dict['value']][
                    'translation'][code] = row_dict['translation'].decode('utf8')

print json.dumps(translation_dict, ensure_ascii=False).encode('utf8')
