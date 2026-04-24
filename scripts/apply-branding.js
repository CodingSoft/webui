#!/usr/bin/env node

/**
 * Script para aplicar personalizaciones de branding
 * 
 * Uso: node scripts/apply-branding.js
 */

const fs = require('fs');
const path = require('path');

// Importar configuración
const brandingConfig = JSON.parse(fs.readFileSync(
  path.join(__dirname, '..', 'branding.config.json'), 'utf8'
));

console.log('🎨 Aplicando personalizaciones de branding para:', brandingConfig.appName);

// 1. Actualizar package.json
console.log('📦 Actualizando package.json...');
const packagePath = path.join(__dirname, '..', 'package.json');
const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
packageJson.name = "codingsoft-webui";
packageJson.description = brandingConfig.description;
fs.writeFileSync(packagePath, JSON.stringify(packageJson, null, 2));

// 2. Actualizar app.html
console.log('📄 Actualizando app.html...');
const appHtmlPath = path.join(__dirname, '..', 'src', 'app.html');
let appHtml = fs.readFileSync(appHtmlPath, 'utf8');

// Reemplazar título
appHtml = appHtml.replace(/<title>Open WebUI<\/title>/, `<title>${brandingConfig.appName}</title>`);

// Actualizar theme-color meta tag
appHtml = appHtml.replace(/<meta name="theme-color" content="#171717" \/>/, 
  `<meta name="theme-color" content="${brandingConfig.meta.themeColor}" />`);

fs.writeFileSync(appHtmlPath, appHtml);

// 3. Actualizar site.webmanifest
console.log('📱 Actualizando site.webmanifest...');
const manifestPath = path.join(__dirname, '..', 'static', 'static', 'site.webmanifest');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
manifest.name = brandingConfig.appName;
manifest.short_name = brandingConfig.appShortName;
manifest.theme_color = brandingConfig.meta.themeColor;
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));

// 4. Actualizar opensearch.xml
console.log('🔍 Actualizando opensearch.xml...');
const opensearchPath = path.join(__dirname, '..', 'static', 'opensearch.xml');
let opensearch = fs.readFileSync(opensearchPath, 'utf8');
opensearch = opensearch.replace(/<ShortName>Open WebUI<\/ShortName>/, 
  `<ShortName>${brandingConfig.appShortName}</ShortName>`);
opensearch = opensearch.replace(/<Description>Search Open WebUI<\/Description>/, 
  `<Description>Search ${brandingConfig.appName}</Description>`);
fs.writeFileSync(opensearchPath, opensearch);

// 5. Crear README personalizado
console.log('📝 Creando README.md personalizado...');
const readmePath = path.join(__dirname, '..', 'README-CUSTOM.md');
const readmeContent = `# ${brandingConfig.appName}

${brandingConfig.description}

## 🚀 Características

- Interfaz personalizada para CodingSoft
- Basado en Open WebUI v${packageJson.version}
- Branding completo de CodingSoft
- Configuración centralizada

## 🎨 Personalización

Todas las personalizaciones están centralizadas en \`branding.config.json\`.

Para aplicar cambios:
\`\`\`bash
node scripts/apply-branding.js
\`\`\`

## 📦 Instalación

\`\`\`bash
npm install
npm run build
\`\`\`

## 🤝 Contribución

Este es un fork personalizado para CodingSoft.
Para contribuciones al proyecto base, visita: https://github.com/open-webui/open-webui

---
${brandingConfig.texts.copyright}
`;

fs.writeFileSync(readmePath, readmeContent);

console.log('✅ Personalizaciones aplicadas exitosamente!');
console.log(`📊 Resumen:`);
console.log(`   - Nombre de app: ${brandingConfig.appName}`);
console.log(`   - Color tema: ${brandingConfig.meta.themeColor}`);
console.log(`   - Archivos actualizados: 5`);