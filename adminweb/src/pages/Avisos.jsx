import { useState } from "react";
import ProtectedLayout from "../components/layout/ProtectedLayout";
import PageHeader from "../components/layout/PageHeader";

import AvisosGrid from "../components/avisos/AvisosGrid";
import AvisosPagination from "../components/avisos/AvisosPagination";
import ModalNuevoAviso from "../components/avisos/ModalNuevoAviso";

import { avisosMock } from "../mock/avisosMock";

export default function Avisos() {
  const [avisos, setAvisos] = useState(avisosMock);
  const [page, setPage] = useState(1);
  const [showModal, setShowModal] = useState(false);
  const [avisoToEdit, setAvisoToEdit] = useState(null);

  const itemsPorPagina = 8;
  const totalPaginas = Math.ceil(avisos.length / itemsPorPagina);
  const inicio = (page - 1) * itemsPorPagina;
  const avisosPagina = avisos.slice(inicio, inicio + itemsPorPagina);

  // Abrir modal para nuevo aviso
  const openNewModal = () => {
    setAvisoToEdit(null);
    setShowModal(true);
  };

  // Abrir modal para editar
  const openEditModal = (aviso) => {
    setAvisoToEdit(aviso);
    setShowModal(true);
  };

  // Guardar (nuevo o edición)
  const handleSaveAviso = (avisoData) => {
    if (avisoToEdit) {
      // Editar existente
      setAvisos(prev =>
        prev.map(a => (a.id === avisoToEdit.id ? { ...a, ...avisoData } : a))
      );
    } else {
      // Nuevo
      const nuevo = {
        id: Date.now(),
        ...avisoData,
        fecha: new Date().toLocaleDateString("es-EC", {
          day: "numeric",
          month: "short",
        }),
        vistas: null,
      };
      setAvisos(prev => [...prev, nuevo]);
      setPage(1);
    }
  };

  // Eliminar aviso
  const handleDelete = (id) => {
    if (window.confirm("¿Estás seguro de eliminar este aviso?")) {
      setAvisos(prev => prev.filter(a => a.id !== id));
      if (avisosPagina.length === 1 && page > 1) {
        setPage(prev => prev - 1);
      }
    }
  };

  // Tres puntos (placeholder)
  const handleMoreOptions = (aviso) => {
    alert(
      `Opciones adicionales para "${aviso.titulo}" (próximamente: Duplicar, Programar, etc.)`
    );
  };

  return (
    <ProtectedLayout>
      <div className="avisos-contenedor">
        <PageHeader
          title="Gestión de Avisos"
          subtitle="Crea, edita y gestiona noticias institucionales, calendarios académicos y anuncios de bienestar"
        />

        {/* Controles superiores */}
        <div className="top-controls">
          <button className="btn-nuevo-aviso" onClick={openNewModal}>
            <span className="plus-icon">+</span>
            Nuevo aviso
          </button>
        </div>

        <AvisosGrid
          avisos={avisosPagina}
          onEdit={openEditModal}
          onDelete={handleDelete}
          onMore={handleMoreOptions}
        />

        <div className="paginacion-wrapper">
          <AvisosPagination
            page={page}
            setPage={setPage}
            total={totalPaginas}
          />
        </div>

        <div className="footer-info">
          Mostrando {avisosPagina.length} de {avisos.length} avisos
        </div>

        {showModal && (
          <ModalNuevoAviso
            avisoInicial={avisoToEdit}
            onClose={() => setShowModal(false)}
            onSave={handleSaveAviso}
          />
        )}
      </div>
    </ProtectedLayout>
  );
}
