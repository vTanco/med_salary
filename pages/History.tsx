
import React, { useState, useEffect } from 'react';
import Layout from '../components/Layout';
import { storageService } from '../services/storageService';
import { Guardia } from '../types';
import { Trash2 } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

const History: React.FC = () => {
  const { user } = useAuth();
  const [guardias, setGuardias] = useState<Guardia[]>([]);

  useEffect(() => {
    loadData();
  }, [user]);

  const loadData = () => {
    if (!user) return;
    // Sort descending
    const data = storageService.getGuardias(user.id).sort((a, b) => 
        new Date(b.fecha).getTime() - new Date(a.fecha).getTime()
    );
    setGuardias(data);
  };

  const handleDelete = (id: string, e: React.MouseEvent) => {
      e.stopPropagation();
      if (!user) return;
      if(window.confirm('¿Eliminar esta guardia?')) {
          storageService.deleteGuardia(user.id, id);
          loadData();
      }
  };

  const parseDate = (dateString: string) => {
      const parts = dateString.split('-');
      return new Date(Number(parts[0]), Number(parts[1]) - 1, Number(parts[2]));
  };

  const grouped = guardias.reduce((acc, g) => {
    const d = parseDate(g.fecha);
    const key = d.toLocaleString('es-ES', { month: 'long', year: 'numeric' });
    if (!acc[key]) acc[key] = [];
    acc[key].push(g);
    return acc;
  }, {} as Record<string, Guardia[]>);

  return (
    <Layout title="Historial">
      <div className="p-4 space-y-6 pb-20">
        {guardias.length === 0 && (
            <div className="text-center text-gray-400 mt-20">
                <p>No hay guardias registradas.</p>
            </div>
        )}

        {Object.entries(grouped).map(([period, items]) => {
          const guardiasEnPeriodo = items as Guardia[];
          return (
            <div key={period}>
              <h3 className="text-sm font-bold text-gray-500 uppercase tracking-wider mb-2 ml-1">{period}</h3>
              <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                {guardiasEnPeriodo.map((item) => {
                    const dateObj = parseDate(item.fecha);
                    return (
                        <div key={item.id} className="p-4 border-b last:border-0 border-gray-100 flex items-center justify-between">
                            <div>
                            <div className="font-semibold text-gray-800 capitalize">
                                {dateObj.toLocaleDateString('es-ES', { day: 'numeric', weekday: 'short' })}
                            </div>
                            <div className="text-xs text-gray-500 capitalize">{item.tipo.replace('_', ' ')}</div>
                            </div>
                            <div className="flex items-center gap-4">
                            <span className="font-bold text-teal-600 bg-teal-50 px-2 py-1 rounded-md">{item.horas}h</span>
                            <button onClick={(e) => handleDelete(item.id, e)} className="text-gray-300 hover:text-red-500">
                                <Trash2 size={18} />
                            </button>
                            </div>
                        </div>
                    );
                })}
                <div className="bg-gray-50 p-3 text-right text-xs text-gray-500 font-medium">
                    Total: {guardiasEnPeriodo.reduce((sum, i) => sum + i.horas, 0)} horas
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </Layout>
  );
};

export default History;
