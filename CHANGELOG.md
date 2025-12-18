# Changelog

Todos los cambios notables en este proyecto se documentan aquí.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

---

## [1.4.0] - 2024-12-18

### 📊 Gestión de IRPF

- **IRPF en Onboarding** - El usuario indica su % de IRPF actual durante el registro
- **Fuentes de ingreso adicionales** - Añadir consultas privadas, docencia, etc. para cálculo preciso
- **KPI IRPF óptimo vs actual** - Nueva tarjeta en el dashboard mostrando comparación visual
- **Notificaciones inteligentes** - Alertas locales cuando debes subir tu IRPF (no cuando debes bajarlo)
- **Edición de IRPF** - Modifica tu porcentaje desde Ajustes → IRPF y Fiscalidad

### 📈 Visualización de Parámetros

- **Mis Parámetros Salariales** - Nueva vista en Ajustes mostrando:
  - Sueldo base mensual
  - Complemento de destino
  - Complemento específico
  - Complemento de productividad
  - Complemento de carrera
  - Otros complementos
  - Precios de guardia (laborable, festivo, noche)

### 🐛 Reporte de Errores

- **Reportar Error en Cifras** - Los usuarios pueden reportar errores en los datos salariales
- Formulario con CCAA, categoría, descripción y valores incorrectos/correctos
- Los reportes se guardan localmente para revisión

### 🔧 Técnico

- Nuevo modelo `FuenteIngreso` para ingresos adicionales
- Nuevo modelo `ReporteError` para reportes de usuarios
- `IRPFEngine` mejorado con comparación óptimo vs actual
- `IRPFNotificationService` para notificaciones locales
- Onboarding expandido de 3 a 5 pasos
- Nuevos componentes: `IRPFKPICard`, `IRPFConfigView`, `FuentesIngresoView`, `MisSalariosView`, `ReportarErrorView`

---

## [1.3.0] - 2024-12-18

### 🔐 Autenticación Social

- **Sign in with Apple** - Inicia sesión rápidamente con tu Apple ID
- **Face ID / Touch ID** - Autenticación biométrica para login rápido
- **Google Sign-In** - Preparado (requiere configuración de SDK)
- **Facebook Login** - Preparado (requiere configuración de SDK)

### 🎨 Mejoras de UI

- **Modo oscuro corregido** - Las tarjetas del dashboard ahora se adaptan correctamente
- **Nuevos botones de login** - Diseño moderno con separadores visuales

### 🔧 Técnico

- Nuevo `AuthenticationService.swift` centralizado
- Modelo `User` extendido con soporte para proveedores sociales
- `Info.plist` con permiso de Face ID
- `MedSalary.entitlements` para Sign in with Apple

---

## [1.2.0] - 2024-12-17

### 📊 Actualización de Datos Salariales 2024-2025

- **Datos oficiales verificados** - Actualización completa basada en documentos oficiales:
  - Resolución 0039/2025 SAS (Andalucía)
  - Tablas agosto 2025 Aragón
  - SESCAM tablas 2025 (Castilla-La Mancha)
  - Acuerdo SACYL 2024 (Castilla y León)
  - ICS III Acord (Cataluña)
  - Osakidetza 2025 (País Vasco)

### 💰 Nuevos Valores

| Concepto | Antes | Ahora |
|----------|-------|-------|
| MIR-1 base | 1.166€ | 1.301€ |
| MIR-5 base | 1.166€ | 1.795€ |
| Guardia País Vasco | ~23€/h | 35-48€/h |
| Guardia Madrid | ~23€/h | 26-33€/h |
| Guardia CLM | ~23€/h | 31.63-37€/h |

### 🔧 Técnico

- Precios de guardia específicos por CCAA (no multiplicadores genéricos)
- Complementos de destino y específico diferenciados por región
- Archivos actualizados: `SalaryData.swift`, `constants.ts`

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

