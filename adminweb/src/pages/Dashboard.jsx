import TopBar from "../components/layout/TopBar";
import StatsGrid from "../components/dashboard/StatsGrid";
import DashboardCharts from "../components/dashboard/DashboardsCharts";
import RecentActivity from "../components/dashboard/RecentActivity";
import ErrorBoundary from "../components/common/ErrorBoundary";

export default function Dashboard() {
  return (
    <>
      <TopBar />

      <main className="dashboard-page">
        <header className="page-header">
          <h1>Resumen del sistema</h1>
          <p>Bienvenido, administrador. Aquí tienes un resumen general.</p>
        </header>

        <StatsGrid />

        <section className="dashboard-grid">
          <ErrorBoundary>
            <DashboardCharts />
          </ErrorBoundary>
          <ErrorBoundary>
            <RecentActivity />
          </ErrorBoundary>
        </section>
      </main>
    </>
  );
}
