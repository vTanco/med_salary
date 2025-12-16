import { TRAMOS_IRPF_2024 } from '../constants';
import { EstadoFamiliar, ResultadoIRPF } from '../types';

export const irpfEngine = {
  /**
   * Calcula el tipo de IRPF efectivo basado en un bruto anual progresivo
   * Algoritmo simple de tramos.
   */
  calcularTipoBase: (brutoAnual: number): number => {
    let cuotaTotal = 0;
    let resto = brutoAnual;
    let ultimoLimite = 0;

    for (const tramo of TRAMOS_IRPF_2024) {
      if (brutoAnual > ultimoLimite) {
        const baseTramo = Math.min(brutoAnual, tramo.hasta) - ultimoLimite;
        cuotaTotal += baseTramo * tramo.tipo;
        ultimoLimite = tramo.hasta;
      } else {
        break;
      }
    }

    // Tipo medio efectivo
    return cuotaTotal / brutoAnual;
  },

  /**
   * Calcula retención final aplicando situación familiar
   */
  calcularIRPF: (brutoAnualEstimado: number, brutoMensualActual: number, estadoFamiliar: EstadoFamiliar): ResultadoIRPF => {
    // 1. Obtener tipo base según tabla progresiva
    let tipoCalculado = irpfEngine.calcularTipoBase(brutoAnualEstimado);

    // 2. Aplicar correcciones familiares (Simplificación MVP)
    // Si tiene hijos, reducimos 1.5 puntos porcentuales (0.015)
    if (estadoFamiliar === EstadoFamiliar.CON_HIJOS) {
      tipoCalculado -= 0.015;
    }

    // Normalizar (no puede ser negativo)
    if (tipoCalculado < 0) tipoCalculado = 0;

    // 3. Calcular montos mensuales
    const retencionMensual = brutoMensualActual * tipoCalculado;
    const netoMensual = brutoMensualActual - retencionMensual;

    return {
      tipoRecomendado: tipoCalculado,
      retencionMensualEstimada: retencionMensual,
      netoMensualEstimado: netoMensual
    };
  }
};