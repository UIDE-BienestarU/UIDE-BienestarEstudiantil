// src/utils/reports/generateSolicitudesPdf.js
import { jsPDF } from "jspdf";
import autoTable from "jspdf-autotable";
import html2canvas from "html2canvas";

function pad(n) {
  return String(n).padStart(2, "0");
}

function formatDateTime(d = new Date()) {
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

/**
 * Captura el elemento y retorna:
 * - dataUrl: imagen PNG
 * - pxW/pxH: tamaño real del canvas (para respetar proporción en el PDF)
 */
async function captureElement(el, { scale = 2 } = {}) {
  if (!el) return null;

  const canvas = await html2canvas(el, {
    scale,
    backgroundColor: "#ffffff",
    useCORS: true,
    logging: false,
    windowWidth: document.documentElement.clientWidth,
    scrollX: 0,
    scrollY: -window.scrollY,
  });

  return {
    dataUrl: canvas.toDataURL("image/png"),
    pxW: canvas.width,
    pxH: canvas.height,
  };
}

function addSectionTitle(doc, text, x, y, w) {
  doc.setFont("helvetica", "bold");
  doc.setFontSize(12);
  doc.text(text, x, y);

  // línea finita a la derecha del título
  const titleWidth = doc.getTextWidth(text);
  const lineStart = x + titleWidth + 4;
  if (lineStart < x + w) {
    doc.setDrawColor(220);
    doc.line(lineStart, y - 1.5, x + w, y - 1.5);
  }
}

function drawCard(doc, x, y, w, h) {
  doc.setDrawColor(230);
  doc.setFillColor(255, 255, 255);
  doc.roundedRect(x, y, w, h, 3, 3, "FD");
}

/**
 * Dibuja una imagen respetando proporción real.
 * - Usa todo el ancho disponible.
 * - Calcula altura según aspect ratio real.
 * - Si no cabe, crea nueva página.
 */
function addResponsiveImage(doc, img, { x, y, maxW, pageH, bottomGap = 16 }) {
  const ratio = img.pxH / img.pxW; // alto/ancho
  const w = maxW;
  const h = w * ratio;

  if (y + h > pageH - bottomGap) {
    doc.addPage();
    y = 16;
  }

  // borde suave
  doc.setDrawColor(230);
  doc.roundedRect(x, y, w, h, 3, 3, "S");

  doc.addImage(img.dataUrl, "PNG", x, y, w, h, undefined, "FAST");

  return { newY: y + h };
}

export async function generateSolicitudesPdf({
  title = "Reporte de Solicitudes",
  subtitle = "",
  solicitudes = [],
  capture = { statsEl: null, chartsEl: null },
  fileName = "reporte.pdf",
}) {
  const doc = new jsPDF("p", "mm", "a4");
  const pageW = doc.internal.pageSize.getWidth();
  const pageH = doc.internal.pageSize.getHeight();

  const marginX = 14;
  const contentW = pageW - marginX * 2;
  let y = 14;

  // ===== Header tipo “card” =====
  drawCard(doc, marginX, y, contentW, 26);

  doc.setFont("helvetica", "bold");
  doc.setFontSize(16);
  doc.text(title, marginX + 10, y + 11);

  doc.setFont("helvetica", "normal");
  doc.setFontSize(10);
  if (subtitle) doc.text(subtitle, marginX + 10, y + 17);

  doc.setTextColor(120);
  doc.text(`Generado: ${formatDateTime(new Date())}`, pageW - marginX - 10, y + 17, { align: "right" });
  doc.setTextColor(0);

  y += 34;

  // ===== Resumen con “mini tarjeta” =====
  const total = solicitudes.length;

  const byEstado = solicitudes.reduce((acc, s) => {
    const k = s.estado ?? "Sin estado";
    acc[k] = (acc[k] || 0) + 1;
    return acc;
  }, {});

  const byPrioridad = solicitudes.reduce((acc, s) => {
    const k = s.prioridad ?? "Sin prioridad";
    acc[k] = (acc[k] || 0) + 1;
    return acc;
  }, {});

  drawCard(doc, marginX, y, contentW, 24);

  doc.setFont("helvetica", "bold");
  doc.setFontSize(12);
  doc.text("Resumen", marginX + 8, y + 9);

  doc.setFont("helvetica", "normal");
  doc.setFontSize(10);
  doc.text(`Total: ${total}`, marginX + 8, y + 16);

  const estadosTexto = Object.entries(byEstado)
    .sort((a, b) => b[1] - a[1])
    .map(([k, v]) => `${k}: ${v}`)
    .join("  ·  ");

  doc.setTextColor(80);
  doc.text(estadosTexto || "—", marginX + 48, y + 16);
  doc.setTextColor(0);

  y += 34;

  // ===== Captura: Estadísticas =====
  const statsImg = await captureElement(capture.statsEl, { scale: 2 });
  if (statsImg) {
    addSectionTitle(doc, "Estadísticas", marginX, y, contentW);
    y += 6;

    const out = addResponsiveImage(doc, statsImg, {
      x: marginX,
      y,
      maxW: contentW, // MISMO ANCHO para todas
      pageH,
    });
    y = out.newY + 10;
  }

  // ===== Captura: Gráficos =====
  const chartsImg = await captureElement(capture.chartsEl, { scale: 2 });
  if (chartsImg) {
    if (y > pageH - 60) {
      doc.addPage();
      y = 16;
    }

    addSectionTitle(doc, "Gráficos", marginX, y, contentW);
    y += 6;

    const out = addResponsiveImage(doc, chartsImg, {
      x: marginX,
      y,
      maxW: contentW, // MISMO ANCHO para todas
      pageH,
    });
    y = out.newY + 10;
  }

  // ===== Resúmenes agregados (SIN detalle por solicitud) =====
  if (y > pageH - 80) {
    doc.addPage();
    y = 16;
  }


  doc.save(fileName);
}
