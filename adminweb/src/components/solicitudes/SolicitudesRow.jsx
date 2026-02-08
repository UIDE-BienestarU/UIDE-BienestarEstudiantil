import EstadoBadge from "./EstadoBadge";
import SolicitudesActions from "./SolicitudesActions";

const SolicitudesRow = ({ solicitud }) => {
  if (!solicitud) return null;

  return (
    <tr style={{ transition: 'background-color 0.2s' }} onMouseOver={(e) => e.currentTarget.style.backgroundColor = '#f8f9fa'} onMouseOut={(e) => e.currentTarget.style.backgroundColor = 'transparent'}>
      <td className="id-col" style={{ padding: '16px', borderBottom: '1px solid #eee', color: '#8b0038', fontWeight: 'bold' }}>#{solicitud.id}</td>

      <td style={{ padding: '16px', borderBottom: '1px solid #eee' }}>
        <div style={{ fontWeight: '600', color: '#333' }}>{solicitud.estudiante?.nombre_completo || "Estudiante"}</div>
        <div className="sub" style={{ fontSize: '0.85rem', color: '#888', marginTop: '4px' }}>{solicitud.estudiante?.correo_institucional || "N/A"}</div>
      </td>

      <td style={{ padding: '16px', borderBottom: '1px solid #eee', color: '#555' }}>
        {solicitud.subtipo?.nombre_sub || solicitud.tipo || "Solicitud General"}
      </td>
      
      <td style={{ padding: '16px', borderBottom: '1px solid #eee', color: '#555' }}>
        {new Date(solicitud.createdAt || solicitud.fecha_solicitud).toLocaleDateString()}
      </td>

      <td style={{ padding: '16px', borderBottom: '1px solid #eee' }}>
        <EstadoBadge estado={solicitud.estado_actual} />
      </td>

      <td style={{ padding: '16px', borderBottom: '1px solid #eee', textAlign: 'center' }}>
        <SolicitudesActions solicitud={solicitud} />
      </td>
    </tr>
  );
};

export default SolicitudesRow;