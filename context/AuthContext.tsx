
import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User } from '../types';
import { storageService } from '../services/storageService';
import { v4 as uuidv4 } from 'uuid';

interface AuthContextType {
  user: User | null;
  login: (email: string, pass: string) => boolean;
  register: (name: string, email: string, pass: string) => boolean;
  logout: () => void;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check for active session in localStorage (simple persistence)
    const sessionData = localStorage.getItem('medsalary_session_user');
    if (sessionData) {
      setUser(JSON.parse(sessionData));
    }
    setLoading(false);
  }, []);

  const login = (email: string, pass: string): boolean => {
    const foundUser = storageService.findUserByEmail(email);
    if (foundUser && foundUser.password === pass) {
      setUser(foundUser);
      localStorage.setItem('medsalary_session_user', JSON.stringify(foundUser));
      return true;
    }
    return false;
  };

  const register = (name: string, email: string, pass: string): boolean => {
    if (storageService.findUserByEmail(email)) {
      return false; // Email exists
    }
    const newUser: User = {
      id: uuidv4(),
      name,
      email,
      password: pass
    };
    storageService.addUser(newUser);
    // Auto login
    setUser(newUser);
    localStorage.setItem('medsalary_session_user', JSON.stringify(newUser));
    return true;
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('medsalary_session_user');
  };

  return (
    <AuthContext.Provider value={{ user, login, register, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};
