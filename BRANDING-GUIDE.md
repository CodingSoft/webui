# Guía de Branding - CodingSoft WebUI

Esta guía documenta el sistema de personalización implementado en el fork de CodingSoft.

## 🎯 Objetivo

Crear un sistema mantenible que permita:
1. Personalizar completamente la apariencia para CodingSoft
2. Mantener la capacidad de actualizar desde upstream
3. Centralizar todas las configuraciones
4. Documentar el proceso claramente

## 📁 Estructura del Sistema

### Archivos Principales

```
branding/
├── branding.config.json          # Configuración central
├── simple-apply.cjs              # Script de aplicación
└── original-logos/               # Logos originales (backup)

static/static/                    # Logos personalizados
├── favicon.png                   # Favicon claro
├── favicon-dark.png              # Favicon oscuro  
├── splash.png                    # Splash screen claro
├── splash-dark.png               # Splash screen oscuro
└── [otros logos...]

docs/
├── BRANDING-GUIDE.md            # Esta guía
└── UPSTREAM-SYNC.md             # Guía de sincronización
```

### Archivos Modificados

| Archivo | Propósito | Estrategia de Merge |
|---------|-----------|---------------------|
| `package.json` | Nombre y descripción | Preservar nombre "codingsoft-webui" |
| `src/app.html` | Título y metadatos | Preservar personalizaciones |
| `static/static/site.webmanifest` | PWA config | Actualizar nombre/colores |
| `static/opensearch.xml` | Búsqueda | Actualizar textos |
| `README.md` | Documentación principal | Reescribir completamente |

## ⚙️ Configuración Centralizada

### `branding.config.json`

```json
{
  "appName": "CodingSoft AI",
  "appShortName": "CS AI",
  "website": "https://codingsoft.mx",
  "description": "Plataforma de IA de CodingSoft...",
  "colors": {
    "primary": "#2563eb",
    "darkBackground": "#171717",
    "lightBackground": "#ffffff"
  },
  "texts": {
    "tagline": "AI Platform by CodingSoft",
    "copyright": "© 2025 CodingSoft - Todos los derechos reservados"
  },
  "logos": {
    "favicon": "favicon.png",
    "splashLight": "splash.png",
    "splashDark": "splash-dark.png"
  },
  "meta": {
    "author": "CodingSoft",
    "keywords": "ai, codingsoft, chatbot",
    "themeColor": "#2563eb"
  }
}
```

### Variables Disponibles

| Variable | Uso | Ejemplo |
|----------|-----|---------|
| `appName` | Título principal | "CodingSoft AI" |
| `appShortName` | Nombres cortos | "CS AI" |
| `colors.primary` | Color tema | "#2563eb" |
| `meta.themeColor` | Meta tag theme-color | "#2563eb" |

## 🔄 Proceso de Aplicación

### Script de Aplicación

```bash
# Aplicar branding desde configuración
node branding/simple-apply.cjs
```

**Lo que hace el script:**
1. Lee `branding.config.json`
2. Actualiza `package.json` (nombre, descripción)
3. Modifica `src/app.html` (título, theme-color)
4. Actualiza `static/opensearch.xml` (textos de búsqueda)
5. Modifica `static/static/site.webmanifest` (PWA)

### Actualización Manual (Opcional)

Si necesitas cambios más específicos:

```bash
# 1. Actualizar package.json
npm pkg set name="codingsoft-webui"
npm pkg set description="Plataforma de IA de CodingSoft..."

# 2. Actualizar app.html
sed -i '' 's/<title>Open WebUI<\/title>/<title>CodingSoft AI<\/title>/g' src/app.html
sed -i '' 's/content="#171717"/content="#2563eb"/g' src/app.html

# 3. Actualizar site.webmanifest
jq '.name = "CodingSoft AI" | .short_name = "CS AI" | .theme_color = "#2563eb" | .background_color = "#2563eb"' static/static/site.webmanifest > temp && mv temp static/static/site.webmanifest
```

## 🖼️ Sistema de Logos

### Requisitos de Logos

| Archivo | Dimensiones | Formato | Uso |
|---------|-------------|---------|-----|
| `favicon.png` | 32x32 | PNG | Favicon principal |
| `favicon-dark.png` | 32x32 | PNG | Favicon modo oscuro |
| `splash.png` | 512x512 | PNG | Splash screen claro |
| `splash-dark.png` | 512x512 | PNG | Splash screen oscuro |
| `logo.png` | 128x128 | PNG | Logo principal |
| `apple-touch-icon.png` | 180x180 | PNG | iOS homescreen |
| `web-app-manifest-192x192.png` | 192x192 | PNG | PWA icon pequeño |
| `web-app-manifest-512x512.png` | 512x512 | PNG | PWA icon grande |

### Proceso de Reemplazo

1. **Preparar logos** con nombres idénticos a los originales
2. **Copiar a `static/static/`**:
   ```bash
   cp branding/new-logos/* static/static/
   ```
3. **Verificar** que todos los archivos necesarios existen
4. **Ejecutar script** de branding
5. **Reconstruir** la aplicación

## 🔄 Sincronización con Upstream

### Flujo de Trabajo Recomendado

