import { DATASETS_CCAA } from '../constants';
import { CategoriaId, Guardia, ResultadoSalario } from '../types';

export const salaryEngine = {
  /**
   * Obtiene la configuración salarial del dataset
   */
  getConfig: (ccaaName: string, categoriaNombre: string) => {
    const dataset = DATASETS_CCAA.find(d => d.ccaa === ccaaName);
    if (!dataset) return null;
    return dataset.categorias.find(c => c.nombre === categoriaNombre);
  },

  /**
   * Calcula el bruto anual y mensual basado en guardias
   */
  calcularSalario: (ccaa: string, categoria: CategoriaId, guardiasMes: Guardia[], guardiasAnio: Guardia[]): ResultadoSalario => {
    const config = salaryEngine.getConfig(ccaa, categoria);
    
    // Fallback if config not found (e.g. invalid CCAA in storage), defaults to first available
    const safeConfig = config || DATASETS_CCAA[0].categorias.find(c => c.nombre === categoria) || DATASETS_CCAA[0].categorias[0];

    // 1. Bruto Fijo Anual (Base + Destino + Especifico) * 14 pagas
    const sueldoBaseAnual = safeConfig.sueldo_base_mensual * 14;
    const destinoAnual = safeConfig.complemento_destino_mensual * 14;
    const especificoAnual = safeConfig.complemento_especifico_mensual * 14;
    
    const brutoFijoAnual = sueldoBaseAnual + destinoAnual + especificoAnual;
    const brutoFijoMensual = (safeConfig.sueldo_base_mensual + safeConfig.complemento_destino_mensual + safeConfig.complemento_especifico_mensual);

    // 2. Bruto Guardias Mes Actual
    let brutoGuardiasMes = 0;
    guardiasMes.forEach(g => {
       const precioHora = safeConfig.precio_guardia[g.tipo];
       brutoGuardiasMes += (g.horas * precioHora);
    });

    // 3. Bruto Guardias Año (Real acumulado)
    let brutoGuardiasAnioReal = 0;
    guardiasAnio.forEach(g => {
      const precioHora = safeConfig.precio_guardia[g.tipo];
      brutoGuardiasAnioReal += (g.horas * precioHora);
    });

    // 4. Proyección Anual para IRPF
    const brutoGuardiasAnualEstimado = brutoGuardiasMes * 12; 
    const brutoTotalAnualEstimado = brutoFijoAnual + brutoGuardiasAnualEstimado;

    return {
      brutoFijoMensual,
      brutoGuardias: brutoGuardiasMes,
      brutoTotalMensual: brutoFijoMensual + brutoGuardiasMes,
      brutoFijoAnual,
      brutoGuardiasAnualEstimado,
      brutoTotalAnualEstimado
    };
  }
};