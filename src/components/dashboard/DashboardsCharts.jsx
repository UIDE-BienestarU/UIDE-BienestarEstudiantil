import { weeklyRequests } from "../../mock/dashboardMock";

export default function DashboardCharts() {
  return (
    <div className="chart-card">
      <h3>Solicitudes semanales</h3>

      <div className="chart-bars">
        {weeklyRequests.map((d, i) => (
          <div key={i} className="bar">
            <div
              className="bar-fill"
              style={{ height: `${d.value}%` }}
            ></div>
            <span>{d.day}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
