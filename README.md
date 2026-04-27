# 🤖 CodingSoft AI - Open WebUI

[![GitHub last commit](https://img.shields.io/github/last-commit/CodingSoft/webui/codingsoft/custom?color=blue)](https://github.com/CodingSoft/webui/commits/codingsoft/custom)
[![Version](https://img.shields.io/badge/version-codingsoft--v0.9.2-brightgreen)](https://github.com/CodingSoft/webui/releases)
[![License](https://img.shields.io/badge/license-Open%20WebUI%20License-blue)](LICENSE)
[![Upstream](https://img.shields.io/badge/upstream-open--webui%2Fopen--webui-orange)](https://github.com/open-webui/open-webui)

**Plataforma de Inteligencia Artificial personalizada basada en Open WebUI**

🔗 **[Sitio Web](https://codingsoft.mx)** | 📖 **[Documentación](CUSTOMIZATIONS.md)** | 🚀 **[Releases](https://github.com/CodingSoft/webui/releases)**

---

## 📋 Tabla de Contenidos

- [🎯 Características](#-características)
- [🏗️ Estructura del Proyecto](#️-estructura-del-proyecto)
- [🚀 Instalación](#-instalación)
- [🔄 Mantenimiento](#-mantenimiento)
- [📁 Documentación](#-documentación)
- [🤝 Contribución](#-contribución)
- [📄 Licencia](#-licencia)

---

## 🎯 Características

### ✨ Personalizaciones de CodingSoft

- 🎨 **Branding Completo**: Nombre "CodingSoft AI", colores corporativos, logos personalizados
- 🔒 **Mejoras de Seguridad**: Actualización de dependencias vulnerables, protección SSRF, fixes de XSS
- 📁 **Gestión de Archivos**: Sistema de archivos local y gestión de proyectos estilo LobeHub Desktop
- 🤖 **Automatizaciones**: Scheduler integrado con calendario

### 🌿 Gestión Profesional de Código

- ✅ **Estrategia de Ramas**: Sistema `codingsoft/*` para desarrollo organizado
- 🏷️ **Versionado Consistente**: Tags `codingsoft-v{VERSION}` siguiendo upstream
- 🔄 **Sincronización Automatizada**: Scripts para mantenerse actualizado con Open WebUI
- 📝 **Documentación Completa**: Guías de branching, customizaciones y contribución

---

## 🏗️ Estructura del Proyecto

```
CodingSoft/webui/
├── 📁 .github/               # GitHub Actions y templates
├── 📁 backend/               # Backend Python/FastAPI
│   └── open_webui/          # Código del backend
├── 📁 src/                   # Frontend Svelte
│   └── lib/                 # Componentes y utilidades
├── 📁 static/                # Assets estáticos
│   └── static/              # Logos e íconos
├── 📁 branding/              # Sistema de branding
│   ├── config.json          # Configuración central
│   └── original-logos/      # Backup logos originales
├── 📁 scripts/               # Scripts de automatización
│   ├── sync-upstream.sh     # Sincronizar con upstream
│   ├── new-feature.sh       # Crear nueva feature
│   └── create-release-tag.sh # Crear release
├── 📄 BRANCHING-STRATEGY.md  # Estrategia de ramas
├── 📄 CUSTOMIZATIONS.md      # Documentación de cambios
└── 📄 README.md             # Este archivo
```

### 🌿 Ramas Principales

| Rama | Propósito | Estado |
|------|-----------|--------|
| `main` | Sincronización con upstream | 🔒 Protegida |
| `codingsoft/custom` ⭐ | Desarrollo principal | 🔒 Protegida + PR reviews |
| `codingsoft/develop` | Features experimentales | 🔄 Activa |
| `codingsoft/production` | Despliegue producción | 🔒 Protegida + PR reviews |

---

## 🚀 Instalación

### Requisitos

- Python 3.11+
- Node.js 20+
- Git

### Instalación Rápida

```bash
# Clonar el repositorio
git clone https://github.com/CodingSoft/webui.git
cd webui

# Cambiar a rama principal
git checkout codingsoft/custom

# Backend
cd backend
pip install -r requirements.txt
cd ..

# Frontend
npm install

# Desarrollo
npm run dev

# Producción
npm run build
```

### Docker (Opcional)

```bash
docker build -t codingsoft-ai .
docker run -p 3000:3000 codingsoft-ai
```

---

## 🔄 Mantenimiento

### Sincronizar con Upstream

```bash
# Automático (recomendado)
./scripts/sync-upstream.sh

# Manual
git checkout main
git fetch upstream
git merge upstream/main
git checkout codingsoft/custom
git merge main
```

### Crear Nueva Feature

```bash
./scripts/new-feature.sh mi-nueva-funcion
# Trabajar en la rama feature/mi-nueva-funcion
# Luego crear PR a codingsoft/custom
```

### Crear Release

```bash
# Preparar producción
git checkout codingsoft/production
git merge codingsoft/custom

# Crear tag
./scripts/create-release-tag.sh "Release v0.9.2"

# O manual
git tag codingsoft-v0.9.2
git push origin codingsoft-v0.9.2
```

---

## 📁 Documentación

- 📖 **[BRANCHING-STRATEGY.md](BRANCHING-STRATEGY.md)** - Flujo de trabajo Git completo
- 🎨 **[CUSTOMIZATIONS.md](CUSTOMIZATIONS.md)** - Registro de personalizaciones
- 🔧 **[Scripts](scripts/)** - Automatización del flujo de trabajo
- 🌐 **[Open WebUI Docs](https://docs.openwebui.com/)** - Documentación del proyecto base

---

## 🤝 Contribución

### Flujo de Trabajo

1. **Crear feature branch desde `codingsoft/custom`**:
   ```bash
   git checkout codingsoft/custom
   git checkout -b feature/mi-feature
   ```

2. **Desarrollar y commitear**:
   ```bash
   git commit -m "feat: descripción del cambio"
   ```

3. **Crear Pull Request** a `codingsoft/custom`

4. **Revisión y merge** (requiere 1 aprobación)

### Convenciones de Commits

- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `security:` Fix de seguridad
- `chore:` Tareas de mantenimiento
- `docs:` Documentación
- `refactor:` Refactorización
- `sync:` Sincronización con upstream

### Reportar Issues

- 🐛 **Issues de este fork**: [CodingSoft/webui/issues](https://github.com/CodingSoft/webui/issues)
- 🔧 **Issues de Open WebUI**: [open-webui/open-webui/issues](https://github.com/open-webui/open-webui/issues)

---

## 📊 Estado del Proyecto

| Aspecto | Detalle |
|---------|---------|
| **Versión Base** | Open WebUI v0.9.2 |
| **Versión CodingSoft** | `codingsoft-v0.9.2` |
| **Última Sincronización** | 2025-04-27 |
| **Commits Personalizados** | ~10+ |
| **Estado** | ✅ Activo y mantenido |

---

## 🔗 Enlaces

- 🌐 **Sitio Web**: [codingsoft.mx](https://codingsoft.mx)
- 💻 **Repositorio**: [CodingSoft/webui](https://github.com/CodingSoft/webui)
- 🏠 **Proyecto Base**: [open-webui/open-webui](https://github.com/open-webui/open-webui)
- 📦 **Releases**: [Ver releases](https://github.com/CodingSoft/webui/releases)

---

## 📄 Licencia

Este proyecto está bajo la misma licencia que Open WebUI. Ver [LICENSE](LICENSE) para detalles.

**CodingSoft AI** © 2025 CodingSoft - Fork de Open WebUI

<p align="center">
  <em>Powered by Open WebUI Community</em>
</p>
