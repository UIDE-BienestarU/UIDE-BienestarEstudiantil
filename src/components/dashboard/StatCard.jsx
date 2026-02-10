import { FaRegFileAlt, FaUsers, FaBoxOpen, FaBell } from "react-icons/fa";

export default function StatCard({ label, value, icon, color }) {
  // Map string icon names to React Icons if needed, or pass component directly
  const getIcon = () => {
    switch (icon) {
      case "file": return <FaRegFileAlt />;
      case "users": return <FaUsers />;
      case "box": return <FaBoxOpen />;
      case "bell": return <FaBell />;
      default: return <FaRegFileAlt />;
    }
  };

  return (
    <div className="stat-card" style={{
      backgroundColor: '#fff',
      padding: '24px',
      borderRadius: '16px',
      boxShadow: '0 4px 20px rgba(0,0,0,0.05)',
      display: 'flex',
      alignItems: 'center',
      gap: '20px',
      transition: 'transform 0.2s',
      border: '1px solid #f0f0f0'
    }}
    onMouseOver={(e) => e.currentTarget.style.transform = 'translateY(-5px)'}
    onMouseOut={(e) => e.currentTarget.style.transform = 'translateY(0)'}
    >
      <div style={{
        backgroundColor: color || '#fdf2f8',
        color: '#8b0038',
        width: '60px',
        height: '60px',
        borderRadius: '12px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontSize: '1.5rem'
      }}>
        {getIcon()}
      </div>
      <div>
        <p style={{ margin: 0, color: '#666', fontSize: '0.9rem', fontWeight: '500' }}>{label}</p>
        <h3 style={{ margin: '4px 0 0 0', fontSize: '2rem', color: '#333', fontWeight: '700' }}>{value}</h3>
      </div>
    </div>
  );
}
