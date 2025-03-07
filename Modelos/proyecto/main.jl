### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

# ╔═╡ 3be3288a-f5c8-444b-a93f-90b92a2da808
begin
	begin
		using Images
		load("./imgs/pob.png")
	end
end

# ╔═╡ c0d46187-970e-4f6c-9f1f-1ad40a08a01a
using DifferentialEquations, Optim, Plots, LinearAlgebra, CSV, DataFrames, Interpolations

# ╔═╡ 984a3f2b-ff68-4821-be19-c0f53314583c
html"""
<h1 style="font-size: 28px; text-align:center">Proyecto Modelos Matemáticos</h1>
  <h2 style="font-size: 24px;text-align:center">Modelado y Ajuste de Parámetros de un Sistema Urbano: Caso Bogotá</h2>
  <p style="font-size: 14px;text-align:center"><strong>Luis Camilo Gómez Rodríguez</strong><br>
     <strong>José Simón Ramos Sandoval</strong><br>
     <strong>Tomas David Rodríguez Agudelo</strong>
  </p>
  
  <p style="font-size: 15px;text-align:center"><strong>Prof. Juan Carlos Galvis Arrieta</strong></p>
  
  <p style="font-size: 13px;text-align:center">Marzo 7, 2025</p>
"""

# ╔═╡ 615ef11d-d9b6-44ac-b2e2-06b897b88bb4
html"""
<h2>Problema</h2>
<p>El tema a abordar consiste en el desarrollo y análisis de un modelo matemático basado en ecuaciones diferenciales ordinarias (EDOs) que describa la dinámica integrada de varios componentes importantes de una ciudad, tales como la población, la huella urbana, la estructura ecológica y el bienestar social (infraestructura, servicios, vivienda, entre otros). El objetivo es entender cómo las interacciones entre estos componentes influyen en la evolución de la ciudad a mediano y largo plazo. Esta problemática es relevante en el contexto del desarrollo urbano sostenible, ya que la expansión descontrolada, la falta de continuidad en políticas públicas y la fragmentación administrativa dificultan la implementación de planes a largo plazo. El modelo busca proporcionar una herramienta para comprender las trayectorias posibles de estos sistemas complejos y, con datos apropiados, ajustar parámetros que permitan un mejor acercamiento a la realidad y apoyar la toma de decisiones.</p>
"""

# ╔═╡ 36947288-7dab-47aa-a9df-e0d0214fe8f1
html"""
<h2>Objetivos</h2>
<h3>Objetivo general</h3>
Desarrollar y analizar un modelo de ecuaciones diferenciales ordinarias que represente la dinámica integrada de la población, el territorio y el bienestar urbano, y ajustar sus parámetros a datos empíricos con el fin de obtener un modelo predictivo más fiel a la realidad.
<h3>Objetivos específicos</h3>
<ul>
<li>Adaptar el modelo para incorporar de forma coherente las variables relevantes (población, huella urbana, estructura ecológica, inversión en infraestructura, servicios públicos, calidad de la vivienda).</li>
<li>Identificar, recopilar y preparar datos empíricos (por ejemplo, del DANE u otras fuentes) que permitan la estimación de las tasas de natalidad, mortalidad, inmigración, así como información sobre infraestructura, servicios, vivienda y variables ambientales (riesgo, clima).</li>
<li>Implementar métodos de ajuste para encontrar el conjunto de parámetros que mejor reproduzca las trayectorias históricas observadas en los datos.</li>
<li>Analizar la sensibilidad del modelo a variaciones en los parámetros y evaluar la robustez de las proyecciones a futuro.</li>
<li>Analizar las EDOs con herramientas vistas en clase.</li>
</ul>
"""

# ╔═╡ d08fda83-d9a2-46bd-8623-16394f1cab99
html"""
<h2>Metodología</h2>
El modelo cuenta con tres componentes: poblacional, territorial y de bienestar. Se presentarán algunas alternativas para modelar cada componente considerado.

<h3>Población</h3>
Para el componente de población se consideraron las siguientes variables:
"""

# ╔═╡ 66cc3684-e801-4ae4-a4de-64ca013f7502
md"""
  - .$P(t)$: Población en el tiempo $t$: número de habitantes en el tiempo $t$.


  - .$B(t)$: Tasa de natalidad en el tiempo $t$: proporción de nacimientos con respecto a la población en el tiempo $t$.


  - .$M(t)$: Tasa de mortalidad en el tiempo $t$: propoción  de muertes con respecto a la población en el tiempo $t$.


  - .$I(t)$: Tasa de migración neta en el tiempo $t$: proporción de la migración neta (diferencia entre inmigraciones y emigraciones) con respecto a la población en el tiempo $t$.
"""

# ╔═╡ d54db4d3-d204-42da-834c-4527372d8dc5
md"""
Se probaron los siguientes dos modelos:


1.Ecuación diferencial de compensación en su forma continua, llegamos a esta ecuación por la lectura de un estudio realizado por el DANE de proyección poblacional [5].


$$\frac{dP}{dt} = B(t) - M(t) + I(t),$$
donde  

$$B(t)=b_0P(t), \quad M(t)=m_0P(t), \quad I(t)=i_0.$$


2.Modelo logístico con término de migración, inspirado en lo visto en clase.


$$\frac{dP}{dt} = rP(t) \left ( 1 - \frac{P(t)}{K}\right ) + I(t),$$
donde $r$ es la tasa de crecimiento y $K$ la capacidad de carga.

Para este componente contamos con una buena cantidad de datos tanto de población, natalidad, mortalidad e inmigración de fuentes oficiales como el DANE. Existen otras alternativas de modelos $-$más complejos$-$ que por ejemplo separan a la población en grupos por edad y género [8].
"""

# ╔═╡ b4038522-2a3d-4735-9427-b5daf2e2e021
html"""
<h3>Territorio</h3>
Para el componente de territorio consideramos las siguientes variables:
"""

# ╔═╡ aeb46253-0b04-4429-8f82-1fd4f33412df
md"""
- .$U(t)$: Huella urbana en el tiempo $t$: número de hectáreas ($ha$) urbanizadas en el tiempo $t$.

- .$E(t)$: Estructura ecológica en el tiempo $t$: número total de hectáreas de área protegida en el tiempo $t$ (parques, humedales, plazas, etc).

- .$V(t)$: Demanda de viviendas en el tiempo $t$: número de viviendas ocupadas en el tiempo $t$.

- .$D(t)$: Área disponible $-$no hurbanizada$-$: número de hectáreas disponibles para hurbanizar en el tiempo $t$.

- .$N(t)$: Suelo en desarrollo: número de hectáreas sobre las que se está expandiendo la ciudad en el tiempo $t$ (generalmente en las periférias de la ciudad).

Hay dos alternativas principales para este modelo:
"""

# ╔═╡ ac57d4c7-90a7-4ee1-9918-c5e3e42646d4
html"""
<h4> Modelo intuitivo:</h4>
"""

# ╔═╡ 69f5485b-f15a-4cd2-a66f-0df8eec38dfb
md"""
###

Modelo intuitivo en el que la expansión de la huella urbana es proporcional al crecimiento poblacional y a la demanda de viviendas, pero limitada por la estructura ecológica (área protegida):

$$\frac{dU}{dt} = \alpha P(t) + \beta V(t) - \gamma E(t);$$

la estructura ecológica disminuye debido a la expansión de la huella urbana:

$$\frac{dE}{dt} = -\delta U(t);$$

la demanda de viviendas, asumimos depende del promedio de personas por hogar $\kappa$:

$$\frac{dV}{dt} = \frac{1}{\kappa}\frac{dP}{dt}$$

y la superficie del suelo urbano disponible disminuirá proporcionalmente con la expansión de la huella urbana:

$$\frac{dD}{dt} = -\nu \frac{dU}{dt}.$$

Notemos que este sistema puede reducirse. En particular, en (4) es evidente que $D(t)$ está completamente determinado por $U(t)$ y no aporta información a la dinámica del sistema.

Un proceso análogo sucede en (3), pues si se integra a ambos lados y se reemplaza en (1) obtenemos una nueva expresión para $\frac{dU}{dt}$ que depende únicamente de $P(t)$ y $E(t)$. Y, al igual que antes, podría eliminarse a (3). En resumen, el sistema reducido es:

$$\frac{dU}{dt} = \bar\alpha\; P(t) - \gamma E(t) + \bar\beta$$

$$\frac{dE}{dt} = -\delta U(t)$$

Donde $\bar\alpha = \alpha + \frac{\beta}{\kappa}$ y $\bar\beta = \beta C_1$ con $C_1$ una constante de integración.

$$\frac{dP}{dt} = \rho P(t) \;( 1- \frac{P(t)}{k_1U(t) - k_2E(t)})$$

con $\rho$ tasa de crecimiento intrínseco y $k_1U(t) + k_2E(t)$ la capacidad de carga que se contribuye por $U(t)$ y se limita por $E(t)$.
"""

# ╔═╡ 2d16f761-a67c-401a-af9b-8fb7e045a47a
html"""
<h4>Modelo SIR</h4>
"""

# ╔═╡ 9b9b6f1e-e816-436d-8353-e32de81ce39c
md"""
### 

Modelo basado en el modelo SIR (epidemiológico). Suponemos que es un sistema cerrado, esto es, $D(t) + N(t) + U(t) = C$ para todo $t \geq 0$, donde $C$ es el área total (en este caso de Bogotá).

$$\frac{dD}{dt} = -\alpha D(t)N(t)$$

$$\frac{dN}{dt} = \alpha D(t)N(t) - \gamma N(t)$$

$$\frac{dU}{dt} = \gamma N(t)$$

donde $\alpha, \gamma > 0$.

No obstante, dado que $U(t)$ no aparece en ninguna de las ecuaciones del sistema, vemos que esta puede determinarse a partir de $N(t)$ y no aporta en nada a la dinámica del sistema. Por tanto, este puede reducirse a:

$$\frac{dD}{dt} = -\alpha D(t)N(t)$$

$$\frac{dN}{dt} = \alpha D(t)N(t) - \gamma N(t)$$


Para este componente hay datos de una considerable cantidad de años (separados por intervalos de tiempo) para la huella urbana, área protegida y la demanda de viviendas. Del suelo en desarrollo no encontramos datos por lo que fue necesario replantear el modelo para que solo considere los compartimentos $D$ y $U$.
"""

# ╔═╡ 6bd2a1f9-cf3a-4f3a-b437-fd2460998400
md"""
Para este componente hay datos de una considerable cantidad de años (separados por intervalos de tiempo) para la huella hurbana, área protegida y la demanda de viviendas [4, 6, 2]. Del suelo en desarrollo no encontramos datos por lo que puede ser más práctico un modelo que solo considere los compartimentos $D$ y $U$, en [7] también se presenta esta simplificación.
"""

# ╔═╡ 7d356bfa-9653-479c-9882-ee24a977c887
md"""

Esta reescritura del modelo se consigue al reemplazar $N(t) = \frac{1}{\gamma} \frac{dU}{dt}$ en las ecuaciones de $\frac{dN}{dt}$ y $\frac{dD}{dt}$. Esta interpretación es la usada para estimar los parámetros del modelo.


$$\frac{dD}{dt} = -\frac{\alpha}{\gamma}D(t) \frac{dU}{dt}$$

$$\frac{d^2U}{dt^2} = (\alpha D(t) - \gamma) \frac{dU}{dt}$$



"""

# ╔═╡ 06fbabc4-86ec-4a96-b21b-f8388642eb80
html"""
<h3>Bienestar</h3>
Para el componente de bienestar consideramos las siguientes variables:
"""

# ╔═╡ a46ab93a-5c30-46ee-b0f4-9422bd815efd
md"""
- 


-


-
"""

# ╔═╡ 701af503-04fd-4a2a-8e6a-c7920742515f
html"""
<h2>Análisis de las EDO</h2>
"""

# ╔═╡ 79bc7e6b-56dc-472c-841d-62b28aa8aaac
html"""
<h2>Ajuste de parámetros</h2>
Para el ajuste de parámetros, se realizó una recopilación de datos de fuentes oficiales. A continuación describiremos el proceso realizado para cada componente.
"""

# ╔═╡ 8c025ed7-800c-45fb-b3e2-d980546082aa
md"""
### Recopilación de datos
Para esta sección, para algunos datasets se tuvo que hacer limpieza e interpolación de datos. Por facilidad este proceso fue realizado usando Python, los notebooks de limpieza de datos se encuentran en el [repositorio](https://github.com/Imcamiloup/Modelos-Matematicos-Works/tree/main/Modelos/proyecto/datos/procesamiento).
"""

# ╔═╡ 6fb4d0dd-6ff1-4622-9f68-09cb504ad39f
html"""
<h4>Población</h4>
Los datos de este componente fueron tomados de la plataforma DataCivilidad de la Sociedad de Ornato y mejoras de Bogotá [4], ahí cuentan con datos sobre la evolución demográfica de la ciudad de Bogotá. Recopilamos datos de población, tasa de natalidad, tasa de mortalidad y tasa de migración neta desde el año 1980 al año 2024. En general la información está muy completa para cada uno de los años considerados.
"""

# ╔═╡ 4100f072-9090-4a12-8910-5a223e67bd67
html"""
<div style="text-align: center;">
  <p style="font-size: 13px">Datos recopilados de población.</p>
</div>
"""

# ╔═╡ 2bcab15c-caf8-404f-8fcc-2e8dfa6d994d
load("./imgs/tasas.png")

# ╔═╡ 45c763ba-69e9-4219-9080-08ca69e69985
html"""
<div style="text-align: center;">
  <p style="font-size: 13px">Datos recopilados tasas de natalidad, mortalidad y migración.</p>
</div>
"""

# ╔═╡ fa9edad9-3499-44f0-9c28-1f7b7175c96b
html"""
<h4>Territorio</h4>
Los datos de este componente fueron tomados de la plataforma DataCivilidad de la Sociedad de Ornato y mejoras de Bogotá [4] y del IDOM del Estudio para crecimiento y evolución de la huella urbana para Bogotá [6]. Se recopilaron datos de huella urbana, área protegida, viviendas ocupadas y viviendas totales (ocupadas y desocupadas). En este caso si hubo algunas particularidades:
"""

# ╔═╡ 4904604e-5326-487d-8776-e0a7d0a8e064
md"""
- Huella urbana y área protegida: Las fuentes solo tenían datos para ciertos años, aproximadamente cada 6 años, es por esto que se hizo una interpolación usando splines cúbicos para obtener los datos faltantes. 
"""

# ╔═╡ dee17d2f-6a00-4eef-8fa3-a2a7be64cf99
load("imgs/huprot.png")

# ╔═╡ e9c8d2eb-dd0e-4248-a911-bfab429bee7b
html"""
<div style="text-align: center;">
  <p style="font-size: 13px">Datos de huella urbana.</p>
</div>
"""

# ╔═╡ dc828511-2862-4b2d-844f-b9042e2a18bd
load("imgs/aprot.png")

# ╔═╡ 2577dd88-596a-45a9-b89e-56545b60a806
html"""
<div style="text-align: center;">
  <p style="font-size: 13px">Datos de área protegida.</p>
</div>
"""

# ╔═╡ c6ea3785-0fdf-4b39-8924-b90386ba5dea
md"""
- Viviendas: Se contaban con datos a partir del año 2005. Para hallar los datos de años anteriores (1980-2004), se linealizaron los datos asumiendo un modelo exponencial y se hizo regresión lineal.
"""

# ╔═╡ 28617099-6ad7-460f-8bc1-34580b435151
load("imgs/viv1.png")

# ╔═╡ 651f1466-eef6-49ff-9dd6-47bbf08da31b
html"""
<div style="text-align: center;">
  <p style="font-size: 13px">Datos de viviendas ocupadas.</p>
</div>
"""

# ╔═╡ 8f043267-6732-478a-996d-9685c24b5978
load("imgs/viv2.png")

# ╔═╡ 89e1367f-d97c-4267-bdbb-d1b4e5bc3e1d
html"""
<div style="text-align: center;">
  <p style="font-size: 13px">Datos de viviendas totales.</p>
</div>
"""

