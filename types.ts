
// Enums
export enum CategoriaId {
  MIR1 = 'MIR-1',
  MIR2 = 'MIR-2',
  MIR3 = 'MIR-3',
  MIR4 = 'MIR-4',
  MIR5 = 'MIR-5',
  FEA = 'Facultativo Especialista (FEA)',
  MED_FAMILIA = 'Médico de Familia (EAP)',
  MED_URGENCIAS = 'Médico Urgencias / SUMMA'
}

export enum EstadoFamiliar {
  GENERAL = 'general',
  CON_HIJOS = 'con_hijos'
}

export enum TipoGuardia {
  LABORABLE = 'laborable',
  FESTIVO = 'festivo',
  NOCHE = 'noche'
}

// Interfaces Dataset
export interface PrecioGuardia {
  laborable: number;
  festivo: number;
  noche: number;
}

export interface CategoriaSalarial {
  nombre: string;
  sueldo_base_mensual: number;
  complemento_destino_mensual: number;
  complemento_especifico_mensual: number;
  precio_guardia: PrecioGuardia;
}

export interface DatasetSalarial {
  ccaa: string;
  categorias: CategoriaSalarial[];
}

// Interfaces de Dominio
export interface User {
  id: string;
  email: string;
  name: string;
  password: string; // Stored locally for MVP demo
}

export interface Guardia {
  id: string;
  userId: string; // Foreign Key to User
  fecha: string; // YYYY-MM-DD
  tipo: TipoGuardia;
  horas: number;
  categoriaId: string; 
}

export interface PerfilUsuario {
  userId?: string;
  ccaa: string;
  categoria: CategoriaId;
  estadoFamiliar: EstadoFamiliar;
  onboardingCompleto: boolean;
}

// Interfaces de Resultados
export interface ResultadoSalario {
  brutoFijoMensual: number;
  brutoGuardias: number;
  brutoTotalMensual: number;
  brutoFijoAnual: number;
  brutoGuardiasAnualEstimado: number;
  brutoTotalAnualEstimado: number;
}

export interface ResultadoIRPF {
  tipoRecomendado: number; // 0.20 for 20%
  retencionMensualEstimada: number;
  netoMensualEstimado: number;
}

export interface IRPFTramo {
  hasta: number;
  tipo: number;
}
