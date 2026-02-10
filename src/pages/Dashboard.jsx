import { useRef } from "react";
import TopBar from "../components/layout/TopBar";
import StatsGrid from "../components/dashboard/StatsGrid";
import DashboardCharts from "../components/dashboard/DashboardsCharts";
import RecentActivity from "../components/dashboard/RecentActivity";
import ErrorBoundary from "../components/common/ErrorBoundary";
import { generateSolicitudesPdf } from "../utils/reports/generateSolicitudesPdf";

export default function Dashboard() {
  const statsRef = useRef(null);
  const chartsRef = useRef(null);

  // EJEMPLO: reemplaza esto por tus solicitudes reales (API/estado global/etc.)
  const solicitudes = [
    { id: "SOL-001", solicitante: "Ana", estado: "Pendiente", prioridad: "Alta", fecha: "2026-02-05" },
    { id: "SOL-002", solicitante: "Luis", estado: "En proceso", prioridad: "Media", fecha: "2026-02-06" },
  ];

  const handlePdf = async () => {
    await generateSolicitudesPdf({
      title: "Reporte de Solicitudes",
      subtitle: "Resumen + estadísticas del sistema",
      solicitudes,
      capture: {
        statsEl: statsRef.current,
        chartsEl: chartsRef.current,
      },
      fileName: `reporte_solicitudes_${new Date().toISOString().slice(0, 10)}.pdf`,
    });
  };

  return (
    <>
      <TopBar />

      <main className="dashboard-page">
        <header className="page-header">
          <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 12 }}>
            <div>
              <h1>Resumen del sistema</h1>
              <p>Bienvenido, administrador. Aquí tienes un resumen general.</p>
            </div>

            <button onClick={handlePdf} className="print-btn">
              Generar PDF
            </button>
          </div>
        </header>

        <div ref={statsRef}>
          <StatsGrid />
        </div>

        <section className="dashboard-grid">
          <ErrorBoundary>
            <div ref={chartsRef}>
              <DashboardCharts />
            </div>
          </ErrorBoundary>

          <ErrorBoundary>
            <RecentActivity />
          </ErrorBoundary>
        </section>
      </main>
    </>
  );
}
