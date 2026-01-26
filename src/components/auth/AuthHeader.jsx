import logo from "../../assets/images/imagen4.png";

export default function AuthHeader() {
  return (
    <div className="auth-header">
      <img src={logo} alt="UIDE" className="auth-logo" />
      <h1>Bienestar Universitario</h1>
      <p>Panel Administrativo</p>
    </div>
  );
}
