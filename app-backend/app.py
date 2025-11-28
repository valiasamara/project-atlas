from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS 
import pandas as pd
import os
import re

app = Flask(__name__)
CORS(app) 

# Load CSV and set image directory
df = pd.read_csv("fixed_output.csv", encoding='utf-8')
IMAGES_DIR = os.path.join(app.root_path, 'static', 'images')

@app.route('/search', methods=['GET'])
def search():
    query = request.args.get('q', '').strip()
    if not query:
        return jsonify({'error': 'Missing query parameter'}), 400

    #  Compile exact-word pattern
    pattern = re.compile(rf"\b{re.escape(query)}\b", re.IGNORECASE)

    #  Search across all columns
    results = df[df.apply(
        lambda row: row.astype(str).apply(lambda val: bool(pattern.search(val))).any(),
        axis=1
    )]

    if results.empty:
        return jsonify({'message': 'No results found.'}), 404

    #  Convert file paths to URLs
    def convert_path(path):
        filename = os.path.basename(str(path))
        return f" http://192.168.2.4:5000/images/{filename}"
    results = results.copy()
    results['Image Path'] = results['Image Path'].apply(convert_path)

    return jsonify(results.to_dict(orient='records'))

#  Separate route for serving images
@app.route('/images/<path:filename>')
def serve_image(filename):
    return send_from_directory(IMAGES_DIR, filename)

if __name__ == '__main__':
    # Make sure your images live in app-backend/static/images/
    app.run(host='0.0.0.0', port=5000, debug=True)
