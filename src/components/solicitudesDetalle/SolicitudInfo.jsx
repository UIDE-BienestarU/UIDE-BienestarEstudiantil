import React from 'react';

const SolicitudInfo = ({ solicitud, adminState, onUpdateEstado, setAdminState, setAdminComentario, loading }) => {
  if (!solicitud) {
    return (
      <div className="p-6 bg-white rounded-lg shadow-md text-center text-gray-500">
        <p>No se encontró la información de la solicitud.</p>
      </div>
    );
  }

  const est = solicitud.estudiante || {};
  
  // Color palette constants
  const PRIMARY_COLOR = '#8b0038';
  const BG_COLOR = '#f8f9fa';
  const BORDER_COLOR = '#e9ecef';

  const containerStyle = {
    display: 'flex',
    flexDirection: 'column',
    gap: '24px',
    fontFamily: "'Inter', sans-serif" // Assuming standard font or similar
  };

  const cardStyle = {
    backgroundColor: '#fff',
    borderRadius: '12px',
    boxShadow: '0 4px 6px rgba(0,0,0,0.05), 0 1px 3px rgba(0,0,0,0.1)',
    overflow: 'hidden',
    border: `1px solid ${BORDER_COLOR}`
  };

  const headerStyle = {
    backgroundColor: BG_COLOR,
    padding: '16px 20px',
    borderBottom: `1px solid ${BORDER_COLOR}`,
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    fontWeight: '600',
    color: '#333',
    fontSize: '1rem'
  };

  const iconStyle = {
    fontSize: '1.2rem'
  };

  const bodyStyle = {
    padding: '24px'
  };

  return (
    <div style={containerStyle}>
      
      {/* 1. INFORMACIÓN DEL ESTUDIANTE */}
      <div style={cardStyle}>
        <div style={headerStyle}>
          <span style={iconStyle}>🎓</span> Información del Estudiante
        </div>
        <div style={bodyStyle}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '24px', flexWrap: 'wrap' }}>
            {/* Avatar */}
            <div style={{ flexShrink: 0 }}>
              <img
                src={est.avatar || `https://ui-avatars.com/api/?name=${encodeURIComponent(est.nombre_completo || est.nombre || "Estudiante")}&background=8b0038&color=fff&size=128&bold=true`}
                alt="Avatar"
                style={{ width: '80px', height: '80px', borderRadius: '50%', objectFit: 'cover', border: `3px solid ${PRIMARY_COLOR}` }}
              />
            </div>
            
            {/* Datos */}
            <div style={{ flex: 1 }}>
              <h2 style={{ margin: '0 0 8px 0', fontSize: '1.4rem', color: '#111', fontWeight: '700' }}>
                {est.nombre_completo || est.nombre || "Nombre Desconocido"}
              </h2>
              
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '12px 24px' }}>
                <div>
                  <span style={{ color: '#666', fontSize: '0.9rem', display: 'block' }}>Matrícula / ID</span>
                  <span style={{ color: '#333', fontWeight: '600', fontSize: '1.05rem' }}>
                    {est.matricula || est.id || "—"}
                  </span>
                </div>
                
                <div>
                  <span style={{ color: '#666', fontSize: '0.9rem', display: 'block' }}>Correo Institucional</span>
                  <span style={{ color: '#333', fontWeight: '500' }}>
                    {est.correo_institucional || est.correo || "—"}
                  </span>
                </div>
                
                <div>
                    <span style={{ color: '#666', fontSize: '0.9rem', display: 'block' }}>Estado</span>
                    <span style={{ 
                        display: 'inline-block', 
                        padding: '4px 12px', 
                        borderRadius: '20px', 
                        backgroundColor: '#d1fae5', 
                        color: '#065f46', 
                        fontSize: '0.85rem', 
                        fontWeight: '600',
                        marginTop: '4px'
                    }}>
                        Activo
                    </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* 2. DETALLE DE SOLICITUD */}
      <div style={cardStyle}>
        <div style={headerStyle}>
          <span style={iconStyle}>📄</span> Detalle del Trámite
        </div>
        <div style={bodyStyle}>
          <div style={{ marginBottom: '20px' }}>
            <span style={{ color: '#666', fontSize: '0.9rem', display: 'block', marginBottom: '4px' }}>Tipo de Trámite</span>
            <div style={{ fontSize: '1.1rem', fontWeight: '600', color: '#111' }}>
                {solicitud.subtipo?.nombre_sub || solicitud.tipo || "Trámite General"}
            </div>
          </div>
          
          <div>
            <span style={{ color: '#666', fontSize: '0.9rem', display: 'block', marginBottom: '8px' }}>Motivo / Observaciones del Estudiante</span>
            <div style={{ 
                backgroundColor: '#fafafa', 
                padding: '16px', 
                borderRadius: '8px', 
                border: '1px solid #eee', 
                color: '#444', 
                lineHeight: '1.6',
                minHeight: '80px'
            }}>
                {solicitud.observaciones || solicitud.detalle?.descripcion || solicitud.comentario || "Sin observaciones."}
            </div>
          </div>
        </div>
      </div>

      {/* 3. DOCUMENTOS ADJUNTOS */}
      <div style={cardStyle}>
        <div style={headerStyle}>
          <span style={iconStyle}>📎</span> Documentos de Soporte
        </div>
        <div style={{ padding: '0' }}>
          {solicitud.documentos?.length > 0 ? (
            <div style={{ display: 'flex', flexDirection: 'column' }}>
              {solicitud.documentos.map((doc, i) => {
                 // Enhanced URL Logic
                 const baseUrl = 'https://api-prod.uidehub.tech';
                 let url = doc.url_archivo || "";
                 // Normalize backslashes to forward slashes
                 url = url.replace(/\\/g, '/');
                 
                 // If not absolute link
                 if (!url.startsWith('http')) {
                    const cleanPath = url.startsWith('/') ? url.slice(1) : url;
                    // Check if path already includes 'Uploads' (case insensitive)
                    if (!cleanPath.toLowerCase().startsWith('uploads')) {
                        url = `${baseUrl}/Uploads/${cleanPath}`;
                    } else {
                        url = `${baseUrl}/${cleanPath}`;
                    }
                 }

                 return (
                    <div key={i} style={{ 
                        display: 'flex', 
                        alignItems: 'center', 
                        justifyContent: 'space-between', 
                        padding: '16px 24px', 
                        borderBottom: i < solicitud.documentos.length - 1 ? '1px solid #eee' : 'none'
                    }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                            <div style={{ 
                                backgroundColor: '#fee2e2', 
                                color: '#991b1b', 
                                width: '40px', 
                                height: '40px', 
                                borderRadius: '8px', 
                                display: 'flex', 
                                alignItems: 'center', 
                                justifyContent: 'center',
                                fontWeight: 'bold',
                                fontSize: '0.8rem'
                            }}>
                                PDF
                            </div>
                            <span style={{ fontWeight: '500', color: '#333' }}>
                                {doc.nombre_documento || `Documento ${i + 1}`}
                            </span>
                        </div>
                        
                        <a 
                            href={url} 
                            target="_blank" 
                            rel="noopener noreferrer"
                            style={{ 
                                textDecoration: 'none',
                                color: PRIMARY_COLOR, 
                                fontWeight: '600', 
                                fontSize: '0.9rem',
                                border: `1px solid ${PRIMARY_COLOR}`,
                                padding: '8px 16px',
                                borderRadius: '6px',
                                transition: 'background-color 0.2s'
                            }}
                            onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#fdf2f8'}
                            onMouseOut={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
                        >
                            Ver Documento →
                        </a>
                    </div>
                 );
              })}
            </div>
          ) : (
             <div style={{ padding: '24px', textAlign: 'center', color: '#888' }}>
                No se han adjuntado documentos.
             </div>
          )}
        </div>
      </div>

      {/* 4. GESTIÓN Y COMENTARIOS (Panel Unificado) */}
      {onUpdateEstado && (
        <div style={{ 
            ...cardStyle, 
            border: `1px solid ${PRIMARY_COLOR}40`, // transparent tint
            boxShadow: '0 4px 12px rgba(139, 0, 56, 0.08)' // primary color shadow
        }}>
            <div style={{ 
                ...headerStyle, 
                backgroundColor: '#fff', 
                borderBottom: 'none', 
                paddingBottom: '0', 
                color: PRIMARY_COLOR 
            }}>
                <span style={iconStyle}>🛠️</span> Gestión de Solicitud
            </div>
            
            <div style={bodyStyle}>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '24px' }}>
                    {/* Columna Izquierda: Estado */}
                    <div>
                        <label style={{ display: 'block', fontSize: '0.95rem', marginBottom: '8px', fontWeight: '600', color: '#444' }}>
                            Estado del Trámite
                        </label>
                        <select 
                            value={adminState.estado} 
                            onChange={(e) => setAdminState(e.target.value)}
                            style={{ 
                                width: '100%', 
                                padding: '12px', 
                                borderRadius: '8px', 
                                border: '1px solid #ccc', 
                                fontSize: '1rem', 
                                outline: 'none',
                                cursor: 'pointer',
                                backgroundColor: '#fff',
                                boxShadow: 'inset 0 1px 2px rgba(0,0,0,0.05)'
                            }}
                        >
                            <option value="Por revisar">Por revisar</option>
                            <option value="En progreso">En progreso</option>
                            <option value="Aprobada">Aprobada</option>
                        </select>
                        <p style={{ marginTop: '8px', fontSize: '0.85rem', color: '#666' }}>
                            Selecciona el nuevo estado para esta solicitud.
                        </p>
                    </div>

                    {/* Columna Derecha: Comentario */}
                    <div>
                        <label style={{ display: 'block', fontSize: '0.95rem', marginBottom: '8px', fontWeight: '600', color: '#444' }}>
                            Nota Interna / Respuesta
                        </label>
                        <textarea 
                            value={adminState.comentario} 
                            onChange={(e) => setAdminComentario(e.target.value)}
                            placeholder="Escribe aquí las observaciones o el motivo del cambio..."
                            rows={4}
                            style={{ 
                                width: '100%', 
                                padding: '12px', 
                                borderRadius: '8px', 
                                border: '1px solid #ccc', 
                                fontSize: '0.95rem', 
                                resize: 'vertical',
                                fontFamily: 'inherit'
                            }}
                        />
                    </div>
                </div>

                <div style={{ marginTop: '24px', display: 'flex', justifyContent: 'flex-end', borderTop: `1px solid ${BORDER_COLOR}`, paddingTop: '20px' }}>
                    <button 
                        onClick={onUpdateEstado}
                        disabled={loading}
                        style={{
                            backgroundColor: PRIMARY_COLOR,
                            color: 'white',
                            padding: '12px 28px',
                            borderRadius: '8px',
                            border: 'none',
                            fontWeight: '600',
                            fontSize: '1rem',
                            cursor: loading ? 'wait' : 'pointer',
                            opacity: loading ? 0.7 : 1,
                            boxShadow: '0 2px 4px rgba(139, 0, 56, 0.2)',
                            transition: 'all 0.2s'
                        }}
                        onMouseOver={(e) => !loading && (e.currentTarget.style.transform = 'translateY(-1px)')}
                        onMouseOut={(e) => !loading && (e.currentTarget.style.transform = 'translateY(0)')}
                    >
                        {loading ? 'Procesando...' : 'Actualizar Solicitud'}
                    </button>
                </div>
            </div>
        </div>
      )}

    </div>
  );
};

export default SolicitudInfo;