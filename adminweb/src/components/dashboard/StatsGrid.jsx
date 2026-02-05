import StatsCard from "./StatCard";
import { stats } from "../../mock/dashboardMock";

export default function StatsGrid() {
  return (
    <div className="stats-grid">
      {stats.map((item, i) => (
        <StatsCard key={i} {...item} />
      ))}
    </div>
  );
}
