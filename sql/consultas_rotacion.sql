/* =========================================================
   Análisis de rotación de personal (People Analytics)
   Dataset: IBM HR Analytics Employee Attrition & Performance
   Motor: MySQL 8
   Autor: Francisco Monsalve Bravo
   ========================================================= */


/* ---------------------------------------------------------
   0. Preparación
   --------------------------------------------------------- */

CREATE DATABASE hr_attrition;
USE hr_attrition;

-- El CSV se importó con Table Data Import Wizard en la tabla "employees".

-- Verificación del total de registros (resultado esperado: 1470)
SELECT COUNT(*) AS total FROM employees;

-- Corrección del nombre de la primera columna: el CSV trae un carácter
-- invisible al inicio (BOM) que convierte "Age" en "ï»¿Age"
ALTER TABLE employees
RENAME COLUMN `ï»¿Age` TO Age;

SELECT Age, Attrition FROM employees LIMIT 5;


/* ---------------------------------------------------------
   1. Tasa de renuncia general
   Resultado: 16,1% (237 de 1.470)
   --------------------------------------------------------- */

SELECT
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees;


/* ---------------------------------------------------------
   2. Tasa de renuncia por área y por cargo
   --------------------------------------------------------- */

-- Por área
SELECT
  Department,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY Department
ORDER BY tasa_pct DESC;

-- Por cargo
SELECT
  JobRole,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY JobRole
ORDER BY tasa_pct DESC;


/* ---------------------------------------------------------
   3. Horas extra
   --------------------------------------------------------- */

-- Tasa de renuncia según horas extra
SELECT
  OverTime,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY OverTime
ORDER BY tasa_pct DESC;

-- Cruce cargo x horas extra: ¿el efecto se mantiene dentro de cada cargo?
SELECT
  JobRole,
  OverTime,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY JobRole, OverTime
ORDER BY tasa_pct DESC;


/* ---------------------------------------------------------
   4. Sueldo
   --------------------------------------------------------- */

-- Sueldo promedio de quienes renunciaron vs quienes se quedaron
SELECT
  Attrition,
  COUNT(*) AS total,
  ROUND(AVG(MonthlyIncome), 0) AS sueldo_promedio
FROM employees
GROUP BY Attrition;

-- Tasa de renuncia por tramo de sueldo
SELECT
  CASE
    WHEN MonthlyIncome < 3000 THEN '1. Menos de 3.000'
    WHEN MonthlyIncome < 6000 THEN '2. 3.000 a 5.999'
    WHEN MonthlyIncome < 10000 THEN '3. 6.000 a 9.999'
    ELSE '4. 10.000 o más'
  END AS tramo_sueldo,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY tramo_sueldo
ORDER BY tramo_sueldo;

-- Cruce tramo de sueldo x horas extra
SELECT
  CASE
    WHEN MonthlyIncome < 3000 THEN '1. Menos de 3.000'
    WHEN MonthlyIncome < 6000 THEN '2. 3.000 a 5.999'
    WHEN MonthlyIncome < 10000 THEN '3. 6.000 a 9.999'
    ELSE '4. 10.000 o más'
  END AS tramo_sueldo,
  OverTime,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY tramo_sueldo, OverTime
ORDER BY tramo_sueldo, OverTime;


/* ---------------------------------------------------------
   5. Edad y antigüedad
   --------------------------------------------------------- */

-- Tasa de renuncia por tramo de edad
SELECT
  CASE
    WHEN Age < 25 THEN '1. Menos de 25'
    WHEN Age < 35 THEN '2. 25 a 34'
    WHEN Age < 45 THEN '3. 35 a 44'
    ELSE '4. 45 o más'
  END AS tramo_edad,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY tramo_edad
ORDER BY tramo_edad;

-- Cruce tramo de edad x horas extra
SELECT
  CASE
    WHEN Age < 25 THEN '1. Menos de 25'
    WHEN Age < 35 THEN '2. 25 a 34'
    WHEN Age < 45 THEN '3. 35 a 44'
    ELSE '4. 45 o más'
  END AS tramo_edad,
  OverTime,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY tramo_edad, OverTime
ORDER BY tramo_edad, OverTime;

-- Tasa de renuncia por años en la empresa
SELECT
  CASE
    WHEN YearsAtCompany < 2 THEN '1. 0 a 1'
    WHEN YearsAtCompany < 5 THEN '2. 2 a 4'
    WHEN YearsAtCompany < 10 THEN '3. 5 a 9'
    ELSE '4. 10 o más'
  END AS tramo_antiguedad,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY tramo_antiguedad
ORDER BY tramo_antiguedad;

-- Cruce años en la empresa x horas extra
SELECT
  CASE
    WHEN YearsAtCompany < 2 THEN '1. 0 a 1'
    WHEN YearsAtCompany < 5 THEN '2. 2 a 4'
    WHEN YearsAtCompany < 10 THEN '3. 5 a 9'
    ELSE '4. 10 o más'
  END AS tramo_antiguedad,
  OverTime,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS renuncias,
  ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1) AS tasa_pct
FROM employees
GROUP BY tramo_antiguedad, OverTime
ORDER BY tramo_antiguedad, OverTime;
