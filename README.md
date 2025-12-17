# 💊 MedSalary

**Calculadora de salarios para médicos en España**

Aplicación iOS nativa que permite a médicos residentes (MIR) y especialistas calcular su salario neto mensual, registrar guardias y estimar retenciones de IRPF según su comunidad autónoma.

> 📅 **Datos actualizados a Diciembre 2024/2025** - Fuentes oficiales: Resoluciones CCAA, SATSE, CESM

## ✨ Características

- 📊 **Dashboard de salario** - Visualiza tu neto estimado mensual en tiempo real
- 🏥 **Registro de guardias** - Añade guardias laborables, festivas y nocturnas
- 📍 **18 Comunidades Autónomas** - Datos salariales específicos por territorio (2024-2025)
- 💰 **Cálculo de IRPF** - Estimación automática según tramos 2024
- 👨‍👩‍👧 **Situación familiar** - Ajuste de retenciones por hijos a cargo
- 📱 **100% Offline** - Funciona sin conexión a internet

## 🏗️ Tecnologías

| Tecnología | Uso |
|------------|-----|
| **Swift 5.9+** | Lenguaje de programación |
| **SwiftUI** | Interfaz de usuario declarativa |
| **SwiftData** | Persistencia local (iOS 17+) |

## 📋 Requisitos

- **iOS 17.0** o superior
- **Xcode 15** o superior
- Mac con macOS Ventura o superior

## 🚀 Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/medsalary.git
   ```

2. Abre el proyecto en Xcode:
   ```bash
   open MedSalary.xcodeproj
   ```

3. Selecciona un simulador (iPhone 15 Pro recomendado)

4. Ejecuta con **⌘R**

## 📁 Estructura del Proyecto

```
MedSalary/
├── MedSalaryApp.swift          # Entry point
├── Assets.xcassets/            # Iconos y colores
├── Models/
│   ├── Enums.swift             # CategoriaId, TipoGuardia, etc.
│   ├── User.swift              # Modelo de usuario
│   ├── Guardia.swift           # Modelo de guardia
│   └── PerfilUsuario.swift     # Configuración del usuario
├── Data/
│   └── SalaryData.swift        # Datos CCAA + tramos IRPF
├── Services/
│   ├── SalaryEngine.swift      # Motor de cálculo salarial
│   └── IRPFEngine.swift        # Motor de cálculo IRPF
└── Views/
    ├── ContentView.swift       # Navegación principal
    ├── Auth/                   # Login y Registro
    ├── Onboarding/             # Configuración inicial
    ├── Home/                   # Dashboard principal
    ├── Shifts/                 # Añadir guardias
    ├── History/                # Historial
    └── Settings/               # Ajustes
```

## 👨‍⚕️ Categorías Soportadas

- MIR-1 a MIR-5 (sueldos base: 1.301€ - 1.795€)
- Facultativo Especialista (FEA)
- Médico de Familia (EAP)
- Médico de Urgencias / SUMMA

## 📈 Datos Salariales 2024-2025

| CCAA | Guardia Lab. | Guardia Fest. | Complemento Específico |
|------|-------------|---------------|------------------------|
| País Vasco | 35€/h | 45€/h | 1.400€/mes |
| Cataluña | 37€/h | 40€/h | 1.200€/mes |
| Castilla-La Mancha | 31.63€/h | 33.91€/h | 972€/mes |
| Madrid | 26€/h | 30€/h | 950€/mes |
| Andalucía | 30€/h | 34€/h | 850€/mes |

*Datos obtenidos de documentos oficiales: Resolución 0039/2025 SAS, SESCAM 2025, Osakidetza, ICS III Acord, etc.*

## 📄 Licencia

MIT License - Ver [LICENSE](LICENSE) para más detalles.