```bash
# 1. Ver estado actual
git status
git log --oneline -10

# 2. Traer cambios del upstream
git fetch upstream

# 3. Crear rama para merge
git checkout -b merge-upstream-$(date +%Y%m%d)

# 4. Merge con revisión manual
git merge upstream/main --no-commit

# 5. Revisar conflictos
git status
# Resolver conflictos manualmente

# 6. Preservar personalizaciones
# Para archivos conflictivos:
git checkout --ours package.json      # Mantener nuestra versión
git checkout --ours src/app.html      # Mantener nuestra versión
git checkout --ours static/static/*   # Mantener nuestros logos

# 7. Commit del merge
git commit -m "Merge upstream/main - preservando branding CodingSoft"

# 8. Volver a main y mergear
git checkout main
git merge merge-upstream-$(date +%Y%m%d)

# 9. Aplicar branding si es necesario
node branding/simple-apply.cjs
```

### Estrategias de Resolución de Conflictos

| Tipo de Archivo | Estrategia | Razón |
|-----------------|------------|-------|
| Archivos de branding | **Siempre ours** | Preservar personalización |
| Archivos de configuración | **Manual** | Mergear funcionalidad, preservar branding |
| Archivos de código | **Theirs** | Actualizar funcionalidad |
| Archivos de assets/logos | **Siempre ours** | Logos personalizados |

### Archivos Críticos a Preservar

```bash
# Estos archivos NUNCA deben sobrescribirse:
git checkout --ours package.json
git checkout --ours src/app.html
git checkout --ours branding.config.json
git checkout --ours branding/simple-apply.cjs
git checkout --ours static/opensearch.xml
git checkout --ours static/static/site.webmanifest
git checkout --ours README.md
git checkout --ours README-CUSTOM.md
git checkout --ours BRANDING-GUIDE.md

# Logos - siempre preservar
git checkout --ours static/static/favicon.png
git checkout --ours static/static/favicon-dark.png
git checkout --ours static/static/splash.png
git checkout --ours static/static/splash-dark.png
git checkout --ours static/static/logo.png
git checkout --ours static/static/apple-touch-icon.png
```

## 🚨 Problemas Comunes y Soluciones

### 1. Merge Conflict en package.json

**Síntoma**: Conflictos en `name` o `description`

**Solución**:
```bash
# Mantener nuestra versión
git checkout --ours package.json

# Luego actualizar manualmente otras partes si es necesario
# Revisar cambios del upstream que queremos incorporar
```

### 2. Logos Sobrescritos

**Síntoma**: Logos revertidos a versión original

**Solución**:
```bash
# Restaurar nuestros logos
git checkout --ours static/static/*.png
git checkout --ours static/static/*.svg
git checkout --ours static/static/*.ico

# Asegurarse de tener backup
cp -r static/static/* branding/original-logos-backup/
```

### 3. Script de Branding No Funciona

**Síntoma**: Errores al ejecutar `node branding/simple-apply.cjs`

**Solución**:
1. Verificar que `branding.config.json` existe y es JSON válido
2. Verificar permisos: `chmod +x branding/simple-apply.cjs`
3. Ejecutar manualmente los pasos del script

### 4. Cambios Perdidos Después de Merge

**Síntoma**: Personalizaciones desaparecen después de sync

**Solución**:
```bash
# Hacer backup antes de merge
git branch backup-pre-merge-$(date +%Y%m%d-%H%M%S)

# Usar estrategia de merge con --no-commit
git merge upstream/main --no-commit

# Aplicar branding después del merge
node branding/simple-apply.cjs
```

## 📈 Mejores Prácticas

### 1. Antes de Hacer Merge
```bash
# Backup completo
git branch backup-before-merge-$(date +%Y%m%d)
cp -r static/static/ branding/backup-logos-$(date +%Y%m%d)/
```

### 2. Durante el Merge
- Siempre usar `--no-commit`
- Revisar cada conflicto manualmente
- Documentar decisiones de merge

### 3. Después del Merge
```bash
# Ejecutar script de branding
node branding/simple-apply.cjs

# Probar la aplicación
npm run build
npm run preview

# Commit final
git add .
git commit -m "Merge completo con upstream - branding aplicado"
```

### 4. Mantenimiento Regular
- Actualizar esta guía cuando cambie el sistema
- Mantener backup de logos originales y personalizados
- Probar el script de branding periódicamente

## 🤖 Automatización (Futuro)

### GitHub Actions
```yaml
# .github/workflows/auto-branding.yml
name: Auto-apply branding
on:
  push:
    branches: [main]
  
jobs:
  apply-branding:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Apply branding
        run: node branding/simple-apply.cjs
      - name: Commit changes
        run: |
          git config user.name "GitHub Action"
          git config user.email "action@github.com"
          git add .
          git commit -m "Auto-applied branding" || echo "No changes to commit"
          git push
```

### Script Avanzado (Futura Mejora)
```javascript
// branding/advanced-apply.mjs
import { readFileSync, writeFileSync } from 'fs';
import { join } from 'path';

// Incluir:
// - Validación de logos
// - Generación de logos desde SVG
// - Actualización de traducciones
// - Modificación de estilos CSS/SCSS
```

## 📚 Recursos

- **Open WebUI Docs**: https://docs.openwebui.com/
- **Repositorio Original**: https://github.com/open-webui/open-webui
- **Discord Community**: https://discord.gg/5rJgQTnV4s
- **CodingSoft Website**: https://codingsoft.mx

---

**Última Actualización**: $(date +%Y-%m-%d)

**Mantenido por**: Equipo de Desarrollo - CodingSoft

**Contacto**: desarrollo@codingsoft.mx