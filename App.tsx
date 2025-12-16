
import React, { useState, useEffect } from 'react';
import Onboarding from './pages/Onboarding';
import Home from './pages/Home';
import AddShift from './pages/AddShift';
import History from './pages/History';
import Settings from './pages/Settings';
import Login from './pages/Login';
import Register from './pages/Register';
import BottomNav from './components/BottomNav';
import { storageService } from './services/storageService';
import { AuthProvider, useAuth } from './context/AuthContext';

const AppContent: React.FC = () => {
  const { user, loading } = useAuth();
  const [view, setView] = useState('home');
  const [authView, setAuthView] = useState<'login' | 'register'>('login');
  const [needsOnboarding, setNeedsOnboarding] = useState(false);

  useEffect(() => {
    if (user) {
      const perfil = storageService.getPerfil(user.id);
      if (!perfil || !perfil.onboardingCompleto) {
        setNeedsOnboarding(true);
      } else {
        setNeedsOnboarding(false);
      }
    }
  }, [user]);

  if (loading) return <div className="h-screen flex items-center justify-center bg-gray-50 text-teal-600">Cargando...</div>;

  // 1. No User -> Auth Screens
  if (!user) {
    if (authView === 'login') return <Login onGoToRegister={() => setAuthView('register')} />;
    return <Register onGoToLogin={() => setAuthView('login')} />;
  }

  // 2. User but no Profile -> Onboarding
  if (needsOnboarding) {
    return <Onboarding onComplete={() => setNeedsOnboarding(false)} />;
  }

  // 3. Main App
  const renderContent = () => {
    switch (view) {
      case 'home':
        return <Home onChangeTab={setView} />;
      case 'add':
        return <AddShift onSaved={() => setView('home')} onCancel={() => setView('home')} />;
      case 'history':
        return <History />;
      case 'settings':
        return <Settings onReset={() => setNeedsOnboarding(true)} />;
      default:
        return <Home onChangeTab={setView} />;
    }
  };

  return (
    <div className="relative h-screen flex flex-col max-w-md mx-auto bg-white sm:my-4 sm:rounded-3xl sm:border sm:shadow-2xl overflow-hidden">
      <div className="flex-1 overflow-hidden relative">
        {renderContent()}
      </div>
      
      {view !== 'add' && (
        <div className="z-20">
            <BottomNav currentTab={view} onTabChange={setView} />
        </div>
      )}
    </div>
  );
};

const App: React.FC = () => {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
};

export default App;
