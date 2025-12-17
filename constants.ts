import { DatasetSalarial, IRPFTramo, CategoriaSalarial, CategoriaId } from './types';

// Datos Salariales Actualizados 2024-2025
// Fuente: Documento oficial "Salarios Médicos Servicio Público Español"

// MARK: - Precios de Guardia por CCAA (€/hora) - Adjuntos/FEA
const GUARDIAS_CCAA: Record<string, { laborable: number; festivo: number; noche: number }> = {
  "Andalucía": { laborable: 30.00, festivo: 34.00, noche: 38.00 },
  "Aragón": { laborable: 27.78, festivo: 29.77, noche: 32.00 },
  "Principado de Asturias": { laborable: 28.50, festivo: 32.00, noche: 35.00 },
  "Illes Balears": { laborable: 32.00, festivo: 37.00, noche: 40.00 },
  "Canarias": { laborable: 28.00, festivo: 32.00, noche: 35.00 },
  "Cantabria": { laborable: 30.00, festivo: 33.00, noche: 36.00 },
  "Castilla y León": { laborable: 30.12, festivo: 33.58, noche: 36.00 },
  "Castilla-La Mancha": { laborable: 31.63, festivo: 33.91, noche: 37.00 },
  "Cataluña": { laborable: 37.00, festivo: 40.00, noche: 43.00 },
  "Comunitat Valenciana": { laborable: 28.00, festivo: 31.00, noche: 34.00 },
  "Extremadura": { laborable: 27.00, festivo: 30.00, noche: 33.00 },
  "Galicia": { laborable: 28.00, festivo: 30.00, noche: 33.00 },
  "Madrid": { laborable: 26.00, festivo: 30.00, noche: 33.00 },
  "Región de Murcia": { laborable: 28.00, festivo: 32.00, noche: 35.00 },
  "Comunidad Foral de Navarra": { laborable: 28.00, festivo: 35.00, noche: 40.00 },
  "País Vasco": { laborable: 35.00, festivo: 45.00, noche: 48.00 },
  "La Rioja": { laborable: 28.00, festivo: 32.00, noche: 35.00 },
  "Ceuta y Melilla (INGESA)": { laborable: 30.00, festivo: 35.00, noche: 38.00 },
};

// Complementos por CCAA
const COMPLEMENTOS_CCAA: Record<string, { destino: number; especifico: number }> = {
  "Andalucía": { destino: 677.66, especifico: 850.00 },
  "Aragón": { destino: 700.00, especifico: 375.00 },
  "Principado de Asturias": { destino: 697.00, especifico: 920.00 },
  "Illes Balears": { destino: 710.00, especifico: 1100.00 },
  "Canarias": { destino: 697.00, especifico: 950.00 },
  "Cantabria": { destino: 697.00, especifico: 1050.00 },
  "Castilla y León": { destino: 697.00, especifico: 920.00 },
  "Castilla-La Mancha": { destino: 697.00, especifico: 972.51 },
  "Cataluña": { destino: 720.00, especifico: 1200.00 },
  "Comunitat Valenciana": { destino: 697.00, especifico: 900.00 },
  "Extremadura": { destino: 677.00, especifico: 800.00 },
  "Galicia": { destino: 697.00, especifico: 880.00 },
  "Madrid": { destino: 697.00, especifico: 950.00 },
  "Región de Murcia": { destino: 697.00, especifico: 870.00 },
  "Comunidad Foral de Navarra": { destino: 720.00, especifico: 1300.00 },
  "País Vasco": { destino: 750.00, especifico: 1400.00 },
  "La Rioja": { destino: 697.00, especifico: 850.00 },
  "Ceuta y Melilla (INGESA)": { destino: 720.00, especifico: 1500.00 },
};

// Multiplicadores MIR por CCAA
const getMIRMultiplier = (ccaa: string): number => {
  switch (ccaa) {
    case "País Vasco": return 1.35;
    case "Comunidad Foral de Navarra": return 1.25;
    case "Cataluña": return 1.20;
    case "Illes Balears": return 1.15;
    case "Castilla-La Mancha": return 1.10;
    case "Castilla y León": return 1.05;
    case "Andalucía": case "Canarias": return 1.00;
    case "Principado de Asturias": case "Cantabria": case "Galicia": case "Comunitat Valenciana": return 0.98;
    case "Aragón": case "Región de Murcia": case "La Rioja": case "Extremadura": return 0.95;
    case "Madrid": return 0.90;
    case "Ceuta y Melilla (INGESA)": return 1.10;
    default: return 1.00;
  }
};