# ╔═╡ e830749c-1795-4467-9d8a-7cf1ebbff1da
html"""
<h4>Bienestar</h4>
"""

# ╔═╡ bf7c7386-9bfd-4834-9f31-c4e481708cc7
html"""
<h3>Carga de datos y optimización de parámetros</h3>
"""

# ╔═╡ 2dfbbd5c-5121-404f-9170-c8b03e562bed
md"""
Cargamos el dataset de población:
"""

# ╔═╡ 1e6eaec1-b7e5-4d48-91f0-91d82a1d80ae
df_poblacion = CSV.read("./datos/datos_poblacion.csv", DataFrame)

# ╔═╡ 0f3efab8-8425-49b7-8fb5-431f494cc0af
md"""
Ahora cargamos el dataset de territorio:
"""

# ╔═╡ e0cf5bb3-a644-4223-aa87-a0e0b921f13a
df_territorio = CSV.read("./datos/datos_territorio.csv", DataFrame)

# ╔═╡ 35438e3a-7306-449b-a176-88a33ab3d8b9
html"""
<h4>Modelo de población (logístico)</h4>
"""

# ╔═╡ c21a0f23-5941-4dcd-a9cb-2bbb03ffddb0
md"""
Consideraremos el modelo logístico con población:

$$\frac{dP}{dt}= rP(t) \left(1 - \frac{P(t)}{K}\right) + I(t),$$
$$\frac{dI}{dt} = f(t)$$

donde $r$ es la tasa de crecimiento y $K$ la capacidad de carga.
"""

# ╔═╡ f087c6ec-f648-49c3-9f86-940ad290abae
md"""
Para realizar un análisis de los diagramas de fase es encesario obtener una ecuación para la derivada de $I(t)$. En este caso, usando los datos observados para la migración, haremos una aproximación a esta usando interpolación lineal. No obstante, por el momento la denotaremos mediante la expresión $\frac{dI}{dt} = f(t)$
"""

# ╔═╡ e8c662b4-0f54-46f0-b61c-cb67b7f55f6f
html"""
<h4>Análisis de diagramas de fase</h4>
"""

# ╔═╡ 7cce6391-8d80-4786-8bad-d1dd5658846c
md"""
#### Puntos fijos

En este caso no tiene sentido asumir que I(t) = 0, dada que la migración en el territorio no es nula. Por tanto, debemos usar la fórmula cuadrática para obtener los puntos fijos en función de I


$$\frac{dI}{dt} = 0, \; I(t) \neq 0$$

$$P(t) = \frac{K \pm \sqrt{K^2 + \frac{4KI}{r}} }{2}$$
"""

# ╔═╡ 9956c3ef-51a4-4260-85c7-9e63adae9b9e
md"""
#### Jacobiano

Para el jacobiano tenemos que:

$$J = 
\begin{bmatrix}
\frac{\partial}{\partial P}(\frac{dP}{dt}) & \frac{\partial}{\partial I}(\frac{dP}{dt}) \\
\frac{\partial}{\partial P}(\frac{dI}{dt}) & \frac{\partial}{\partial I}(\frac{dI}{dt})
\end{bmatrix}$$

$$J = 
\begin{bmatrix}
r(1-\frac{2P(t)}{K}) & 1 \\
0 & 0
\end{bmatrix}$$


"""

# ╔═╡ 83d199ce-b358-41ca-bf72-8b2662dec7d0
md"""
#### Valores y vectores propios

Se debe evaluar el jacobiano en los puntos fijos para posteriormente sacar los valores y vectores propios.

- $(P(t)^*, I(t)^*) = (\frac{K + \sqrt{K^2 + \frac{4KI}{r}} }{2}, I^*):$

$$J = 
\begin{bmatrix}
r\sqrt{1+\frac{4I^*}{rK}} & 1 \\
0 & 0 
\end{bmatrix}$$

Valores propios:

$$\lambda_1 = 0, \;\; \lambda_2 = r\sqrt{1+\frac{4I^*}{rK}}$$

Vectores propios:

$$\vec{v_1} = 
\begin{pmatrix}
1 \\
- r\sqrt{1+\frac{4I^*}{rK}}
\end{pmatrix}
\;\;
\vec{v_2} = 
\begin{pmatrix}
1 \\
0
\end{pmatrix}$$

- $(P(t)^*, I(t)^*) = (\frac{K - \sqrt{K^2 + \frac{4KI}{r}} }{2}, I^*):$

$$J = 
\begin{bmatrix}
- (r\sqrt{1+\frac{4I^*}{rK}}) & 1 \\
0 & 0 
\end{bmatrix}$$

Valores propios:

$$\lambda_1 = 0, \;\; \lambda_2 = -r\sqrt{1+\frac{4I^*}{rK}}$$

Vectores propios:

$$\vec{v_1} = 
\begin{pmatrix}
1 \\
 r\sqrt{1+\frac{4I^*}{rK}}
\end{pmatrix}
\;\;
\vec{v_2} = 
\begin{pmatrix}
1 \\
0
\end{pmatrix}$$


"""

# ╔═╡ 602cf17d-7b1f-40a5-a2a4-e891bb6a5560
md"""
#### Análisis
- $(P(t)^*, I(t)^*) = (\frac{K + \sqrt{K^2 + \frac{4KI}{r}} }{2}, I^*):$

$$\lambda_1 = 0, \;\; \lambda_2 = \pm r\sqrt{1+\frac{4I^*}{rK}}$$

Dado que uno de los valores propios es cero, no hay equililibrios isolados

"""

# ╔═╡ 1e867ef2-5480-44b9-b36a-18ac2a79ddd9
md"""
Usando los parametros estimados en la sección siguiente, una aproximación numérica de la derivada $\frac{dI}{dt}$ y apoyándonos en las librerías de Julia, podemos hacer una pequeña visualización de este diagrama de fase


"""

# ╔═╡ 1c8b972b-c360-4dd9-b634-f1b77725174f
migracion = df_poblacion[!, "migración"]

# ╔═╡ 85d4e17f-c268-4f71-929f-37c482c3a873
poblacion = df_poblacion[!, "población"]

# ╔═╡ 8f2f03e2-9989-4230-b711-760c9a437268
html"""
<h4>Implementación del modelo</h4>
"""

# ╔═╡ 6d57a957-0c0d-4695-8c02-204a5ef305bb
# Modelo logístico con migración
function modeloLogistico(du, u, par, t)
  P = u[1]
  r, K = par
  I_t = migracion[Int(round(t))]
  du[1] = r * P * (1 - P / K) + I_t
end

# ╔═╡ ba331eb3-1306-419f-b701-d28dbf909849
md"""
A continuación, declaramos variables para el tiempo, población y migración:
"""

# ╔═╡ 568b05cf-ebfd-44a0-8032-5d823cb20fcf
begin
	t_years = df_poblacion.año
	t0 = minimum(t_years)
	t_data = Int.(t_years .- t0 .+ 1)
	años = t_data
end

# ╔═╡ 57712785-86ed-4ef6-828b-8a33c7a82799
begin
	
	# Calcular I(t) = migrantes(t) * P(t)
	I_data = migracion .* poblacion
	
	# Aproximar dI/dt usando diferencias finitas
	dI_dt = diff(I_data) ./ diff(t_data)
	
	# Interpolación de dI/dt

	itp_mig = LinearInterpolation(t_data[1:end-1], dI_dt, extrapolation_bc=Line())  # Interpolación lineal
	
	# Definir el sistema de EDOs
	function sistema_log(du, u, p, t)
	    P, I = u
	    r, K = p
	    du[1] = r * P * (1 - P / K) + I  # dP/dt
	    du[2] = itp_mig(t)  # dI/dt (usando la interpolación)
	end
	
	# Parámetros del modelo
	# r = 0.061585326110287275 # Tasa de crecimiento
	# K = 8.514304236741986e6
  # Capacidad de carga
	p_mig = [0.061585326110287275, 8.514304236741986e6
]  # Parámetros
	
	# Condiciones iniciales
	P0_mig = poblacion[1]  # Población inicial
	I0_mig = I_data[1]  # Migrantes iniciales
	u0_mig = [P0_mig, I0_mig]
	
	# Rango de tiempo
	tspan_mig = (t_data[1], t_data[end])
	
	# Resolver el sistema
	prob_mig = ODEProblem(sistema_log, u0_mig, tspan_mig, p_mig)
	sol_mig = solve(prob_mig)
	
	# Graficar el diagrama de fase
	plot(sol_mig, vars=(1, 2), xlabel="P(t)", ylabel="I(t)", 
	     title="Diagrama de fase población logístico", label="Trayectoria", linecolor=:blue)

end

# ╔═╡ 82dfc6bb-2c49-4f7f-b0c4-a52df4d51531
# Función de error para optimización
function residuoLogistico(par, pop_obs, tiempo)
  r, K = par
  P0 = pop_obs[1]
  u0 = [P0]
  tspan = (tiempo[1], tiempo[end])
  prob = ODEProblem(modeloLogistico, u0, tspan, par)
  sol = solve(prob, saveat=tiempo)
  pop_model = [sol(t)[1] for t in tiempo]
  res = pop_obs .- pop_model
  return norm(res)
end

# ╔═╡ e6513348-b3da-4a00-acdb-a4b55151576e
md"""
Ajustamos los parámetros:
"""

# ╔═╡ d5be5faf-5ada-471e-bf6a-1ea29c999df6
begin
	# Ajuste de parámetros
	par_inicial_P = [0.02, 10^7]  # Valores iniciales estimados
	opt_P = Optim.optimize(par -> residuoLogistico(par, poblacion, años), par_inicial_P, NelderMead())
	par_est_P = opt_P.minimizer

	r = par_est_P[1]
	K = par_est_P[2]
	println("Parámetros estimados:")
	println("r = ", r)
	println("K = ", K)
end

# ╔═╡ 5a26090b-ec7f-4e9f-a75d-1f5383c55d31
md"""
Resolvemos la EDO con los parámetros encontrados:
"""

# ╔═╡ 34dff0ab-b7f2-43fc-befe-1633485a4589
begin 
	# Resolver la ecuación diferencial con los parámetros óptimos
	P0 = poblacion[1]
	u0_P = [P0]
	tspan_P = (años[1], años[end])
	prob_P = ODEProblem(modeloLogistico, u0_P, tspan_P, par_est_P)
	sol_P = solve(prob_P, saveat=años, reltol=1e-8)
	function P(t)
		return sol_P(t)[1]
	end
	function dP_(t)
		return r * P(t) * (1 - P(t) / K) + migracion[Int64(round(t))]
	end
	# Solución analítica del modelo logístico (falta meter dI/dt)
	function P_logistico(t)
  		return (K * P0 * exp(r * t)) / (K + P0 * (exp(r * t) - 1))
	end
end

# ╔═╡ 8b4a5414-45c6-4e06-b52f-c39708f5cc51
md"""
Podemos graficar el modelo obtenido:
"""

# ╔═╡ 7985babc-fa7f-49bc-a4cc-f46852b818e2
begin
	# Graficar
	plot(años .+ t0, poblacion, label="Población Observada", marker=:o, color=:blue)
	plot!(años .+ t0, [sol_P(t)[1] for t in años], label="Población Modelada", linestyle=:dash, color=:red)
	plot!(años .+ t0, [P_logistico(t) for t in años], label="Solución analítica", linestyle=:dash, color=:green)
	xlabel!("Año")
	ylabel!("Población")
	title!("Ajuste del Modelo Logístico con Migración")
end

# ╔═╡ 10824b06-7872-4695-ba44-45dec2765af8
html"""
<h4>Modelo de población (ecuación compensadora)</h4>
"""

# ╔═╡ aa32a966-ddc0-404f-824f-0e6abeb553ca
md"""
Consideramos el modelo

$$\frac{dP}{dt} = B(t) - M(t) + I(t),$$

donde

$$B(t)=b_0P(t), \quad M(t)=m_0P(t), \quad I(t)=i_0P(t).$$

Para este caso en particular, la solución analítica es:

$$P(t) = P(0) \cdot e^{(b_0-m_0+i_0)t}.$$
"""

# ╔═╡ b414f8e8-7f47-4ac8-9f0d-fd0dde6a20d6
html"""
<h4>Análisis de diagramas de fase</h4>
"""

# ╔═╡ b5ed718c-17c9-4892-b9cd-136dc752600d
md"""
En este caso, como el sistema 1D, el análisis es mucho más sencillo. El sistema puede reducirse como

$$\frac{dP}{dt} = (b_0 - m_0 + i_0)P(t) = f(P)$$

Por lo que el punto fijo es simplemente $P(t)^* = 0$

Para el análisis de estabilidad, derivando obtenemos $f'(P) = b_0 - m_0 + i_0$. Luego:

- Si $(b_0 - m_0 + i_0)<0$ el punto es estable
- Si $(b_0 - m_0 + i_0)>0$  el punto es inestable
"""

# ╔═╡ 7c9ac58b-b519-4e6b-82a1-ca4054e85159
md"""
Usando los parametros estimados en la sección siguiente podemos hacer una pequeña visualización de este diagrama de fase


"""

# ╔═╡ 034dc903-a4fa-4b03-a727-2010e2e5bcaa
begin

	
	# Parámetros del modelo
	b0 = 0.017677145853682758
	m0 = 0.018711228739109045
	i0 = 0.0205127998223295
	r_pc = b0 - m0 + i0  # Parámetro r
	
	# Función que define el sistema
	function dPdt(P, r)
	    return r * P
	end
	# Rango de valores de P para graficar
	P_range = minimum(poblacion):0.1:maximum(poblacion)  
	
	# Calcular dP/dt para cada valor de P
	dP_values = dPdt.(P_range, r_pc)
	
	# Graficar el diagrama de fase
	plt_pc = plot(P_range, dP_values, 
	     xlabel="P(t)", 
	     ylabel="dP/dt", 
	     title="Diagrama de fase: dP/dt = r P(t)", 
	     label="dP/dt", 
	     linewidth=2)
	
	# Agregar una línea horizontal en dP/dt = 0 para indicar el punto fijo
	hline!([0], label="Punto fijo (dP/dt = 0)", linestyle=:dash, linecolor=:red)
	
	# Agregar flechas para indicar la dirección del flujo
	for P in -10:2:10  # Agregar flechas cada 2 unidades
	    dP = dPdt(P, r)
	    quiver!([P], [0], quiver=([0], [dP]), label="", color=:blue)
	end
	
	# Mostrar la gráfica
	display(plt_pc)
end

# ╔═╡ 88b6ab95-398f-4239-b372-1d89d9d20931
html"""
<h4>Implementación del modelo</h4>
"""

# ╔═╡ 572426eb-7a73-4334-8c25-af2400967afc
# Modelo de crecimiento poblacional
function modeloPop(du, u, par, t)
  P = u[1]
  b0, m0, i0 = par
  du[1] = (b0 - m0 + i0) * P
end

# ╔═╡ 0bc0c101-8a9f-4973-95d8-acced03dc3c2
md"""
Implementamos la función para calcular el error:
"""

# ╔═╡ 12646e4a-7551-4f63-9cb8-32db1f122eab
# Función que calcula el residuo (error) entre el modelo y los datos observados
function residuoPop(par, pop_obs, tiempo)
  P0 = pop_obs[1]
  u0 = [P0]
  tspan = (tiempo[1], tiempo[end])
  prob = ODEProblem(modeloPop, u0, tspan, par)
  sol = solve(prob, saveat=tiempo)
  # Extraemos la población modelada en cada instante de tiempo
  pop_model = [sol(t)[1] for t in tiempo]
  res = pop_obs .- pop_model
  return norm(res)
end

# ╔═╡ 22f24035-d7da-4cc9-890b-2c61d52bf64c
# Función a minimizar
rPop(par) = residuoPop(par, poblacion, años)

# ╔═╡ 3e9cff88-8cee-4b25-b24d-9fb429fc7cfd
# Ajuste de parámetros
# Usamos una conjetura inicial para [b0, m0, i0].
# Por ejemplo, dado que en 1980 se tenía:
#   natalidad ≈ 0.0254, mortalidad ≈ 0.0048, migración ≈ 0.0121,
# podríamos iniciar con esos valores.
par_inicial_22 = [0.0254, 0.0048, 0.0121]

