from flask import Flask, jsonify
import requests
import time
import urllib.parse
import csv
import os
import re

app = Flask(__name__)

BASE_URL = "https://datosabiertos.bogota.gov.co/api/3/action/datastore_search"
RESOURCE_IDS = {
    "2014": "5c28ec3d-0168-4dbe-ab4f-a61ecb874e3b",
    "2015": "5270c966-f812-48ac-9bbd-a7ed05125285",
    "2016": "db60fa26-8fd6-4eb9-bef4-5e1ca3d453e9",
    "2017": "7cd3c774-8d32-4b42-a2f6-fb7fbf0e1c87",
    "2018": "fa88a748-55fe-44a2-865e-ae535497f937",
    "2019": "c0a4acc1-a5f3-475f-8feb-408408c33af9"
}

# User-Agent mejorado + Referer + Accept
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
    "Accept": "application/json, text/javascript, */*; q=0.01",
    "Referer": "https://datosabiertos.bogota.gov.co/"
}


def obtener_datos_pm25():
    """Consulta y consolida los datos de calidad del aire."""
    datos_totales = []

    for anio, resource_id in RESOURCE_IDS.items():
        url = f"{BASE_URL}?{urllib.parse.urlencode({'resource_id': resource_id, 'limit': 1000})}"
        intentos = 3

        for intento in range(intentos):
            print(f"\n🔍 Debug - Año {anio}: Intento {intento+1}")
            print(f"📌 URL consultada: {url}")

            response = requests.get(url, headers=HEADERS)
            print(f"🔎 Estado HTTP: {response.status_code}")

            if response.status_code == 200:
                data = response.json()
                if "result" in data and "records" in data["result"]:
                    registros = data["result"]["records"]
                    for registro in registros:
                        # Agregar el año a cada registro
                        registro["anio"] = anio
                    datos_totales.extend(registros)
                print(
                    f"✅ Datos obtenidos para {anio}: {len(registros)} registros")
                break
            elif response.status_code == 503:
                print(
                    f"⚠️ Año {anio} no disponible (503). Reintentando ({intento+1}/{intentos})...")
                time.sleep(3)
            elif response.status_code == 404:
                print(
                    f"❌ Error 404 en {anio}. Puede que Flask esté construyendo mal la URL o la API esté bloqueando el request.")
                print(f"🛑 Respuesta API: {response.text}")
                break
            else:
                print(f"❌ Error {response.status_code} en {anio}")
                print(f"🛑 Respuesta API: {response.text}")
                break

        time.sleep(2)  # Espera 2 segundos entre cada request

    # Guardar datos en un archivo CSV
    guardar_csv(datos_totales)

    return datos_totales


def normalizar_nombre(nombre):
    """Normaliza los nombres de columna eliminando espacios extra y caracteres especiales."""
    nombre = nombre.strip()  # Eliminar espacios en los extremos
    # Reemplazar múltiples espacios por uno solo
    nombre = re.sub(r'\s+', ' ', nombre)
    nombre = nombre.replace("(ug/m3)", "").strip()  # Eliminar unidades
    nombre = nombre.lower()  # Convertir todo a minúsculas
    return nombre


def guardar_csv(datos):
    """Guarda los datos en un archivo CSV con nombres de columnas unificados."""
    if not datos:
        print("⚠️ No hay datos para guardar en CSV.")
        return

    # Normalizar nombres de columnas y crear un diccionario de equivalencias
    columnas_normalizadas = {}
    for d in datos:
        for key in d.keys():
            nombre_normalizado = normalizar_nombre(key)
            columnas_normalizadas[key] = nombre_normalizado

    # Obtener las claves normalizadas únicas
    columnas_finales = sorted(set(columnas_normalizadas.values()))

    # Nombre del archivo CSV
    archivo_csv = "calidad_aire_unificado.csv"

    with open(archivo_csv, mode="w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(
            file, fieldnames=columnas_finales, delimiter=";")

        # Escribir encabezado
        writer.writeheader()

        # Escribir datos asegurando que los valores `null` sean reemplazados por ""
        for fila in datos:
            fila_limpia = {columnas_normalizadas.get(key, key): (
                "" if value is None else value) for key, value in fila.items()}
            writer.writerow(fila_limpia)

    print(
        f"✅ Datos guardados en {archivo_csv} ({len(datos)} registros) correctamente.")
    """Guarda los datos en un archivo CSV con un formato correcto para Excel."""
    if not datos:
        print("⚠️ No hay datos para guardar en CSV.")
        return

    # Obtener todas las claves únicas para las columnas del CSV
    columnas = set()
    for d in datos:
        columnas.update(d.keys())

    columnas = sorted(columnas)  # Ordenamos las columnas para consistencia

    # Nombre del archivo CSV
    archivo_csv = "calidad_aire.csv"

    with open(archivo_csv, mode="w", newline="", encoding="utf-8") as file:
        # Usar punto y coma como separador
        writer = csv.DictWriter(file, fieldnames=columnas, delimiter=";")
        writer.writeheader()  # Escribir encabezados
        writer.writerows(datos)  # Escribir los datos

    print(
        f"✅ Datos guardados en {archivo_csv} ({len(datos)} registros) correctamente.")


@app.route('/datos_pm25', methods=['GET'])
def datos_pm25():
    """Endpoint que devuelve la consolidación de todos los datos de calidad del aire."""
    datos = obtener_datos_pm25()
    return jsonify(datos)


if __name__ == '__main__':
    app.run(debug=True)
