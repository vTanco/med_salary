import React from 'react';
import { Home, PlusCircle, Calendar, Settings } from 'lucide-react';

interface BottomNavProps {
  currentTab: string;
  onTabChange: (tab: string) => void;
}

const BottomNav: React.FC<BottomNavProps> = ({ currentTab, onTabChange }) => {
  const tabs = [
    { id: 'home', icon: Home, label: 'Inicio' },
    { id: 'add', icon: PlusCircle, label: 'Añadir' },
    { id: 'history', icon: Calendar, label: 'Historial' },
    { id: 'settings', icon: Settings, label: 'Ajustes' },
  ];

  return (
    <div className="bg-white border-t border-gray-200 px-6 py-3 flex justify-between items-center pb-6 sm:pb-3">
      {tabs.map((tab) => {
        const Icon = tab.icon;
        const isActive = currentTab === tab.id;
        return (
          <button
            key={tab.id}
            onClick={() => onTabChange(tab.id)}
            className={`flex flex-col items-center gap-1 transition-colors ${
              isActive ? 'text-teal-600' : 'text-gray-400 hover:text-gray-600'
            }`}
          >
            <Icon size={24} strokeWidth={isActive ? 2.5 : 2} />
            <span className="text-[10px] font-medium">{tab.label}</span>
          </button>
        );
      })}
    </div>
  );
};

export default BottomNav;