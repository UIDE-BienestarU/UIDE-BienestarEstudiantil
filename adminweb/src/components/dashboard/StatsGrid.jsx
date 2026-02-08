import { useState, useEffect } from "react";
import StatsCard from "./StatCard";
import estadisticasService from "../../services/estadisticasService";
import objetosPerdidosService from "../../services/objetosPerdidosService";
import publicacionesService from "../../services/publicacionesService";
import { FaBoxOpen, FaClipboardList, FaBullhorn } from "react-icons/fa";

export default function StatsGrid() {
  const [stats, setStats] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Parallel fetching for speed
        const [resumenStats, objetosRes, avisosRes] = await Promise.all([
           estadisticasService.getResumen().catch(() => ({ data: {} })),
           objetosPerdidosService.getAll().catch(() => ({ data: [] })),
           publicacionesService.getAll().catch(() => ({ data: [] }))
        ]);

        const statsData = resumenStats.data || resumenStats;
        
        // Helper to safely get count from various response formats
        const getCount = (response) => {
            if (!response) return 0;
            if (response.data && Array.isArray(response.data)) return response.data.length;
            if (Array.isArray(response)) return response.length;
            if (response.rows && Array.isArray(response.rows)) return response.count || response.rows.length;
            if (response.data && response.data.rows) return response.data.count || response.data.rows.length;
            return 0;
        };

        const objetosCount = getCount(objetosRes);
        const avisosCount = getCount(avisosRes);

        const mappedStats = [
          { 
              label: "Solicitudes Totales", 
              value: statsData.totalSolicitudes ?? statsData.total ?? 0, 
              icon: <FaClipboardList />, 
              color: "#ecfccb",  // Lime
              iconColor: "#65a30d"
          }, 
          { 
              label: "Objetos Perdidos", 
              value: objetosCount, 
              icon: <FaBoxOpen />, 
              color: "#fef3c7", // Amber
              iconColor: "#d97706"
          },
          { 
              label: "Avisos Publicados", 
              value: avisosCount, 
              icon: <FaBullhorn />, 
              color: "#ffe4e6", // Rose (changed from Red for softer look)
              iconColor: "#e11d48"
          },
        ];
        
        setStats(mappedStats);
      } catch (error) {
        console.error("Error fetching dashboard stats", error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) return <div style={{ padding: '20px', textAlign: 'center', color: '#9ca3af' }}>Cargando resumen...</div>;

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
