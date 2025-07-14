import React, { ReactNode } from 'react';
import Navigation from '@/components/shared/Navigation';

interface MainLayoutNewProps {
  children: ReactNode;
  currentPage?: string;
}

export const MainLayoutNew: React.FC<MainLayoutNewProps> = ({
  children,
  currentPage,
}) => {
  return (
    <div className="min-h-screen bg-background-color">
      <Navigation />
      <main className="flex-1">
        {children}
      </main>
    </div>
  );
}; 