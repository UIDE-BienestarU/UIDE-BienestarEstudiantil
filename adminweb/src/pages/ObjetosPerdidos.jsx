import { useState } from "react";
import ProtectedLayout from "../components/layout/ProtectedLayout";
import PageHeader from "../components/layout/PageHeader";

import ObjetosGrid from "../components/objetosPerdidos/ObjetosGrid";
import ModalObjetoDetalle from "../components/objetosPerdidos/ModalObjetoDetalle";
import ModalPublicarObjeto from "../components/objetosPerdidos/ModalPublicarObjeto";

import { objetosMock } from "../mock/objetosMock";

export default function ObjetosPerdidos() {
  const [objetos, setObjetos] = useState(objetosMock);
  const [selectedObjeto, setSelectedObjeto] = useState(null);
  const [showPublicarModal, setShowPublicarModal] = useState(false);

  // Publicar nuevo objeto
  const handlePublicar = (nuevo) => {
    setObjetos(prev => [...prev, nuevo]);
  };

  // Ver detalles
  const handleVerDetalles = (objeto) => {
    setSelectedObjeto(objeto);
  };

  // Entregar (cambia estado)
  const handleEntregar = (id) => {
    if (window.confirm("¿Confirmas la entrega del objeto?")) {
      setObjetos(prev =>
        prev.map(o =>
          o.id === id ? { ...o, estado: "ENTREGADO" } : o
        )
      );
    }
  };

  return (
    <ProtectedLayout>
      <div className="objetos-contenedor">
        <div className="objetos-header">
          <PageHeader
            title="Objetos Perdidos"
            subtitle="Gestiona los objetos encontrados en el campus. Asegúrate de verificar la identidad del estudiante antes de realizar la entrega formal."
          />
        </div>

        <div className="top-actions">
          <button 
            className="btn-publicar"
            onClick={() => setShowPublicarModal(true)}
          >
            + Publicar objeto perdido
          </button>
        </div>

        {/* Aquí va el grid con el prop objetos obligatorio */}
        <ObjetosGrid 
          objetos={objetos}                  // ← FIX PRINCIPAL: pasa el array aquí
          onVerDetalles={handleVerDetalles}
          onEntregar={handleEntregar}
        />

        <div className="paginacion-info">
          Mostrando {objetos.length} de {objetos.length} objetos
          {/* Aquí puedes poner paginación real más adelante */}
        </div>

        {selectedObjeto && (
          <ModalObjetoDetalle
            objeto={selectedObjeto}
            onClose={() => setSelectedObjeto(null)}
            onEntregar={handleEntregar}
          />
        )}

        {showPublicarModal && (
          <ModalPublicarObjeto
            onClose={() => setShowPublicarModal(false)}
            onPublicar={handlePublicar}
          />
        )}
      </div>
    </ProtectedLayout>
  );
}