# ╔═╡ 032e5837-f60c-412c-838d-28fd78e61add
opt2 = Optim.optimize(rPop, par_inicial_22, NelderMead())

# ╔═╡ de9311f3-03fb-43c5-93ea-49f295a560d8
par_est2 = opt2.minimizer

# ╔═╡ cdcd7e4d-6ce8-4af4-b362-bfb2a05483cc
begin
	println("Parámetros estimados:")
	println("b0 = ", par_est2[1])
	println("m0 = ", par_est2[2])
	println("i0 = ", par_est2[3])
end

# ╔═╡ 4b6664d0-2955-4fe4-ba06-620560e7602a
begin
	# Resolver la ecuación diferencial con los parámetros óptimos
	P0_2 = poblacion[1]
	u0_2 = [P0]
	tspan_2 = (años[1], años[end])
	prob_2 = ODEProblem(modeloPop, u0_2, tspan_2, par_est2)
	sol_2 = solve(prob_2, saveat=años)
end

# ╔═╡ 9dffe7fd-ec96-4f1e-8a6a-a883e973bb9c
begin
	# Graficar
	plot(años, poblacion, label="Población Observada", marker=:o, color=:blue)
	plot!(años, [sol_2(t)[1] for t in años], label="Población Modelada", linestyle=:dash, color=:red)
	xlabel!("Año")
	ylabel!("Población")
	title!("Ajuste del Modelo de Crecimiento Poblacional")
end

# ╔═╡ af490f60-9de6-4d44-a611-7af29c766a0f
html"""
<h4>Modelo intuitivo de territorio</h4>
"""

# ╔═╡ da98c8b9-4902-4221-90ed-5c4dd90a53ac
md"""
Retomando la simplificación del modelo tenemos

$$\frac{dU}{dt} = \bar\alpha\; P(t) - \gamma E(t) + \bar\beta$$

$$\frac{dE}{dt} = -\delta U(t)$$

Donde $\bar\alpha = \alpha + \frac{\beta}{\kappa}$ y $\bar\beta = \beta C_1$ con $C_1$ una constante de integración.

$$\frac{dP}{dt} = \rho P(t) \;( 1- \frac{P(t)}{k_1U(t) - k_2E(t)})$$

con $\rho$ tasa de crecimiento intrínseco y $k_1U(t) + k_2E(t)$ la capacidad de carga que se contribuye por $U(t)$ y se limita por $E(t)$.
"""

# ╔═╡ d402fa78-10e6-4906-97c8-a864439624f5
md"""
Extraemos los datos observados para las variables territoriales:
"""

# ╔═╡ 5283490a-07cc-4117-b40a-7ae2af2ddc15
begin
	U_obs = df_territorio[!, "Huella Urbana"]
	E_obs = df_territorio[!, "Área protegida"]
	D_obs = df_territorio[!, "Area disponible"]
	V_obs = df_territorio[!, "Viviendas (ocupadas)"]
end

# ╔═╡ 7937faec-3fb6-4738-8101-2ef043fb94d7
html"""
<h4>Análisis de diagramas de fase</h4>
"""

# ╔═╡ 551d99ca-b51c-4227-81aa-96a35c5fb6ed
md"""
#### Puntos fijos

Al igualar a cero obtenemos las siguientes puntos fijos:

- Si $P(t) = 0$:

$$U(t) = 0$$

$$P(t) = 0$$

$$E(t) = \frac{\bar\beta}{\gamma}$$

- Si $P(t) \neq 0$:

$$U(t) = 0$$

$$P(t) = k_2E(t) = \frac{k_2\bar\beta}{k_2 \bar\alpha + \gamma}$$

$$E(t) = \frac{\bar\beta}{k_2 \bar\alpha + \gamma}$$
"""

# ╔═╡ efaf86c6-f6ab-45ea-9efc-fc0e7a5049d4
md"""
#### Jacobiano

Para el jacobiano tenemos que:

$$J = 
\begin{bmatrix}
\frac{\partial}{\partial U}(\frac{dU}{dt}) & \frac{\partial}{\partial E}(\frac{dU}{dt}) & \frac{\partial}{\partial P}(\frac{dU}{dt}) \\
\frac{\partial}{\partial U}(\frac{dE}{dt}) & \frac{\partial}{\partial E}(\frac{dE}{dt}) & \frac{\partial}{\partial P}(\frac{dE}{dt}) \\
\frac{\partial}{\partial U}(\frac{dP}{dt}) & \frac{\partial}{\partial E}(\frac{dP}{dt}) & \frac{\partial}{\partial P}(\frac{dP}{dt})
\end{bmatrix}$$

$$J = 
\begin{bmatrix}
0 & -\gamma & \bar\alpha \\
-\gamma & 0 & 0 \\
\frac{\rho k_1 P(t)^2}{K^2} & \frac{-\rho k_2 P(t)^2}{K^2} & \rho - \frac{2\rho P(t)}{K}
\end{bmatrix}$$

Donde $K = k_1U(t) - k_2E(t)$.
"""

# ╔═╡ 972a0170-5ccd-4073-816b-62ec89f6b8d8
md"""
#### Valores y vectores propios

Se debe evaluar el jacobiano en los puntos fijos para posteriormente sacar los valores y vectores propios.

- $(U(t)^*, E(t)^*, P(t)^*) = (0, \frac{\bar\beta}{\gamma}, 0):$

$$J = 
\begin{bmatrix}
0 & -\gamma & \bar\alpha \\
-\gamma & 0 & 0 \\
0 & 0 & \rho
\end{bmatrix}$$

Valores propios:

$$\lambda_1 = \rho, \;\; \lambda_2 = \gamma, \;\; \lambda_3 = -\gamma$$

Vectores propios:

$$\vec{v_1} = 
\begin{pmatrix}
1 \\
- \frac{\gamma}{\rho}\\
\frac{\rho^2 - \gamma^2}{\rho \bar\alpha}
\end{pmatrix}
\;\;
\vec{v_2} = 
\begin{pmatrix}
1 \\
-1\\
0
\end{pmatrix}
\;\;
\vec{v_3} = 
\begin{pmatrix}
1 \\
1 \\
0
\end{pmatrix}$$

- $(U(t)^*, E(t)^*, P(t)^*) = (0, E(t)^*, k_2E(t)^*):$

Dado este punto fijo se tiene $K = -k_2E(t)^* = -P(t)^*$:

$$J = 
\begin{bmatrix}
0 & -\gamma & \bar\alpha \\
-\gamma & 0 & 0 \\
\rho k_1 & -\rho k_2 & 3\rho
\end{bmatrix}$$

Valores propios:

$$\lambda_1 = 3\rho, \;\; \lambda_2 = \sqrt{\gamma ^2 + \bar\alpha\gamma} \;\; \lambda_3 = - \sqrt{\gamma ^2 + \bar\alpha\gamma}$$

Vectores propios:

$$\vec{v_1} = 
\begin{pmatrix}
0\\
0\\
1
\end{pmatrix}
\;\;
\vec{v_2} = 
\begin{pmatrix}
1 \\
-\frac{\gamma}{\sqrt{\gamma ^2 + \bar\alpha\gamma}}\\
\frac{\gamma}{\sqrt{\gamma ^2 + \bar\alpha\gamma}}
\end{pmatrix}
\;\;
\vec{v_3} = 
\begin{pmatrix}
1 \\
\frac{\gamma}{\sqrt{\gamma ^2 + \bar\alpha\gamma}} \\
-\frac{\gamma}{\sqrt{\gamma ^2 + \bar\alpha\gamma}}
\end{pmatrix}$$

"""

# ╔═╡ f3f0002c-ac51-417b-93f8-7525c00be911
md"""
#### Análisis
- $(U(t)^*, E(t)^*, P(t)^*) = (0, \frac{\bar\beta}{\gamma}, 0):$

$$\lambda_1 = \rho, \;\; \lambda_2 = \gamma, \;\; \lambda_3 = -\gamma$$

Dadas las diferentes combinaciones posibles con los signos de $\lambda _1, \; \lambda _2, \; \lambda _3$, se tienen o bien dos valores propios negativos y uno positivo, o dos valores propios positivos y uno negativo. En cualquier caso, el punto en cuestión es un **punto de silla**


- $(U(t)^*, E(t)^*, P(t)^*) = (0, E(t)^*, k_2E(t)^*):$

$$\lambda_1 = 3\rho, \;\; \lambda_2 = \sqrt{\gamma ^2 + \bar\alpha\gamma} \;\; \lambda_3 = - \sqrt{\gamma ^2 + \bar\alpha\gamma}$$

De manera análoga al punto anterior, en todas las combinaciones posibles de signos se obtienen o bien dos valores propios positivos y uno negativo, o bien dos valores negativos y uno positivo. Por tanto, este punto también es un **punto de silla**

"""

# ╔═╡ 793d4505-1222-420c-89df-15f18c87b553
md"""
Usando los parametros estimados en la sección siguiente y apoyándonos en las librerías de Julia, podemos hacer una pequeña visualización de este diagrama de fase


"""

# ╔═╡ 17ccc2ee-ebec-4338-9fa5-afbe6ccf54c8
html"""
<h4>Implementación del modelo</h4>
"""

# ╔═╡ 6e2fc998-b00c-41ba-94ad-e0efe6fa77ef
# --------------------------------------------------
# Modelo de territorio
# Variables del sistema: U(t), E(t), V(t), D(t)
# Parámetros a estimar: par = [α, β, γ, δ, κ, ν]
# Ecuaciones:
#   dU/dt = α * P(t) + β * V(t) - γ * E(t)
#   dE/dt = -δ * U(t)
#   dV/dt = (1/κ) * dP/dt
#   dD/dt = -ν * dU/dt
# --------------------------------------------------
function modeloTerritorio(u, par, t)
  α, β, γ, δ, κ, ν = par
  U, E, V, D = u
  P = sol_P(t)[1]
  dP = dP_(t)
  dU = α * P + β * V - γ * E
  dE = -δ * U
  dV = (1 / κ) * dP
  dD = -ν * dU
  return [dU, dE, dV, dD]
end

# ╔═╡ e6690cd2-05e7-4ffb-8486-d70de5e87717
md"""
Implementamos la función para calcular el error:
"""

# ╔═╡ 61c00ce3-e2ec-4be9-a6c1-fe4f5aaf6505
function residuoTerritorio(par)
  # Condiciones iniciales tomadas de los datos (en t = t_data[1])
  u0 = [U_obs[1], E_obs[1], V_obs[1], D_obs[1]]
  # Asegurarse de que tspan sea una tupla de dos elementos:
  tspan = (t_data[1], t_data[end])
  # Crear el problema ODE, pasando 'par' como parámetros:
  prob = ODEProblem((u, par, t) -> modeloTerritorio(u, par, t),
                    u0, tspan, par)
  # Resolver el problema, guardando la solución en los tiempos definidos en t_data:
  sol = solve(prob, Tsit5(), saveat=t_data)
  # Extraer la solución simulada para cada variable:
  U_sim = [sol[i][1] for i in 1:length(sol)]
  E_sim = [sol[i][2] for i in 1:length(sol)]
  V_sim = [sol[i][3] for i in 1:length(sol)]
  D_sim = [sol[i][4] for i in 1:length(sol)]
  # Suma de errores cuadrados
  error = sum((U_sim .- U_obs).^2) +
          sum((E_sim .- E_obs).^2) +
          sum((V_sim .- V_obs).^2) +
          sum((D_sim .- D_obs).^2)
  return error
end

# ╔═╡ 7d283b58-32f3-4ed9-8464-97c19d103586
md"""
Consideramos los siguientes valores iniciales para los parámetros:
"""

# ╔═╡ 7ee01df6-97cf-4e40-a66e-2a887d657b0a
# [α, β, γ, δ, κ, ν]
# par_inicial = [1e-3, 1e-5, 1e-5, -1e-5, 4.0, 1.0]
par_inicial_3 = [1e-3, 1e-3, 1e-3, -1e-5, 2.0, 1.0]

# ╔═╡ 8da23acd-72f6-4f8a-bd67-39645449d592
begin
	opt_result = Optim.optimize(residuoTerritorio, par_inicial_3, NelderMead())
	par_est = Optim.minimizer(opt_result)

	println(opt_result)
	println("Parámetros territoriales estimados:")
	println("α = ", par_est[1])
	println("β = ", par_est[2])
	println("γ = ", par_est[3])
	println("δ = ", par_est[4])
	println("κ = ", par_est[5])
	println("ν = ", par_est[6])
end

# ╔═╡ 642a589c-4c79-495a-b27a-70b08363f8d1
begin
	u0 = [U_obs[1], E_obs[1], V_obs[1], D_obs[1]]
	tspan = (t_data[1], t_data[end])  # Aseguramos que sea una tupla de 2 elementos
	prob = ODEProblem((u, par, t) -> modeloTerritorio(u, par, t),
	                   u0, tspan, par_est)
	sol = solve(prob, Tsit5(), saveat=t_data)
end

# ╔═╡ 7728dcee-c025-4d37-a2d6-e14e1eeaf571
md"""
Podemos graficar lo obtenido:
"""

# ╔═╡ bdac7231-c2ff-47b8-83ab-e8a5fff54e95
begin
  anim = @animate for i in 1:length(t_data)
    # Definir layout de 4 paneles (uno para cada variable)
    l1 = @layout [a; b; c; d]
    p1 = plot(layout = l1, size=(800, 1200))
    
    # Huella Urbana
    plot!(p1[1], t_data, U_obs, lw=2, linestyle=:dash, label="Huella Urbana (obs)")
    plot!(p1[1], t_data[1:i], [sol[j][1] for j in 1:i], lw=2, label="Huella Urbana (sim)")
    xlabel!(p1[1], "Tiempo (años)")
    ylabel!(p1[1], "Valor de la variable")
    title!(p1[1], "Huella Urbana")
    
    # Área protegida
    plot!(p1[2], t_data, E_obs, lw=2, linestyle=:dash, label="Área protegida (obs)")
    plot!(p1[2], t_data[1:i], [sol[j][2] for j in 1:i], lw=2, label="Área protegida (sim)")
    xlabel!(p1[2], "Tiempo (años)")
    ylabel!(p1[2], "Valor de la variable")
    title!(p1[2], "Área Protegida")
    
    # Viviendas
    plot!(p1[3], t_data, V_obs, lw=2, linestyle=:dash, label="Viviendas (obs)")
    plot!(p1[3], t_data[1:i], [sol[j][3] for j in 1:i], lw=2, label="Viviendas (sim)")
    xlabel!(p1[3], "Tiempo (años)")
    ylabel!(p1[3], "Valor de la variable")
    title!(p1[3], "Viviendas")
    
    # Área disponible
    plot!(p1[4], t_data, D_obs, lw=2, linestyle=:dash, label="Área disponible (obs)")
    plot!(p1[4], t_data[1:i], [sol[j][4] for j in 1:i], lw=2, label="Área disponible (sim)")
    xlabel!(p1[4], "Tiempo (años)")
    ylabel!(p1[4], "Valor de la variable")
    title!(p1[4], "Área Disponible")
  end
  gif(anim, "animacion_observados_simulados.gif", fps=20)
end


# ╔═╡ 27173b13-3025-4d81-9562-e92902d9ecbe
md"""
Notemos que en el anterior modelo consideramos el componente de población aislado del modelo territorial, pues usamos la solución de la ecuación obtenida en el anterior componente. Veamos qué pasa si incorporamos el modelo de población al territorial:
"""

