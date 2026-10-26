# Análisis de rotación de personal (People Analytics) con SQL

¿Qué empleados tienen más riesgo de renunciar y por qué? Este proyecto analiza la rotación de personal de una empresa usando SQL, para identificar los factores asociados a la renuncia y proponer medidas concretas.

## Hallazgos principales

- **Las horas extra son el factor más fuerte.** Quienes hacen horas extra renuncian 3 veces más (30,5% vs 10,4%). Son el 28% de la plantilla, pero concentran más de la mitad de las renuncias. El efecto se mantiene en todos los cargos, tramos de sueldo, edades y niveles de antigüedad.
- **El sueldo bajo pesa, pero solo bajo cierto umbral.** Quienes ganan menos de 3.000 renuncian a una tasa de 28,6%; sobre ese monto la tasa cae a cerca de 12% o menos.
- **El primer año es el período crítico.** Los empleados con 0 a 1 año de antigüedad renuncian a una tasa de 34,9%, más del doble del promedio.
- **La renuncia se concentra en jóvenes y cargos de entrada.** Los menores de 25 años renuncian a 39,2%, y los Representantes de Ventas a 39,8%.
- **Los factores se suman.** Más de la mitad de los empleados con sueldo bajo y horas extra renuncia (56,1%), al igual que los empleados en su primer año con horas extra (55,1%).

## Datos

- **Fuente:** dataset *IBM HR Analytics Employee Attrition & Performance*, disponible en Kaggle. Son datos ficticios creados por IBM con fines de práctica.
- **Tamaño:** 1.470 empleados y 35 variables (datos personales, laborales, de sueldo y de satisfacción).
- **Variable objetivo:** `Attrition` (Yes = renunció, No = sigue en la empresa).
- **Tasa de renuncia general:** 16,1% (237 de 1.470).

## Herramientas

- MySQL 8 y MySQL Workbench

## Metodología

1. Importación del CSV a una base de datos MySQL y verificación del total de registros.
2. Cálculo de la **tasa de renuncia** (renuncias / total) para distintos grupos, usando `CASE`, `SUM`, `COUNT` y `GROUP BY`.
3. Agrupación de variables continuas (sueldo, edad, antigüedad) en **tramos**.
4. **Cruce con horas extra** en cada análisis, para comprobar si cada factor tiene efecto propio o si se explica por otra variable.
5. Revisión del **tamaño de cada grupo** antes de sacar conclusiones, ya que los porcentajes de grupos pequeños son menos confiables.

Las consultas completas están en [`sql/consultas_rotacion.sql`](sql/consultas_rotacion.sql).

## Análisis

### 1. ¿Cómo cambia la tasa de renuncia según el área y el cargo?

**La renuncia se concentra en los cargos de entrada, más que en un área específica.**

| Área | Total | Renuncias | Tasa |
|---|---:|---:|---:|
| Sales | 446 | 92 | 20,6% |
| Human Resources | 63 | 12 | 19,0% |
| Research & Development | 961 | 133 | 13,8% |

| Cargo | Total | Renuncias | Tasa |
|---|---:|---:|---:|
| Sales Representative | 83 | 33 | 39,8% |
| Laboratory Technician | 259 | 62 | 23,9% |
| Human Resources | 52 | 12 | 23,1% |
| Sales Executive | 326 | 57 | 17,5% |
| Research Scientist | 292 | 47 | 16,1% |
| Manufacturing Director | 145 | 10 | 6,9% |
| Healthcare Representative | 131 | 9 | 6,9% |
| Manager | 102 | 5 | 4,9% |
| Research Director | 80 | 2 | 2,5% |

- Ventas tiene la tasa más alta por área (20,6%). RR.HH. también está sobre el promedio (19,0%), pero con solo 63 personas la cifra es menos confiable.
- Por cargo, los **Representantes de Ventas** renuncian casi 2,5 veces más que el promedio (39,8%).
- Los **Técnicos de Laboratorio** (23,9%) aportan 62 renuncias, más de un cuarto del total, por ser un grupo grande.
- Los cargos directivos y gerenciales tienen tasas bajo el 7%.

### 2. ¿Los que hacen horas extra renuncian más?

**Sí. Es el factor más fuerte del análisis, y su efecto se mantiene dentro de cada cargo.**

| Horas extra | Total | Renuncias | Tasa |
|---|---:|---:|---:|
| Sí | 416 | 127 | 30,5% |
| No | 1.054 | 110 | 10,4% |

Al comparar dentro de un mismo cargo, quienes hacen horas extra renuncian bastante más en casi todos los casos:

| Cargo | Tasa sin horas extra | Tasa con horas extra |
|---|---:|---:|
| Sales Representative | 28,8% | 66,7% |
| Laboratory Technician | 15,7% | 50,0% |
| Human Resources | 17,9% | 38,5% |
| Research Scientist | 7,2% | 34,0% |
| Sales Executive | 11,2% | 33,0% |
| Manager | 1,3% | 14,8% |
| Manufacturing Director | 5,7% | 10,3% |
| Healthcare Representative | 7,4% | 5,4% |
| Research Director | 1,8% | 4,3% |

- Menos de un tercio de la empresa (28%) genera más de la mitad de las renuncias (127 de 237).
- El cargo y las horas extra se suman: 2 de cada 3 Representantes de Ventas con horas extra renuncian (grupo pequeño, de 24 personas).
- La única excepción es Healthcare Representative, con muy pocas renuncias para ser concluyente.

