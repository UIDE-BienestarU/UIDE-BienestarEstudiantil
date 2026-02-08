import { useState, useEffect } from "react";
import TopBar from "../components/layout/TopBar"; 
import PageHeader from "../components/layout/PageHeader";
import PerfilInfo from "../components/perfil/PerfilInfo";
import usuarioService from "../services/usuarioService";

const Perfil = () => {
  const [perfil, setPerfil] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchPerfil = async () => {
      try {
        const response = await usuarioService.getPerfil();
        const backendUser = response.data;
        
        // Mapeo de datos Backend -> Frontend
        setPerfil({
          ...backendUser,
          nombre: backendUser.nombre_completo,
          correo: backendUser.correo_institucional,
          avatar: backendUser.avatar || "https://ui-avatars.com/api/?name=" + (backendUser.nombre_completo || "U") + "&background=0D8ABC&color=fff",
          estado: "ACTIVO" // Valor por defecto
        });
      } catch (err) {
        console.error("Error cargando perfil", err);
        setError("Error al cargar la información del perfil");
      } finally {
        setLoading(false);
      }
    };
    fetchPerfil();
  }, []);

  return (
    <div className="perfil-layout">
      <TopBar />

      <div className="perfil-page">
        <PageHeader
          title="Configuración de Perfil"
          subtitle="Gestione su identidad profesional, credenciales de seguridad y preferencias."
        />

        {loading ? (
          <p>Cargando perfil...</p>
        ) : error ? (
          <p className="error-text">{error}</p>
        ) : (
          <PerfilInfo perfil={perfil} />
        )}

      </div>
    </div>
  );
};

export default Perfil;