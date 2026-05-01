# Dashboard Power BI — Laptop Data Analysis

## Conexión de Datos

### Opción A: Directa desde ADLS Gen2 (recomendada si tienes acceso Azure)

1. Abre **Power BI Desktop**
2. **Obtener datos** → **Azure** → **Azure Data Lake Storage Gen2**
3. URL: `https://stgabritenreiroprueba.dfs.core.windows.net`
4. Autenticación: **Cuenta de Microsoft** (la misma de tu suscripción Azure)
5. Navega al container `curated` y selecciona los archivos `.parquet`
6. Power BI leerá automáticamente el particionamiento por `Company`

### Opción B: Desde CSV local (si no tienes acceso directo a Azure)

1. Exporta los datos de `curated/` a CSV desde Synapse:
   ```python
   df_curated.coalesce(1).write.mode("overwrite").option("header", "true").csv("abfss://raw@stgabritenreiroprueba.dfs.core.windows.net/curated_export/")
   ```
2. Descarga el CSV desde Azure Storage Explorer
3. En Power BI: **Obtener datos** → **Texto/CSV** → selecciona el archivo

---

## Página 1: Overview

### KPI Cards (tarjetas)
- **Total Laptops**: `COUNTROWS(tabla)` → ~1,547
- **Precio Medio**: `AVERAGE(tabla[Price])` → ~1,947 €
- **RAM Media**: `AVERAGE(tabla[Ram_GB])` → ~29 GB
- **Marcas Únicas**: `DISTINCTCOUNT(tabla[Company])`

### Gráficos
| Gráfico | Tipo | Eje X | Eje Y | Filtro |
|---|---|---|---|---|
| Precio medio por marca | Barras verticales | Company | AVG(Price) | — |
| Distribución por SO | Circular (donut) | OpSys | COUNTROWS | — |
| Distribución por almacenamiento | Barras horizontales | Storage_Category | COUNTROWS | — |

### Filtros de página
- Company (multiselección)
- OpSys (multiselección)
- Rango de precio (slider)

---

## Página 2: Análisis de Specs

### Gráficos
| Gráfico | Tipo | Eje X | Eje Y | Color |
|---|---|---|---|---|
| Precio vs RAM | Dispersión (scatter) | Ram_GB | Price | Company |
| Distribución de precios | Histograma | Price (bins) | COUNTROWS | — |
| Precio medio por GPU | Barras verticales | GPU_Brand | AVG(Price) | — |
| % GPU dedicada por marca | Barras apiladas | Company | % Has_Dedicated_GPU | — |

### Tabla
- **Top 10 mejor relación precio/RAM**: ordenar por `Price_per_RAM_GB` ASC

### Filtros de página
- CPU_Brand
- GPU_Brand
- Screen_Category

---

## Página 3: Outliers y Calidad

### Gráficos
| Gráfico | Tipo | Eje X | Eje Y | Color |
|---|---|---|---|---|
| Precio por marca (box plot) | Box & Whisker | Company | Price | — |
| Precio vs pulgadas | Dispersión | Inches | Price | CPU_Brand |

### Tablas
| Tabla | Columnas | Orden |
|---|---|---|
| Top 10 más caras | TypeName, Company, Price, Ram_GB, Cpu, Gpu | Price DESC |
| Top 10 mejor precio/RAM | TypeName, Company, Price, Ram_GB, Price_per_RAM_GB | Price_per_RAM_GB ASC |

### KPI Cards de calidad
- **Registros en Quarantine**: _(valor del notebook 03)_
- **Registros Rejected**: _(valor del notebook 03)_
- **Duplicados eliminados**: 2

---

## Formato y Diseño

### Tema
- **Tema**: Predeterminado de Power BI o "Stories"
- **Colores corporativos**: Azul (#0078D4) como color principal
- **Fondo**: Blanco con bordes sutiles en los gráficos

### Tipografía
- **Títulos**: Segoe UI Semibold, 14pt
- **Etiquetas**: Segoe UI, 10pt
- **KPIs**: Segoe UI Semibold, 24pt

### Interactividad
- Activar **cross-filtering** entre todos los gráficos
- Tooltips con detalles adicionales en cada gráfico
- Botón de navegación entre páginas en la parte superior