# ╔═╡ cde71548-be8c-4539-a718-69c7a39b339b
begin
	# Datos observados
	P_obs = df_poblacion[!, "población"]
	
	# Condiciones iniciales:
	# u0 = [P(0), U(0), E(0), V(0), D(0)]
	u0_D = [P_obs[1], U_obs[1], E_obs[1], V_obs[1], D_obs[1]]
	
	# --------------------------------------------------
	# Modelo: población y territorio
	# Estado: u = [P, U, E, V, D]
	# Parámetros: par = [r, K, α, β, γ, δ, κ, ν]
	#   - Población: dP/dt = r * P * (1 - P/K)
	#   - Huella Urbana: dU/dt = α * P + β * V - γ * E
	#   - Área Protegida: dE/dt = -δ * U
	#   - Viviendas: dV/dt = (1/κ) * dP/dt
	#   - Área Disponible: dD/dt = -ν * dU/dt
	# --------------------------------------------------
	function modeloCompleto(u, par, t)
	  r, K, α, β, γ, δ, κ, ν = par
	  P = u[1]
	  U = u[2]
	  E = u[3]
	  V = u[4]
	  D = u[5]
	  
	  dP = r * P * (1 - P / K)
	  dU = α * P + β * V - γ * E
	  dE = -δ * U
	  dV = (1 / κ) * dP
	  dD = -ν * dU
	  
	  return [dP, dU, dE, dV, dD]
	end
end

# ╔═╡ 0b8fe699-b513-4fa9-9fce-615468f6abaa
begin

	
	# Definir el sistema de ecuaciones
	function modelo_intuitivo(u, p, t)
	    # Parámetros


		α, β, γ, δ, κ, ν, ρ, k1, k2, C1   = [-0.00018954163479880512, 
		0.001211966263261876,
		0.019042918813165898,
		-0.0039867402564575626,
		2.6759783795361796,
		0.712744354419162, 0.00018954163479880512, 0.019042918813165898, 0.0290329188147231, 1 ]
	    # Variables del sistema
	    U, E, P = u
	
	    # Definir α_bar y β_bar
	    α_bar = α + β / κ
	    β_bar = β * C1
	
	    # Ecuaciones diferenciales
	    dU = α_bar * P - γ * E + β_bar  # dU/dt
	    dE = -δ * U                     # dE/dt
	    dP = ρ * P * (1 - P / (k1 * U - k2 * E))  # dP/dt
		return [dU, dE, dP]
	end
	
	# Condiciones iniciales y rango de tiempo
	u0_intuitivo = [U_obs[1], E_obs[1], P_obs[1]]
	tspan_intuitivo = (t_data[1], t_data[end])
	
	# Resolver el sistema
	prob_int = ODEProblem(modelo_intuitivo, u0_intuitivo, tspan_intuitivo)
	sol_int = solve(prob_int)
	
	# Graficar en 3D
	plot(sol_int, vars=(1, 2, 3), xlabel="U(t)", ylabel="E(t)", zlabel="P(t)", title="Diagrama de fase Modelo Intuitivo", legend=false)
end

# ╔═╡ c9b515c9-777f-4d0a-9dee-9e9881393e2b
md"""
Función para calcular el error:
"""

# ╔═╡ 7f616003-377d-400e-bc6a-79d74fd36e11
# --------------------------------------------------
# Función de error para la optimización del modelo
# --------------------------------------------------
function residuoCompleto(par_D)
  tspan = (t_data[1], t_data[end])
  prob = ODEProblem((u, par, t) -> modeloCompleto(u, par, t),
                    u0_D, tspan, par_D)
  sol = solve(prob, Tsit5(), saveat=t_data)
  
  P_sim = [sol[i][1] for i in 1:length(sol)]
  U_sim = [sol[i][2] for i in 1:length(sol)]
  E_sim = [sol[i][3] for i in 1:length(sol)]
  V_sim = [sol[i][4] for i in 1:length(sol)]
  D_sim = [sol[i][5] for i in 1:length(sol)]
  
  error = sum((P_sim .- P_obs).^2) +
          sum((U_sim .- U_obs).^2) +
          sum((E_sim .- E_obs).^2) +
          sum((V_sim .- V_obs).^2) +
          sum((D_sim .- D_obs).^2)
  return error
end

# ╔═╡ 42678b26-0334-4b1d-962d-3895a2625132
md"""
Consideramos los siguientes valores iniciales:
"""

# ╔═╡ 90c249a7-38e6-4c71-a90a-b3437332e114
# --------------------------------------------------
# Estimación inicial de parámetros
# par = [r, K, α, β, γ, δ, κ, ν]
# Usamos los parámetros calibrados para la población y estimaciones para los territoriales
# --------------------------------------------------
par_inicial_D = [0.02, 1e7, 1e-5, 1e-5, 1e-5, 1e-5, 4.0, 1e-5]

# ╔═╡ adfdcc27-f634-4592-865c-1914a1bfcc4c
begin
# Optimización con el método Nelder-Mead
opt_result_D = Optim.optimize(residuoCompleto, par_inicial_D, NelderMead())
par_est_D = Optim.minimizer(opt_result_D)

println(opt_result_D)
println("Parámetros estimados:")
println("r  = ", par_est_D[1])
println("K  = ", par_est_D[2])
println("α  = ", par_est_D[3])
println("β  = ", par_est_D[4])
println("γ  = ", par_est_D[5])
println("δ  = ", par_est_D[6])
println("κ  = ", par_est_D[7])
println("ν  = ", par_est_D[8])
end

# ╔═╡ 4dd8b483-622c-403e-8b90-318fb3824879
md"""
Y resolvemos el sistema con los parámetros:
"""

# ╔═╡ ea3a24df-c13c-4c5c-b0ab-e8ee145fbfd2
# --------------------------------------------------
# Resolver el sistema ODE del modelo
# --------------------------------------------------
begin
prob_D = ODEProblem((u, par, t) -> modeloCompleto(u, par, t),
                    u0_D, tspan, par_est_D)
sol_D = solve(prob_D, Tsit5(), saveat=t_data)
end

# ╔═╡ 267f5483-a347-459b-8701-96bdb02f3ee9
begin
	anim1 = @animate for i in 1:length(t_data)
	l1 = @layout [a; b; c; d; e]
	p1 = plot(layout = l1, size=(1000,1400))
	
	# Población
	plot!(p1[1], t_data .+ t0, P_obs, lw=2, linestyle=:dash, label="Población (obs)")
	plot!(p1[1], t_data[1:i] .+ t0, [sol_D[j][1] for j in 1:i], lw=2, label="Población (sim)")
	xlabel!(p1[1], "Tiempo (años)")
	ylabel!(p1[1], "Número de personas")
	title!(p1[1], "Población")
	
	# Huella Urbana
	plot!(p1[2], t_data .+ t0, U_obs, lw=2, linestyle=:dash, label="Huella Urbana (obs)")
	plot!(p1[2], t_data[1:i] .+ t0, [sol_D[j][2] for j in 1:i], lw=2, label="Huella Urbana (sim)")
	xlabel!(p1[2], "Tiempo (años)")
	ylabel!(p1[2], "Hectáreas")
	title!(p1[2], "Huella Urbana")
	
	# Área Protegida
	plot!(p1[3], t_data .+ t0, E_obs, lw=2, linestyle=:dash, label="Área Protegida (obs)")
	plot!(p1[3], t_data[1:i] .+ t0, [sol_D[j][3] for j in 1:i], lw=2, label="Área Protegida (sim)")
	xlabel!(p1[3], "Tiempo (años)")
	ylabel!(p1[3], "Hectáreas")
	title!(p1[3], "Área Protegida")
	
	# Viviendas (ocupadas)
	plot!(p1[4], t_data .+ t0, V_obs, lw=2, linestyle=:dash, label="Viviendas (obs)")
	plot!(p1[4], t_data[1:i] .+ t0, [sol_D[j][4] for j in 1:i], lw=2, label="Viviendas (sim)")
	xlabel!(p1[4], "Tiempo (años)")
	ylabel!(p1[4], "Número de viviendas")
	title!(p1[4], "Viviendas Ocupadas")
	
	# Área Disponible
	plot!(p1[5], t_data .+ t0, D_obs, lw=2, linestyle=:dash, label="Área Disponible (obs)")
	plot!(p1[5], t_data[1:i] .+ t0, [sol_D[j][5] for j in 1:i], lw=2, label="Área Disponible (sim)")
	xlabel!(p1[5], "Tiempo (años)")
	ylabel!(p1[5], "Hectáreas")
	title!(p1[5], "Área Disponible")
	end
	gif(anim, "animacion_variables.gif", fps=20)
end

# ╔═╡ 90abe302-556a-4571-b1bc-5a8b2a283f10
html"""
<h4>Modelo SIR de territorio</h4>
"""

# ╔═╡ 08e74abb-b535-45c7-a30c-cfbef145cb1f
md"""
El modelo simplificado que se tiene es

$$\frac{dD}{dt} = -\alpha D(t)N(t)$$

$$\frac{dN}{dt} = \alpha D(t)N(t) - \gamma N(t)$$
"""

# ╔═╡ 26c62ab8-f189-4817-a9ca-3c2547d517ee
html"""
<h4>Análisis de diagramas de fase</h4>
"""

# ╔═╡ 0ab22288-b241-4213-9583-3066aa870eb4
md"""
#### Puntos fijos

Al igualar a cero obtenemos el siguiente punto fijo:

$$N(t) = 0$$

$$D(t) = D$$

El este caso, tomamos a $D(t)$ como una constante
"""

# ╔═╡ a86bd973-41de-4a60-a78d-cb38a48dbe2b
md"""
#### Jacobiano

Para el jacobiano tenemos que:

$$J = 
\begin{bmatrix}
\frac{\partial}{\partial N}(\frac{dN}{dt}) & \frac{\partial}{\partial D}(\frac{dN}{dt}) \\
\frac{\partial}{\partial N}(\frac{dD}{dt}) & \frac{\partial}{\partial D}(\frac{dD}{dt})
\end{bmatrix}$$

$$J = 
\begin{bmatrix}
\alpha D(t) - \gamma & \alpha N(t)\\
-\alpha D(t) & - \alpha N(t) 
\end{bmatrix}$$
"""

# ╔═╡ 3020fde9-79ea-4e64-8bd4-fd9951e5d869
md"""
#### Valores y vectores propios
Se debe evaluar el jacobiano en el punto fijo para posteriormente sacar los valores y vectores propios.

- $(N(t)^*, D(t)^*) = (0, D):$

$$J = 
\begin{bmatrix}
\alpha D - \gamma & 0 \\
-\alpha D & 0
\end{bmatrix}$$

Valores propios:

$$\lambda_1 = \alpha - \gamma , \;\; \lambda_2 = 0$$

Vectores propios:

$$\vec{v_1} = 
\begin{pmatrix}
1 \\
- \frac{\alpha D}{\alpha D - \gamma }
\end{pmatrix}
\;\;
\vec{v_2} = 
\begin{pmatrix}
0 \\
1
\end{pmatrix}$$
"""

# ╔═╡ 23e13275-6161-4cd2-9db7-640bb3f2f2d7
md"""
#### Análisis

- $(N(t)^*, D(t)^*) = (0, D):$

$$\lambda_1 = \alpha - \gamma , \;\; \lambda_2 = 0$$

Dado que uno de los valores propios es cero, no hay equililibrios isolados
"""

# ╔═╡ 9ce52baf-59fd-4ff5-a813-b10b3c2e97df
md"""
Usando los parametros estimados en la sección siguiente y apoyándonos en las librerías de Julia, podemos hacer una pequeña visualización de este diagrama de fase


"""

# ╔═╡ 3dc31262-5060-482e-ac8d-96a63d5daf90
begin

	function modeloSIR_params(u, par, t)
	    D, N= u
	    α, γ = [0.0000001, 0.02]
	    dD = -α * D * N  # dD/dt
	    dN = α * D * N  - γ * N          # dN/dt
		return [dD, dN]

	end

	dUdT = (U_obs[2] - U_obs[1]) / (t_data[2] - t_data[1])

	u0_sir = [U_obs[1], dUdT/0.02]
	
	tspan_sir = (t_data[1], t_data[end])

	
	prob_sir = ODEProblem(modeloSIR_params, u0_sir, tspan_sir)
	sol_sir = solve(prob_sir)
	
	# Graficar
	plot(sol_sir, vars=(1, 2), xlabel="D(t)", ylabel="N(t)", title="Diagrama de fase territorio SIR", legend=false)
end

# ╔═╡ 1f84fe46-40f6-4ce3-ab97-eda399afaebe
html"""
<h4>Implementación del modelo</h4>
"""

# ╔═╡ c3355b2a-e708-4278-bf53-469a24a3a05e
md"""
Como se mencionó anteriormente, dada la imposibilidad de encontrar datos para el suelo en desarrollo, se consideró la siguiente reescritura:

$$\frac{dD}{dt} = -\frac{\alpha}{\gamma}D(t) \frac{dU}{dt}$$

$$\frac{d^2U}{dt^2} = (\alpha D(t) - \gamma) \frac{dU}{dt}$$

"""

# ╔═╡ 5070459f-1156-4bb6-92dd-1bd524ecc1e8
begin
	function modelo!(u, p, t)
	    D, U, dudt = u
	    α, γ = p
	    dD = -α/γ * D * dudt  # dD/dt
	    dU = dudt             # dU/dt
	    dUdT = (α * D - γ) * dudt  # d²U/dt²
		return [dD, dU, dUdT]
	end
end

# ╔═╡ 298d2b81-9fcf-4d42-9c3e-290962ca42a6
begin
	
	# Función para resolver el modelo y calcular el error
	function error_sir(params)
	    α, γ = params
		dU0 = (U_obs[2] - U_obs[1]) / (t_data[2] - t_data[1])  # Aproximación de dU/dt en t=0
	    u0 = [D_obs[1], U_obs[1], dU0]
	    p = (α, γ)
	    tspan = (t_data[1], t_data[end])
		
	    prob = ODEProblem((u, par, t) -> modelo!(u, par, t), u0, tspan, p)

		
		# Resolver el modelo en los puntos de tiempo de los datos
	    sol = solve(prob, saveat=t_data) 
	        # Extraer las predicciones del modelo
	    D_pred = [u[2] for u in sol.u]  # Predicciones de D(t)
    	U_pred = [u[1] for u in sol.u]  # Predicciones de U(t)
		
	    # Calcular el error cuadrático medio
	    error_D = sum((D_pred .- D_obs).^2)  # Error en D(t)
	    error_U = sum((U_pred .- U_obs).^2)  # Error en U(t)
	
	    # Error total (suma de errores cuadrados)
	    error_total = error_D + error_U
		
	    return error_total

	end
		
end

# ╔═╡ eca0ce08-0094-480b-9c89-1964f56d0430
begin
	par_inicial_sir = [0.1, 0.05]  # [α, γ]
	lower_bounds = [0.0, 0.0]   # Límites inferiores para α y γ
	upper_bounds = [Inf, Inf]  # Límites superiores para α y γ
	opt_result_sir = Optim.optimize(error_sir, lower_bounds, upper_bounds, par_inicial_sir, NelderMead())
	par_est_sir = Optim.minimizer(opt_result_sir)

	println(opt_result_sir)
	println("Parámetros territoriales estimados:")
	println("α = ", par_est_sir[1])
	println("γ = ", par_est_sir[2])

end


# ╔═╡ 06519699-0193-4f27-9424-a561c2a35208
begin
	# --------------------------------------------------
	# Resolución del sistema territorial con parámetros estimados
	# --------------------------------------------------

	function sir_estimado(p)
		dU0 = (U_obs[2] - U_obs[1]) / (t_data[2] - t_data[1])  # Aproximación de dU/dt en t=0
	    u0 = [D_obs[1], U_obs[1], dU0]
	    tspan = (t_data[1], t_data[end])
	    prob = ODEProblem(modelo!, u0, tspan, p)
		
		# Resolver el modelo en los puntos de tiempo de los datos
	    sol = solve(prob, saveat=t_data) 
	        # Extraer las predicciones del modelo
	    D_pred = sol[1, :]  # Predicciones de D(t)
	    U_pred = sol[2, :]  # Predicciones de U(t)
		return D_pred, U_pred
	end
end

