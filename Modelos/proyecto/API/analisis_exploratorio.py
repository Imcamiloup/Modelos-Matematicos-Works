import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit

# 📌 1. Cargar el archivo CSV y corregir errores en la codificación
file_path = "datos_sistema_hidrico_limpio.csv"
df = pd.read_csv(file_path, encoding="utf-8", delimiter=";")

# 📌 2. Convertir las comas decimales a puntos y transformar a float
df["Shape_Area"] = df["Shape_Area"].astype(
    str).str.replace(",", ".").astype(float)
df["Shape_Leng"] = df["Shape_Leng"].astype(
    str).str.replace(",", ".").astype(float)

# 📌 3. Resumen estadístico para verificar valores
print("\n📊 Resumen Estadístico:")
print(df[["Shape_Area", "Shape_Leng"]].describe())

# 📌 4. Matriz de correlación
plt.figure(figsize=(8, 5))
sns.heatmap(df[["Shape_Area", "Shape_Leng"]].corr(),
            annot=True, cmap="coolwarm", fmt=".2f")
plt.title("Matriz de Correlación entre Shape_Area y Shape_Leng")
plt.show()

# 📌 5. Definir la función del modelo de recursos disponibles


def modelo_recursos(t, alpha, beta):
    return alpha - beta * t  # dR/dt = α - βP(t)


# 📌 6. Crear datos simulados para estimar parámetros
# Supongamos que Shape_Area representa recursos hídricos y Shape_Leng mide la presión poblacional indirecta
# Suponiendo que el tiempo va en años/semanas
t_values = np.linspace(1, len(df), len(df))
R_values = df["Shape_Area"].values  # Recursos hídricos estimados

# 📌 7. Estimación de parámetros α y β usando ajuste de curvas
popt, _ = curve_fit(modelo_recursos, t_values, R_values)
alpha_estimado, beta_estimado = popt

# 📌 8. Resultados del ajuste
print("\n🔢 Parámetros estimados del modelo:")
print(f"✅ α (Tasa de regeneración de recursos) = {alpha_estimado:.4f}")
print(f"✅ β (Impacto poblacional en el consumo) = {beta_estimado:.4f}")

# 📌 9. Graficar la evolución de los recursos en el tiempo con el modelo ajustado
plt.figure(figsize=(8, 5))
plt.scatter(t_values, R_values, label="Datos Observados",
            color="blue", alpha=0.6)
plt.plot(t_values, modelo_recursos(t_values, alpha_estimado,
         beta_estimado), label="Modelo Ajustado", color="red")
plt.xlabel("Tiempo")
plt.ylabel("Recursos Disponibles (Shape_Area)")
plt.title("Evolución de Recursos en el Tiempo")
plt.legend()
plt.show()
