
import React, { useState } from 'react';
import Layout from '../components/Layout';
import { CategoriaId, EstadoFamiliar, PerfilUsuario } from '../types';
import { DATASETS_CCAA } from '../constants';
import { storageService } from '../services/storageService';
import { Stethoscope, ArrowRight, MapPin, Briefcase } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

interface Props {
  onComplete: () => void;
}

const Onboarding: React.FC<Props> = ({ onComplete }) => {
  const { user } = useAuth();
  const [ccaa, setCcaa] = useState<string>("Madrid");
  const [categoria, setCategoria] = useState<CategoriaId>(CategoriaId.MIR1); 
  const [familia, setFamilia] = useState<EstadoFamiliar>(EstadoFamiliar.GENERAL);

  const handleSave = () => {
    if (!user) return;
    const perfil: PerfilUsuario = {
      userId: user.id,
      ccaa,
      categoria,
      estadoFamiliar: familia,
      onboardingCompleto: true
    };
    storageService.savePerfil(user.id, perfil);
    onComplete();
  };

  const currentDataset = DATASETS_CCAA.find(d => d.ccaa === ccaa);
  const availableCategories = currentDataset ? currentDataset.categorias : [];

  return (
    <Layout>
      <div className="p-6 flex flex-col h-full">
        <div className="mb-6 text-center mt-4">
          <div className="w-16 h-16 bg-teal-100 text-teal-600 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <Stethoscope size={32} />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Hola, {user?.name}</h1>
          <p className="text-gray-500">Configura tu perfil profesional</p>
        </div>

        <div className="space-y-6">
          {/* CCAA Selection */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <MapPin size={16} className="text-teal-600"/> Comunidad Autónoma
            </label>
            <div className="relative">
                <select 
                    value={ccaa} 
                    onChange={(e) => setCcaa(e.target.value)}
                    className="w-full p-4 bg-white border border-gray-200 rounded-xl appearance-none focus:ring-2 focus:ring-teal-500 outline-none text-gray-700 font-medium"
                >
                    {DATASETS_CCAA.map(d => (
                        <option key={d.ccaa} value={d.ccaa}>{d.ccaa}</option>
                    ))}
                </select>
            </div>
          </div>

          {/* Category Selection */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2 flex items-center gap-2">
                <Briefcase size={16} className="text-teal-600"/> Categoría Profesional
            </label>
            <div className="relative">
                <select 
                    value={categoria} 
                    onChange={(e) => setCategoria(e.target.value as CategoriaId)}
                    className="w-full p-4 bg-white border border-gray-200 rounded-xl appearance-none focus:ring-2 focus:ring-teal-500 outline-none text-gray-700 font-medium"
                >
                    {availableCategories.map(cat => (
                        <option key={cat.nombre} value={cat.nombre}>{cat.nombre}</option>
                    ))}
                </select>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">Situación Familiar</label>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setFamilia(EstadoFamiliar.GENERAL)}
                className={`p-3 rounded-xl border text-center transition-all ${
                  familia === EstadoFamiliar.GENERAL
                    ? 'border-teal-500 bg-teal-50 text-teal-700 ring-1 ring-teal-500'
                    : 'border-gray-200 bg-white text-gray-600'
                }`}
              >
                <span className="text-sm font-medium block">General</span>
              </button>
              <button
                onClick={() => setFamilia(EstadoFamiliar.CON_HIJOS)}
                className={`p-3 rounded-xl border text-center transition-all ${
                  familia === EstadoFamiliar.CON_HIJOS
                    ? 'border-teal-500 bg-teal-50 text-teal-700 ring-1 ring-teal-500'
                    : 'border-gray-200 bg-white text-gray-600'
                }`}
              >
                <span className="text-sm font-medium block">Con Hijos</span>
              </button>
            </div>
          </div>
        </div>

        <button
          onClick={handleSave}
          className="mt-8 w-full bg-teal-600 hover:bg-teal-700 text-white font-bold py-4 rounded-xl shadow-lg flex items-center justify-center gap-2 transition-transform active:scale-95"
        >
          Guardar y Comenzar
          <ArrowRight size={20} />
        </button>
      </div>
    </Layout>
  );
};

export default Onboarding;
