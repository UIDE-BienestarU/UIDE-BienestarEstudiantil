import { useState, useEffect } from "react";
import sugerenciasService from "../services/sugerenciasService";
import TopBar from "../components/layout/TopBar";
import { FaUserSecret, FaUser, FaQuoteLeft, FaCalendarAlt, FaEnvelopeOpenText } from 'react-icons/fa';

const Sugerencias = () => {
  const [sugerencias, setSugerencias] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchSugerencias = async () => {
      try {
        const response = await sugerenciasService.getAll();
        // Backend returns { message: "OK", data: [...] }
        setSugerencias(response.data || []);
      } catch (error) {
        console.error("Error al cargar sugerencias", error);
      } finally {
        setLoading(false);
      }
    };

    fetchSugerencias();
  }, []);

  const formatDate = (dateString) => {
    return new Date(dateString).toLocaleDateString("es-EC", {
      year: 'numeric',
      month: 'long', 
      day: 'numeric'
    });
  };

  return (
    <>
      <TopBar />
      <div className="contenedor">
        <h1>Buzón de Sugerencias</h1>
        
        <div className="header-actions">
           <div className="contador-pendientes">
              <span>Tienes <strong>{sugerencias.length} mensajes</strong> recibidos</span>
           </div>
        </div>

        {loading ? (
             <div style={{ display: 'grid', placeItems: 'center', height: '400px', color: '#9ca3af' }}>
               <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '16px' }}>
                    <div className="spinner" style={{ width: '40px', height: '40px', border: '3px solid #f3f4f6', borderTop: '3px solid #be123c', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></div>
                    <span>Cargando mensajes recientes...</span>
               </div>
               <style>{`@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }`}</style>
             </div>
        ) : sugerencias.length === 0 ? (
             <div style={{ 
                 textAlign: 'center', 
                 padding: '80px 20px', 
                 backgroundColor: '#fff', 
                 borderRadius: '24px', 
                 boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)',
                 border: '1px dashed #e5e7eb'
             }}>
                 <div style={{ 
                     display: 'inline-flex', padding: '24px', borderRadius: '50%', backgroundColor: '#f9fafb', marginBottom: '24px'
                 }}>
                    <FaEnvelopeOpenText size={64} color="#d1d5db" />
                 </div>
                 <h3 style={{ color: '#111827', margin: '0 0 12px 0', fontSize: '1.5rem', fontWeight: 'bold' }}>Buzón Vacío</h3>
                 <p style={{ color: '#6b7280', margin: 0, fontSize: '1.1rem' }}>
                    No hay nuevas sugerencias. ¡Todo parece estar en orden!
                 </p>
             </div>
        ) : (
          <div style={{ 
              display: 'grid', 
              gridTemplateColumns: 'repeat(auto-fill, minmax(380px, 1fr))', 
              gap: '28px',
              alignItems: 'start' 
          }}>
            {sugerencias.map((item, index) => {
              const isAnonimo = item.es_anonima;
              
              return (
                <div key={item.id} style={{
                    backgroundColor: 'white',
                    borderRadius: '20px',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03)',
                    padding: '0', // Reset padding for inner layout
                    display: 'flex',
                    flexDirection: 'column',
                    transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
                    position: 'relative',
                    overflow: 'hidden',
                    border: '1px solid rgba(0,0,0,0.04)'
                }}
                onMouseOver={e => {
                    e.currentTarget.style.transform = 'translateY(-8px)';
                    e.currentTarget.style.boxShadow = '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05)';
                    e.currentTarget.style.borderColor = 'rgba(190, 18, 60, 0.1)';
                }}
                onMouseOut={e => {
                    e.currentTarget.style.transform = 'translateY(0)';
                    e.currentTarget.style.boxShadow = '0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03)';
                    e.currentTarget.style.borderColor = 'rgba(0,0,0,0.04)';
                }}
                >
                  {/* Top Identifier Strip */}
                  <div style={{ 
                      height: '6px', 
                      background: isAnonimo ? 'linear-gradient(90deg, #9ca3af, #d1d5db)' : 'linear-gradient(90deg, #0284c7, #38bdf8)' 
                  }} />

                  <div style={{ padding: '28px' }}>
                      {/* Header: User Info */}
                      <div style={{ display: 'flex', alignItems: 'center', gap: '14px', marginBottom: '20px' }}>
                         <div style={{ 
                             width: '48px', height: '48px', 
                             borderRadius: '14px', 
                             backgroundColor: isAnonimo ? '#f3f4f6' : '#e0f2fe',
                             color: isAnonimo ? '#4b5563' : '#0369a1',
                             display: 'flex', alignItems: 'center', justifyContent: 'center',
                             fontSize: '1.2rem',
                             boxShadow: '0 2px 4px rgba(0,0,0,0.05)'
                         }}>
                            {isAnonimo ? <FaUserSecret /> : <FaUser />}
                         </div>
                         <div>
                             <h4 style={{ margin: 0, color: '#111827', fontSize: '1.05rem', fontWeight: '700' }}>
                                 {isAnonimo ? 'Anónimo' : (item.estudiante?.nombre || 'Estudiante')}
                             </h4>
                             <span style={{ fontSize: '0.85rem', color: '#6b7280', display: 'flex', alignItems: 'center', gap: '5px', marginTop: '2px' }}>
                                <FaCalendarAlt size={11} />
                                {formatDate(item.createdAt)}
                             </span>
                         </div>
                      </div>

                      {/* Body: Message */}
                      <div style={{ position: 'relative', marginTop: '10px' }}>
                          <FaQuoteLeft size={24} color={isAnonimo ? "#f3f4f6" : "#e0f2fe"} style={{ position: 'absolute', top: -10, left: -10, zIndex: 0 }} />
                          <p style={{ 
                              margin: 0, 
                              color: '#374151', 
                              lineHeight: '1.7', 
                              fontSize: '1rem',
                              fontStyle: 'italic',
                              position: 'relative',
                              zIndex: 1,
                              fontFamily: 'serif' // Optional touch for "Quote" feel
                          }}>
                              "{item.mensaje}"
                          </p>
                      </div>
                  </div>
                  
                  {/* Footer / Meta (Optional, creates visual balance) */}
                  <div style={{ 
                      padding: '12px 28px', 
                      backgroundColor: '#f9fafb', 
                      borderTop: '1px solid #f3f4f6', 
                      display: 'flex', 
                      justifyContent: 'flex-end',
                      fontSize: '0.8rem',
                      color: '#9ca3af'
                  }}>
                      ID: #{item.id?.toString().slice(-4) || '????'}
                  </div>

                </div>
              );
            })}
          </div>
        )}
      </div>
    </>
  );
};

export default Sugerencias;
