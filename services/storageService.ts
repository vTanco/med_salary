
import { Guardia, PerfilUsuario, CategoriaId, EstadoFamiliar, User } from '../types';

const KEY_USERS = 'medsalary_users';
const KEY_SESSION = 'medsalary_session_user';

// Helper for dynamic keys per user
const getKeyGuardias = (userId: string) => `medsalary_guardias_${userId}`;
const getKeyPerfil = (userId: string) => `medsalary_perfil_${userId}`;

export const storageService = {
  // --- Auth & Users ---
  getUsers: (): User[] => {
    try {
      const data = localStorage.getItem(KEY_USERS);
      return data ? JSON.parse(data) : [];
    } catch (e) { return []; }
  },

  addUser: (user: User): void => {
    const users = storageService.getUsers();
    users.push(user);
    localStorage.setItem(KEY_USERS, JSON.stringify(users));
  },

  findUserByEmail: (email: string): User | undefined => {
    const users = storageService.getUsers();
    return users.find(u => u.email.toLowerCase() === email.toLowerCase());
  },

  // --- Guardias (User Isolated) ---
  getGuardias: (userId: string): Guardia[] => {
    try {
      const data = localStorage.getItem(getKeyGuardias(userId));
      return data ? JSON.parse(data) : [];
    } catch (e) {
      return [];
    }
  },

  addGuardia: (userId: string, guardia: Guardia): void => {
    const current = storageService.getGuardias(userId);
    const updated = [...current, { ...guardia, userId }];
    localStorage.setItem(getKeyGuardias(userId), JSON.stringify(updated));
  },

  deleteGuardia: (userId: string, guardiaId: string): void => {
    const current = storageService.getGuardias(userId);
    const updated = current.filter(g => g.id !== guardiaId);
    localStorage.setItem(getKeyGuardias(userId), JSON.stringify(updated));
  },

  getGuardiasPorMes: (userId: string, year: number, month: number): Guardia[] => {
    const all = storageService.getGuardias(userId);
    return all.filter(g => {
      const d = new Date(g.fecha);
      return d.getFullYear() === year && d.getMonth() === month;
    });
  },

  getGuardiasAnio: (userId: string, year: number): Guardia[] => {
    const all = storageService.getGuardias(userId);
    return all.filter(g => new Date(g.fecha).getFullYear() === year);
  },

  // --- Perfil (User Isolated) ---
  getPerfil: (userId: string): PerfilUsuario | null => {
    try {
      const data = localStorage.getItem(getKeyPerfil(userId));
      if (data) return JSON.parse(data);
    } catch (e) {
      console.error("Error reading perfil", e);
    }
    return null;
  },

  savePerfil: (userId: string, perfil: PerfilUsuario): void => {
    localStorage.setItem(getKeyPerfil(userId), JSON.stringify({ ...perfil, userId }));
  },

  // --- System ---
  resetUserData: (userId: string): void => {
    localStorage.removeItem(getKeyGuardias(userId));
    localStorage.removeItem(getKeyPerfil(userId));
  }
};
