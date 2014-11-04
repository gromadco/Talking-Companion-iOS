"""
Prepare translation.json.

Structure of json:

    key:
        value:
            translation:
                en:
                ru:
"""

import io
import json
from collections import defaultdict
import csv

LANG_CODES = ('en', 'ru')
FILE_NAME_TEMPLATE = 'map_features_{}.csv'
TRANSLATION_JSON_FILE = 'translation.json'


# create translation structure
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

# save translation json
with io.open(TRANSLATION_JSON_FILE, 'w', encoding='utf8') as f:
    f.write(
        unicode(
            json.dumps(
                translation_dict,
                ensure_ascii=False,
                sort_keys=True,
                indent=2)))

# print keys only with one translation translations
no_single_translation = True
for key in translation_dict:
    for value in translation_dict[key]:
        if len(translation_dict[key][value]['translation']) < 2:
            print key, value, translation_dict[key][value]['translation']
            no_single_translation = False
if no_single_translation:
    print "no keys with one translation"
