// src/components/dashboard/TopBar.jsx
import { NavLink } from "react-router-dom";
import logo from "../../assets/images/image.png";
import { FiLogOut } from "react-icons/fi";
import useAuth from "../../hooks/useAuth";

export default function TopBar() {
  const { user, logout } = useAuth();
  return (
    <header className="topbar">
      <div className="topbar-left">
        <div className="topbar-brand">
          <img src={logo} alt="UIDE" />
          <h1>
            Bienestar<span>Admin</span>
          </h1>
        </div>

        <nav className="topbar-nav">
          <NavLink to="/dashboard">Dashboard</NavLink>
          <NavLink to="/solicitudes">Solicitudes</NavLink>
          <NavLink to="/avisos">Noticias</NavLink>
          <NavLink to="/objetos-perdidos">Objetos Perdidos</NavLink>
          <NavLink to="/sugerencias">Sugerencias</NavLink>
        </nav>
      </div>

      <div className="topbar-user">
        <NavLink to="/perfil" className="user-info">
          <strong>{user?.nombre_completo || "Admin User"}</strong>
        </NavLink>
        <div className="avatar">{user?.nombre_completo?.charAt(0) || "A"}</div>
        <button onClick={logout} className="logout-icon" title="Cerrar sesión" style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'inherit' }}>
          <FiLogOut size={20} />
        </button>
      </div>
    </header>
  );
}
