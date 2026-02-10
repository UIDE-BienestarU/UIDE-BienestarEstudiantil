import { useState, useEffect } from 'react';
import { FaTimes, FaMapMarkerAlt, FaCalendarAlt, FaUser, FaCommentDots, FaTrash } from 'react-icons/fa';
import objetosPerdidosService from '../../services/objetosPerdidosService';

export default function ModalObjetoDetalle({ objeto, onClose, onEntregar, onEliminar }) {
  const [comentarios, setComentarios] = useState([]);
  const [loadingComentarios, setLoadingComentarios] = useState(true);

  useEffect(() => {
    if (objeto?.id) {
        fetchComentarios();
    }
  }, [objeto]);

  const fetchComentarios = async () => {
      try {
          setLoadingComentarios(true);
          const data = await objetosPerdidosService.getComentarios(objeto.id);
          // Backend returns { data: [...], meta: ... } or just [...]
          setComentarios(Array.isArray(data.data) ? data.data : (Array.isArray(data) ? data : []));
      } catch (error) {
          console.error("Error cargando comentarios", error);
      } finally {
          setLoadingComentarios(false);
      }
  };

  if (!objeto) return null;

  const imageUrl = objeto.imagen 
    ? (objeto.imagen.startsWith('http') ? objeto.imagen : `https://api-prod.uidehub.tech${objeto.imagen.startsWith('/') ? '' : '/'}${objeto.imagen}`)
    : 'https://via.placeholder.com/600x400?text=Sin+Foto';

  return (
    <div className="modal-overlay" style={{
      position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
      backgroundColor: 'rgba(0,0,0,0.7)', display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 1000,
      backdropFilter: 'blur(8px)'
    }} onClick={onClose}>
      <div className="modal-content" style={{
        backgroundColor: 'white', borderRadius: '20px', width: '90%', maxWidth: '900px', height: '85vh',
        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25)', overflow: 'hidden', display: 'flex', flexDirection: 'column'
      }} onClick={e => e.stopPropagation()}>
        
        {/* Header */}
        <div style={{
          padding: '20px 30px', borderBottom: '1px solid #eee', display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          backgroundColor: '#fff'
        }}>
          <div>
            <span style={{ fontSize: '0.9rem', color: '#8b0038', fontWeight: 'bold', textTransform: 'uppercase', letterSpacing: '1px' }}>
                {objeto.estado}
            </span>
            <h2 style={{ margin: '5px 0 0 0', color: '#111', fontSize: '1.8rem', fontWeight: '800' }}>{objeto.titulo}</h2>
          </div>
          <button onClick={onClose} style={{ background: '#f3f4f6', border: 'none', cursor: 'pointer', color: '#666', fontSize: '1.2rem', padding: '10px', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <FaTimes />
          </button>
        </div>

        <div style={{ flex: 1, overflowY: 'auto', display: 'flex', flexDirection: 'column', md: { flexDirection: 'row' } }}>
            <div style={{ display: 'flex', flexWrap: 'wrap', height: '100%' }}>
                {/* Left: Image & Details */}
                <div style={{ flex: '1 1 500px', padding: '30px', borderRight: '1px solid #eee', overflowY: 'auto' }}>
                    <div style={{ width: '100%', height: '300px', borderRadius: '16px', overflow: 'hidden', marginBottom: '24px', boxShadow: '0 4px 12px rgba(0,0,0,0.1)' }}>
                        <img src={imageUrl} alt={objeto.titulo} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    </div>

                    <div style={{ display: 'flex', gap: '20px', marginBottom: '24px', color: '#555' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <FaCalendarAlt style={{ color: '#8b0038' }} />
                            <span>{new Date(objeto.createdAt).toLocaleDateString(undefined, { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</span>
                        </div>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <FaMapMarkerAlt style={{ color: '#8b0038' }} />
                            <span>{objeto.lugar_encontrado}</span>
                        </div>
                    </div>

                    <h3 style={{ fontSize: '1.1rem', fontWeight: '700', marginBottom: '12px', color: '#333' }}>Descripción</h3>
                    <p style={{ color: '#4b5563', lineHeight: '1.6', fontSize: '1rem', whiteSpace: 'pre-line' }}>
                        {objeto.descripcion}
                    </p>

                    <div style={{ marginTop: '30px', paddingTop: '20px', borderTop: '1px solid #eee' }}>
                         <h4 style={{ fontSize: '0.9rem', color: '#6b7280', marginBottom: '10px' }}>Reportado por:</h4>
                         <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                             <div style={{ width: '40px', height: '40px', borderRadius: '50%', backgroundColor: '#fce7f3', color: '#8b0038', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>
                                 <FaUser />
                             </div>
                             <div>
                                 <div style={{ fontWeight: '600', color: '#1f2937' }}>{objeto.reportador?.nombre_completo || 'Usuario'}</div>
                                 <div style={{ fontSize: '0.85rem', color: '#9ca3af' }}>{objeto.reportador?.rol || 'Estudiante'}</div>
                             </div>
                         </div>
                    </div>
                </div>

                {/* Right: Comments */}
                <div style={{ flex: '1 1 350px', backgroundColor: '#f9fafb', display: 'flex', flexDirection: 'column', height: '100%' }}>
                    <div style={{ padding: '20px', borderBottom: '1px solid #eee', backgroundColor: '#fff' }}>
                        <h3 style={{ margin: 0, fontSize: '1.1rem', display: 'flex', alignItems: 'center', gap: '10px' }}>
                            <FaCommentDots style={{ color: '#8b0038' }}/> Comentarios / Reclamos
                        </h3>
                    </div>
                    
                    <div style={{ flex: 1, padding: '20px', overflowY: 'auto' }}>
                        {loadingComentarios ? (
                            <div style={{ textAlign: 'center', color: '#9ca3af', padding: '40px' }}>Cargando comentarios...</div>
                        ) : comentarios.length > 0 ? (
                            comentarios.map((c, i) => (
                                <div key={i} style={{ backgroundColor: 'white', padding: '16px', borderRadius: '12px', marginBottom: '12px', boxShadow: '0 2px 4px rgba(0,0,0,0.02)', border: '1px solid #e5e7eb' }}>
                                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                                        <span style={{ fontWeight: '600', color: '#1f2937', fontSize: '0.9rem' }}>{c.autor?.nombre_completo || 'Estudiante'}</span>
                                        <span style={{ fontSize: '0.75rem', color: '#9ca3af' }}>{new Date(c.fecha || c.createdAt).toLocaleDateString()}</span>
                                    </div>
                                    <p style={{ margin: 0, color: '#4b5563', fontSize: '0.95rem', lineHeight: '1.4' }}>{c.mensaje}</p>
                                    {c.es_reclamo && (
                                        <span style={{ display: 'inline-block', marginTop: '8px', fontSize: '0.7rem', backgroundColor: '#fee2e2', color: '#991b1b', padding: '2px 8px', borderRadius: '4px', fontWeight: 'bold' }}>POSIBLE DUEÑO</span>
                                    )}
                                </div>
                            ))
                        ) : (
                            <div style={{ textAlign: 'center', color: '#9ca3af', padding: '40px' }}>
                                No hay comentarios aún.
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>

        {/* Footer Actions */}
        <div style={{ padding: '20px', borderTop: '1px solid #eee', backgroundColor: '#fff', display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
            <button 
              onClick={() => {
                  onEliminar(objeto.id);
                  // Don't close details yet; wait for delete confirmation or let parent handle it.
                  // Actually, standard behavior is usually to keep this open until deleted.
                  // But since onEliminar (requestEliminar) just sets state in parent, 
                  // we might want to close this modal OR keep it open behind the confirmation?
                  // Keeping it open behind is better UX, but z-index handles that.
                  // Let's NOT call onClose() here, so the user sees the confirmation ON TOP of the details.
              }}
              style={{
                  padding: '12px 24px', borderRadius: '8px', border: '1px solid #fee2e2', background: '#fff1f2', color: '#e11d48', cursor: 'pointer', fontWeight: '600', fontSize: '1rem', marginRight: 'auto', display: 'flex', alignItems: 'center', gap: '8px'
              }}
            >
              <FaTrash /> Eliminar Objeto
            </button>
            
            {objeto.estado !== "devuelto" && (
              <button 
                onClick={() => {
                  onEntregar(objeto.id);
                  onClose();
                }}
                style={{ padding: '12px 24px', borderRadius: '8px', border: 'none', background: '#8b0038', color: 'white', cursor: 'pointer', fontWeight: '600', fontSize: '1rem', boxShadow: '0 4px 6px rgba(139, 0, 56, 0.2)' }}
              >
                Marcar como Entregado / Devuelto
              </button>
            )}
            <button onClick={onClose} style={{ padding: '12px 24px', borderRadius: '8px', border: '1px solid #d1d5db', background: 'white', color: '#374151', cursor: 'pointer', fontWeight: '600', fontSize: '1rem' }}>
              Cerrar
            </button>
        </div>
      </div>
    </div>
  );
}