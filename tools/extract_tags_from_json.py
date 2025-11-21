import json
from collections import Counter

# Archivos a procesar
files = ['Devocional_year_2025.json', 'Devocional_year_2026.json']
all_tags = []


def extract_devocionales(data):
    devocionales = []
    if isinstance(data, dict):
        for idioma in data.values():
            if isinstance(idioma, dict):
                for fecha in idioma.values():
                    if isinstance(fecha, list):
                        devocionales.extend(fecha)
    return devocionales


for filename in files:
    try:
        with open(filename, encoding='utf-8') as f:
            raw_json = json.load(f)
        # Extrae devocionales desde la estructura anidada
        devocionales = extract_devocionales(raw_json.get('data', {}))
        for dev in devocionales:
            tags = dev.get('tags', [])
            if isinstance(tags, list):
                all_tags.extend([str(tag).strip().lower() for tag in tags if str(tag).strip()])
    except Exception as e:
        print(f'Error leyendo {filename}: {e}')

counter = Counter(all_tags)

with open('tags_frecuencia.txt', 'w', encoding='utf-8') as out:
    out.write('Tags únicos y frecuencia (mayor a menor):\n')
    for tag, freq in counter.most_common():
        out.write(f'{tag}: {freq}\n')
print('Archivo tags_frecuencia.txt generado correctamente.')
