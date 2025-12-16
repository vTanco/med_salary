# Changelog

Todos los cambios notables en este proyecto se documentan aquí.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

---

## [1.1.0] - 2024-12-16

### ✨ Nuevas Funcionalidades
- **Gráficas de evolución** - Visualiza tus ingresos de los últimos 6 meses con Swift Charts
- **Comparador de CCAA** - Compara salarios entre comunidades autónomas
- **Proyección anual** - Estimación de ingresos anuales con desglose
- **Notas en guardias** - Añade comentarios a cada guardia
- **Hospital** - Registra en qué hospital hiciste la guardia

### 🎨 Mejoras de UX
- **Pull-to-refresh** - Actualiza el dashboard arrastrando hacia abajo
- **Haptic feedback** - Vibración táctil al guardar y seleccionar
- **Confirmación de borrado** - Alert antes de eliminar guardias
- **Validación de duplicados** - Aviso si ya hay guardia en esa fecha
- **Animaciones spring** - Transiciones suaves en selecciones
- **Colores adaptativos** - Mejor soporte para modo oscuro

### 📱 Nuevas Vistas
- ChartsView (nueva pestaña en Tab Bar)
- CCAAComparatorView (en Ajustes → Herramientas)
- AnnualProjectionView (en Ajustes → Herramientas)

---

## [1.0.0] - 2024-12-16

### ✨ Añadido
- **Autenticación local** - Registro e inicio de sesión de usuarios
- **Onboarding** - Configuración inicial de CCAA, categoría y situación familiar
- **Dashboard principal** - Visualización de salario neto estimado mensual
- **Registro de guardias** - Soporte para guardias laborables, festivas y nocturnas
- **Historial** - Lista de guardias con opción de eliminar
- **Ajustes** - Cambio de configuración y cierre de sesión
- **Motor de cálculo salarial** - Cálculo bruto basado en tablas por CCAA
- **Motor de IRPF** - Cálculo progresivo por tramos 2024

### 📊 Datos incluidos
- 18 Comunidades Autónomas con datos salariales específicos
- 8 categorías profesionales (MIR-1 a MIR-5, FEA, Familia, Urgencias)
- Tramos IRPF 2024 actualizados

### 🔧 Técnico
- SwiftUI para interfaz declarativa
- SwiftData para persistencia local
- iOS 17+ como requisito mínimo
- Arquitectura MVVM simplificada

---

## [Unreleased]

### Pendiente
- [ ] Exportar historial a PDF
- [ ] Sincronización con iCloud
- [ ] Notificaciones de recordatorio
- [ ] Widget de iOS para ver neto rápido

