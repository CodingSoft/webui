#!/usr/bin/env node

/**
 * Script simple para aplicar branding basado en configuración
 */

const fs = require('fs');
const path = require('path');

const configPath = path.join(__dirname, '..', 'branding.config.json');
if (!fs.existsSync(configPath)) {
  console.error('❌ branding.config.json no encontrado');
  process.exit(1);
}

const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

console.log(`🎨 Aplicando branding: ${config.appName}`);

// Función para reemplazar texto en archivo
function replaceInFile(filePath, replacements) {
  if (!fs.existsSync(filePath)) {
    console.warn(`⚠️  Archivo no encontrado: ${filePath}`);
    return;
  }
  
  let content = fs.readFileSync(filePath, 'utf8');
  let changes = 0;
  
  for (const [search, replace] of replacements) {
    const regex = new RegExp(search, 'g');
    const matches = (content.match(regex) || []).length;
    if (matches > 0) {
      content = content.replace(regex, replace);
      changes += matches;
      console.log(`   ↳ ${filePath}: ${matches} ocurrencias de "${search}"`);
    }
  }
  
  if (changes > 0) {
    fs.writeFileSync(filePath, content);
    console.log(`   ✅ Actualizado: ${changes} cambios`);
  }
}

// Archivos a actualizar
const filesToUpdate = [
  {
    path: path.join(__dirname, '..', 'src', 'app.html'),
    replacements: [
      ['<title>Open WebUI</title>', `<title>${config.appName}</title>`],
      ['content="#171717"', `content="${config.meta.themeColor}"`]
    ]
  },
  {
    path: path.join(__dirname, '..', 'static', 'opensearch.xml'),
    replacements: [
      ['<ShortName>Open WebUI</ShortName>', `<ShortName>${config.appShortName}</ShortName>`],
      ['<Description>Search Open WebUI</Description>', `<Description>Search ${config.appName}</Description>`]
    ]
  }
];

// Aplicar cambios
filesToUpdate.forEach(file => {
  console.log(`\n📄 Procesando: ${path.relative(process.cwd(), file.path)}`);
  replaceInFile(file.path, file.replacements);
});

// Actualizar package.json
console.log('\n📦 Actualizando package.json...');
const packagePath = path.join(__dirname, '..', 'package.json');
const packageJson = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
packageJson.name = config.appName.toLowerCase().replace(/\s+/g, '-');
packageJson.description = config.description;
fs.writeFileSync(packagePath, JSON.stringify(packageJson, null, 2));
console.log('   ✅ Actualizado nombre y descripción');

// Actualizar site.webmanifest
console.log('\n📱 Actualizando site.webmanifest...');
const manifestPath = path.join(__dirname, '..', 'static', 'static', 'site.webmanifest');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
manifest.name = config.appName;
manifest.short_name = config.appShortName;
manifest.theme_color = config.meta.themeColor;
manifest.background_color = config.meta.themeColor;
fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));
console.log('   ✅ Actualizado manifest');

console.log('\n✅ Branding aplicado exitosamente!');
console.log('\n📊 Resumen:');
console.log(`   App: ${config.appName}`);
console.log(`   Short: ${config.appShortName}`);
console.log(`   Color: ${config.meta.themeColor}`);
console.log(`   Archivos actualizados: ${filesToUpdate.length + 2}`);