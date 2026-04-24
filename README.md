# CodingSoft WebUI 🚀

**Fork personalizado de Open WebUI para CodingSoft**

![GitHub last commit](https://img.shields.io/github/last-commit/CodingSoft/webui?color=blue)
![Version](https://img.shields.io/badge/version-0.9.1-brightgreen)

## 📖 Acerca de este Fork

Este repositorio es un fork personalizado de **Open WebUI** adaptado para **CodingSoft**. Hemos implementado un sistema completo de branding y configuración centralizada.

🔗 **Proyecto Original**: [open-webui/open-webui](https://github.com/open-webui/open-webui)

## 🎨 Personalizaciones Aplicadas

### ✅ Completado
- **Branding completo**: Nombre "CodingSoft AI", color primario azul (#2563eb)
- **Configuración centralizada**: `branding.config.json` para fácil mantenimiento
- **Metadatos actualizados**: Título, descripción, manifest PWA
- **Sistema de documentación**: README personalizado y guías

### 📋 Archivos Modificados
- `package.json` - Nombre y descripción del proyecto
- `src/app.html` - Título y metadatos HTML
- `static/static/site.webmanifest` - Configuración PWA
- `static/opensearch.xml` - Búsqueda personalizada
- `README-CUSTOM.md` - Documentación específica del fork

## 🚀 Instalación Rápida

```bash
# Clonar el repositorio
git clone https://github.com/CodingSoft/webui.git
cd webui

# Instalar dependencias
npm install

# Desarrollo
npm run dev

# Construir para producción
npm run build
```

## 🔧 Sistema de Personalización

### Archivos de Configuración

1. **`branding.config.json`** - Configuración central
   ```json
   {
     "appName": "CodingSoft AI",
     "appShortName": "CS AI",
     "colors": {
       "primary": "#2563eb"
     }
   }
   ```

2. **`branding/simple-apply.cjs`** - Script de aplicación
   ```bash
   node branding/simple-apply.cjs
   ```

3. **`branding/original-logos/`** - Logos originales (backup)

### Para Personalizar

1. Edita `branding.config.json`
2. Reemplaza logos en `static/static/`
3. Ejecuta `node branding/simple-apply.cjs`
4. Reconstruye: `npm run build`

## 🔄 Mantenimiento del Fork

### Sincronización con Upstream

```bash
# Traer cambios del original
git fetch upstream

# Ver diferencias
git diff main..upstream/main

# Merge seguro (preserva customizaciones)
git merge upstream/main --no-commit
# Resolver conflictos manualmente
```

### Conflictos Comunes y Soluciones

| Archivo | Estrategia |
|---------|------------|
| `package.json` | Mantener nombre "codingsoft-webui", mergear resto |
| `src/app.html` | Preservar título y theme-color personalizados |
| Archivos de logos | Siempre preservar versiones personalizadas |

## 📁 Estructura del Proyecto

```
codingsoft-webui/
├── branding/                    # Sistema de personalización
│   ├── config.json             # Configuración central
│   ├── simple-apply.cjs        # Script de aplicación
│   └── original-logos/         # Logos originales (backup)
├── static/static/              # Logos e íconos personalizados
├── README-CUSTOM.md            # Documentación específica
└── [archivos del proyecto base]
```

## 🤝 Contribución

Este fork está mantenido por **CodingSoft**. Para contribuciones al proyecto base, visita el repositorio original:

👉 **[open-webui/open-webui](https://github.com/open-webui/open-webui)**

### Reportar Issues
- Issues del **fork**: [CodingSoft/webui/issues](https://github.com/CodingSoft/webui/issues)
- Issues del **proyecto base**: [open-webui/open-webui/issues](https://github.com/open-webui/open-webui/issues)

## 📊 Estado del Fork

**Última sincronización**: `upstream/main` @ `0a8a620fb`
**Versión base**: Open WebUI v0.9.1
**Customizaciones**: Branding completo, sistema de configuración

---

## 📄 Licencia

Este proyecto está bajo la misma licencia que Open WebUI. Ver [LICENSE](LICENSE) para detalles.

**CodingSoft WebUI** © 2025 CodingSoft - Fork de Open WebUI

*"Powered by Open WebUI Community"*