import { recentActivity } from "../../mock/dashboardMock";

export default function RecentActivity() {
  return (
    <div className="recent-activity">
      <h3>Actividad reciente</h3>

      <table>
        <thead>
          <tr>
            <th>Estudiante</th>
            <th>Categoría</th>
            <th>Fecha</th>
            <th>Estado</th>
          </tr>
        </thead>
        <tbody>
          {recentActivity.map((a, i) => (
            <tr key={i}>
              <td>
                <div className="student-cell">
                  <div className="avatar-sm">{a.initials}</div>
                  {a.name}
                </div>
              </td>
              <td>{a.category}</td>
              <td>{a.date}</td>
              <td>
                <span className={`status ${a.status.toLowerCase()}`}>
                  {a.status}
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
