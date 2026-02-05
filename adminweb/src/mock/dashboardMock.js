// src/mock/dashboardMock.js
export const stats = [
  {
    title: "Solicitudes pendientes",
    value: 2,
    trend: "+12% esta semana",
    color: "secondary",
    icon: "pending"
  },
  {
    title: "Solicitudes aprobadas",
    value: 10,
    trend: "92% aprobadas",
    color: "primary",
    icon: "check"
  },
  {
    title: "Total revisadas",
    value: 10,
    trend: "Histórico",
    color: "accent",
    icon: "history"
  }
];

export const weeklyRequests = [
  { day: "LUN", value: 45 },
  { day: "MAR", value: 65 },
  { day: "MIÉ", value: 90 },
  { day: "JUE", value: 55 },
  { day: "VIE", value: 80 },
  { day: "SÁB", value: 30 },
  { day: "DOM", value: 20 }
];

export const recentActivity = [
  {
    name: "Juan Fuentes",
    category: "Beca Academica",
    date: "Hace 2 horas",
    status: "PENDIENTE",
    initials: "JPR",
    id: "REQ-2024" // coincide con solicitudesMock
  },
  {
    name: "Mateo Castillo",
    category: "Beca Económica",
    date: "Hace 5 horas",
    status: "APROBADA",
    initials: "MGL",
    id: "REQ-2025"
  },
  {
    name: "Cristian Salinas",
    category: "Asistencia Psicologica",
    date: "Ayer",
    status: "EN REVISIÓN",
    initials: "CRM",
    id: "REQ-2026"
  }
];