# ╔═╡ b2d0f888-e004-4986-96f6-f4284ae13e73
begin
	# --------------------------------------------------
	# Graficar resultados (observados vs simulados)
	# --------------------------------------------------
	
	function graficar_sir(params)
		D_sim, U_sim = sir_estimado(params)
		println("Tamaño de D_sim: ", length(D_sim))
		println("D_sim: ", D_sim)
	    println("U_sim: ", U_sim)
	    println("Tamaño de U_sim: ", length(U_sim))
		plt_sir = plot(t_data, U_obs, lw=2, linestyle=:dash, label="Huella Urbana (obs)")
		plot!(plt_sir, t_data, D_obs, lw=2, linestyle=:dash, label="Área disponible (obs)")
		
		plot!(plt_sir, t_data, U_sim, lw=2, label="Huella Urbana (sim)")
		plot!(plt_sir, t_data, D_sim, lw=2, label="Área disponible (sim)")
		xlabel!("Tiempo (años)")
		ylabel!("Valor de la variable")
		title!("Comparación: Datos observados vs. Simulación del modelo territorial")
	end
end

# ╔═╡ 981d8630-1009-46c5-8d18-15cf83182d29
graficar_sir(par_est_sir)

# ╔═╡ d759d211-ca6d-440b-95e3-98deaa575e15
md"""No obstante, este enfoque presentó problemas a la hora de buscar los parametros correctos. En particular, vemos como en la gráfica las curvas no ajustan bien para los datos observados. Los parámetros encontrados por el optimizador son

$$\alpha = 1.93 \cdot 10^8 \; \gamma = 6.91 \cdot 10^8$$

A pesar de los esfuerzos infructuosos por una búsqueda acertada por medio del optimizador, se halló la siguiente aproximación de forma manual. Aproximación mucho más acertada usando los parametros

$$\alpha = 2 \cdot 10^{-7} \; \gamma = 0.0365$$
"""

# ╔═╡ 60b65057-c281-4506-be6d-872c8ea1f815
graficar_sir([0.0000002, 0.0365])

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DifferentialEquations = "0c46a032-eb83-5123-abaf-570d42b7fbaa"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
Interpolations = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Optim = "429524aa-4258-5aef-a3af-852621145aeb"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"

[compat]
CSV = "~0.10.15"
DataFrames = "~1.7.0"
DifferentialEquations = "~7.13.0"
Images = "~0.26.1"
Interpolations = "~0.15.1"
Optim = "~1.10.0"
Plots = "~1.40.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.1"
manifest_format = "2.0"
project_hash = "b8680a7fdcb1bb806329b237407f83e1e2476eff"

[[deps.ADTypes]]
git-tree-sha1 = "016833eb52ba2d6bea9fcb50ca295980e728ee24"
uuid = "47edcb42-4c32-4615-8424-f2b9edc5f35b"
version = "0.2.7"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "InverseFunctions", "LinearAlgebra", "MacroTools", "Markdown"]
git-tree-sha1 = "b392ede862e506d451fc1616e79aa6f4c673dab8"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.38"

    [deps.Accessors.extensions]
    AccessorsAxisKeysExt = "AxisKeys"
    AccessorsDatesExt = "Dates"
    AccessorsIntervalSetsExt = "IntervalSets"
    AccessorsStaticArraysExt = "StaticArrays"
    AccessorsStructArraysExt = "StructArrays"
    AccessorsTestExt = "Test"
    AccessorsUnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    Requires = "ae029012-a4dd-5104-9daa-d747884805df"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "50c3c56a52972d78e8be9fd135bfb91c9574c140"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.1.1"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "d57bd3762d308bded22c3b82d033bff85f6195c6"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.4.0"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra"]
git-tree-sha1 = "d60a1922358aa203019b7857a2c8c37329b8736c"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.17.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceCUDSSExt = "CUDSS"
    ArrayInterfaceChainRulesCoreExt = "ChainRulesCore"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceSparseArraysExt = "SparseArrays"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    CUDSS = "45b445bb-4962-46a0-9369-b4df9d0f772e"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra"]
git-tree-sha1 = "492681bc44fac86804706ddb37da10880a2bd528"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "1.10.4"
weakdeps = ["SparseArrays"]

    [deps.ArrayLayouts.extensions]
    ArrayLayoutsSparseArraysExt = "SparseArrays"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.BandedMatrices]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "PrecompileTools"]
git-tree-sha1 = "a2c85f53ddcb15b4099da59867868bd40f005579"
uuid = "aae01518-5342-5314-be14-df237901396f"
version = "1.7.5"
weakdeps = ["SparseArrays"]

    [deps.BandedMatrices.extensions]
    BandedMatricesSparseArraysExt = "SparseArrays"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "f21cfd4950cb9f0587d5067e69405ad2acd27b87"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.6"

[[deps.BoundaryValueDiffEq]]
deps = ["ADTypes", "Adapt", "ArrayInterface", "BandedMatrices", "ConcreteStructs", "DiffEqBase", "FastAlmostBandedMatrices", "ForwardDiff", "LinearAlgebra", "LinearSolve", "NonlinearSolve", "PreallocationTools", "PrecompileTools", "Preferences", "RecursiveArrayTools", "Reexport", "SciMLBase", "Setfield", "SparseArrays", "SparseDiffTools", "Tricks", "TruncatedStacktraces", "UnPack"]
git-tree-sha1 = "3ff968887be48760b0e9e8650c2d05c96cdea9d8"
uuid = "764a87c0-6b3e-53db-9096-fe964310641d"
version = "5.6.3"

    [deps.BoundaryValueDiffEq.extensions]
    BoundaryValueDiffEqODEInterfaceExt = "ODEInterface"
    BoundaryValueDiffEqOrdinaryDiffEqExt = "OrdinaryDiffEq"

    [deps.BoundaryValueDiffEq.weakdeps]
    ODEInterface = "54ca160b-1b9f-5127-a996-1867f4bc2a2c"
    OrdinaryDiffEq = "1dea7af3-3e70-54e6-95c3-0bf5283fa5ed"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "8873e196c2eb87962a2048b3b8e08946535864a1"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+2"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CPUSummary]]
deps = ["CpuId", "IfElse", "PrecompileTools", "Static"]
git-tree-sha1 = "5a97e67919535d6841172016c9530fd69494e5ec"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.2.6"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "deddd8725e5e1cc49ee205a1964256043720a6c3"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.15"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "009060c9a6168704143100f36ab08f06c2af4642"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.2+1"

[[deps.CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "3e4b134270b372f2ed4d4d0e936aabaefc1802bc"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CloseOpenIntervals]]
deps = ["Static", "StaticArrayInterface"]
git-tree-sha1 = "05ba0d07cd4fd8b7a39541e31a7b0254704ea581"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.13"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "Random", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "9ebb045901e9bbf58767a9f34ff89831ed711aae"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.15.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "c785dfb1b3bfddd1da557e861b919819b82bbe5b"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.27.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.ConcreteStructs]]
git-tree-sha1 = "f749037478283d372048690eb3b5f92a79432b34"
uuid = "2569d6c7-a4a2-43d3-a901-331e8e4be471"
version = "0.2.3"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "f9d7112bfff8a19a3a4ea4e03a8e6a91fe8456bf"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.3"

[[deps.CpuId]]
deps = ["Markdown"]
git-tree-sha1 = "fcbb72b032692610bfbdb15018ac16a36cf2e406"
uuid = "adafc99b-e345-5852-983c-f28acb93d879"
version = "0.3.1"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "fb61b4812c49343d7ef0b533ba982c46021938a6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.7.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fc173b380865f70627d7dd1190dc2fce6cc105af"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.14.10+0"

[[deps.DelayDiffEq]]
deps = ["ArrayInterface", "DataStructures", "DiffEqBase", "LinearAlgebra", "Logging", "OrdinaryDiffEq", "Printf", "RecursiveArrayTools", "Reexport", "SciMLBase", "SimpleNonlinearSolve", "SimpleUnPack"]
git-tree-sha1 = "dd3dfeca90deb4b38be9598d7c51cd558816e596"
uuid = "bcd4f6db-9728-5f36-b5f7-82caef46ccdb"
version = "5.45.1"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DiffEqBase]]
deps = ["ArrayInterface", "DataStructures", "DocStringExtensions", "EnumX", "EnzymeCore", "FastBroadcast", "ForwardDiff", "FunctionWrappers", "FunctionWrappersWrappers", "LinearAlgebra", "Logging", "Markdown", "MuladdMacro", "Parameters", "PreallocationTools", "PrecompileTools", "Printf", "RecursiveArrayTools", "Reexport", "SciMLBase", "SciMLOperators", "Setfield", "SparseArrays", "Static", "StaticArraysCore", "Statistics", "Tricks", "TruncatedStacktraces"]
git-tree-sha1 = "044648af911974c3928058c1f8c83f159dece274"
uuid = "2b5f629d-d688-5b77-993f-72d75c75574e"
version = "6.145.6"

    [deps.DiffEqBase.extensions]
    DiffEqBaseChainRulesCoreExt = "ChainRulesCore"
    DiffEqBaseDistributionsExt = "Distributions"
    DiffEqBaseEnzymeExt = ["ChainRulesCore", "Enzyme"]
    DiffEqBaseGeneralizedGeneratedExt = "GeneralizedGenerated"
    DiffEqBaseMPIExt = "MPI"
    DiffEqBaseMeasurementsExt = "Measurements"
    DiffEqBaseMonteCarloMeasurementsExt = "MonteCarloMeasurements"
    DiffEqBaseReverseDiffExt = "ReverseDiff"
    DiffEqBaseTrackerExt = "Tracker"
    DiffEqBaseUnitfulExt = "Unitful"

    [deps.DiffEqBase.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"
    GeneralizedGenerated = "6b9d7cbe-bcb9-11e9-073f-15a7a543e2eb"
    MPI = "da04e1cc-30fd-572f-bb4f-1f8673147195"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    MonteCarloMeasurements = "0987c9cc-fe09-11e8-30f0-b96dd679fdca"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.DiffEqCallbacks]]
deps = ["DataStructures", "DiffEqBase", "ForwardDiff", "Functors", "LinearAlgebra", "Markdown", "NLsolve", "Parameters", "RecipesBase", "RecursiveArrayTools", "SciMLBase", "StaticArraysCore"]
git-tree-sha1 = "cf334da651a6e42c50e1477d6ab978f1b8be3057"
uuid = "459566f4-90b8-5000-8ac3-15dfb0a30def"
version = "2.36.1"
weakdeps = ["OrdinaryDiffEq", "Sundials"]

[[deps.DiffEqNoiseProcess]]
deps = ["DiffEqBase", "Distributions", "GPUArraysCore", "LinearAlgebra", "Markdown", "Optim", "PoissonRandom", "QuadGK", "Random", "Random123", "RandomNumbers", "RecipesBase", "RecursiveArrayTools", "ResettableStacks", "SciMLBase", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "ab1e6515ce15f01316a9825b02729fefa51726bd"
uuid = "77a26b50-5914-5dd7-bc55-306e6241c503"
version = "5.23.0"

    [deps.DiffEqNoiseProcess.extensions]
    DiffEqNoiseProcessReverseDiffExt = "ReverseDiff"

    [deps.DiffEqNoiseProcess.weakdeps]
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.DifferentialEquations]]
deps = ["BoundaryValueDiffEq", "DelayDiffEq", "DiffEqBase", "DiffEqCallbacks", "DiffEqNoiseProcess", "JumpProcesses", "LinearAlgebra", "LinearSolve", "NonlinearSolve", "OrdinaryDiffEq", "Random", "RecursiveArrayTools", "Reexport", "SciMLBase", "SteadyStateDiffEq", "StochasticDiffEq", "Sundials"]
git-tree-sha1 = "81042254a307980b8ab5b67033aca26c2e157ebb"
uuid = "0c46a032-eb83-5123-abaf-570d42b7fbaa"
version = "7.13.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "c7e3a542b999843086e2f29dac96a618c105be1d"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.12"
weakdeps = ["ChainRulesCore", "SparseArrays"]

    [deps.Distances.extensions]
    DistancesChainRulesCoreExt = "ChainRulesCore"
    DistancesSparseArraysExt = "SparseArrays"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "3101c32aab536e7a27b1763c0797dba151b899ad"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.113"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.EnzymeCore]]
git-tree-sha1 = "1bc328eec34ffd80357f84a84bb30e4374e9bd60"
uuid = "f151be2c-9106-41f4-ab19-57ee4f262869"
version = "0.6.6"
weakdeps = ["Adapt"]

    [deps.EnzymeCore.extensions]
    AdaptExt = "Adapt"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8e9441ee83492030ace98f9789a654a6d0b1f643"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc5231d52eb1771251fbd37171dbc408bcc8a1b6"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.4+0"

[[deps.ExponentialUtilities]]
deps = ["Adapt", "ArrayInterface", "GPUArraysCore", "GenericSchur", "LinearAlgebra", "PrecompileTools", "Printf", "SparseArrays", "libblastrampoline_jll"]
git-tree-sha1 = "8e18940a5ba7f4ddb41fe2b79b6acaac50880a86"
uuid = "d4d017d3-3776-5f7e-afef-a10c40355c18"
version = "1.26.1"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

[[deps.Expronicon]]
deps = ["MLStyle", "Pkg", "TOML"]
git-tree-sha1 = "fc3951d4d398b5515f91d7fe5d45fc31dccb3c9b"
uuid = "6b7a57c9-7cc1-4fdf-b7f5-e857abae3636"
version = "0.8.5"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "53ebe7511fa11d33bec688a9178fac4e49eeee00"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.2"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[deps.FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "cbdf14d1e8c7c8aacbe8b19862e0179fd08321c2"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "4820348781ae578893311153d69049a93d05f39d"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.8.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FastAlmostBandedMatrices]]
deps = ["ArrayInterface", "ArrayLayouts", "BandedMatrices", "ConcreteStructs", "LazyArrays", "LinearAlgebra", "MatrixFactorizations", "PrecompileTools", "Reexport"]
git-tree-sha1 = "3f03d94c71126b6cfe20d3cbcc41c5cd27e1c419"
uuid = "9d29842c-ecb8-4973-b1e9-a27b1157504e"
version = "0.1.4"

[[deps.FastBroadcast]]
deps = ["ArrayInterface", "LinearAlgebra", "Polyester", "Static", "StaticArrayInterface", "StrideArraysCore"]
git-tree-sha1 = "a6e756a880fc419c8b41592010aebe6a5ce09136"
uuid = "7034ab61-46d4-4ed7-9d0f-46aef9175898"
version = "0.2.8"

[[deps.FastClosures]]
git-tree-sha1 = "acebe244d53ee1b461970f8910c235b259e772ef"
uuid = "9aa1b823-49e4-5ca5-8b0f-3971ec8bab6a"
version = "0.3.2"

