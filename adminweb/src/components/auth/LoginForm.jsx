import { useState } from "react";
import { useNavigate } from "react-router-dom";
import useAuth from "../../hooks/useAuth";

export default function LoginForm() {
  const { login } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    setError("");

    // ❌ Campos vacíos
    if (!email || !password) {
      setError("Complete todos los campos");
      return;
    }

    // ❌ Correo incorrecto
    if (email !== "admin@uide.edu.ec") {
      setError("Correo incorrecto");
      return;
    }

    // ✅ Login correcto
    login({ email });
    navigate("/dashboard");
  };

  return (
    <form onSubmit={handleSubmit}>
      {error && <div className="error-msg">{error}</div>}

      <div className="form-group">
        <label>Correo institucional</label>
        <input
          type="email"
          placeholder="admin@uide.edu.ec"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
      </div>

      <div className="form-group">
        <label>Contraseña</label>
        <input
          type="password"
          placeholder="********"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
      </div>

      <button type="submit" className="btn-primary w-full">
        Ingresar
      </button>
    </form>
  );
}
