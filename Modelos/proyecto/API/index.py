from flask import Flask, jsonify
import requests
import pandas as pd

app = Flask(__name__)

# URL Base de la API de ArcGIS (Sistema Hídrico)
API_URL = "https://secretariadeambiente.gov.co/arcgis/rest/services/Estructura_Ecologica_Principal/Sistema_Hidrico/MapServer/0/query"

# Parámetros para la consulta según la documentación de ArcGIS
PARAMS = {
    "where": "1=1",  # Obtiene todos los registros
    "outFields": "*",  # Obtiene todos los campos
    "f": "json",  # Formato de salida en JSON
    "returnGeometry": "false",  # No necesitamos la geometría
}


@app.route('/obtener_datos', methods=['GET'])
def obtener_datos():
    try:
        # Realiza la petición a la API
        response = requests.get(API_URL, params=PARAMS)

        # Verifica si la respuesta es válida
        if response.status_code != 200:
            return jsonify({"error": "No se pudo obtener los datos", "status_code": response.status_code}), 500

        data = response.json()

        # Verifica si la API devolvió un error
        if "error" in data:
            return jsonify({"error": "Error en la API", "detalle": data["error"]}), 500

        # Extrae los datos de los atributos de las entidades
        if "features" not in data or not data["features"]:
            return jsonify({"message": "No hay datos disponibles", "rows": 0})

        registros = [feature["attributes"] for feature in data["features"]]

        # Guarda los datos en un archivo CSV con formato correcto
        df = pd.DataFrame(registros)
        df.to_csv("datos_sistema_hidrico.csv",
                  index=False, sep=";", decimal=",", encoding="utf-8-sig")

        return jsonify({"message": "Datos obtenidos y guardados exitosamente", "rows": len(registros)})

    except Exception as e:
        return jsonify({"error": f"Ocurrió un error: {str(e)}"}), 500


if __name__ == '__main__':
    app.run(debug=True)
