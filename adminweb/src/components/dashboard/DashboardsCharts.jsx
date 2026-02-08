import { useEffect, useState } from "react";
import estadisticasService from "../../services/estadisticasService";

export default function DashboardCharts() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const res = await estadisticasService.getResumen();
        const stats = res.data || res;
        if (stats.porSubtipo) {
           const chartData = Object.entries(stats.porSubtipo).map(([label, value]) => ({
             label,
             value
           }));
           // Calculate percentages for bars or just use raw count?
           // Let's use raw count but normalize for bar height for visual
           const max = Math.max(...chartData.map(d => d.value), 1);
           const normalized = chartData.map(d => ({
             ...d,
             percent: (d.value / max) * 100
           }));
           setData(normalized);
        }
      } catch (error) {
        console.error("Error loading charts", error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) return <div style={{ padding: '40px', textAlign: 'center', color: '#888' }}>Cargando gráficos...</div>;
  if (data.length === 0) return (
    <div className="chart-card" style={{ padding: '40px', backgroundColor: '#fff', borderRadius: '16px', boxShadow: '0 4px 20px rgba(0,0,0,0.05)', textAlign: 'center' }}>
       <h3 style={{ margin: '0 0 10px 0', color: '#444' }}>Solicitudes por Tipo</h3>
       <p style={{ color: '#888' }}>No hay datos suficientes para mostrar el gráfico.</p>
    </div>
  );

  return (
    <div className="chart-card" style={{ 
      backgroundColor: '#fff', 
      padding: '30px', 
      borderRadius: '16px', 
      boxShadow: '0 4px 20px rgba(0,0,0,0.05)',
      height: '100%',
      display: 'flex',
      flexDirection: 'column'
    }}>
      <h3 style={{ margin: '0 0 30px 0', fontSize: '1.2rem', color: '#333' }}>Solicitudes por Tipo</h3>

      <div style={{ flex: 1, display: 'flex', alignItems: 'flex-end', gap: '20px', minHeight: '400px', position: 'relative' }}>
        
        {/* Y-Axis Lines (Grid) */}
        <div style={{ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, display: 'flex', flexDirection: 'column', justifyContent: 'space-between', zIndex: 0, pointerEvents: 'none' }}>
           {[100, 75, 50, 25, 0].map((line) => (
              <div key={line} style={{ borderBottom: '1px dashed #eee', width: '100%', height: '1px', position: 'relative' }}>
                 {/* <span style={{ position: 'absolute', left: '-30px', top: '-8px', fontSize: '0.7rem', color: '#ccc' }}>{line}%</span> */} 
              </div>
           ))}
        </div>

        {data.map((d, i) => (
          <div key={i} className="bar-container" style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', height: '100%', justifyContent: 'flex-end', zIndex: 1, position: 'relative', group: 'bar' }}>
            
            {/* Tooltip on hover (CSS magic needed or JS state, keeping simple for now) */}
            <div 
                style={{ 
                    marginBottom: '10px', 
                    fontWeight: 'bold', 
                    color: '#8b0038', 
                    opacity: d.percent > 0 ? 1 : 0,
                    transition: 'all 0.3s',
                    fontSize: '0.9rem'
                }}
            >
                {d.value}
            </div>

            <div
              className="bar-fill"
              style={{ 
                width: '60%', 
                maxWidth: '60px',
                height: d.percent > 0 ? `${d.percent}%` : '4px', 
                backgroundColor: '#8b0038', 
                borderRadius: '8px 8px 0 0',
                transition: 'height 1s ease-out',
                opacity: 0.9,
                cursor: 'pointer'
              }}
              title={`${d.label}: ${d.value}`}
              onMouseOver={(e) => e.currentTarget.style.opacity = '1'}
              onMouseOut={(e) => e.currentTarget.style.opacity = '0.9'}
            ></div>
            
            <span style={{ 
                fontSize: '0.75rem', 
                marginTop: '12px', 
                textAlign: 'center', 
                color: '#666',
                fontWeight: '500',
                width: '100%',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
                display: '-webkit-box',
                WebkitLineClamp: 2,
                WebkitBoxOrient: 'vertical',
                lineHeight: '1.2'
            }}>
                {d.label}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
