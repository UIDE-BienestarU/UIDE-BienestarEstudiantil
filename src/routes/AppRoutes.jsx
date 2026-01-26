import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";

import Login from "../pages/Login";
import Dashboard from "../pages/Dashboard";
import Solicitudes from "../pages/Solicitudes";
import DetalleSolicitud from "../pages/DetalleSolicitud";
import Avisos from "../pages/Avisos";
import ObjetosPerdidos from "../pages/ObjetosPerdidos";
import Perfil from "../pages/Perfil";

import useAuth from "../hooks/useAuth";

function PrivateRoute({ children }) {
  const { user } = useAuth();
  return user ? children : <Navigate to="/" />;
}

export default function AppRoutes() {
  return (
    <BrowserRouter>
      <Routes>

        {/* Login */}
        <Route path="/" element={<Login />} />

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
