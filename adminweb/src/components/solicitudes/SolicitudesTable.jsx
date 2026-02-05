import SolicitudesRow from "./SolicitudesRow";

const SolicitudesTable = ({ solicitudes = [] }) => {
  if (!Array.isArray(solicitudes) || solicitudes.length === 0) {
    return <p>No hay solicitudes para mostrar</p>;
  }

  return (
    <table className="tabla">
      <thead>
        <tr>
          <th>ID</th>
          <th>Estudiante</th>
          <th>Trámite</th>
          <th>Fecha</th>
          <th>Estado</th>
          <th className="acciones-header">ACCIONES</th>  {/* ← clase nueva */}
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
  );
};

export default SolicitudesTable;
