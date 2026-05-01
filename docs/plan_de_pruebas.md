# Plan de Pruebas — Laptop Data Pipeline

## Objetivo

Validar la integridad, unicidad, completitud y consistencia de los datos a lo largo del pipeline ETL en Azure Synapse.

## Pruebas

### P-01: Integridad — No columnas 100% nulas en Processed

| Campo | Valor |
|---|---|
| **Tipo** | Integridad |
| **Descripción** | Ninguna columna en `processed/` debe tener el 100% de valores NULL |
| **Criterio PASS** | Para todas las columnas: `count(null) < total_rows` |
| **Criterio FAIL** | Existe al menos una columna con `count(null) == total_rows` |
| **Zona** | Processed |

### P-02: Integridad — Price > 0 en Processed

| Campo | Valor |
|---|---|
| **Tipo** | Integridad |
| **Descripción** | Todos los registros en `processed/` deben tener Price > 0 |
| **Criterio PASS** | `MIN(Price) > 0` |
| **Criterio FAIL** | `MIN(Price) <= 0` o existe algún NULL |
| **Zona** | Processed |

### P-03: Integridad — Ram_GB > 0 en Processed

| Campo | Valor |
|---|---|
| **Tipo** | Integridad |
| **Descripción** | Todos los registros en `processed/` deben tener Ram_GB > 0 |
| **Criterio PASS** | `MIN(Ram_GB) > 0` |
| **Criterio FAIL** | `MIN(Ram_GB) <= 0` o existe algún NULL |
| **Zona** | Processed |

### P-04: Integridad — Weight_kg > 0 en Processed

| Campo | Valor |
|---|---|
| **Tipo** | Integridad |
| **Descripción** | Todos los registros en `processed/` deben tener Weight_kg > 0 |
| **Criterio PASS** | `MIN(Weight_kg) > 0` |
| **Criterio FAIL** | `MIN(Weight_kg) <= 0` o existe algún NULL |
| **Zona** | Processed |

### P-05: Unicidad — No duplicados exactos en Curated

| Campo | Valor |
|---|---|
| **Tipo** | Unicidad |
| **Descripción** | No deben existir filas duplicadas exactas en `curated/` |
| **Criterio PASS** | `COUNT(*) == COUNT(DISTINCT *)` |
| **Criterio FAIL** | `COUNT(*) > COUNT(DISTINCT *)` |
| **Zona** | Curated |

### P-06: Completitud — % nulos por columna < 5%

| Campo | Valor |
|---|---|
| **Tipo** | Completitud |
| **Descripción** | El porcentaje de valores NULL por columna en `curated/` no debe superar el 5% |
| **Criterio PASS** | Para todas las columnas: `(count(null) / total_rows * 100) < 5` |
| **Criterio FAIL** | Existe al menos una columna con `% nulls >= 5` |
| **Zona** | Curated |

### P-07: Consistencia — Columna HDD renombrada correctamente

| Campo | Valor |
|---|---|
| **Tipo** | Consistencia |
| **Descripción** | La columna `HHD` (typo) ha sido renombrada a `HDD` en Processed y Curated |
| **Criterio PASS** | `HDD` existe en el schema Y `HHD` NO existe |
| **Criterio FAIL** | `HHD` sigue existiendo o `HDD` no existe |
| **Zona** | Processed, Curated |

### P-08: Consistencia — Tipos de datos correctos en Processed

| Campo | Valor |
|---|---|
| **Tipo** | Consistencia |
| **Descripción** | Los tipos de datos en `processed/` coinciden con el schema esperado |
| **Criterio PASS** | Todos los tipos coinciden con la definición del modelo de datos |
| **Criterio FAIL** | Al menos un tipo no coincide |
| **Zona** | Processed |

### P-09: Consistencia — Conteo total coherente

| Campo | Valor |
|---|---|
| **Tipo** | Consistencia |
| **Descripción** | La suma de filas en Processed + Quarantine + Rejected debe igualar el total de filas Raw |
| **Criterio PASS** | `raw_count == processed_count + quarantine_count + rejected_count` |
| **Criterio FAIL** | Los conteos no coinciden |
| **Zona** | Todas |

### P-10: Consistencia — Columnas derivadas en Curated

| Campo | Valor |
|---|---|
| **Tipo** | Consistencia |
| **Descripción** | Las 6 columnas derivadas existen en `curated/` con valores calculados correctamente |
| **Criterio PASS** | Existen: `Price_per_RAM_GB`, `Price_per_Storage_GB`, `CPU_Brand`, `GPU_Brand`, `Has_Dedicated_GPU`, `Screen_Category` |
| **Criterio FAIL** | Falta alguna columna derivada o contiene solo NULLs |
| **Zona** | Curated |

## Resumen de Pruebas

| ID | Tipo | Zona | Criterio |
|---|---|---|---|
| P-01 | Integridad | Processed | No columnas 100% NULL |
| P-02 | Integridad | Processed | Price > 0 |
| P-03 | Integridad | Processed | Ram_GB > 0 |
| P-04 | Integridad | Processed | Weight_kg > 0 |
| P-05 | Unicidad | Curated | Sin duplicados |
| P-06 | Completitud | Curated | < 5% nulos por columna |
| P-07 | Consistencia | Processed, Curated | HDD renombrado |
| P-08 | Consistencia | Processed | Tipos correctos |
| P-09 | Consistencia | Todas | Conteo coherente |
| P-10 | Consistencia | Curated | Columnas derivadas existen |
