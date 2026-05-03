# AGENTS.md - Reglas para Agentes de IA

## Regla estricta de ramas

**SIEMPRE** crea una nueva rama de Git usando el formato `agent/<nombre-de-tarea>` antes de editar o añadir cualquier código.

**NUNCA** hagas commits directamente en la rama `main`.

### Flujo de trabajo obligatorio:

1. Crear rama: `git checkout -b agent/<nombre-de-tarea>`
2. Realizar los cambios necesarios
3. Hacer commit en la rama `agent/`
4. NO hacer merge a `main` sin aprobación del usuario

## Proyecto

Práctica fin de curso — data pipeline con **PySpark** sobre un dataset de laptops scraped, desplegado en **Azure Synapse Analytics**.

**Problema de negocio:** Predicción de precios de laptops basada en especificaciones técnicas.

**Dataset:** `laptop_scrap_data.csv` — 1,563 filas, 21 columnas (scraped de tiendas online).

## Entorno y comandos

- **Gestor de paquetes**: `uv` (no pip). Usa `uv sync` para instalar dependencias.
- **Python**: 3.12 (ver `.python-version`).
- **Entorno virtual**: `.venv/` (en `.gitignore`).
- **Ejecutar notebooks localmente**: desde `notebooks/` o usar `ipykernel` ya instalado en el venv.

## Windows + Spark: HADOOP_HOME obligatorio (solo local)

Spark en Windows necesita `winutils.exe`. La variable `HADOOP_HOME` debe apuntar a `hadoop/` **antes** de crear la `SparkSession`:

```python
os.environ['HADOOP_HOME'] = r"<ruta-al-repo>\hadoop"
```

Los binarios están en `hadoop/bin/` (`winutils.exe` + `hadoop.dll`).

> **Nota:** En Azure Synapse esto NO es necesario — el runtime Linux ya incluye los binarios.

## Infraestructura Azure

| Recurso | Nombre |
|---|---|
| Resource Group | `rg-gabritenreiro` |
| Storage Account | `stgabritenreiroprueba` (ADLS Gen2) |
| Synapse Workspace | `syn-laptop-dl-dev-001` |
| Spark Pool | `sparkpoollaptop` (Small, 3 nodes, auto-shutdown 15min, Spark 3.4) |

### Despliegue

```bash
az deployment group create --resource-group rg-gabritenreiro --template-file infra/deploy.bicep
```

### Paths ADLS Gen2

| Zona | Path |
|---|---|
| Raw | `abfss://raw@stgabritenreiroprueba.dfs.core.windows.net/` |
| Processed | `abfss://processed@stgabritenreiroprueba.dfs.core.windows.net/` |
| Quarantine | `abfss://quarantine@stgabritenreiroprueba.dfs.core.windows.net/` |
| Curated | `abfss://curated@stgabritenreiroprueba.dfs.core.windows.net/` |
| Rejected | `abfss://rejected@stgabritenreiroprueba.dfs.core.windows.net/` |

## Arquitectura del datalake

Estructura tipo medallón:

| Zona | Contenido |
|---|---|
| `raw/` | CSV fuente (`laptop_scrap_data.csv`) |
| `processed/` | Datos limpios en Parquet (snappy) — 1,549 filas |
| `quarantine/` | Registros anómalos recuperables en Parquet — ~11 filas |
| `curated/` | Datos deduplicados + columnas derivadas, particionado por Company — ~1,547 filas |
| `rejected/` | Registros irrecuperables (100% NULL) — 3 filas |

## Pipeline ETL (notebooks Synapse)

| Notebook | Función |
|---|---|
| `01_ingesta_raw_a_processed.ipynb` | CSV → schema explícito → calidad → quarantine → processed |
| `02_processed_to_curated.ipynb` | Deduplicar + columnas derivadas + partición por Company |
| `03_quarantine_to_rejected.ipynb` | Separar irrecuperables → rejected, resto → quarantine |
| `04_eda_y_visualizacion.ipynb` | EDA desde Curated: precio promedio, config estándar, market share |
| `05_modelado_ml.ipynb` | Predicción de precios: LR, RF, GBT + feature importance |

**Notas clave para notebooks Synapse:**
- La variable `spark` ya viene inyectada — NO crear `SparkSession`
- NO usar `os.environ['HADOOP_HOME']` — no necesario en Linux
- Usar `mssparkutils.notebook.getParameter()` para parámetros
- Paths en formato `abfss://container@account.dfs.core.windows.net/`
- El rename `HHD` → `HDD` se aplica a AMBOS branches (clean y quarantine)

## Calidad de datos

**Criterios de quarantine:** Price/Ram_GB/Weight_kg/Inches nulos o <= 0.
**Criterios de rejected:** Todas las columnas NULL.
**Pruebas:** Ver `docs/plan_de_pruebas.md` (10 pruebas: integridad, unicidad, completitud, consistencia).

## Documentación

| Archivo | Contenido |
|---|---|
| `docs/modelo_de_datos.md` | Arquitectura medallón, schemas, reglas de calidad, flujo de datos |
| `docs/plan_de_pruebas.md` | 10 pruebas con criterios PASS/FAIL |
| `docs/evidencias_pruebas.md` | Plantilla para rellenar con resultados reales |
| `dashboard/README.md` | Instrucciones para crear el dashboard Power BI (.pbix) |

## `main.py`

Es un placeholder sin funcionalidad real. No es el entrypoint del proyecto.
