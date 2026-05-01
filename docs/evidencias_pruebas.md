# Evidencias de Pruebas — Laptop Data Pipeline

> **Nota:** Este documento debe completarse con los resultados reales tras ejecutar las pruebas en Azure Synapse. Las evidencias se capturan como screenshots o output de los notebooks.

## Ejecución

| Campo | Valor |
|---|---|
| **Fecha de ejecución** | _(completar)_ |
| **Entorno** | Azure Synapse — `syn-laptop-dl-dev-001` |
| **Spark Pool** | `sparkpoollaptop` |
| **Ejecutado por** | _(completar)_ |

## Resultados

### P-01: Integridad — No columnas 100% nulas en Processed

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **Evidencia** | _(pegar screenshot del output del null_profile)_ |

### P-02: Integridad — Price > 0 en Processed

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **MIN(Price)** | _(valor)_ |
| **Evidencia** | _(pegar screenshot)_ |

### P-03: Integridad — Ram_GB > 0 en Processed

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **MIN(Ram_GB)** | _(valor)_ |
| **Evidencia** | _(pegar screenshot)_ |

### P-04: Integridad — Weight_kg > 0 en Processed

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **MIN(Weight_kg)** | _(valor)_ |
| **Evidencia** | _(pegar screenshot)_ |

### P-05: Unicidad — No duplicados exactos en Curated

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **COUNT(*)** | _(valor)_ |
| **COUNT(DISTINCT *)** | _(valor)_ |
| **Evidencia** | _(pegar screenshot)_ |

### P-06: Completitud — % nulos por columna < 5%

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **Columna con mayor % null** | _(nombre y porcentaje)_ |
| **Evidencia** | _(pegar screenshot)_ |

### P-07: Consistencia — Columna HDD renombrada correctamente

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **HDD existe** | Sí / No |
| **HHD existe** | Sí / No |
| **Evidencia** | _(pegar screenshot del printSchema)_ |

### P-08: Consistencia — Tipos de datos correctos en Processed

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **Evidencia** | _(pegar screenshot del printSchema)_ |

### P-09: Consistencia — Conteo total coherente

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **Raw** | 1,563 |
| **Processed** | _(valor)_ |
| **Quarantine** | _(valor)_ |
| **Rejected** | _(valor)_ |
| **Suma** | _(valor)_ |
| **Evidencia** | _(pegar screenshot)_ |

### P-10: Consistencia — Columnas derivadas en Curated

| Campo | Valor |
|---|---|
| **Resultado** | ⬜ PASS / ⬜ FAIL |
| **Columnas verificadas** | Price_per_RAM_GB, Price_per_Storage_GB, CPU_Brand, GPU_Brand, Has_Dedicated_GPU, Screen_Category |
| **Evidencia** | _(pegar screenshot)_ |

## Resumen Final

| Prueba | Tipo | Resultado |
|---|---|---|
| P-01 | Integridad | ⬜ |
| P-02 | Integridad | ⬜ |
| P-03 | Integridad | ⬜ |
| P-04 | Integridad | ⬜ |
| P-05 | Unicidad | ⬜ |
| P-06 | Completitud | ⬜ |
| P-07 | Consistencia | ⬜ |
| P-08 | Consistencia | ⬜ |
| P-09 | Consistencia | ⬜ |
| P-10 | Consistencia | ⬜ |

**Total PASS:** _/10_
**Total FAIL:** _/10_
