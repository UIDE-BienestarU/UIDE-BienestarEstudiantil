import { createContext, useState, useEffect, useCallback } from "react";
import api from "../api/axios";

export const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Check for existing session on mount
  useEffect(() => {
    try {
      const storedUser = localStorage.getItem("user");
      const token = localStorage.getItem("token");

      if (storedUser && token && storedUser !== "undefined") {
        setUser(JSON.parse(storedUser));
      } else {
        // Clear potential garbage
        localStorage.removeItem("user");
        localStorage.removeItem("token");
        localStorage.removeItem("refreshToken");
      }
    } catch (error) {
      console.error("Error parsing user from storage", error);
      localStorage.clear();
      setUser(null);
    }
    setLoading(false);
  }, []);

  const login = useCallback(async (correo_institucional, contrasena) => {
    const response = await api.post("/auth/login", {
      correo_institucional,
      contrasena,
    });

    const { user, accessToken, refreshToken } = response.data.data;

    if (accessToken) {
      localStorage.setItem("token", accessToken);
      localStorage.setItem("refreshToken", refreshToken);
      localStorage.setItem("user", JSON.stringify(user));
      setUser(user);
    } else {
      console.error("Login exitoso pero no se recibió accessToken");
    }
    return response.data;
  }, []);

  const logout = useCallback(async () => {
    try {
      const refreshToken = localStorage.getItem("refreshToken");
      if (refreshToken) {
        await api.post("/auth/logout", { refreshToken });
      }
    } catch (error) {
      console.error("Error during logout:", error);
    } finally {
      localStorage.removeItem("token");
      localStorage.removeItem("refreshToken");
      localStorage.removeItem("user");
      setUser(null);
    }
  }, []);

  // ✅ REEMPLAZA SOLO ESTA FUNCIÓN POR ESTA (arreglada)
  const refreshAccessToken = useCallback(async () => {
    const refreshToken = localStorage.getItem("refreshToken");
    if (!refreshToken) {
      await logout();
      throw new Error("No refresh token");
    }

    try {
      const response = await api.post("/auth/refresh", { refreshToken });

      // ✅ consistente con login: response.data.data
      const payload = response.data?.data || response.data;
      const accessToken = payload?.accessToken || payload?.token;
      const newRefresh = payload?.refreshToken;

      if (!accessToken) throw new Error("Refresh no devolvió accessToken/token");

      localStorage.setItem("token", accessToken);
      if (newRefresh) localStorage.setItem("refreshToken", newRefresh);

      return accessToken;
    } catch (e) {
      await logout();
      throw e;
    }
  }, [logout]);

  return (
    <AuthContext.Provider
      value={{ user, loading, login, logout, refreshAccessToken }}
    >
      {children}
    </AuthContext.Provider>
  );
}
