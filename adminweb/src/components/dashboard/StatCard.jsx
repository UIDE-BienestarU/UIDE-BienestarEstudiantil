export default function StatsCard({ title, value, trend, color }) {
  return (
    <div className={`stat-card ${color}`}>
      <p className="stat-title">{title}</p>
      <h3>{value}</h3>
      <span className="stat-trend">{trend}</span>
    </div>
  );
}