[[deps.FastLapackInterface]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "cbf5edddb61a43669710cbc2241bc08b36d9e660"
uuid = "29a986be-02c6-4525-aec4-84b980013641"
version = "2.0.4"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "82d8afa92ecf4b52d78d869f038ebfb881267322"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.3"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "7878ff7172a8e6beedd1dea14bd27c3c6340d361"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.22"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FiniteDiff]]
deps = ["ArrayInterface", "LinearAlgebra", "Setfield"]
git-tree-sha1 = "b10bdafd1647f57ace3885143936749d61638c3b"
uuid = "6a86dc24-6348-571c-b903-95158fe2bd41"
version = "2.26.0"

    [deps.FiniteDiff.extensions]
    FiniteDiffBandedMatricesExt = "BandedMatrices"
    FiniteDiffBlockBandedMatricesExt = "BlockBandedMatrices"
    FiniteDiffSparseArraysExt = "SparseArrays"
    FiniteDiffStaticArraysExt = "StaticArrays"

    [deps.FiniteDiff.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "db16beca600632c95fc8aca29890d83788dd8b23"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.96+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "a2df1b776752e3f344e5116c06d75a10436ab853"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.38"
weakdeps = ["StaticArrays"]

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "5c1d8ae0efc6c2e7b1fc502cbe25def8f661b7bc"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.2+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1ed150b39aebcc805c26b93a8d0122c940f64ce2"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.14+0"

[[deps.FunctionWrappers]]
git-tree-sha1 = "d62485945ce5ae9c0c48f124a84998d755bae00e"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.3"

[[deps.FunctionWrappersWrappers]]
deps = ["FunctionWrappers"]
git-tree-sha1 = "b104d487b34566608f8b4e1c39fb0b10aa279ff8"
uuid = "77dc65aa-8811-40c2-897b-53d922fa7daf"
version = "0.1.3"

[[deps.Functors]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "64d8e93700c7a3f28f717d265382d52fac9fa1c1"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.4.12"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "532f9126ad901533af1d4f5c198867227a7bb077"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.0+1"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "ec632f177c0d990e64d955ccc1b8c04c485a0950"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.6"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "8e2d86e06ceb4580110d9e716be26658effc5bfd"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.72.8"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "da121cbdc95b065da07fbb93638367737969693f"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.72.8+0"

[[deps.GenericSchur]]
deps = ["LinearAlgebra", "Printf"]
git-tree-sha1 = "af49a0851f8113fcfae2ef5027c6d49d0acec39b"
uuid = "c145ed77-6b09-5dd9-b285-bf645a82121e"
version = "0.5.4"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "43ba3d3c82c18d88471cfd2924931658838c9d8f"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+4"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "674ff0db93fffcd11a3573986e550d66cd4fd71f"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.80.5+0"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "1dc470db8b1131cfc7fb4c115de89fe391b9e780"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.12.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "1336e07ba2eb75614c99496501a8f4b233e9fafe"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.10"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "401e4f3f30f43af2c8478fc008da50096ea5240f"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.3.1+0"

[[deps.HistogramThresholding]]
deps = ["ImageBase", "LinearAlgebra", "MappedArrays"]
git-tree-sha1 = "7194dfbb2f8d945abdaf68fa9480a965d6661e69"
uuid = "2c695a8d-9458-5d45-9878-1b8a99cf7853"
version = "0.3.1"

[[deps.HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "8e070b599339d622e9a081d17230d74a5c473293"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.17"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "b1c2585431c382e3fe5805874bda6aea90a95de9"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.25"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "2e4520d67b0cef90865b3ef727594d2a58e0e1f8"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.11"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageBinarization]]
deps = ["HistogramThresholding", "ImageCore", "LinearAlgebra", "Polynomials", "Reexport", "Statistics"]
git-tree-sha1 = "f5356e7203c4a9954962e3757c08033f2efe578a"
uuid = "cbc4b850-ae4b-5111-9e64-df94c024a13d"
version = "0.3.0"

[[deps.ImageContrastAdjustment]]
deps = ["ImageBase", "ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "eb3d4365a10e3f3ecb3b115e9d12db131d28a386"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.12"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "b2a7eaa169c13f5bcae8131a83bc30eff8f71be0"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.2"

[[deps.ImageCorners]]
deps = ["ImageCore", "ImageFiltering", "PrecompileTools", "StaticArrays", "StatsBase"]
git-tree-sha1 = "24c52de051293745a9bad7d73497708954562b79"
uuid = "89d5987c-236e-4e32-acd0-25bd6bd87b70"
version = "0.1.3"

[[deps.ImageDistances]]
deps = ["Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "08b0e6354b21ef5dd5e49026028e41831401aca8"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.17"

[[deps.ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "PrecompileTools", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "432ae2b430a18c58eb7eca9ef8d0f2db90bc749c"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.8"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "437abb322a41d527c197fa800455f79d414f0a3c"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.8"

[[deps.ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils"]
git-tree-sha1 = "8e2eae13d144d545ef829324f1f0a5a4fe4340f3"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.3.1"

[[deps.ImageMagick_jll]]
deps = ["Artifacts", "Ghostscript_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "OpenJpeg_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "8d2e786fd090199a91ecbf4a66d03aedd0fb24d4"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.11+4"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "355e2b974f2e3212a75dfb60519de21361ad3cb7"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.9"

[[deps.ImageMorphology]]
deps = ["DataStructures", "ImageCore", "LinearAlgebra", "LoopVectorization", "OffsetArrays", "Requires", "TiledIteration"]
git-tree-sha1 = "6f0a801136cb9c229aebea0df296cdcd471dbcd1"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.4.5"

[[deps.ImageQualityIndexes]]
deps = ["ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "LazyModules", "OffsetArrays", "PrecompileTools", "Statistics"]
git-tree-sha1 = "783b70725ed326340adf225be4889906c96b8fd1"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.3.7"

[[deps.ImageSegmentation]]
deps = ["Clustering", "DataStructures", "Distances", "Graphs", "ImageCore", "ImageFiltering", "ImageMorphology", "LinearAlgebra", "MetaGraphs", "RegionTrees", "SimpleWeightedGraphs", "StaticArrays", "Statistics"]
git-tree-sha1 = "3ff0ca203501c3eedde3c6fa7fd76b703c336b5f"
uuid = "80713f31-8817-5129-9cf8-209ff8fb23e1"
version = "1.8.2"

[[deps.ImageShow]]
deps = ["Base64", "ColorSchemes", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "3b5344bcdbdc11ad58f3b1956709b5b9345355de"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.8"

[[deps.ImageTransformations]]
deps = ["AxisAlgorithms", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "e0884bdf01bbbb111aea77c348368a86fb4b5ab6"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.10.1"

[[deps.Images]]
deps = ["Base64", "FileIO", "Graphics", "ImageAxes", "ImageBase", "ImageBinarization", "ImageContrastAdjustment", "ImageCore", "ImageCorners", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageSegmentation", "ImageShow", "ImageTransformations", "IndirectArrays", "IntegralArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "12fdd617c7fe25dc4a6cc804d657cc4b2230302b"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.26.1"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0936ba688c6d201805a83da835b55c61a180db52"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.11+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InlineStrings]]
git-tree-sha1 = "45521d31238e87ee9f9732561bfee12d4eebd52d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.2"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.IntegralArrays]]
deps = ["ColorTypes", "FixedPointNumbers", "IntervalSets"]
git-tree-sha1 = "be8e690c3973443bec584db3346ddc904d4884eb"
uuid = "1d092043-8f09-5a30-832f-7509e371ab51"
version = "0.1.5"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "10bd689145d2c3b2a9844005d01087cc1194e79e"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2024.2.1+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "88a101217d7cb38a7b481ccd50d21876e1d1b0e0"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.1"
weakdeps = ["Unitful"]

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"
weakdeps = ["Random", "RecipesBase", "Statistics"]

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "630b497eafcc20001bba38a4651b327dcfc491d2"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.2"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "PrecompileTools", "Requires", "TranscodingStreams"]
git-tree-sha1 = "a0746c21bdc986d0dc293efa6b1faee112c37c28"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.53"

[[deps.JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "39d64b09147620f5ffbf6b2d3255be3c901bec63"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.8"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "be3dc50a92e5a386872a493a10050136d4703f9b"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.6.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "fa6d0bcff8583bac20f1ffa708c3913ca605c611"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.5"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "25ee0be4d43d0269027024d75a24c24d6c6e590c"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.0.4+0"

[[deps.JumpProcesses]]
deps = ["ArrayInterface", "DataStructures", "DiffEqBase", "DocStringExtensions", "FunctionWrappers", "Graphs", "LinearAlgebra", "Markdown", "PoissonRandom", "Random", "RandomNumbers", "RecursiveArrayTools", "Reexport", "SciMLBase", "StaticArrays", "UnPack"]
git-tree-sha1 = "c451feb97251965a9fe40bacd62551a72cc5902c"
uuid = "ccbc3e58-028d-4f4c-8cd5-9ae44345cda5"
version = "9.10.1"
weakdeps = ["FastBroadcast"]

    [deps.JumpProcesses.extensions]
    JumpProcessFastBroadcastExt = "FastBroadcast"

[[deps.KLU]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse_jll"]
git-tree-sha1 = "884c2968c2e8e7e6bf5956af88cb46aa745c854b"
uuid = "ef3ab10e-7fda-4108-b977-705223b18434"
version = "0.4.1"

[[deps.Krylov]]
deps = ["LinearAlgebra", "Printf", "SparseArrays"]
git-tree-sha1 = "4f20a2df85a9e5d55c9e84634bbf808ed038cabd"
uuid = "ba0b0d4f-ebba-5204-a429-3ac8c609bfb7"
version = "0.9.8"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "78211fb6cbc872f77cad3fc0b6cf647d923f4929"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.7+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "854a9c268c43b77b0a27f22d7fab8d33cdb3a731"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.2+1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LayoutPointers]]
deps = ["ArrayInterface", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "a9eaadb366f5493a5654e843864c13d8b107548c"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.17"

[[deps.LazyArrays]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "MacroTools", "MatrixFactorizations", "SparseArrays"]
git-tree-sha1 = "35079a6a869eecace778bcda8641f9a54ca3a828"
uuid = "5078a376-72f3-5289-bfd5-ec5146d43c02"
version = "1.10.0"
weakdeps = ["StaticArrays"]

    [deps.LazyArrays.extensions]
    LazyArraysStaticArraysExt = "StaticArrays"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"
version = "1.11.0"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LevyArea]]
deps = ["LinearAlgebra", "Random", "SpecialFunctions"]
git-tree-sha1 = "56513a09b8e0ae6485f34401ea9e2f31357958ec"
uuid = "2d8b4e74-eb68-11e8-0fb9-d5eb67b50637"
version = "1.0.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll"]
git-tree-sha1 = "8be878062e0ffa2c3f67bb58a595375eda5de80b"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.11.0+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c6ce1e19f3aec9b59186bdf06cdf3c4fc5f5f3e6"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.50.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "61dfdba58e585066d8bce214c5a51eaa0539f269"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0c4f9c4f1a50d8f35048fa0532dabbadf702f81e"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.40.1+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "5ee6203157c120d79034c748a2acba45b82b8807"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.40.1+0"

[[deps.LineSearches]]
deps = ["LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "Printf"]
git-tree-sha1 = "e4c3be53733db1051cc15ecf573b1042b3a712a1"
uuid = "d3d80556-e9d4-5f37-9878-2ab0fcc64255"
version = "7.3.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LinearSolve]]
deps = ["ArrayInterface", "ConcreteStructs", "DocStringExtensions", "EnumX", "FastLapackInterface", "GPUArraysCore", "InteractiveUtils", "KLU", "Krylov", "Libdl", "LinearAlgebra", "MKL_jll", "PrecompileTools", "Preferences", "RecursiveFactorization", "Reexport", "SciMLBase", "SciMLOperators", "Setfield", "SparseArrays", "Sparspak", "StaticArraysCore", "UnPack"]
git-tree-sha1 = "6f8e084deabe3189416c4e505b1c53e1b590cae8"
uuid = "7ed4a6bd-45f5-4d41-b270-4a48e9bafcae"
version = "2.22.1"

    [deps.LinearSolve.extensions]
    LinearSolveBandedMatricesExt = "BandedMatrices"
    LinearSolveBlockDiagonalsExt = "BlockDiagonals"
    LinearSolveCUDAExt = "CUDA"
    LinearSolveEnzymeExt = ["Enzyme", "EnzymeCore"]
    LinearSolveFastAlmostBandedMatricesExt = ["FastAlmostBandedMatrices"]
    LinearSolveHYPREExt = "HYPRE"
    LinearSolveIterativeSolversExt = "IterativeSolvers"
    LinearSolveKernelAbstractionsExt = "KernelAbstractions"
    LinearSolveKrylovKitExt = "KrylovKit"
    LinearSolveMetalExt = "Metal"
    LinearSolvePardisoExt = "Pardiso"
    LinearSolveRecursiveArrayToolsExt = "RecursiveArrayTools"

    [deps.LinearSolve.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockDiagonals = "0a1fb500-61f7-11e9-3c65-f5ef3456f9f0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    FastAlmostBandedMatrices = "9d29842c-ecb8-4973-b1e9-a27b1157504e"
    HYPRE = "b5ffcf37-a2bd-41ab-a3da-4bd9bc8ad771"
    IterativeSolvers = "42fd0dbc-a981-5370-80f2-aaf504508153"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    KrylovKit = "0b1a1467-8014-51b9-945f-bf0ae24f4b77"
    Metal = "dde4c033-4e86-420c-a63e-0dd931031962"
    Pardiso = "46dd5b70-b6fb-5a00-ae2d-e8fea33afaf2"
    RecursiveArrayTools = "731186ca-8d62-57ce-b412-fbd966d074cd"

[[deps.LittleCMS_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg"]
git-tree-sha1 = "110897e7db2d6836be22c18bffd9422218ee6284"
uuid = "d3a379c0-f9a3-5b72-a4c0-6bf4d2e8af0f"
version = "2.12.0+0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a2d09619db4e765091ee5c6ffe8872849de0feea"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.28"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f02b56007b064fbfddb4c9cd60161b6dd0f40df3"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.1.0"

[[deps.LoopVectorization]]
deps = ["ArrayInterface", "CPUSummary", "CloseOpenIntervals", "DocStringExtensions", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "PrecompileTools", "SIMDTypes", "SLEEFPirates", "Static", "StaticArrayInterface", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "8084c25a250e00ae427a379a5b607e7aed96a2dd"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.171"
weakdeps = ["ChainRulesCore", "ForwardDiff", "SpecialFunctions"]

    [deps.LoopVectorization.extensions]
    ForwardDiffExt = ["ChainRulesCore", "ForwardDiff"]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "oneTBB_jll"]
git-tree-sha1 = "f046ccd0c6db2832a9f639e2c669c6fe867e5f4f"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2024.2.0+0"

[[deps.MLStyle]]
git-tree-sha1 = "bc38dff0548128765760c79eb7388a4b37fae2c8"
uuid = "d8e11817-5142-5d16-987a-aa16d5891078"
version = "0.4.17"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.ManualMemory]]
git-tree-sha1 = "bcaef4fc7a0cfe2cba636d84cda54b5e4e4ca3cd"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.8"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MatrixFactorizations]]
deps = ["ArrayLayouts", "LinearAlgebra", "Printf", "Random"]
git-tree-sha1 = "6731e0574fa5ee21c02733e397beb133df90de35"
uuid = "a3b82374-2e81-5b9e-98ce-41277c0e4c87"
version = "2.2.0"

[[deps.MaybeInplace]]
deps = ["ArrayInterface", "LinearAlgebra", "MacroTools"]
git-tree-sha1 = "54e2fdc38130c05b42be423e90da3bade29b74bd"
uuid = "bb5d69b7-63fc-4a16-80bd-7e42200c7bdb"
version = "0.1.4"
weakdeps = ["SparseArrays"]

    [deps.MaybeInplace.extensions]
    MaybeInplaceSparseArraysExt = "SparseArrays"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[deps.MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "1130dbe1d5276cb656f6e1094ce97466ed700e5a"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.MuladdMacro]]
git-tree-sha1 = "cac9cc5499c25554cba55cd3c30543cff5ca4fab"
uuid = "46d2c3a1-f734-5fdb-9937-b9b9aeba4221"
version = "0.2.4"

[[deps.NLSolversBase]]
deps = ["DiffResults", "Distributed", "FiniteDiff", "ForwardDiff"]
git-tree-sha1 = "a0b464d183da839699f4c79e7606d9d186ec172c"
uuid = "d41bc354-129a-5804-8e4c-c37616107c6c"
version = "7.8.3"

[[deps.NLsolve]]
deps = ["Distances", "LineSearches", "LinearAlgebra", "NLSolversBase", "Printf", "Reexport"]
git-tree-sha1 = "019f12e9a1a7880459d0173c182e6a99365d7ac1"
uuid = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"
version = "4.5.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "91a67b4d73842da90b526011fa85c5c4c9343fe0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.18"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.NonlinearSolve]]
deps = ["ADTypes", "ArrayInterface", "ConcreteStructs", "DiffEqBase", "EnumX", "FastBroadcast", "FastClosures", "FiniteDiff", "ForwardDiff", "LazyArrays", "LineSearches", "LinearAlgebra", "LinearSolve", "MaybeInplace", "PrecompileTools", "Printf", "RecursiveArrayTools", "Reexport", "SciMLBase", "SciMLOperators", "SimpleNonlinearSolve", "SparseArrays", "SparseDiffTools", "StaticArrays", "UnPack"]
git-tree-sha1 = "72b036b728461272ae1b1c3f7096cb4c319d8793"
uuid = "8913a72c-1f9b-4ce2-8d82-65094dcecaec"
version = "3.4.0"

    [deps.NonlinearSolve.extensions]
    NonlinearSolveBandedMatricesExt = "BandedMatrices"
    NonlinearSolveFastLevenbergMarquardtExt = "FastLevenbergMarquardt"
    NonlinearSolveFixedPointAccelerationExt = "FixedPointAcceleration"
    NonlinearSolveLeastSquaresOptimExt = "LeastSquaresOptim"
    NonlinearSolveMINPACKExt = "MINPACK"
    NonlinearSolveNLsolveExt = "NLsolve"
    NonlinearSolveSIAMFANLEquationsExt = "SIAMFANLEquations"
    NonlinearSolveSpeedMappingExt = "SpeedMapping"
    NonlinearSolveSymbolicsExt = "Symbolics"
    NonlinearSolveZygoteExt = "Zygote"

    [deps.NonlinearSolve.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    FastLevenbergMarquardt = "7a0df574-e128-4d35-8cbd-3d84502bf7ce"
    FixedPointAcceleration = "817d07cb-a79a-5c30-9a31-890123675176"
    LeastSquaresOptim = "0fc2ff8b-aaa3-5acd-a817-1944a5e08891"
    MINPACK = "4854310b-de5a-5eb6-a2a5-c1dee2bd17f9"
    NLsolve = "2774e3e8-f4cf-5e23-947b-6d7e65073b56"
    SIAMFANLEquations = "084e46ad-d928-497d-ad5e-07fa361a48c4"
    SpeedMapping = "f1835b91-879b-4a3f-a438-e4baacf14412"
    Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.OffsetArrays]]
git-tree-sha1 = "1a27764e945a152f7ca7efa04de513d473e9542e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.14.1"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "8292dd5c8a38257111ada2174000a33745b06d4e"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.2.4+0"

[[deps.OpenJpeg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libtiff_jll", "LittleCMS_jll", "Pkg", "libpng_jll"]
git-tree-sha1 = "76374b6e7f632c130e78100b166e5a48464256f8"
uuid = "643b3616-a352-519d-856d-80112ee9badc"
version = "2.4.0+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a12e56c72edee3ce6b96667745e6cbbe5498f200"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.23+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Optim]]
deps = ["Compat", "FillArrays", "ForwardDiff", "LineSearches", "LinearAlgebra", "NLSolversBase", "NaNMath", "Parameters", "PositiveFactorizations", "Printf", "SparseArrays", "StatsBase"]
git-tree-sha1 = "ab7edad78cdef22099f43c54ef77ac63c2c9cc64"
uuid = "429524aa-4258-5aef-a3af-852621145aeb"
version = "1.10.0"

    [deps.Optim.extensions]
    OptimMOIExt = "MathOptInterface"

    [deps.Optim.weakdeps]
    MathOptInterface = "b8f27783-ece8-5eb3-8dc8-9495eed66fee"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.OrdinaryDiffEq]]
deps = ["ADTypes", "Adapt", "ArrayInterface", "DataStructures", "DiffEqBase", "DocStringExtensions", "ExponentialUtilities", "FastBroadcast", "FastClosures", "FillArrays", "FiniteDiff", "ForwardDiff", "FunctionWrappersWrappers", "IfElse", "InteractiveUtils", "LineSearches", "LinearAlgebra", "LinearSolve", "Logging", "LoopVectorization", "MacroTools", "MuladdMacro", "NonlinearSolve", "Polyester", "PreallocationTools", "PrecompileTools", "Preferences", "RecursiveArrayTools", "Reexport", "SciMLBase", "SciMLOperators", "SimpleNonlinearSolve", "SimpleUnPack", "SparseArrays", "SparseDiffTools", "StaticArrayInterface", "StaticArrays", "TruncatedStacktraces"]
git-tree-sha1 = "96ae028da53cdfe24712ab015a6f854cfd7609c0"
uuid = "1dea7af3-3e70-54e6-95c3-0bf5283fa5ed"
version = "6.66.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "949347156c25054de2db3b166c52ac4728cbad65"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.31"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "67186a2bc9a90f9f85ff3cc8277868961fb57cbd"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.3"

[[deps.PackageExtensionCompat]]
git-tree-sha1 = "fb28e33b8a95c4cee25ce296c817d89cc2e53518"
uuid = "65ce6f38-6b18-4e1d-a461-8949797d7930"
version = "1.0.2"
weakdeps = ["Requires", "TOML"]

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e127b609fb9ecba6f201ba7ab753d5a605d53801"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.54.1+0"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "35621f10a7531bc8fa58f74610b1bfb70a3cfc6b"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.43.4+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "UnitfulLatexify", "Unzip"]
git-tree-sha1 = "f202a1ca4f6e165238d8175df63a7e26a51e04dc"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.40.7"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PoissonRandom]]
deps = ["Random"]
git-tree-sha1 = "a0f1159c33f846aa77c3f30ebbc69795e5327152"
uuid = "e409e4f3-bfea-5376-8464-e040bb5c01ab"
version = "0.4.4"

[[deps.Polyester]]
deps = ["ArrayInterface", "BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "ManualMemory", "PolyesterWeave", "Static", "StaticArrayInterface", "StrideArraysCore", "ThreadingUtilities"]
git-tree-sha1 = "6d38fea02d983051776a856b7df75b30cf9a3c1f"
uuid = "f517fe37-dbe3-4b94-8317-1923a5111588"
version = "0.7.16"

[[deps.PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "645bed98cd47f72f67316fd42fc47dee771aefcd"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.2.2"

[[deps.Polynomials]]
deps = ["LinearAlgebra", "RecipesBase"]
git-tree-sha1 = "a14a99e430e42a105c898fcc7f212334bc7be887"
uuid = "f27b6e38-b328-58d1-80ce-0feddd5e7a45"
version = "3.2.4"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PositiveFactorizations]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "17275485f373e6673f7e7f97051f703ed5b15b20"
uuid = "85a6dd25-e78a-55b7-8502-1745935b8125"
version = "0.2.4"

[[deps.PreallocationTools]]
deps = ["Adapt", "ArrayInterface", "ForwardDiff"]
git-tree-sha1 = "6c62ce45f268f3f958821a1e5192cf91c75ae89c"
uuid = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
version = "0.4.24"

    [deps.PreallocationTools.extensions]
    PreallocationToolsReverseDiffExt = "ReverseDiff"

    [deps.PreallocationTools.weakdeps]
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "8f6bc219586aef8baf0ff9a5fe16ee9c70cb65e4"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.2"

[[deps.PtrArrays]]
git-tree-sha1 = "77a42d78b6a92df47ab37e177b2deac405e1c88f"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.2.1"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "cda3b045cf9ef07a08ad46731f5a3165e56cf3da"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.1"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random", "RealDot"]
git-tree-sha1 = "994cc27cdacca10e68feb291673ec3a76aa2fae9"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.7.6"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "4743b43e5a9c4a2ede372de7061eed81795b12e7"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.7.0"

[[deps.RandomNumbers]]
deps = ["Random"]
git-tree-sha1 = "c6ec94d2aaba1ab2ff983052cf6a606ca5985902"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.6.0"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterface", "DocStringExtensions", "GPUArraysCore", "IteratorInterfaceExtensions", "LinearAlgebra", "RecipesBase", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables"]
git-tree-sha1 = "6f4dca5fd8e97087a76b7ab8384d1c3086ace0b7"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "3.27.3"

    [deps.RecursiveArrayTools.extensions]
    RecursiveArrayToolsFastBroadcastExt = "FastBroadcast"
    RecursiveArrayToolsForwardDiffExt = "ForwardDiff"
    RecursiveArrayToolsMeasurementsExt = "Measurements"
    RecursiveArrayToolsMonteCarloMeasurementsExt = "MonteCarloMeasurements"
    RecursiveArrayToolsReverseDiffExt = ["ReverseDiff", "Zygote"]
    RecursiveArrayToolsSparseArraysExt = ["SparseArrays"]
    RecursiveArrayToolsTrackerExt = "Tracker"
    RecursiveArrayToolsZygoteExt = "Zygote"

    [deps.RecursiveArrayTools.weakdeps]
    FastBroadcast = "7034ab61-46d4-4ed7-9d0f-46aef9175898"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    MonteCarloMeasurements = "0987c9cc-fe09-11e8-30f0-b96dd679fdca"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.RecursiveFactorization]]
deps = ["LinearAlgebra", "LoopVectorization", "Polyester", "PrecompileTools", "StrideArraysCore", "TriangularSolve"]
git-tree-sha1 = "6db1a75507051bc18bfa131fbc7c3f169cc4b2f6"
uuid = "f2c3362d-daeb-58d1-803e-2bc74f2840b4"
version = "0.2.23"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.ResettableStacks]]
deps = ["StaticArrays"]
git-tree-sha1 = "256eeeec186fa7f26f2801732774ccf277f05db9"
uuid = "ae5879a3-cd67-5da8-be7f-38c6eb64a37b"
version = "1.1.1"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays"]
git-tree-sha1 = "5680a9276685d392c87407df00d57c9924d9f11e"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.7.1"
weakdeps = ["RecipesBase"]

    [deps.Rotations.extensions]
    RotationsRecipesBaseExt = "RecipesBase"

[[deps.RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "04c968137612c4a5629fa531334bb81ad5680f00"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.13"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "2803cab51702db743f3fda07dd1745aadfbf43bd"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.5.0"

[[deps.SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[deps.SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "456f610ca2fbd1c14f5fcf31c6bfadc55e7d66e0"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.43"

[[deps.SciMLBase]]
deps = ["ADTypes", "Accessors", "ArrayInterface", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "EnumX", "Expronicon", "FunctionWrappersWrappers", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "Markdown", "PrecompileTools", "Preferences", "Printf", "RecipesBase", "RecursiveArrayTools", "Reexport", "RuntimeGeneratedFunctions", "SciMLOperators", "SciMLStructures", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface"]
git-tree-sha1 = "cacc7bc54bab8749b1fc1032c4911fe80cffb959"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "2.61.0"

    [deps.SciMLBase.extensions]
    SciMLBaseChainRulesCoreExt = "ChainRulesCore"
    SciMLBaseMakieExt = "Makie"
    SciMLBasePartialFunctionsExt = "PartialFunctions"
    SciMLBasePyCallExt = "PyCall"
    SciMLBasePythonCallExt = "PythonCall"
    SciMLBaseRCallExt = "RCall"
    SciMLBaseZygoteExt = "Zygote"

    [deps.SciMLBase.weakdeps]
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    PartialFunctions = "570af359-4316-4cb7-8c74-252c00c2016b"
    PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
    PythonCall = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"
    RCall = "6f49c342-dc21-5d91-9882-a32aef131414"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.SciMLOperators]]
deps = ["Accessors", "ArrayInterface", "DocStringExtensions", "LinearAlgebra", "MacroTools"]
git-tree-sha1 = "6149620767866d4b0f0f7028639b6e661b6a1e44"
uuid = "c0aeaf25-5076-4817-a8d5-81caf7dfa961"
version = "0.3.12"
weakdeps = ["SparseArrays", "StaticArraysCore"]

    [deps.SciMLOperators.extensions]
    SciMLOperatorsSparseArraysExt = "SparseArrays"
    SciMLOperatorsStaticArraysCoreExt = "StaticArraysCore"

[[deps.SciMLStructures]]
deps = ["ArrayInterface"]
git-tree-sha1 = "25514a6f200219cd1073e4ff23a6324e4a7efe64"
uuid = "53ae85a6-f571-4167-b2af-e1d143709226"
version = "1.5.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "d0553ce4031a081cc42387a9b9c8441b7d99f32d"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.7"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "e2cc6d8c88613c05e1defb55170bf5ff211fbeac"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.SimpleNonlinearSolve]]
deps = ["ADTypes", "ArrayInterface", "ConcreteStructs", "DiffEqBase", "FastClosures", "FiniteDiff", "ForwardDiff", "LinearAlgebra", "MaybeInplace", "PrecompileTools", "Reexport", "SciMLBase", "StaticArraysCore"]
git-tree-sha1 = "df8266e0d4960d61325db8c54fad3fa95712b57e"
uuid = "727e6d20-b764-4bd8-a329-72de5adea6c7"
version = "1.4.0"

    [deps.SimpleNonlinearSolve.extensions]
    SimpleNonlinearSolveChainRulesCoreExt = "ChainRulesCore"
    SimpleNonlinearSolvePolyesterForwardDiffExt = "PolyesterForwardDiff"
    SimpleNonlinearSolveStaticArraysExt = "StaticArrays"

    [deps.SimpleNonlinearSolve.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    PolyesterForwardDiff = "98d1487c-24ca-40b6-b7ab-df2af84e126b"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleUnPack]]
git-tree-sha1 = "58e6353e72cde29b90a69527e56df1b5c3d8c437"
uuid = "ce78b400-467f-4804-87d8-8f486da07d0a"
version = "1.1.0"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays"]
git-tree-sha1 = "4b33e0e081a825dbfaf314decf58fa47e53d6acb"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.4.0"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SparseDiffTools]]
deps = ["ADTypes", "Adapt", "ArrayInterface", "Compat", "DataStructures", "FiniteDiff", "ForwardDiff", "Graphs", "LinearAlgebra", "PackageExtensionCompat", "Random", "Reexport", "SciMLOperators", "Setfield", "SparseArrays", "StaticArrayInterface", "StaticArrays", "Tricks", "UnPack", "VertexSafeGraphs"]
git-tree-sha1 = "cce98ad7c896e52bb0eded174f02fc2a29c38477"
uuid = "47a9eef4-7e08-11e9-0b38-333d64bd3804"
version = "2.18.0"

    [deps.SparseDiffTools.extensions]
    SparseDiffToolsEnzymeExt = "Enzyme"
    SparseDiffToolsPolyesterExt = "Polyester"
    SparseDiffToolsPolyesterForwardDiffExt = "PolyesterForwardDiff"
    SparseDiffToolsSymbolicsExt = "Symbolics"
    SparseDiffToolsZygoteExt = "Zygote"

    [deps.SparseDiffTools.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"
    Polyester = "f517fe37-dbe3-4b94-8317-1923a5111588"
    PolyesterForwardDiff = "98d1487c-24ca-40b6-b7ab-df2af84e126b"
    Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.Sparspak]]
deps = ["Libdl", "LinearAlgebra", "Logging", "OffsetArrays", "Printf", "SparseArrays", "Test"]
git-tree-sha1 = "342cf4b449c299d8d1ceaf00b7a49f4fbc7940e7"
uuid = "e56a9233-b9d6-4f03-8d0f-1825330902ac"
version = "0.3.9"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "2f5d4697f21388cbe1ff299430dd169ef97d7e14"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.4.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "83e6cce8324d49dfaf9ef059227f91ed4441a8e5"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.2"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "b366eb1eb68075745777d80861c6706c33f588ae"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.8.9"

[[deps.StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "PrecompileTools", "Static"]
git-tree-sha1 = "96381d50f1ce85f2663584c8e886a6ca97e60554"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.8.0"
weakdeps = ["OffsetArrays", "StaticArrays"]

    [deps.StaticArrayInterface.extensions]
    StaticArrayInterfaceOffsetArraysExt = "OffsetArrays"
    StaticArrayInterfaceStaticArraysExt = "StaticArrays"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "777657803913ffc7e8cc20f0fd04b634f871af8f"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.8"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "5cf7606d6cef84b543b483848d4ae08ad9832b21"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.3"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"
weakdeps = ["ChainRulesCore", "InverseFunctions"]

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

[[deps.SteadyStateDiffEq]]
deps = ["ConcreteStructs", "DiffEqBase", "DiffEqCallbacks", "LinearAlgebra", "Reexport", "SciMLBase"]
git-tree-sha1 = "a735fd5053724cf4de31c81b4e2cc429db844be5"
uuid = "9672c7b4-1e72-59bd-8a11-6ac3964bc41f"
version = "2.0.1"

[[deps.StochasticDiffEq]]
deps = ["Adapt", "ArrayInterface", "DataStructures", "DiffEqBase", "DiffEqNoiseProcess", "DocStringExtensions", "FiniteDiff", "ForwardDiff", "JumpProcesses", "LevyArea", "LinearAlgebra", "Logging", "MuladdMacro", "NLsolve", "OrdinaryDiffEq", "Random", "RandomNumbers", "RecursiveArrayTools", "Reexport", "SciMLBase", "SciMLOperators", "SparseArrays", "SparseDiffTools", "StaticArrays", "UnPack"]
git-tree-sha1 = "97e5d0b7e5ec2e68eec6626af97c59e9f6b6c3d0"
uuid = "789caeaf-c7a9-5a7d-9973-96adeb23e2a0"
version = "6.65.1"

[[deps.StrideArraysCore]]
deps = ["ArrayInterface", "CloseOpenIntervals", "IfElse", "LayoutPointers", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static", "StaticArrayInterface", "ThreadingUtilities"]
git-tree-sha1 = "f35f6ab602df8413a50c4a25ca14de821e8605fb"
uuid = "7792a7ef-975c-4747-a70f-980b88e8d1da"
version = "0.5.7"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a6b1675a536c5ad1a60e5a5153e1fee12eb146e3"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.0"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.Sundials]]
deps = ["CEnum", "DataStructures", "DiffEqBase", "Libdl", "LinearAlgebra", "Logging", "PrecompileTools", "Reexport", "SciMLBase", "SparseArrays", "Sundials_jll"]
git-tree-sha1 = "e15f5a73f0d14b9079b807a9d1dac13e4302e997"
uuid = "c3572dad-4567-51f8-b174-8c6c989267f4"
version = "4.24.0"

[[deps.Sundials_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "SuiteSparse_jll", "libblastrampoline_jll"]
git-tree-sha1 = "91db7ed92c66f81435fe880947171f1212936b14"
uuid = "fb77eaff-e24c-56d4-86b1-d163f2edb164"
version = "5.2.3+0"

[[deps.SymbolicIndexingInterface]]
deps = ["Accessors", "ArrayInterface", "RuntimeGeneratedFunctions", "StaticArraysCore"]
git-tree-sha1 = "6c6761e08bf5a270905cdd065be633abfa1b155b"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.3.35"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "eda08f7e9818eb53661b3deb74e3159460dfbc27"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.5.2"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "bc7fd5c91041f44636b2c134041f7e5263ce58ae"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.10.0"

[[deps.TiledIteration]]
deps = ["OffsetArrays", "StaticArrayInterface"]
git-tree-sha1 = "1176cc31e867217b06928e2f140c90bd1bc88283"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.5.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.TriangularSolve]]
deps = ["CloseOpenIntervals", "IfElse", "LayoutPointers", "LinearAlgebra", "LoopVectorization", "Polyester", "Static", "VectorizationBase"]
git-tree-sha1 = "be986ad9dac14888ba338c2554dcfec6939e1393"
uuid = "d5829a12-d9aa-46ab-831f-fb7c9ab06edf"
version = "0.2.1"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.TruncatedStacktraces]]
deps = ["InteractiveUtils", "MacroTools", "Preferences"]
git-tree-sha1 = "ea3e54c2bdde39062abf5a9758a23735558705e1"
uuid = "781d530d-4396-4725-bb49-402e4bee1e77"
version = "1.4.0"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "d95fe458f26209c66a187b1114df96fd70839efd"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.21.0"
weakdeps = ["ConstructionBase", "InverseFunctions"]

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static", "StaticArrayInterface"]
git-tree-sha1 = "4ab62a49f1d8d9548a1c8d1a75e5f55cf196f64e"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.71"

[[deps.VertexSafeGraphs]]
deps = ["Graphs"]
git-tree-sha1 = "8351f8d73d7e880bfc042a8b6922684ebeafb35c"
uuid = "19fa3120-7c27-5ec5-8db8-b0b0aa330d6f"
version = "0.2.0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "7558e29847e99bc3f04d6569e82d0f5c54460703"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+1"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "93f43ab61b16ddfb2fd3bb13b3ce241cafb0e6c9"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.31.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c1a7aa6219628fcd757dede0ca95e245c5cd9511"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.0.0"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "a2fccc6559132927d4c5dc183e3e01048c6dcbd6"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.5+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "a54ee957f4c86b526460a720dbc882fa5edcbefc"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.41+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "afead5aba5aa507ad5a3bf01f58f82c8d1403495"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.6+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6035850dcc70518ca32f012e46015b9beeda49d8"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.11+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "34d526d318358a859d7de23da945578e8e8727b7"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.4+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "d2d1a5c49fae4ba39983f63de6afcbea47194e85"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.6+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "47e45cd78224c53109495b3e324df0c37bb61fbe"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.11+0"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8fdda4c692503d44d04a0603d9ac0982054635f9"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "bcd466676fef0878338c61e655629fa7bbc69d8e"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.0+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "730eeca102434283c50ccf7d1ecdadf521a765a4"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.2+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "330f955bc41bb8f5270a369c473fc4a5a4e4d3cb"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.6+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "691634e5453ad362044e2ad653e79f3ee3bb98c3"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.39.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e92a1a012a10506618f10b7047e478403a046c77"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.5.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "555d1076590a6cc2fdee2ef1469451f872d8b41b"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.6+1"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "936081b536ae4aa65415d869287d43ef3cb576b2"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.53.0+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1827acba325fdcdf1d2647fc8d5301dd9ba43a9d"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.9.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "b70c870239dc3d7bc094eb2d6be9b73d27bef280"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.44+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.oneTBB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7d0ea0f4895ef2f5cb83645fa689e52cb55cf493"
uuid = "1317d2d5-d96f-522e-a858-c73665f53c3e"
version = "2021.12.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9c304562909ab2bab0262639bd4f444d7bc2be37"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+1"
"""

# ╔═╡ Cell order:
# ╟─984a3f2b-ff68-4821-be19-c0f53314583c
# ╟─615ef11d-d9b6-44ac-b2e2-06b897b88bb4
# ╟─36947288-7dab-47aa-a9df-e0d0214fe8f1
# ╟─d08fda83-d9a2-46bd-8623-16394f1cab99
# ╟─66cc3684-e801-4ae4-a4de-64ca013f7502
# ╟─d54db4d3-d204-42da-834c-4527372d8dc5
# ╟─b4038522-2a3d-4735-9427-b5daf2e2e021
# ╟─aeb46253-0b04-4429-8f82-1fd4f33412df
# ╟─ac57d4c7-90a7-4ee1-9918-c5e3e42646d4
# ╟─69f5485b-f15a-4cd2-a66f-0df8eec38dfb
# ╟─2d16f761-a67c-401a-af9b-8fb7e045a47a
# ╟─9b9b6f1e-e816-436d-8353-e32de81ce39c
# ╟─6bd2a1f9-cf3a-4f3a-b437-fd2460998400
# ╟─7d356bfa-9653-479c-9882-ee24a977c887
# ╟─06fbabc4-86ec-4a96-b21b-f8388642eb80
# ╟─a46ab93a-5c30-46ee-b0f4-9422bd815efd
# ╟─701af503-04fd-4a2a-8e6a-c7920742515f
# ╟─79bc7e6b-56dc-472c-841d-62b28aa8aaac
# ╟─8c025ed7-800c-45fb-b3e2-d980546082aa
# ╟─6fb4d0dd-6ff1-4622-9f68-09cb504ad39f
# ╟─3be3288a-f5c8-444b-a93f-90b92a2da808
# ╟─4100f072-9090-4a12-8910-5a223e67bd67
# ╟─2bcab15c-caf8-404f-8fcc-2e8dfa6d994d
# ╟─45c763ba-69e9-4219-9080-08ca69e69985
# ╟─fa9edad9-3499-44f0-9c28-1f7b7175c96b
# ╟─4904604e-5326-487d-8776-e0a7d0a8e064
# ╟─dee17d2f-6a00-4eef-8fa3-a2a7be64cf99
# ╟─e9c8d2eb-dd0e-4248-a911-bfab429bee7b
# ╟─dc828511-2862-4b2d-844f-b9042e2a18bd
# ╟─2577dd88-596a-45a9-b89e-56545b60a806
# ╟─c6ea3785-0fdf-4b39-8924-b90386ba5dea
# ╟─28617099-6ad7-460f-8bc1-34580b435151
# ╟─651f1466-eef6-49ff-9dd6-47bbf08da31b
# ╟─8f043267-6732-478a-996d-9685c24b5978
# ╟─89e1367f-d97c-4267-bdbb-d1b4e5bc3e1d
# ╟─e830749c-1795-4467-9d8a-7cf1ebbff1da
# ╟─bf7c7386-9bfd-4834-9f31-c4e481708cc7
# ╠═c0d46187-970e-4f6c-9f1f-1ad40a08a01a
# ╟─2dfbbd5c-5121-404f-9170-c8b03e562bed
# ╠═1e6eaec1-b7e5-4d48-91f0-91d82a1d80ae
# ╟─0f3efab8-8425-49b7-8fb5-431f494cc0af
# ╠═e0cf5bb3-a644-4223-aa87-a0e0b921f13a
# ╟─35438e3a-7306-449b-a176-88a33ab3d8b9
# ╟─c21a0f23-5941-4dcd-a9cb-2bbb03ffddb0
# ╟─f087c6ec-f648-49c3-9f86-940ad290abae
# ╟─e8c662b4-0f54-46f0-b61c-cb67b7f55f6f
# ╟─7cce6391-8d80-4786-8bad-d1dd5658846c
# ╟─9956c3ef-51a4-4260-85c7-9e63adae9b9e
# ╟─83d199ce-b358-41ca-bf72-8b2662dec7d0
# ╟─602cf17d-7b1f-40a5-a2a4-e891bb6a5560
# ╟─1e867ef2-5480-44b9-b36a-18ac2a79ddd9
# ╠═1c8b972b-c360-4dd9-b634-f1b77725174f
# ╠═85d4e17f-c268-4f71-929f-37c482c3a873
# ╠═57712785-86ed-4ef6-828b-8a33c7a82799
# ╟─8f2f03e2-9989-4230-b711-760c9a437268
# ╠═6d57a957-0c0d-4695-8c02-204a5ef305bb
# ╟─ba331eb3-1306-419f-b701-d28dbf909849
# ╠═568b05cf-ebfd-44a0-8032-5d823cb20fcf
# ╠═82dfc6bb-2c49-4f7f-b0c4-a52df4d51531
# ╟─e6513348-b3da-4a00-acdb-a4b55151576e
# ╠═d5be5faf-5ada-471e-bf6a-1ea29c999df6
# ╟─5a26090b-ec7f-4e9f-a75d-1f5383c55d31
# ╠═34dff0ab-b7f2-43fc-befe-1633485a4589
# ╟─8b4a5414-45c6-4e06-b52f-c39708f5cc51
# ╠═7985babc-fa7f-49bc-a4cc-f46852b818e2
# ╟─10824b06-7872-4695-ba44-45dec2765af8
# ╟─aa32a966-ddc0-404f-824f-0e6abeb553ca
# ╟─b414f8e8-7f47-4ac8-9f0d-fd0dde6a20d6
# ╟─b5ed718c-17c9-4892-b9cd-136dc752600d
# ╟─7c9ac58b-b519-4e6b-82a1-ca4054e85159
# ╠═034dc903-a4fa-4b03-a727-2010e2e5bcaa
# ╟─88b6ab95-398f-4239-b372-1d89d9d20931
# ╠═572426eb-7a73-4334-8c25-af2400967afc
# ╟─0bc0c101-8a9f-4973-95d8-acced03dc3c2
# ╠═12646e4a-7551-4f63-9cb8-32db1f122eab
# ╠═22f24035-d7da-4cc9-890b-2c61d52bf64c
# ╠═3e9cff88-8cee-4b25-b24d-9fb429fc7cfd
# ╠═032e5837-f60c-412c-838d-28fd78e61add
# ╠═de9311f3-03fb-43c5-93ea-49f295a560d8
# ╠═cdcd7e4d-6ce8-4af4-b362-bfb2a05483cc
# ╠═4b6664d0-2955-4fe4-ba06-620560e7602a
# ╠═9dffe7fd-ec96-4f1e-8a6a-a883e973bb9c
# ╟─af490f60-9de6-4d44-a611-7af29c766a0f
# ╟─da98c8b9-4902-4221-90ed-5c4dd90a53ac
# ╟─d402fa78-10e6-4906-97c8-a864439624f5
# ╠═5283490a-07cc-4117-b40a-7ae2af2ddc15
# ╟─7937faec-3fb6-4738-8101-2ef043fb94d7
# ╟─551d99ca-b51c-4227-81aa-96a35c5fb6ed
# ╟─efaf86c6-f6ab-45ea-9efc-fc0e7a5049d4
# ╟─972a0170-5ccd-4073-816b-62ec89f6b8d8
# ╟─f3f0002c-ac51-417b-93f8-7525c00be911
# ╟─793d4505-1222-420c-89df-15f18c87b553
# ╠═0b8fe699-b513-4fa9-9fce-615468f6abaa
# ╟─17ccc2ee-ebec-4338-9fa5-afbe6ccf54c8
# ╠═6e2fc998-b00c-41ba-94ad-e0efe6fa77ef
# ╟─e6690cd2-05e7-4ffb-8486-d70de5e87717
# ╠═61c00ce3-e2ec-4be9-a6c1-fe4f5aaf6505
# ╟─7d283b58-32f3-4ed9-8464-97c19d103586
# ╠═7ee01df6-97cf-4e40-a66e-2a887d657b0a
# ╠═8da23acd-72f6-4f8a-bd67-39645449d592
# ╠═642a589c-4c79-495a-b27a-70b08363f8d1
# ╟─7728dcee-c025-4d37-a2d6-e14e1eeaf571
# ╠═bdac7231-c2ff-47b8-83ab-e8a5fff54e95
# ╟─27173b13-3025-4d81-9562-e92902d9ecbe
# ╠═cde71548-be8c-4539-a718-69c7a39b339b
# ╟─c9b515c9-777f-4d0a-9dee-9e9881393e2b
# ╠═7f616003-377d-400e-bc6a-79d74fd36e11
# ╟─42678b26-0334-4b1d-962d-3895a2625132
# ╠═90c249a7-38e6-4c71-a90a-b3437332e114
# ╠═adfdcc27-f634-4592-865c-1914a1bfcc4c
# ╟─4dd8b483-622c-403e-8b90-318fb3824879
# ╠═ea3a24df-c13c-4c5c-b0ab-e8ee145fbfd2
# ╠═267f5483-a347-459b-8701-96bdb02f3ee9
# ╟─90abe302-556a-4571-b1bc-5a8b2a283f10
# ╟─08e74abb-b535-45c7-a30c-cfbef145cb1f
# ╟─26c62ab8-f189-4817-a9ca-3c2547d517ee
# ╟─0ab22288-b241-4213-9583-3066aa870eb4
# ╟─a86bd973-41de-4a60-a78d-cb38a48dbe2b
# ╟─3020fde9-79ea-4e64-8bd4-fd9951e5d869
# ╟─23e13275-6161-4cd2-9db7-640bb3f2f2d7
# ╟─9ce52baf-59fd-4ff5-a813-b10b3c2e97df
# ╠═3dc31262-5060-482e-ac8d-96a63d5daf90
# ╟─1f84fe46-40f6-4ce3-ab97-eda399afaebe
# ╟─c3355b2a-e708-4278-bf53-469a24a3a05e
# ╠═5070459f-1156-4bb6-92dd-1bd524ecc1e8
# ╠═298d2b81-9fcf-4d42-9c3e-290962ca42a6
# ╠═eca0ce08-0094-480b-9c89-1964f56d0430
# ╠═06519699-0193-4f27-9424-a561c2a35208
# ╠═b2d0f888-e004-4986-96f6-f4284ae13e73
# ╠═981d8630-1009-46c5-8d18-15cf83182d29
# ╟─d759d211-ca6d-440b-95e3-98deaa575e15
# ╠═60b65057-c281-4506-be6d-872c8ea1f815
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
