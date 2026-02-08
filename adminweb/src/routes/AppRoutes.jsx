import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

import Login from "../pages/Login";
import Dashboard from "../pages/Dashboard";
import Solicitudes from "../pages/Solicitudes";
import DetalleSolicitud from "../pages/DetalleSolicitud";
import Avisos from "../pages/Avisos";
import ObjetosPerdidos from "../pages/ObjetosPerdidos";
import Sugerencias from "../pages/Sugerencias";
import Perfil from "../pages/Perfil";

import useAuth from "../hooks/useAuth";

function PrivateRoute({ children }) {
  const { user, loading } = useAuth();

  if (loading) return <div>Cargando...</div>;

  return user ? children : <Navigate to="/" />;
}

// Redirects to dashboard if already logged in
function PublicRoute({ children }) {
  const { user, loading } = useAuth();

  if (loading) return <div>Cargando...</div>;

  return user ? <Navigate to="/dashboard" /> : children;
}

export default function AppRoutes() {
  return (
    <BrowserRouter>
      <Routes>

        {/* Login - Wrapped in PublicRoute */}
        <Route
          path="/"
          element={
            <PublicRoute>
              <Login />
            </PublicRoute>
          }
        />

        {/* Dashboard */}
        <Route
          path="/dashboard"
          element={
            <PrivateRoute>
              <Dashboard />
            </PrivateRoute>
          }
        />

        {/* Solicitudes */}
        <Route
          path="/solicitudes"
          element={
            <PrivateRoute>
              <Solicitudes />
            </PrivateRoute>
          }
        />

        {/* Detalle de solicitud */}
        <Route
          path="/solicitudes/:id"
          element={
            <PrivateRoute>
              <DetalleSolicitud />
            </PrivateRoute>
          }
        />

        {/* Avisos */}
        <Route
          path="/avisos"
          element={
            <PrivateRoute>
              <Avisos />
            </PrivateRoute>
          }
        />

        {/* Objetos perdidos */}
        <Route
          path="/objetos-perdidos"
          element={
            <PrivateRoute>
              <ObjetosPerdidos />
            </PrivateRoute>
          }
        />

        {/* Sugerencias */}
        <Route
          path="/sugerencias"
          element={
            <PrivateRoute>
              <Sugerencias />
            </PrivateRoute>
          }
        />

        {/* Perfil */}
        <Route
          path="/perfil"
          element={
            <PrivateRoute>
              <Perfil />
            </PrivateRoute>
          }
        />

        {/* Fallback */}
        <Route path="*" element={<Navigate to="/" />} />

      </Routes>
    </BrowserRouter>
  );
}
