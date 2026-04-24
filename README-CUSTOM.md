# CodingSoft AI

Plataforma de IA de CodingSoft - Interfaz personalizada basada en Open WebUI

## 🚀 Características

- Interfaz personalizada para CodingSoft
- Basado en Open WebUI v0.9.1
- Branding completo de CodingSoft
- Configuración centralizada

## 🎨 Sistema de Personalización

### Archivos de Configuración

1. **`branding.config.json`** - Configuración central de branding
2. **`branding/original-logos/`** - Logos originales de Open WebUI
3. **`README-CUSTOM.md`** - Esta documentación

### Valores Configurables

- **Nombre de aplicación**: `CodingSoft AI`
- **Color primario**: `#2563eb` (Azul CodingSoft)
- **Logos**: Todos los archivos en `/static/static/`
- **Metadatos**: Título, descripción, keywords

### Para Aplicar Cambios

1. Editar `branding.config.json`
2. Reemplazar logos en `/static/static/` (mantener nombres iguales)
3. Reconstruir la aplicación:
   ```bash
   npm run build
   ```

## 📦 Instalación y Desarrollo

```bash
# Instalar dependencias
npm install

# Desarrollo
npm run dev

# Construcción para producción
npm run build

# Vista previa
npm run preview
```

## 🔄 Mantenimiento del Fork

### Sincronización con Upstream

```bash
# Agregar upstream (solo primera vez)
git remote add upstream https://github.com/open-webui/open-webui.git

# Traer cambios del upstream
git fetch upstream

# Ver diferencias
git diff main..upstream/main

# Merge seguro (preserva customizaciones)
git merge upstream/main --no-commit
# Revisar conflictos y resolver
```

### Preservar Personalizaciones

Las customizaciones están en:
- `package.json` - Nombre y descripción
- `src/app.html` - Título y metadatos
- `static/static/` - Logos e íconos
- `static/opensearch.xml` - Búsqueda
- `static/static/site.webmanifest` - PWA

## 🤝 Contribución

Este es un fork personalizado para CodingSoft.
Para contribuciones al proyecto base, visita: https://github.com/open-webui/open-webui

## 📊 Estado Actual

✅ **Completado:**
- Sistema de configuración centralizada
- Branding básico (nombre, colores, metadatos)
- Documentación del sistema

⏳ **Pendiente:**
- Logos personalizados de CodingSoft
- Customizaciones avanzadas de UI
- Script de automatización de branding

---

© 2025 CodingSoft - Todos los derechos reservados