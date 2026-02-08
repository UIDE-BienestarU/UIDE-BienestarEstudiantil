import { useEffect, useState } from "react";
import solicitudesService from "../../services/solicitudesService";
import EstadoBadge from "../solicitudes/EstadoBadge";
import { FaClock, FaHistory, FaSyncAlt, FaUser } from "react-icons/fa";

export default function RecentActivity() {
  const [recentActivity, setRecentActivity] = useState([]);
  const [loading, setLoading] = useState(true);
  const [lastUpdated, setLastUpdated] = useState(new Date());

  const fetchActivity = async (isBackground = false) => {
    try {
      if (!isBackground) setLoading(true);
      const response = await solicitudesService.getAll({ limit: 5 });
      const list = response.data || [];
      setRecentActivity(list);
      setLastUpdated(new Date());
    } catch (error) {
      console.error("Error fetching recent activity", error);
    } finally {
      if (!isBackground) setLoading(false);
    }
  };

  useEffect(() => {
    fetchActivity(); // Initial load

    const interval = setInterval(() => {
      fetchActivity(true); // Background update
    }, 15000); // Poll every 15 seconds

    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ 
      backgroundColor: 'white', 
      borderRadius: '16px', 
      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.05)',
      padding: '24px',
      overflow: 'hidden',
      border: '1px solid #f3f4f6',
      height: '100%'
    }}>
      <div style={{ 
          display: 'flex', 
          justifyContent: 'space-between', 
          alignItems: 'center', 
          marginBottom: '20px',
          borderBottom: '1px solid #f3f4f6',
          paddingBottom: '16px'
      }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
             <div style={{ backgroundColor: '#f0fdf4', padding: '8px', borderRadius: '8px', color: '#16a34a' }}>
                <FaHistory size={18} />
             </div>
             <div>
                <h3 style={{ margin: 0, color: '#111827', fontSize: '1.1rem', fontWeight: '700' }}>Actividad Reciente</h3>
                <p style={{ margin: 0, color: '#6b7280', fontSize: '0.85rem' }}>Últimas solicitudes recibidas</p>
             </div>
          </div>
          
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '0.75rem', color: '#9ca3af' }}>
              <FaSyncAlt className={loading ? "spin" : ""} size={10} />
              <span>Actualizado: {lastUpdated.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}</span>
          </div>
          <style>{`@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } } .spin { animation: spin 1s linear infinite; }`}</style>
      </div>

      {loading && recentActivity.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px', color: '#9ca3af' }}>Cargando actividad...</div>
      ) : recentActivity.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '40px', color: '#9ca3af' }}>No hay actividad reciente.</div>
      ) : (
        <div className="activity-list">
          <table style={{ width: '100%', borderCollapse: 'separate', borderSpacing: '0 8px' }}>
            <tbody>
              {recentActivity.map((solicitud) => (
                <tr key={solicitud.id} style={{ 
                    backgroundColor: '#fff',
                    transition: 'transform 0.2s',
                    cursor: 'default'
                }}
                onMouseOver={(e) => {
                    e.currentTarget.style.transform = 'translateX(4px)';
                }}
                onMouseOut={(e) => {
                    e.currentTarget.style.transform = 'translateX(0)';
                }}
                >
                  {/* User Avatar & Name */}
                  <td style={{ padding: '8px 4px', borderBottom: '1px solid #f9fafb' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div style={{ 
                          width: '36px', 
                          height: '36px', 
                          borderRadius: '10px', 
                          background: 'linear-gradient(135deg, #f3f4f6 0%, #e5e7eb 100%)', 
                          display: 'flex', 
                          alignItems: 'center', 
                          justifyContent: 'center',
                          fontSize: '0.9rem',
                          fontWeight: 'bold',
                          color: '#4b5563',
                          boxShadow: '0 2px 4px rgba(0,0,0,0.05)'
                      }}>
                        {solicitud.estudiante?.nombre_completo ? solicitud.estudiante.nombre_completo.charAt(0) : <FaUser size={12} />}
                      </div>
                      <div style={{ display: 'flex', flexDirection: 'column' }}>
                         <span style={{ fontWeight: '600', color: '#374151', fontSize: '0.95rem' }}>
                           {solicitud.estudiante?.nombre_completo || "Estudiante"}
                         </span>
                         <span style={{ fontSize: '0.8rem', color: '#6b7280' }}>
                           {solicitud.subtipo?.nombre_sub || "Trámite General"}
                         </span>
                      </div>
                    </div>
                  </td>

                  {/* Date */}
                  <td style={{ padding: '8px 12px', borderBottom: '1px solid #f9fafb', color: '#6b7280', fontSize: '0.85rem' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <FaClock size={10} />
                          {new Date(solicitud.createdAt).toLocaleDateString()}
                      </div>
                  </td>

                  {/* Status Badge */}
                  <td style={{ padding: '8px 4px', borderBottom: '1px solid #f9fafb', textAlign: 'right' }}>
                    <div style={{ transform: 'scale(0.9)', transformOrigin: 'right center' }}>
                        <EstadoBadge estado={solicitud.estado_actual} />
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
