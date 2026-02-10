import { FaHistory, FaPlusCircle, FaExchangeAlt, FaUser, FaClock } from 'react-icons/fa';

const HistorialTramites = ({ historial = [] }) => {
  const formatDate = (dateString) => {
    if (!dateString) return "Fecha desconocida";
    const date = new Date(dateString);
    return new Intl.DateTimeFormat('es-EC', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit'
    }).format(date);
  };

  const getActionIcon = (action) => {
    switch (action) {
      case 'CREATE': return <FaPlusCircle size={14} />;
      case 'UPDATE_STATUS': return <FaExchangeAlt size={14} />;
      default: return <FaClock size={14} />;
    }
  };

  const getActionColor = (action) => {
    switch (action) {
      case 'CREATE': return '#2563eb'; // Blue
      case 'UPDATE_STATUS': return '#f59e0b'; // Amber
      default: return '#9ca3af'; // Gray
    }
  };

  const safeHistorial = Array.isArray(historial) ? historial : [];

  return (
    <div style={{
      backgroundColor: 'white',
      borderRadius: '16px',
      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
      padding: '24px',
      height: '100%',
      border: '1px solid #f3f4f6'
    }}>
      <div style={{ 
        display: 'flex', 
        alignItems: 'center', 
        gap: '10px', 
        marginBottom: '24px',
        color: '#111827',
        fontSize: '1.1rem',
        fontWeight: '600',
        paddingBottom: '16px',
        borderBottom: '1px solid #f3f4f6'
      }}>
        <div style={{ 
          backgroundColor: '#f0f9ff', 
          padding: '8px', 
          borderRadius: '8px', 
          color: '#0284c7' 
        }}>
          <FaHistory size={18} />
        </div>
        Historial de Actividad
        <span style={{ 
            fontSize: '0.8rem', 
            backgroundColor: '#f3f4f6', 
            padding: '2px 8px', 
            borderRadius: '12px', 
            color: '#6b7280',
            marginLeft: 'auto'
        }}>
            {safeHistorial.length}
        </span>
      </div>

      <div className="timeline-container" style={{ position: 'relative', paddingLeft: '10px' }}>
        {safeHistorial.length === 0 ? (
          <div style={{ textAlign: 'center', color: '#9ca3af', padding: '20px' }}>
            No hay actividad registrada.
          </div>
        ) : (
          safeHistorial.map((item, index) => {
             const isLast = index === safeHistorial.length - 1;
             const color = getActionColor(item.action || item.accion);
             
             return (
              <div key={index} style={{ position: 'relative', paddingBottom: isLast ? '0' : '32px', paddingLeft: '24px' }}>
                {/* Connecting Line */}
                {!isLast && (
                  <div style={{
                    position: 'absolute',
                    left: '7px',
                    top: '24px',
                    bottom: '0',
                    width: '2px',
                    backgroundColor: '#e5e7eb'
                  }} />
                )}

                {/* Dot / Icon */}
                <div style={{
                  position: 'absolute',
                  left: '0',
                  top: '0',
                  width: '16px',
                  height: '16px',
                  borderRadius: '50%',
                  backgroundColor: 'white',
                  border: `2px solid ${color}`,
                  boxShadow: `0 0 0 2px white` // Ring effect
                }} />

                {/* Content */}
                <div>
                   <div style={{ 
                       fontSize: '0.75rem', 
                       color: '#9ca3af', 
                       marginBottom: '4px',
                       display: 'flex',
                       alignItems: 'center',
                       gap: '6px'
                   }}>
                       {formatDate(item.createdAt || item.fecha)}
                   </div>
                   
                   <div style={{ 
                       fontWeight: '600', 
                       color: '#374151',
                       fontSize: '0.95rem',
                       marginBottom: '4px'
                   }}>
                       {item.action === 'UPDATE_STATUS' ? 'Actualización de Estado' : 
                        item.action === 'CREATE' ? 'Solicitud Creada' : 
                        (item.action || 'Acción desconocida')}
                   </div>

                   {(item.comentario || item.detalle) && (
                     <div style={{ 
                         color: '#4b5563', 
                         fontSize: '0.9rem',
                         backgroundColor: '#f9fafb',
                         padding: '8px 12px',
                         borderRadius: '8px',
                         marginTop: '6px',
                         borderLeft: '3px solid #e5e7eb'
                     }}>
                        {item.comentario || item.detalle}
                     </div>
                   )}

                   {item.actor && (
                       <div style={{ 
                           marginTop: '6px', 
                           display: 'flex', 
                           alignItems: 'center', 
                           gap: '6px',
                           fontSize: '0.8rem',
                           color: '#6b7280'
                       }}>
                           <FaUser size={10} />
                           {item.actor.nombre_completo || item.usuario}
                       </div>
                   )}
                </div>
              </div>
             );
          })
        )}
      </div>
    </div>
  );
};

export default HistorialTramites;