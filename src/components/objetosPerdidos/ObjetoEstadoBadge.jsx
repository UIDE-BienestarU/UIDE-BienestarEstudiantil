export default function ObjetosEstadoBadge({ estado }) {
  const colores = {
    "POR RECLAMAR": "bg-yellow-500 text-white",
    "VERIFICADO":   "bg-purple-600 text-white",
    "EN BODEGA":    "bg-blue-600 text-white",
    "ENTREGADO":    "bg-green-600 text-white",
  };

  const colorClase = colores[estado] || "bg-gray-500 text-white";

  return (
    <span className={`px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wide shadow-sm ${colorClase}`}>
      {estado}
    </span>
  );
}