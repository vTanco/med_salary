
import React, { useState } from 'react';
import Layout from '../components/Layout';
import { TipoGuardia, Guardia } from '../types';
import { storageService } from '../services/storageService';
import { Calendar, Clock, Check, Moon, Sun, Briefcase } from 'lucide-react';
import { v4 as uuidv4 } from 'uuid';
import { useAuth } from '../context/AuthContext';

interface Props {
  onSaved: () => void;
  onCancel: () => void;
}

const AddShift: React.FC<Props> = ({ onSaved, onCancel }) => {
  const { user } = useAuth();
  const getTodayString = () => {
    const d = new Date();
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  };

  const [fecha, setFecha] = useState(getTodayString());
  const [tipo, setTipo] = useState<TipoGuardia>(TipoGuardia.LABORABLE);
  const [horas, setHoras] = useState<number>(17);
  const [error, setError] = useState('');

  const handleSave = () => {
    if (!user) return;
    if (horas <= 0 || horas > 24) {
      setError('Las horas deben ser entre 1 y 24');
      return;
    }
    const perfil = storageService.getPerfil(user.id);
    
    const nuevaGuardia: Guardia = {
      id: uuidv4(),
      userId: user.id,
      fecha,
      tipo,
      horas,
      categoriaId: perfil ? perfil.categoria : 'unknown'
    };

    storageService.addGuardia(user.id, nuevaGuardia);
    onSaved();
  };

  const types = [
    { id: TipoGuardia.LABORABLE, label: 'Laborable', icon: Briefcase },
    { id: TipoGuardia.FESTIVO, label: 'Festivo', icon: Sun },
    { id: TipoGuardia.NOCHE, label: 'Noche Especial', icon: Moon },
  ];

  return (
    <Layout title="Nueva Guardia" showBack onBack={onCancel}>
      <div className="p-6 space-y-8">
        
        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-2 flex items-center gap-2">
            <Calendar size={16} /> Fecha
          </label>
          <input
            type="date"
            value={fecha}
            onChange={(e) => setFecha(e.target.value)}
            className="w-full p-4 bg-white border border-gray-200 rounded-xl focus:ring-2 focus:ring-teal-500 focus:outline-none text-lg"
          />
        </div>

        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-3">Tipo de Guardia</label>
          <div className="grid grid-cols-1 gap-3">
            {types.map((t) => {
              const Icon = t.icon;
              return (
                <button
                  key={t.id}
                  onClick={() => setTipo(t.id)}
                  className={`flex items-center p-4 rounded-xl border-2 transition-all ${
                    tipo === t.id
                      ? 'border-teal-500 bg-teal-50 text-teal-800'
                      : 'border-gray-200 bg-white text-gray-600'
                  }`}
                >
                  <div className={`p-2 rounded-full mr-3 ${tipo === t.id ? 'bg-teal-200' : 'bg-gray-100'}`}>
                    <Icon size={20} />
                  </div>
                  <span className="font-medium text-lg">{t.label}</span>
                  {tipo === t.id && <Check className="ml-auto text-teal-600" />}
                </button>
              );
            })}
          </div>
        </div>

        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-2 flex items-center gap-2">
            <Clock size={16} /> Duración (Horas)
          </label>
          <div className="flex items-center gap-4">
             <button onClick={() => setHoras(Math.max(1, horas - 1))} className="w-12 h-12 rounded-full bg-gray-200 text-xl font-bold text-gray-600">-</button>
             <input
                type="number"
                value={horas}
                onChange={(e) => setHoras(Number(e.target.value))}
                className="flex-1 text-center p-4 bg-white border border-gray-200 rounded-xl text-2xl font-bold focus:ring-teal-500 focus:outline-none"
             />
             <button onClick={() => setHoras(Math.min(24, horas + 1))} className="w-12 h-12 rounded-full bg-gray-200 text-xl font-bold text-gray-600">+</button>
          </div>
          {error && <p className="text-red-500 text-sm mt-2">{error}</p>}
        </div>

        <div className="pt-4">
          <button
            onClick={handleSave}
            className="w-full bg-teal-600 hover:bg-teal-700 text-white font-bold py-4 rounded-xl shadow-lg transform active:scale-95 transition-all"
          >
            Guardar Guardia
          </button>
        </div>

      </div>
    </Layout>
  );
};

export default AddShift;
