import { DatasetSalarial, IRPFTramo, CategoriaSalarial, CategoriaId } from './types';

// Helper to generate categories based on a template with multipliers
// This avoids writing 2000+ lines of redundant JSON while providing full data for all regions.
const createCategorias = (
  baseSueldo: number, 
  baseGuardia: number, 
  extraSupplement: number = 0
): CategoriaSalarial[] => {
  return [
    {
      nombre: CategoriaId.MIR1,
      sueldo_base_mensual: 1166.67, // Base nacional común
      complemento_destino_mensual: 0,
      complemento_especifico_mensual: 145.00 * baseSueldo, 
      precio_guardia: { 
        laborable: 10.00 * baseGuardia, 
        festivo: 12.00 * baseGuardia, 
        noche: 14.00 * baseGuardia 
      }
    },
    {
      nombre: CategoriaId.MIR2,
      sueldo_base_mensual: 1166.67,
      complemento_destino_mensual: 0,
      complemento_especifico_mensual: 240.00 * baseSueldo,
      precio_guardia: { 
        laborable: 11.50 * baseGuardia, 
        festivo: 14.00 * baseGuardia, 
        noche: 16.00 * baseGuardia 
      }
    },
    {
      nombre: CategoriaId.MIR3,
      sueldo_base_mensual: 1166.67,
      complemento_destino_mensual: 0,
      complemento_especifico_mensual: 460.00 * baseSueldo,
      precio_guardia: { 
        laborable: 13.00 * baseGuardia, 
        festivo: 16.50 * baseGuardia, 
        noche: 18.00 * baseGuardia 
      }
    },
    {
      nombre: CategoriaId.MIR4,
      sueldo_base_mensual: 1166.67,
      complemento_destino_mensual: 423.50,
      complemento_especifico_mensual: 685.00 * baseSueldo,
      precio_guardia: { 
        laborable: 14.00 * baseGuardia, 
        festivo: 18.50 * baseGuardia, 
        noche: 20.00 * baseGuardia 
      }
    },
    {
      nombre: CategoriaId.MIR5,
      sueldo_base_mensual: 1166.67,
      complemento_destino_mensual: 423.50,
      complemento_especifico_mensual: 750.00 * baseSueldo,
      precio_guardia: { 
        laborable: 15.50 * baseGuardia, 
        festivo: 20.00 * baseGuardia, 
        noche: 22.00 * baseGuardia 
      }
    },
    {
      nombre: CategoriaId.FEA,
      sueldo_base_mensual: 1567.37, // Base nacional estatutario
      complemento_destino_mensual: 647.48,
      complemento_especifico_mensual: (1380.00 + extraSupplement) * baseSueldo,
      precio_guardia: { 
        laborable: 23.00 * baseGuardia, 
        festivo: 29.00 * baseGuardia, 
        noche: 34.00 * baseGuardia 
      }
    },
    {
      nombre: CategoriaId.MED_FAMILIA,
      sueldo_base_mensual: 1567.37,
      complemento_destino_mensual: 647.48,
      complemento_especifico_mensual: (1450.00 + extraSupplement) * baseSueldo,
      precio_guardia: { 
        laborable: 23.00 * baseGuardia, 
        festivo: 29.00 * baseGuardia, 
        noche: 34.00 * baseGuardia 
      }
    },
    {
      nombre: CategoriaId.MED_URGENCIAS,
      sueldo_base_mensual: 1567.37,
      complemento_destino_mensual: 647.48,
      complemento_especifico_mensual: (1600.00 + extraSupplement) * baseSueldo,
      precio_guardia: { 
        laborable: 24.50 * baseGuardia, 
        festivo: 31.00 * baseGuardia, 
        noche: 36.00 * baseGuardia 
      }
    }
  ];
};

// Configuración por grupos salariales aproximados para MVP
const CAT_MADRID = createCategorias(1.0, 1.0, 0); 
const CAT_ANDALUCIA = createCategorias(0.95, 0.95, -50); 
const CAT_NORTE_ALTA = createCategorias(1.10, 1.15, 100); // Pais Vasco, Navarra
const CAT_INSULAR = createCategorias(1.05, 1.0, 300); // Canarias, Baleares (Plus residencia)
const CAT_MEDIO = createCategorias(0.98, 0.98, 0); // Valencia, Galicia, etc.
const CAT_CEUTA = createCategorias(1.2, 1.1, 700); // Ceuta Melilla (Plus residencia alto)

export const DATASETS_CCAA: DatasetSalarial[] = [
  { ccaa: "Andalucía", categorias: CAT_ANDALUCIA },
  { ccaa: "Aragón", categorias: CAT_MEDIO },
  { ccaa: "Principado de Asturias", categorias: CAT_MEDIO },
  { ccaa: "Illes Balears", categorias: CAT_INSULAR },
  { ccaa: "Canarias", categorias: CAT_INSULAR },
  { ccaa: "Cantabria", categorias: CAT_MEDIO },
  { ccaa: "Castilla y León", categorias: CAT_ANDALUCIA },
  { ccaa: "Castilla-La Mancha", categorias: CAT_ANDALUCIA },
  { ccaa: "Cataluña", categorias: CAT_MADRID },
  { ccaa: "Comunitat Valenciana", categorias: CAT_MEDIO },
  { ccaa: "Extremadura", categorias: CAT_ANDALUCIA },
  { ccaa: "Galicia", categorias: CAT_MEDIO },
  { ccaa: "Madrid", categorias: CAT_MADRID },
  { ccaa: "Región de Murcia", categorias: CAT_ANDALUCIA },
  { ccaa: "Comunidad Foral de Navarra", categorias: CAT_NORTE_ALTA },
  { ccaa: "País Vasco", categorias: CAT_NORTE_ALTA },
  { ccaa: "La Rioja", categorias: CAT_MEDIO },
  { ccaa: "Ceuta y Melilla (INGESA)", categorias: CAT_CEUTA },
];

export const TRAMOS_IRPF_2024: IRPFTramo[] = [
  { hasta: 12450, tipo: 0.19 },
  { hasta: 20200, tipo: 0.24 },
  { hasta: 35200, tipo: 0.30 },
  { hasta: 60000, tipo: 0.37 },
  { hasta: 300000, tipo: 0.45 },
  { hasta: 999999999, tipo: 0.47 }
];