import React from 'react';
import './PageHeader.scss';

interface PageHeaderProps {
  title: string;
  subtitle?: string;
  children?: React.ReactNode;
}

const PageHeader: React.FC<PageHeaderProps> = ({ 
  title, 
  subtitle, 
  children 
}) => {
  return (
    <header className="page-header">
      <div>
        <h1 className="page-title">{title}</h1>
        {subtitle && <p className="page-subtitle">{subtitle}</p>}
      </div>
      {children && (
        <div className="header-actions">
          {children}
        </div>
      )}
    </header>
  );
};

export default PageHeader; 