# Publicación de Paquetes

## PyPI (Python Package Index)

### Configuración previa
1. Crear cuenta en https://pypi.org
2. Generar API token con permisos de publicación
3. Añadir token como secret en GitHub: `PYPI_TOKEN`

### Publicación manual
```bash
# Instalar herramientas de publicación
python3 -m pip install build twine

# Construir paquetes
python3 -m build

# Verificar paquetes
twine check dist/*

# Subir a PyPI
twine upload dist/*
```

### Publicación automática
El workflow `release-pypi.yml` publica automáticamente cuando:
- Se hace push a las ramas `main` o `pypi-release`
- Se actualiza `version` en `pyproject.toml`

## NPM (Node Package Manager)

### Configuración previa
1. Crear cuenta en https://npmjs.com
2. Generar access token con permisos de publicación
3. Añadir token como secret en GitHub: `NPM_TOKEN`

### Publicación manual
```bash
# Iniciar sesión en NPM
npm login

# Construir paquete
npm run build

# Publicar
npm publish --access public
```

### Configuración de package.json
```json
{
  "name": "codingsoft-webui",
  "version": "0.8.3",
  "description": "CodingSoft WebUI - Custom fork of Open WebUI",
  "author": "Oscar Alardin <o.alardin@codingsoft.org>",
  "repository": {
    "type": "git",
    "url": "https://github.com/codingsoft/webui.git"
  },
  "homepage": "https://webui.codingsoft.org",
  "bugs": {
    "url": "https://github.com/codingsoft/webui/issues"
  },
  "license": "MIT"
}
```

## GitHub Packages

### Configuración
1. El token `GITHUB_TOKEN` está disponible automáticamente
2. Los workflows de Docker publican automáticamente en GitHub Packages

### URLs de paquetes
- PyPI: https://pypi.org/project/codingsoft-webui/
- NPM: https://www.npmjs.com/package/codingsoft-webui
- Docker: https://github.com/codingsoft/webui/pkgs/container/webui
