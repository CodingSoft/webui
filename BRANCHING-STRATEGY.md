# 🌿 Estrategia de Ramas - CodingSoft WebUI

## 📋 Resumen de Ramas

```
upstream/main ────────────────→ (código original)
        │
        ▼
    main ───────────────────→ (sincronizada con upstream, limpia)
        │
        ├── codingsoft/custom ──→ (personalizaciones + branding)
        │
        ├── codingsoft/develop ─→ (desarrollo de nuevas features)
        │
        └── codingsoft/production → (versión estable para deploy)
```

## 🎯 Propósito de cada Rama

### `main`
- **Propósito:** Punto de sincronización con upstream
- **Estado:** Siempre idéntica a `upstream/main`
- **Commits:** Solo merge de upstream, sin cambios propios
- **Uso:** Sincronización y base para otras ramas

### `codingsoft/custom` ⭐ (Principal)
- **Propósito:** Tu versión personalizada de Open WebUI
- **Contiene:** Branding, seguridad, features personalizadas
- **Base:** `main` + tus customizaciones
- **Uso:** Trabajo diario, desarrollo continuo

### `codingsoft/develop`
- **Propósito:** Desarrollo de nuevas features
- **Base:** `codingsoft/custom`
- **Uso:** Features experimentales antes de merge a custom

### `codingsoft/production`
- **Propósito:** Versión estable para despliegue
- **Base:** `codingsoft/custom` (cuando esté estable)
- **Uso:** Deploy en producción

## 🔄 Flujo de Trabajo

### 1. Sincronizar con Upstream
```bash
# En main
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# Actualizar custom
git checkout codingsoft/custom
git merge main
# Resolver conflictos si los hay
git push origin codingsoft/custom
```

### 2. Desarrollar Nueva Feature
```bash
# Crear rama feature desde custom
git checkout codingsoft/custom
git checkout -b feature/nueva-funcion

# Trabajar...
git commit -m "feat: descripción"
git push origin feature/nueva-funcion

# Merge a develop para pruebas
git checkout codingsoft/develop
git merge feature/nueva-funcion
git push origin codingsoft/develop

# Cuando esté lista, merge a custom
git checkout codingsoft/custom
git merge codingsoft/develop
git push origin codingsoft/custom
```

### 3. Preparar para Producción
```bash
git checkout codingsoft/production
git merge codingsoft/custom
git tag v0.9.2-codingsoft.1
git push origin codingsoft/production --tags
```

## 📝 Convenciones de Commits

- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `security:` Fix de seguridad
- `chore:` Tareas de mantenimiento
- `docs:` Documentación
- `style:` Cambios de estilo/formato
- `refactor:` Refactorización de código
- `sync:` Sincronización con upstream

## ⚠️ Reglas Importantes

1. **Nunca hagas push force** en `main` o `codingsoft/custom`
2. **Siempre crea branches** para nuevas features
3. **Testea en develop** antes de merge a custom
4. **Documenta** tus cambios en CUSTOMIZATIONS.md

## 🚀 Comandos Rápidos

```bash
# Ver estado de todas las ramas
git branch -vv

# Ver commits que no están en upstream
git log upstream/main..codingsoft/custom --oneline

# Ver cambios desde el último sync
git log --since="1 week ago" --oneline

# Comparar con upstream
git diff upstream/main..codingsoft/custom --stat
```
