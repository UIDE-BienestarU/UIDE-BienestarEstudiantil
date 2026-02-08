import { useState, useEffect } from "react";
import StatsCard from "./StatCard";
// import { stats } from "../../mock/dashboardMock"; // Remove mock
import estadisticasService from "../../services/estadisticasService";

export default function StatsGrid() {
  const [stats, setStats] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const data = await estadisticasService.getResumen();
        const statsData = data.data || data;
        
        // Only showing 3 main cards as per user request to remove extras
        // If values are 0, we still show them to indicate system status, but we can filter if needed.
        const mappedStats = [
          { label: "Solicitudes Totales", value: statsData.totalSolicitudes ?? statsData.total ?? 0, icon: "file", color: "#fce7f3" }, // Pink
          { label: "Objetos Perdidos", value: statsData.totalObjetos ?? 0, icon: "box", color: "#fef3c7" }, // Amber
        ];
        // Optional: Filter out 0 values if user really hates empty boxes? 
        // For now, let's keep these 3 as they are core modules.
        
        setStats(mappedStats);
      } catch (error) {
        console.error("Error fetching stats", error);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) return <div style={{ padding: '20px', textAlign: 'center', color: '#888' }}>Cargando resumen...</div>;

  return (
    <div className="stats-grid" style={{ 
      display: 'grid', 
      gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', 
      gap: '24px', 
      marginBottom: '40px' 
    }}>
      {stats.map((item, i) => (
        <StatsCard key={i} {...item} />
      ))}
    </div>
  );
}
