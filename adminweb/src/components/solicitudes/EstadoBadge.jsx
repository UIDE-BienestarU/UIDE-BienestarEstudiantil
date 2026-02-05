const EstadoBadge = ({ estado }) => {
  const estadoLower = estado.toLowerCase();
  let clase = "badge";

  if (estadoLower === "pendiente") clase += " pendiente";
  else if (estadoLower === "aprobado") clase += " aprobado";
  else if (estadoLower === "en progreso" || estadoLower === "revision") clase += " en progreso";
  else clase += " " + estadoLower;

  const texto = estadoLower === "pendiente" ? "PENDIENTE" :
                estadoLower === "aprobado"  ? "APROBADO"  :
                estadoLower === "En progreso"  ? "EN PROGRESO"  : estado;

  return <span className={clase}>{texto}</span>;
};

export default EstadoBadge;