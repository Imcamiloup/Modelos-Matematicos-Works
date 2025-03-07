from flask import Flask, jsonify, request
import requests

app = Flask(__name__)

# URL de la API de Socrata
SOCATA_API_URL = "https://www.datos.gov.co/resource/53gx-j5pc.json"


@app.route('/datos', methods=['GET'])
def obtener_datos():
    """Obtiene datos de la API de Socrata y los devuelve en formato JSON."""
    params = request.args  # Permite filtrar datos con parámetros en la URL
    response = requests.get(SOCATA_API_URL, params=params)

    if response.status_code == 200:
        return jsonify(response.json())
    else:
        return jsonify({"error": "No se pudo obtener los datos"}), response.status_code


if __name__ == '__main__':
    app.run(debug=True)
