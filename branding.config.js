/**
 * Configuración de Branding para CodingSoft WebUI
 * 
 * Este archivo centraliza todas las personalizaciones de branding
 * para facilitar el mantenimiento y futuras actualizaciones
 */

export const brandingConfig = {
  // Nombre de la aplicación
  appName: "CodingSoft AI",
  appShortName: "CS AI",
  
  // URLs y metadatos
  website: "https://codingsoft.mx",
  description: "Plataforma de IA de CodingSoft - Interfaz personalizada basada en Open WebUI",
  
  // Colores principales
  colors: {
    primary: "#2563eb", // Azul CodingSoft
    darkBackground: "#171717",
    lightBackground: "#ffffff",
  },
  
  // Textos y mensajes
  texts: {
    tagline: "AI Platform by CodingSoft",
    copyright: "© 2025 CodingSoft - Todos los derechos reservados",
    poweredBy: "Powered by CodingSoft AI",
  },
  
  // Configuración de logos
  logos: {
    // Nombres de archivos para logos (deben existir en /static/)
    favicon: "favicon.png",
    splashLight: "splash.png",
    splashDark: "splash-dark.png",
    logoLight: "logo.png",
    logoDark: "logo-dark.png",
    appleTouchIcon: "apple-touch-icon.png",
  },
  
  // Configuración de metadatos
  meta: {
    author: "CodingSoft",
    keywords: "ai, artificial intelligence, codingsoft, chatbot, assistant",
    themeColor: "#2563eb",
  },
  
  // Opciones de despliegue
  deployment: {
    // Base path para despliegues en subdirectorios
    basePath: "/",
    // Prefijo para rutas de API
    apiPrefix: "/api/v1",
  }
};

export default brandingConfig;