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

    // Backend returns: { data: { user, accessToken, refreshToken } }
    // Response data is wrapped in 'data' by Axios, and then our API returns 'data' property
    // Actually, looking at controller: return ok(res, { data: { user, accessToken... } })
    // So axios response.data looks like: { message, data: { user, accessToken, refreshToken } }
    
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

  const refreshAccessToken = useCallback(async () => {
    try {
      const refreshToken = localStorage.getItem("refreshToken");
      if (!refreshToken) throw new Error("No refresh token");

      const response = await api.post("/auth/refresh", { refreshToken });
      const { token } = response.data;

      localStorage.setItem("token", token);
      return token;
    } catch (error) {
      logout();
      throw error;
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
