// src/components/dashboard/TopBar.jsx
import { NavLink } from "react-router-dom";
import logo from "../../assets/images/image.png";
import { FiLogOut } from "react-icons/fi"; 
export default function TopBar() {
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
        </nav>
      </div>

      <div className="topbar-user">
        <NavLink to="/perfil" className="user-info">
          <strong>Admin User</strong>
        </NavLink>
        <div className="avatar">A</div>
        <NavLink to="/logout" className="logout-icon" title="Cerrar sesión">
          <FiLogOut size={20} />
        </NavLink>
      </div>
    </header>
  );
}
