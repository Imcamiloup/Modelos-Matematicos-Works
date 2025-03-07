import pandas as pd
import matplotlib.pyplot as plt

# Cargar el archivo CSV con el delimitador correcto (;)
file_path = "datos_sistema_hidrico.csv"
df = pd.read_csv(file_path, encoding="utf-8", delimiter=";")

# Mostrar los nombres de las columnas para verificar que están correctamente leídos
print("Columnas disponibles en el dataset:")
print(df.columns)

# Normalizar nombres de columnas eliminando espacios en blanco
df.columns = df.columns.str.strip()

# Verificar si la columna 'Shape_Area' está en el DataFrame
if "Shape_Area" not in df.columns:
    print("Error: La columna 'Shape_Area' no se encuentra en el archivo. Nombres disponibles:")
    print(df.columns)
    exit()

# Convertir los valores de la columna 'Shape_Area' a números flotantes
df["Shape_Area"] = df["Shape_Area"].astype(
    str).str.replace(",", ".").astype(float)

# ✅ CORRECCIÓN: Convertir FECHA_CAPT correctamente
if "FECHA_CAPT" in df.columns:
    df["FECHA_CAPT"] = df["FECHA_CAPT"].astype(
        str).str.replace(",", ".")  # Reemplazar comas
    df["FECHA_CAPT"] = df["FECHA_CAPT"].astype(float)  # Convertir a número
    df["FECHA_CAPT"] = pd.to_datetime(
        df["FECHA_CAPT"], unit='ms')  # Convertir a fecha

# Resumen de estadísticas descriptivas de la columna 'Shape_Area'
print("\nEstadísticas descriptivas del área de los cuerpos de agua:")
print(df["Shape_Area"].describe())

# Graficar la distribución de áreas de cuerpos de agua
plt.figure(figsize=(10, 5))
plt.hist(df["Shape_Area"], bins=30, color='skyblue', edgecolor='black')
plt.xlabel("Área del cuerpo de agua (m²)")
plt.ylabel("Frecuencia")
plt.title("Distribución del área de los cuerpos de agua en Bogotá")
plt.grid(True)
plt.show()

# Guardar la versión limpia del CSV sin caracteres corruptos
output_file = "datos_sistema_hidrico_limpio.csv"
df.to_csv(output_file, index=False, encoding="utf-8", sep=";")
print(f"\n✅ Archivo limpio guardado en: {output_file}")
