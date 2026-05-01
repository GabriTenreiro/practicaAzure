# Modelo de Datos — Laptop Data Pipeline

## Arquitectura Medallón

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    RAW      │────▶│  PROCESSED  │────▶│   CURATED   │
│  (Bronze)   │     │  (Silver)   │     │   (Gold)    │
└─────────────┘     └─────────────┘     └─────────────┘
       │                    │
       ▼                    ▼
┌─────────────┐     ┌─────────────┐
│ QUARANTINE  │────▶│  REJECTED   │
│ (Anómalos)  │     │ (Irrecup.)  │
└─────────────┘     └─────────────┘
```

## Zonas del Datalake

| Zona | Container ADLS | Formato | Partición | Descripción |
|---|---|---|---|---|
| **Raw** | `raw` | CSV | Ninguna | Datos crudos del scraping, sin transformar |
| **Processed** | `processed` | Parquet (snappy) | Ninguna | Datos limpios, tipos estandarizados, sin duplicados eliminados |
| **Curated** | `curated` | Parquet (snappy) | Por `Company` | Datos deduplicados + columnas derivadas para consumo |
| **Quarantine** | `quarantine` | Parquet (snappy) | Ninguna | Registros con anomalías recuperables (Weight_kg=0, etc.) |
| **Rejected** | `rejected` | Parquet (snappy) | Ninguna | Registros irrecuperables (100% NULL) |

## Schema de Datos

### Raw / Processed (21 columnas)

| Columna | Tipo | Nullable | Descripción |
|---|---|---|---|
| `Company` | String | Sí | Marca del fabricante (MSI, ASUS, Lenovo, etc.) |
| `TypeName` | String | Sí | Modelo específico del laptop |
| `Inches` | Double | Sí | Tamaño de pantalla en pulgadas |
| `ScreenResolution` | String | Sí | Resolución en formato "W x H" |
| `Cpu` | String | Sí | Procesador completo |
| `Gpu` | String | Sí | Tarjeta gráfica completa |
| `OpSys` | String | Sí | Sistema operativo |
| `TouchScreen` | Integer | Sí | 1 = táctil, 0 = no táctil |
| `Ips` | Integer | Sí | 1 = panel IPS, 0 = otro |
| `X_res` | Integer | Sí | Resolución horizontal en píxeles |
| `Y_res` | Integer | Sí | Resolución vertical en píxeles |
| `ppi` | Double | Sí | Píxeles por pulgada |
| `Dedicated_Gpu` | Integer | Sí | 1 = GPU dedicada, 0 = integrada |
| `Ram_GB` | Integer | Sí | Memoria RAM en GB |
| `Weight_kg` | Double | Sí | Peso en kilogramos |
| `SSD` | Integer | Sí | Capacidad SSD en GB |
| `HDD` | Integer | Sí | Capacidad HDD en GB (renombrado de `HHD`) |
| `Storage_Type` | String | Sí | Categoría de almacenamiento |
| `Total_Storage_GB` | Integer | Sí | Almacenamiento total en GB |
| `Storage_Category` | String | Sí | Categoría de capacidad |
| `Price` | Double | Sí | Precio en euros |

### Curated (27 columnas — 21 base + 6 derivadas)

| Columna | Tipo | Origen | Descripción |
|---|---|---|---|
| *(21 columnas base)* | — | Heredadas de Processed | Mismo schema que Processed |
| `Price_per_RAM_GB` | Double | Derivada | Price / Ram_GB |
| `Price_per_Storage_GB` | Double | Derivada | Price / Total_Storage_GB |
| `CPU_Brand` | String | Derivada | Intel / AMD / Apple / Other |
| `GPU_Brand` | String | Derivada | NVIDIA / AMD / Intel / Other |
| `Has_Dedicated_GPU` | Integer | Derivada | 1 si Dedicated_Gpu == 1 |
| `Screen_Category` | String | Derivada | Compact / Standard / Large / XL |

## Reglas de Calidad por Zona

### Raw → Processed
| Regla | Criterio | Acción |
|---|---|---|
| Price válido | NOT NULL AND > 0 | Si no → Quarantine |
| Ram_GB válido | NOT NULL AND > 0 | Si no → Quarantine |
| Weight_kg válido | NOT NULL AND > 0 | Si no → Quarantine |
| Inches válido | NOT NULL AND > 0 | Si no → Quarantine |
| Columna HHD | Typo del scraping | Renombrar a HDD |
| Tipos de datos | Inferidos del CSV | Cast explícito a tipos correctos |

### Processed → Curated
| Regla | Criterio | Acción |
|---|---|---|
| Duplicados exactos | Filas idénticas en todas las columnas | Eliminar (dropDuplicates) |
| Columnas derivadas | Cálculos sobre datos existentes | Añadir 6 nuevas columnas |
| Particionamiento | Optimización de consulta | Particionar por Company |

### Quarantine → Rejected
| Regla | Criterio | Acción |
|---|---|---|
| Irrecuperable | TODAS las columnas NULL | Mover a Rejected |
| Recuperable | Al menos 1 columna con dato | Mantener en Quarantine |

## Flujo de Datos

```
laptop_scrap_data.csv (1,563 filas)
    │
    ├─ 01_ingesta_raw_a_processed.ipynb
    │   ├─ Diagnóstico: 3 filas 100% NULL, 2 duplicados
    │   ├─ Quarantine: 14 filas (Price/Ram/Weight/Inches inválidos)
    │   └─ Processed: 1,549 filas
    │
    ├─ 02_processed_to_curated.ipynb
    │   ├─ Elimina 2 duplicados exactos
    │   ├─ Añade 6 columnas derivadas
    │   └─ Curated: 1,547 filas (particionado por Company)
    │
    └─ 03_quarantine_to_rejected.ipynb
        ├─ Rejected: 3 filas (100% NULL)
        └─ Quarantine: 11 filas (recuperables)
```

## Infraestructura Azure

| Recurso | Nombre |
|---|---|
| Resource Group | `rg-gabritenreiro` |
| Storage Account | `stgabritenreiroprueba` (ADLS Gen2) |
| Synapse Workspace | `syn-laptop-dl-dev-001` |
| Spark Pool | `sparkpoollaptop` (Small, 3 nodes, auto-shutdown 15min) |
