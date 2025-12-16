import React, { ReactNode } from 'react';

interface LayoutProps {
  children: ReactNode;
  title?: string;
  showBack?: boolean;
  onBack?: () => void;
  actions?: ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children, title, showBack, onBack, actions }) => {
  return (
    <div className="min-h-screen bg-gray-100 flex items-center justify-center p-0 sm:p-4">
      <div className="w-full max-w-md bg-white h-screen sm:h-[850px] sm:rounded-3xl shadow-2xl flex flex-col overflow-hidden relative border-gray-200 sm:border">
        
        {/* Header */}
        {(title || showBack) && (
          <header className="bg-white border-b border-gray-100 p-4 flex items-center justify-between sticky top-0 z-10">
            <div className="flex items-center gap-3">
              {showBack && (
                <button onClick={onBack} className="p-2 -ml-2 hover:bg-gray-50 rounded-full text-gray-600">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
                </button>
              )}
              {title && <h1 className="text-xl font-bold text-gray-800">{title}</h1>}
            </div>
            {actions && <div>{actions}</div>}
          </header>
        )}

        {/* Content */}
        <main className="flex-1 overflow-y-auto no-scrollbar bg-slate-50 relative">
          {children}
        </main>

      </div>
    </div>
  );
};

export default Layout;