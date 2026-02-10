import { useState } from "react";
import { useNavigate } from "react-router-dom";
import useAuth from "../../hooks/useAuth";

export default function LoginForm() {
  const { login } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    if (!email || !password) {
      setError("Complete todos los campos");
      setLoading(false);
      return;
    }

    try {
      await login(email, password);
      navigate("/dashboard");
    } catch (err) {
      console.error(err);
      if (err.response?.status === 401) {
        setError("Credenciales incorrectas");
      } else {
        setError(err.response?.data?.message || "Error al iniciar sesión");
      }
    } finally {
      setLoading(false);
    }
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
          disabled={loading}
          autoComplete="username"
        />
      </div>

      <div className="form-group">
        <label>Contraseña</label>
        <input
          type="password"
          placeholder="********"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          disabled={loading}
          autoComplete="current-password"
        />
      </div>

      <button type="submit" className="btn-primary w-full" disabled={loading}>
        {loading ? "Ingresando..." : "Ingresar"}
      </button>
    </form>
  );
}
