import SolicitudesRow from "./SolicitudesRow";

const SolicitudesTable = ({ solicitudes = [] }) => {
  if (!Array.isArray(solicitudes) || solicitudes.length === 0) {
    return <p>No hay solicitudes para mostrar</p>;
  }

  return (
    <div style={{ overflowX: 'auto', backgroundColor: '#fff', borderRadius: '12px', boxShadow: '0 4px 6px rgba(0,0,0,0.05)' }}>
      <table className="tabla" style={{ width: '100%', borderCollapse: 'separate', borderSpacing: '0', minWidth: '800px' }}>
        <thead style={{ backgroundColor: '#f9fafb' }}>
          <tr>
            <th style={{ padding: '16px', textAlign: 'left', fontWeight: '600', color: '#666', borderBottom: '1px solid #eee' }}>ID</th>
            <th style={{ padding: '16px', textAlign: 'left', fontWeight: '600', color: '#666', borderBottom: '1px solid #eee' }}>Estudiante</th>
            <th style={{ padding: '16px', textAlign: 'left', fontWeight: '600', color: '#666', borderBottom: '1px solid #eee' }}>Trámite</th>
            <th style={{ padding: '16px', textAlign: 'left', fontWeight: '600', color: '#666', borderBottom: '1px solid #eee' }}>Fecha</th>
            <th style={{ padding: '16px', textAlign: 'left', fontWeight: '600', color: '#666', borderBottom: '1px solid #eee' }}>Estado</th>
            <th className="acciones-header" style={{ padding: '16px', textAlign: 'center', fontWeight: '600', color: '#666', borderBottom: '1px solid #eee' }}>Acciones</th>
          </tr>
        </thead>
        <tbody>
          {solicitudes.map((solicitud) =>
            solicitud ? (
              <SolicitudesRow
                key={solicitud.id}
                solicitud={solicitud}
              />
            ) : null
          )}
        </tbody>
      </table>
    </div>
  );
};

export default SolicitudesTable;
