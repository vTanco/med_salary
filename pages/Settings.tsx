
import React, { useEffect, useState } from 'react';
import Layout from '../components/Layout';
import { storageService } from '../services/storageService';
import { Trash2, LogOut, MapPin, User as UserIcon } from 'lucide-react';
import { useAuth } from '../context/AuthContext';

interface Props {
  onReset: () => void;
}

const Settings: React.FC<Props> = ({ onReset }) => {
  const { user, logout } = useAuth();
  const [ccaa, setCcaa] = useState('');

  useEffect(() => {
    if (user) {
      const p = storageService.getPerfil(user.id);
      if (p) setCcaa(p.ccaa);
    }
  }, [user]);

  const handleReset = () => {
    if (!user) return;
    if (window.confirm("¿Estás seguro de que quieres borrar TUS datos?")) {
      storageService.resetUserData(user.id);
      onReset();
    }
  };

  return (
    <Layout title="Ajustes">
      <div className="p-4 space-y-6">
        
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-4 border-b border-gray-100">
                <h3 className="font-semibold text-gray-800">Usuario</h3>
            </div>
            <div className="p-4 flex items-center justify-between border-b border-gray-50">
                 <div className="flex items-center gap-2 text-gray-600">
                    <UserIcon size={18} />
                    <span>Nombre</span>
                 </div>
                 <span className="font-medium text-teal-700">{user?.name}</span>
            </div>
            <div className="p-4 flex items-center justify-between">
                 <div className="flex items-center gap-2 text-gray-600">
                    <MapPin size={18} />
                    <span>CCAA</span>
                 </div>
                 <span className="font-medium text-teal-700">{ccaa || '-'}</span>
            </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
          <div className="p-4 border-b border-gray-100">
            <h3 className="font-semibold text-gray-800">Datos</h3>
          </div>
          <button 
            onClick={handleReset}
            className="w-full text-left p-4 flex items-center gap-3 text-red-600 hover:bg-red-50 transition-colors"
          >
            <Trash2 size={20} />
            <div>
                <span className="block font-medium">Borrar historial</span>
                <span className="text-xs text-gray-500 opacity-80">Solo elimina datos de esta cuenta</span>
            </div>
          </button>
        </div>

        <div className="flex justify-center mt-8">
            <button onClick={logout} className="flex items-center gap-2 text-gray-500 hover:text-red-600 font-medium text-sm transition-colors border border-gray-200 px-6 py-2 rounded-full">
                <LogOut size={16} /> Cerrar Sesión
            </button>
        </div>

        <div className="text-center mt-6">
            <p className="text-xs text-gray-300">MedSalary v2.0 • {user?.email}</p>
        </div>

      </div>
    </Layout>
  );
};

export default Settings;
