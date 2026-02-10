import React from 'react';
import campusImage from '../../assets/images/login.png';  
export default function AuthBackground({ children }) {
  return (
    <div className="auth-layout">
      <div 
        className="auth-left"
        style={{
          '--campus-image': `url(${campusImage})` 
        }}
      >
        <div className="auth-left-content">
          <h1>Sistema de Gestión de<br />Bienestar Universitario</h1>
          <p>
            Herramienta integral para la administración y supervisión de los
            servicios de bienestar estudiantil.
          </p>
        </div>
      </div>

      <div className="auth-right">
        {children}
      </div>
    </div>
  );
}