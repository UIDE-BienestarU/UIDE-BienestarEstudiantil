import TopBar from "../components/layout/TopBar"; 
import PageHeader from "../components/layout/PageHeader";

import PerfilInfo from "../components/perfil/PerfilInfo";
import perfilMock from "../mock/perfilMock";

const Perfil = () => {
  return (
    <div className="perfil-layout">
      <TopBar />

      {/* Contenido principal con espacio para el TopBar */}
      <div className="perfil-page">

        <PageHeader
          title="Configuración de Perfil"
          subtitle="Gestione su identidad profesional, credenciales de seguridad y preferencias de notificación para la plataforma administrativa."
        />

        <PerfilInfo perfil={perfilMock} />

      </div>
    </div>
  );
};

export default Perfil;