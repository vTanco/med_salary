
import React, { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { storageService } from '../services/storageService';
import { salaryEngine } from '../services/salaryEngine';
import { irpfEngine } from '../services/irpfEngine';
import { Guardia, ResultadoSalario, ResultadoIRPF, PerfilUsuario } from '../types';
import { Euro, Clock, TrendingUp, MapPin } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

interface Props {
  onChangeTab: (tab: string) => void;
}

const Home: React.FC<Props> = ({ onChangeTab }) => {
  const { user } = useAuth();
  const [perfil, setPerfil] = useState<PerfilUsuario | null>(null);
  const [guardiasMes, setGuardiasMes] = useState<Guardia[]>([]);
  const [salario, setSalario] = useState<ResultadoSalario | null>(null);
  const [irpf, setIrpf] = useState<ResultadoIRPF | null>(null);

  const now = new Date();
  const currentMonth = now.getMonth();
  const currentYear = now.getFullYear();
  const monthName = now.toLocaleString('es-ES', { month: 'long' });

  useEffect(() => {
    if (!user) return;
    
    const p = storageService.getPerfil(user.id);
    setPerfil(p);

    const gMes = storageService.getGuardiasPorMes(user.id, currentYear, currentMonth);
    const gAnio = storageService.getGuardiasAnio(user.id, currentYear);
    setGuardiasMes(gMes);

    if (p) {
      const calcSalario = salaryEngine.calcularSalario(p.ccaa, p.categoria, gMes, gAnio);
      setSalario(calcSalario);
      
      const calcIrpf = irpfEngine.calcularIRPF(
        calcSalario.brutoTotalAnualEstimado, 
        calcSalario.brutoTotalMensual, 
        p.estadoFamiliar
      );
      setIrpf(calcIrpf);
    }
  }, [currentMonth, currentYear, user]);

  if (!salario || !irpf || !perfil) return <div className="p-10 text-center">Cargando...</div>;

  const totalHoras = guardiasMes.reduce((acc, curr) => acc + curr.horas, 0);

  return (
    <Layout>
      <div className="p-4 space-y-6 pb-20">
        
        {/* Header with CCAA info */}
        <div className="flex justify-between items-center px-1">
            <div>
              <h1 className="text-xl font-bold text-gray-800 capitalize">Resumen {monthName}</h1>
              <p className="text-xs text-gray-400">Hola, {user?.name}</p>
            </div>
            <div className="flex items-center gap-1 text-xs font-medium text-gray-500 bg-gray-100 px-2 py-1 rounded-full">
                <MapPin size={12} />
                {perfil.ccaa}
            </div>
        </div>

        {/* Main Card - Net Salary */}
        <div className="bg-gradient-to-br from-teal-500 to-teal-700 rounded-2xl p-6 text-white shadow-xl">
          <p className="text-teal-100 text-sm font-medium mb-1">Neto Estimado (Mensual)</p>
          <div className="flex items-baseline gap-1">
            <span className="text-4xl font-bold">{irpf.netoMensualEstimado.toLocaleString('es-ES', { maximumFractionDigits: 0 })}</span>
            <span className="text-xl">€</span>
          </div>
          <div className="mt-4 flex gap-4 text-xs text-teal-100 bg-white/10 p-3 rounded-lg">
             <div className="flex-1">
                <p className="opacity-70">Bruto Total</p>
                <p className="font-semibold text-white text-lg">{salario.brutoTotalMensual.toLocaleString('es-ES', { maximumFractionDigits: 0 })}€</p>
             </div>
             <div className="w-px bg-white/20"></div>
             <div className="flex-1">
                <p className="opacity-70">IRPF ({(irpf.tipoRecomendado * 100).toFixed(1)}%)</p>
                <p className="font-semibold text-white text-lg">-{irpf.retencionMensualEstimada.toLocaleString('es-ES', { maximumFractionDigits: 0 })}€</p>
             </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-4">
          <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100">
            <div className="flex items-center gap-2 text-gray-500 mb-2">
              <Clock size={18} />
              <span className="text-xs font-semibold uppercase">Horas Guardia</span>
            </div>
            <p className="text-2xl font-bold text-gray-800">{totalHoras}h</p>
            <p className="text-xs text-gray-400 mt-1">Este mes</p>
          </div>
          <div className="bg-white p-4 rounded-xl shadow-sm border border-gray-100">
            <div className="flex items-center gap-2 text-gray-500 mb-2">
              <TrendingUp size={18} />
              <span className="text-xs font-semibold uppercase">Bruto Guardias</span>
            </div>
            <p className="text-2xl font-bold text-gray-800">{salario.brutoGuardias.toFixed(0)}€</p>
            <p className="text-xs text-gray-400 mt-1">Extra este mes</p>
          </div>
        </div>

        {/* Breakdown Card */}
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
            <h3 className="font-semibold text-gray-800 mb-4 flex items-center gap-2">
                <Euro size={18} className="text-teal-600"/>
                Desglose Nómina
            </h3>
            <div className="space-y-3 text-sm">
                <div className="flex justify-between text-gray-600">
                    <span>Sueldo Base + Compl.</span>
                    <span>{salario.brutoFijoMensual.toFixed(2)} €</span>
                </div>
                <div className="flex justify-between text-teal-700 font-medium bg-teal-50 p-2 rounded">
                    <span>Guardias ({guardiasMes.length})</span>
                    <span>+{salario.brutoGuardias.toFixed(2)} €</span>
                </div>
                <div className="border-t pt-2 flex justify-between font-bold text-gray-900">
                    <span>Total Bruto</span>
                    <span>{salario.brutoTotalMensual.toFixed(2)} €</span>
                </div>
            </div>
        </div>

        {/* Quick Action */}
        <button 
            onClick={() => onChangeTab('add')}
            className="w-full bg-gray-900 text-white py-3 rounded-xl font-medium shadow-lg active:scale-95 transition-transform"
        >
            Añadir Guardia
        </button>

      </div>
    </Layout>
  );
};

export default Home;
