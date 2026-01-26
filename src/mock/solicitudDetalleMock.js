const solicitudDetalleMock = [
  {
    id: "REQ-2024", 
    estado: "EN TRÁMITE",
    tipo: "Subsidio de Comedor",
    estudiante: {
      nombre: "Juan Fuentes",
      avatar: "https://ui-avatars.com/api/?name=Juan+Fuentes&size=128&rounded=true&bold=true&background=1e40af&color=ffffff",
      carrera: "Ingeniería en Sistemas",
      cedula: "1103456789",
      activo: true,
      idEstudiante: "2030045"
    },
    detalle: {
      descripcion: "Solicito subsidio de comedor debido a dificultades económicas familiares. Mantengo promedio 4.8 y asisto regularmente a clases."
    },
    documentos: [
      { nombre: "Certificado_de_Ingresos.pdf", tamaño: "1.2 MB", fecha: "01/10/2025" },
      { nombre: "Certificado_Médico_Familiar.jpg", tamaño: "2.5 MB", fecha: "23/10/2025" }
    ],
    historial: [
      {
        fecha: "Hoy 09:15",
        accion: "Comentario agregado",
        detalle: "Se requiere verificar vigencia del certificado médico.",
        usuario: "admin_MarcelaV",
        icon: "💬",
        color: "#fbbf24"
      },
      {
        fecha: "24 Oct 10:00",
        accion: "Documentos verificados",
        detalle: "Documentos económicos y académicos validados.",
        usuario: "Sistema",
        icon: "✅",
        color: "#10b981"
      },
      {
        fecha: "23 Oct 15:45",
        accion: "Solicitud asignada",
        detalle: "Asignada a revisión de Bienestar.",
        usuario: "admin_Olga",
        icon: "📋",
        color: "#3b82f6"
      },
      {
        fecha: "23 Oct 14:30",
        accion: "Solicitud recibida",
        detalle: "Recibida desde el portal del estudiante.",
        usuario: "Juan Pérez Rodríguez",
        icon: "📤",
        color: "#6b7280"
      }
    ]
  },
  {
    id: "REQ-2025", 
    estado: "APROBADA",
    tipo: "Apoyo Económico",
    estudiante: {
      nombre: "Mateo Castillo",
      avatar: "https://ui-avatars.com/api/?name=Mateo+Castillo&size=128&rounded=true&bold=true&background=16a34a&color=ffffff",
      carrera: "Arquitectura",
      cedula: "1724567890",
      activo: true,
      idEstudiante: "2040123"
    },
    detalle: {
      descripcion: "Solicitud de apoyo económico para pago de materiales de construcción y software especializado para el proyecto final de carrera."
    },
    documentos: [
      { nombre: "Plan_de_Estudios.pdf", tamaño: "0.9 MB", fecha: "05/10/2025" },
      { nombre: "Comprobante_Ingresos_Familiares.pdf", tamaño: "1.8 MB", fecha: "10/10/2025" }
    ],
    historial: [
      {
        fecha: "Ayer 14:30",
        accion: "Aprobada",
        detalle: "Solicitud aprobada tras revisión completa.",
        usuario: "admin_RicardoA",
        icon: "✅",
        color: "#10b981"
      },
      {
        fecha: "11 Oct 11:00",
        accion: "Revisión final",
        detalle: "Documentos validados y promedio académico confirmado.",
        usuario: "Sistema",
        icon: "📄",
        color: "#3b82f6"
      }
    ]
  },
  {
    id: "REQ-2026", 
    estado: "EN REVISIÓN",
    tipo: "Residencia Universitaria",
    estudiante: {
      nombre: "Cristian Salinas",
      avatar: "https://ui-avatars.com/api/?name=Cristian+Salinas&size=128&rounded=true&bold=true&background=1d4ed8&color=ffffff",
      carrera: "Derecho",
      cedula: "1725678901",
      activo: true,
      idEstudiante: "2050678"
    },
    detalle: {
      descripcion: "Solicitud de residencia estudiantil por ser de fuera de la ciudad y tener horarios de rotación hospitalaria extensa."
    },
    documentos: [
      { nombre: "Certificado_Domicilio.pdf", tamaño: "1.1 MB", fecha: "08/10/2025" }
    ],
    historial: [
      {
        fecha: "Hoy 10:45",
        accion: "En revisión",
        detalle: "Asignada a comité de bienestar para evaluación.",
        usuario: "admin_Olga",
        icon: "📋",
        color: "#3b82f6"
      }
    ]
  }
];

export default solicitudDetalleMock;