// Crear categorías para una CCAA específica
const createCategorias = (ccaa: string): CategoriaSalarial[] => {
  const guardias = GUARDIAS_CCAA[ccaa] || { laborable: 28, festivo: 32, noche: 35 };
  const complementos = COMPLEMENTOS_CCAA[ccaa] || { destino: 697, especifico: 900 };
  const mirMult = getMIRMultiplier(ccaa);
  const sueldoBase = 1333.40; // Base A1 nacional 2025

  return [
    // MIR Categories (2024-2025 real values)
    {
      nombre: CategoriaId.MIR1,
      sueldo_base_mensual: 1301.00,
      complemento_destino_mensual: 0,
      complemento_especifico_mensual: 0,
      precio_guardia: { laborable: 17.50 * mirMult, festivo: 19.00 * mirMult, noche: 21.00 * mirMult }
    },
    {
      nombre: CategoriaId.MIR2,
      sueldo_base_mensual: 1400.00,
      complemento_destino_mensual: 0,
      complemento_especifico_mensual: 0,
      precio_guardia: { laborable: 19.50 * mirMult, festivo: 21.50 * mirMult, noche: 23.50 * mirMult }
    },
    {
      nombre: CategoriaId.MIR3,
      sueldo_base_mensual: 1500.00,
      complemento_destino_mensual: 0,
      complemento_especifico_mensual: 0,
      precio_guardia: { laborable: 22.00 * mirMult, festivo: 24.00 * mirMult, noche: 26.00 * mirMult }
    },
    {
      nombre: CategoriaId.MIR4,
      sueldo_base_mensual: 1650.00,
      complemento_destino_mensual: 0,
      complemento_especifico_mensual: 0,
      precio_guardia: { laborable: 24.50 * mirMult, festivo: 27.00 * mirMult, noche: 29.00 * mirMult }
    },
    {
      nombre: CategoriaId.MIR5,
      sueldo_base_mensual: 1795.00,
      complemento_destino_mensual: 0,
      complemento_especifico_mensual: 0,
      precio_guardia: { laborable: 26.66 * mirMult, festivo: 29.00 * mirMult, noche: 31.00 * mirMult }
    },
    // Adjuntos/FEA (CCAA-specific values)
    {
      nombre: CategoriaId.FEA,
      sueldo_base_mensual: sueldoBase,
      complemento_destino_mensual: complementos.destino,
      complemento_especifico_mensual: complementos.especifico,
      precio_guardia: guardias
    },
    {
      nombre: CategoriaId.MED_FAMILIA,
      sueldo_base_mensual: sueldoBase,
      complemento_destino_mensual: complementos.destino,
      complemento_especifico_mensual: complementos.especifico + 70,
      precio_guardia: guardias
    },
    {
      nombre: CategoriaId.MED_URGENCIAS,
      sueldo_base_mensual: sueldoBase,
      complemento_destino_mensual: complementos.destino,
      complemento_especifico_mensual: complementos.especifico + 150,
      precio_guardia: { 
        laborable: guardias.laborable + 1.5, 
        festivo: guardias.festivo + 2.0, 
        noche: guardias.noche + 2.0 
      }
    }
  ];
};

export const DATASETS_CCAA: DatasetSalarial[] = [
  { ccaa: "Andalucía", categorias: createCategorias("Andalucía") },
  { ccaa: "Aragón", categorias: createCategorias("Aragón") },
  { ccaa: "Principado de Asturias", categorias: createCategorias("Principado de Asturias") },
  { ccaa: "Illes Balears", categorias: createCategorias("Illes Balears") },
  { ccaa: "Canarias", categorias: createCategorias("Canarias") },
  { ccaa: "Cantabria", categorias: createCategorias("Cantabria") },
  { ccaa: "Castilla y León", categorias: createCategorias("Castilla y León") },
  { ccaa: "Castilla-La Mancha", categorias: createCategorias("Castilla-La Mancha") },
  { ccaa: "Cataluña", categorias: createCategorias("Cataluña") },
  { ccaa: "Comunitat Valenciana", categorias: createCategorias("Comunitat Valenciana") },
  { ccaa: "Extremadura", categorias: createCategorias("Extremadura") },
  { ccaa: "Galicia", categorias: createCategorias("Galicia") },
  { ccaa: "Madrid", categorias: createCategorias("Madrid") },
  { ccaa: "Región de Murcia", categorias: createCategorias("Región de Murcia") },
  { ccaa: "Comunidad Foral de Navarra", categorias: createCategorias("Comunidad Foral de Navarra") },
  { ccaa: "País Vasco", categorias: createCategorias("País Vasco") },
  { ccaa: "La Rioja", categorias: createCategorias("La Rioja") },
  { ccaa: "Ceuta y Melilla (INGESA)", categorias: createCategorias("Ceuta y Melilla (INGESA)") },
];

export const TRAMOS_IRPF_2024: IRPFTramo[] = [
  { hasta: 12450, tipo: 0.19 },
  { hasta: 20200, tipo: 0.24 },
  { hasta: 35200, tipo: 0.30 },
  { hasta: 60000, tipo: 0.37 },
  { hasta: 300000, tipo: 0.45 },
  { hasta: 999999999, tipo: 0.47 }
];