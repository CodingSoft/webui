# 🎨 Personalizaciones de CodingSoft

## 📅 Última actualización: 2025-04-27

## 🏷️ Estrategia de Versionado

### Formato de Tags
Seguimos el mismo versionado que upstream pero con prefijo `codingsoft-`:

| Upstream | Tu Tag | Significado |
|----------|--------|-------------|
| `v0.9.2` | `codingsoft-v0.9.2` | Versión base de upstream |
| `v0.9.2` | `codingsoft-v0.9.2.1` | Hotfix sobre v0.9.2 |
| `v0.9.3` | `codingsoft-v0.9.3` | Nueva versión upstream |

### Scripts de Release
```bash
# Crear release tag automáticamente
./scripts/create-release-tag.sh

# O con mensaje personalizado
./scripts/create-release-tag.sh "Release con nuevas funcionalidades"
```

## 🏷️ Branding

### Configuración Principal
- **Nombre:** CodingSoft AI
- **Nombre Corto:** CS AI
- **Website:** https://codingsoft.mx
- **Descripción:** Plataforma de IA de CodingSoft

### Archivos de Branding
- `branding.config.json` - Configuración de branding
- `branding.config.js` - Script de configuración
- `branding/` - Carpeta con logos originales y personalizados
- `scripts/apply-branding.js` - Script para aplicar branding

### Colores
- **Primario:** `#2563eb` (Azul)
- **Fondo Oscuro:** `#171717`
- **Fondo Claro:** `#ffffff`

## 🔒 Mejoras de Seguridad

### Dependencias Actualizadas
1. **uuid:** `^9.0.1` → `^11.1.0` (CVE fixes)
2. **xmldom:** `0.8.11` → `0.8.13` (vulnerability fix)
3. **exceljs:** Migración desde librería anterior

### Fixes Implementados
- SSRF Protection con blocklist configurable
- SVG XSS fix
- Path traversal en uploads de pipelines
- Path traversal en uploads de Ollama models
- Access control en notas
- Default access control: private

## ✨ Features Adicionales

### Sistema de Archivos Local
- Implementación de filesystem local
- Gestión de proyectos
- Estilo similar a LobeHub Desktop

### Automatizaciones
- Sistema de automatizaciones con scheduler
- Integración con calendario

## 🗂️ Estructura de Carpetas

```
branding/
├── original-logos/          # Logos originales de Open WebUI
│   ├── favicon.png
│   ├── logo.png
│   ├── splash.png
│   └── ...
└── [logos personalizados]  # Logos de CodingSoft (no trackeados)

scripts/
├── apply-branding.js        # Aplica branding automáticamente
├── new-feature.sh           # Crea nuevas features
└── sync-upstream.sh         # Sincroniza con upstream

docs/
├── BRANCHING-STRATEGY.md    # Estrategia de ramas
└── CUSTOMIZATIONS.md        # Este archivo
```

## 🔄 Sincronización con Upstream

### Proceso Manual
```bash
# 1. Actualizar main
git checkout main
git fetch upstream
git merge upstream/main

# 2. Actualizar custom
git checkout codingsoft/custom
git merge main
# Resolver conflictos si es necesario
```

### Proceso Automatizado
```bash
./scripts/sync-upstream.sh
```

## 📝 Notas Importantes

- Siempre trabajar en ramas `feature/*` desde `codingsoft/custom`
- Nunca hacer push force en `main` o `codingsoft/custom`
- Documentar nuevas personalizaciones aquí
- Mantener `branding.config.json` actualizado

## 🚀 Deployment

### Preparar Producción
```bash
# Usar el mismo número de versión que upstream + prefijo codingsoft-
git checkout codingsoft/production
git merge codingsoft/custom
git tag codingsoft-v0.9.2
git push origin codingsoft/production --tags
git push origin codingsoft-v0.9.2
```

### Hotfixes (versiones intermedias)
```bash
# Si necesitas un hotfix antes del siguiente upstream
git tag codingsoft-v0.9.2.1
git push origin codingsoft-v0.9.2.1
```

### Build
```bash
cd backend && pip install -r requirements.txt
cd .. && npm install
npm run build
```

## 📚 Referencias

- [Open WebUI Documentation](https://docs.openwebui.com/)
- [Git Branching Strategy](./BRANCHING-STRATEGY.md)
