import EstadoBadge from "./EstadoBadge";
import SolicitudesActions from "./SolicitudesActions";

const SolicitudesRow = ({ solicitud }) => {
  if (!solicitud) return null;

  return (
    <tr>
      <td className="id-col">#{solicitud.id}</td>

      <td>
        <strong>{solicitud.estudiante}</strong>
        <div className="sub">{solicitud.carrera}</div>
      </td>

      <td>{solicitud.tramite}</td>
      <td>{solicitud.fecha}</td>

      <td>
        <EstadoBadge estado={solicitud.estado} />
      </td>

      <td>
        <SolicitudesActions solicitud={solicitud} />
      </td>
    </tr>
  );
};

export default SolicitudesRow;