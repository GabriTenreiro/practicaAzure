# AGENTS.md - Reglas para Agentes de IA

## Regla estricta de ramas

**SIEMPRE** crea una nueva rama de Git usando el formato `agent/<nombre-de-tarea>` antes de editar o añadir cualquier código.

**NUNCA** hagas commits directamente en la rama `main`.

### Flujo de trabajo obligatorio:

1. Crear rama: `git checkout -b agent/<nombre-de-tarea>`
2. Realizar los cambios necesarios
3. Hacer commit en la rama `agent/`
4. NO hacer merge a `main` sin aprobación del usuario

### Ejemplos de nombres de rama válidos:

- `agent/add-auth-endpoint`
- `agent/fix-login-bug`
- `agent/update-readme`
- `agent/refactor-database-models`
