import { FaMapMarkerAlt, FaCalendarAlt, FaCheckCircle, FaExclamationCircle, FaBoxOpen, FaTrash } from 'react-icons/fa';

export default function ObjetosCard({ objeto, onVerDetalles, onEntregar, onEliminar }) {
  const isDevuelto = objeto.estado === 'devuelto';
  const isEncontrado = objeto.estado === 'encontrado';

  const getStatusColor = () => {
    if (isDevuelto) return '#10b981'; // Green
    if (isEncontrado) return '#f59e0b'; // Amber
    return '#ef4444'; // Red (Perdido)
  };

  const getStatusIcon = () => {
      if (isDevuelto) return <FaCheckCircle />;
      if (isEncontrado) return <FaExclamationCircle />;
      return <FaBoxOpen />;
  };

  const imageUrl = objeto.imagen 
    ? (objeto.imagen.startsWith('http') ? objeto.imagen : `https://api-prod.uidehub.tech${objeto.imagen.startsWith('/') ? '' : '/'}${objeto.imagen}`)
    : 'https://via.placeholder.com/400x300?text=Sin+Foto';

  return (
    <div className="objetos-card" style={{
      backgroundColor: '#fff',
      borderRadius: '16px',
      overflow: 'hidden',
      boxShadow: '0 4px 20px rgba(0,0,0,0.08)',
      display: 'flex',
      flexDirection: 'column',
      transition: 'transform 0.2s, box-shadow 0.2s',
      border: '1px solid #f0f0f0',
      height: '100%',
      position: 'relative'
    }}
    onMouseOver={(e) => {
      e.currentTarget.style.transform = 'translateY(-5px)';
      e.currentTarget.style.boxShadow = '0 10px 25px rgba(0,0,0,0.12)';
    }}
    onMouseOut={(e) => {
      e.currentTarget.style.transform = 'translateY(0)';
      e.currentTarget.style.boxShadow = '0 4px 20px rgba(0,0,0,0.08)';
    }}
    >
      <div className="card-image" style={{ height: '200px', overflow: 'hidden', position: 'relative' }}>
        <img 
          src={imageUrl} 
          alt={objeto.titulo} 
          style={{ width: '100%', height: '100%', objectFit: 'cover' }}
          onError={(e) => e.target.src = 'https://via.placeholder.com/400x300?text=Uide'}
        />
        <div style={{ position: 'absolute', top: '15px', right: '15px' }}>
             <span style={{ 
                 backgroundColor: getStatusColor(), 
                 color: 'white', 
                 padding: '6px 12px', 
                 borderRadius: '30px', 
                 fontSize: '0.75rem', 
                 fontWeight: 'bold',
                 textTransform: 'uppercase',
                 letterSpacing: '0.5px',
                 boxShadow: '0 2px 5px rgba(0,0,0,0.2)',
                 display: 'flex',
                 alignItems: 'center',
                 gap: '6px'
             }}>
                 {getStatusIcon()} {objeto.estado}
             </span>
        </div>
      </div>

      <div className="card-content" style={{ padding: '24px', flex: 1, display: 'flex', flexDirection: 'column' }}>
        <h3 style={{ margin: '0 0 10px 0', fontSize: '1.2rem', color: '#222', fontWeight: '700' }}>
            {objeto.titulo || 'Sin Título'}
        </h3>
        
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '16px', color: '#666', fontSize: '0.9rem' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <FaCalendarAlt style={{ color: '#8b0038' }} />
                <span>
                    {objeto.createdAt || objeto.fecha 
                        ? new Date(objeto.createdAt || objeto.fecha).toLocaleDateString() 
                        : 'Fecha desconocida'}
                </span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <FaMapMarkerAlt style={{ color: '#8b0038' }} />
                <span>{objeto.lugar_encontrado || 'Ubicación no especificada'}</span>
            </div>
        </div>

        <p style={{ 
            color: '#555', 
            fontSize: '0.95rem', 
            lineHeight: '1.5', 
            flex: 1,
            display: '-webkit-box',
            WebkitLineClamp: 2,
            WebkitBoxOrient: 'vertical',
            overflow: 'hidden',
            marginBottom: '20px'
        }}>
            {objeto.descripcion}
        </p>

        <div className="card-actions" style={{ 
            display: 'flex', 
            gap: '10px', 
            marginTop: 'auto'
        }}>
          <button 
            onClick={() => onVerDetalles(objeto)}
            title="Ver Detalles"
            style={{
                flex: 1,
                padding: '10px',
                border: '1px solid #e5e7eb',
                backgroundColor: '#fff',
                color: '#374151',
                borderRadius: '8px',
                cursor: 'pointer',
                fontWeight: '600',
                fontSize: '0.9rem',
                transition: 'all 0.2s'
            }}
            onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#f9fafb'}
            onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#fff'}
          >
            Ver Detalles
          </button>
          
          {!isDevuelto && (
            <button 
              onClick={() => onEntregar(objeto.id)}
              title="Entregar"
              style={{
                  flex: 1,
                  padding: '10px',
                  border: 'none',
                  backgroundColor: '#8b0038',
                  color: 'white',
                  borderRadius: '8px',
                  cursor: 'pointer',
                  fontWeight: '600',
                  fontSize: '0.9rem',
                  transition: 'all 0.2s'
              }}
              onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#be123c'}
              onMouseOut={(e) => e.currentTarget.style.backgroundColor = '#8b0038'}
            >
              Entregar
            </button>
          )}

            <button 
              onClick={() => onEliminar(objeto.id)}
              title="Eliminar"
              style={{
                  padding: '10px 14px',
                  border: '1px solid #fee2e2',
                  backgroundColor: '#fff1f2',
                  color: '#e11d48',
                  borderRadius: '8px',
                  cursor: 'pointer',
                  fontSize: '1rem',
                  transition: 'all 0.2s',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
              }}
              onMouseOver={(e) => { e.currentTarget.style.backgroundColor = '#ffe4e6'; e.currentTarget.style.borderColor = '#fecdd3'; }}
              onMouseOut={(e) => { e.currentTarget.style.backgroundColor = '#fff1f2'; e.currentTarget.style.borderColor = '#fee2e2'; }}
            >
              <FaTrash />
            </button>
        </div>
      </div>
    </div>
  );
}