### 3. ¿Influye el sueldo?

**Sí, pero el efecto se concentra en los sueldos más bajos y es menor que el de las horas extra.**

Quienes renunciaron ganaban en promedio 4.787, cerca de un 30% menos que quienes se quedaron (6.833). Como el promedio se ve afectado por los sueldos altos de los cargos directivos, se analizó también por tramos:

| Tramo de sueldo mensual | Total | Renuncias | Tasa | Tasa sin horas extra | Tasa con horas extra |
|---|---:|---:|---:|---:|---:|
| Menos de 3.000 | 395 | 113 | 28,6% | 17,4% | 56,1% |
| 3.000 a 5.999 | 519 | 66 | 12,7% | 8,5% | 24,1% |
| 6.000 a 9.999 | 275 | 33 | 12,0% | 8,0% | 22,4% |
| 10.000 o más | 281 | 25 | 8,9% | 6,6% | 14,1% |

- La renuncia no baja de forma gradual: hay un **umbral** en 3.000. El tramo más bajo es el 27% de la plantilla, pero concentra casi la mitad de las renuncias (113 de 237).
- El sueldo bajo tiene efecto propio: sin horas extra, el tramo bajo 3.000 renuncia al doble que los demás tramos (17,4% vs ~8%).
- **Perfil de mayor riesgo:** sueldo bajo 3.000 + horas extra = 56,1% de renuncia, sobre un grupo de 114 personas.
- Las horas extra pesan más que el sueldo: un empleado con sueldo medio y horas extra (24,1%) renuncia más que uno con sueldo bajo sin horas extra (17,4%).

### 4. ¿Influyen la edad y los años en la empresa?

**Sí. El riesgo se concentra en los empleados jóvenes y en los recién llegados, y aumenta fuertemente con las horas extra.**

| Tramo de edad | Total | Renuncias | Tasa | Tasa sin horas extra | Tasa con horas extra |
|---|---:|---:|---:|---:|---:|
| Menos de 25 | 97 | 38 | 39,2% | 25,8% | 67,7% |
| 25 a 34 | 554 | 112 | 20,2% | 13,3% | 40,4% |
| 35 a 44 | 505 | 51 | 10,1% | 5,6% | 20,5% |
| 45 o más | 314 | 36 | 11,5% | 8,1% | 19,4% |

| Años en la empresa | Total | Renuncias | Tasa | Tasa sin horas extra | Tasa con horas extra |
|---|---:|---:|---:|---:|---:|
| 0 a 1 | 215 | 75 | 34,9% | 25,3% | 55,1% |
| 2 a 4 | 365 | 66 | 18,1% | 11,2% | 35,2% |
| 5 a 9 | 524 | 58 | 11,1% | 6,1% | 24,1% |
| 10 o más | 366 | 38 | 10,4% | 7,8% | 17,5% |

- **Edad:** desde los 35 años la tasa baja a cerca de 10%. El tramo de 25 a 34 es el que más renuncias aporta (112 de 237), por ser el más numeroso.
- **Antigüedad:** el primer año es el período más crítico. Quienes llevan 0 a 1 año concentran casi un tercio de las renuncias (75 de 237). La tasa baja gradualmente y se estabiliza cerca del 10% desde los 5 años.
- Ambos factores tienen efecto propio: sin horas extra, los menores de 25 (25,8%) y los empleados en su primer año (25,3%) renuncian mucho más que los empleados mayores o con más antigüedad (6–8%).
- Con horas extra, el riesgo se dispara: 55,1% en empleados de primer año y 40,4% en el tramo de 25 a 34 años (141 personas, 57 renuncias).

## Recomendaciones

1. **Reducir las horas extra**, especialmente en cargos de entrada y en empleados nuevos. Es la medida con mayor impacto potencial.
2. **Evitar asignar horas extra durante el primer año** y reforzar la inducción y el acompañamiento en ese período.
3. **Revisar los sueldos del tramo más bajo**, en lugar de aplicar alzas generales: sobre los 3.000 la tasa de renuncia cambia poco.
4. **Poner foco en los Representantes de Ventas y Técnicos de Laboratorio**: el primero por su tasa de renuncia, el segundo por su volumen de renuncias.

## Limitaciones

- Los datos son ficticios, por lo que las conclusiones ilustran el método y no describen una empresa real.
- El análisis muestra **relaciones, no causas**.
- Edad, antigüedad, sueldo y cargo están relacionados entre sí (los empleados nuevos suelen ser más jóvenes, ganar menos y estar en cargos de entrada). Las tablas cruzadas separan solo dos factores a la vez.
- `OverTime` solo indica si la persona hace horas extra (sí/no), no cuántas. Con ese dato se podría identificar a partir de qué cantidad aumenta el riesgo.
- Algunos grupos cruzados son pequeños (menos de 50 personas), por lo que sus tasas deben tomarse como señales y no como cifras exactas.

## Próximos pasos

- **Python (pandas):** analizar todas las variables a la vez para separar el efecto de cada factor y construir un modelo que estime la probabilidad de renuncia de cada empleado.
- **Power BI:** dashboard con los hallazgos principales y los perfiles de riesgo.

## Autor

Francisco Monsalve Bravo, Ingeniero Civil Industrial
