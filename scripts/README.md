Add `translation` column to language file: `map_features_en.csv`, `map_features_ru.csv` etc.
Language files could be parsed from OSM wiki with `get_osm_features.py` (code needs to be manipulated for now).
Generate `translation.json` file with `make_translation_json.py`. 
Structure of generated JSON is described in the beginning of that script.

Scripts to get and manipulate data.

- `get_osm_features.py`: get map features from OSM wiki and save in CSV files
- `make_translation_json.py`: prepare json file with translations
