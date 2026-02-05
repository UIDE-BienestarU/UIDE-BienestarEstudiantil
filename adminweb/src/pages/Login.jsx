import AuthBackground from "../components/auth/AuthBackground";
import AuthHeader from "../components/auth/AuthHeader";
import LoginCard from "../components/auth/LoginCard";
import LoginForm from "../components/auth/LoginForm";
import AuthFooter from "../components/auth/AuthFooter";

export default function Login() {
  return (
    <AuthBackground>
      <AuthHeader />

      <LoginCard>
        <h2>Iniciar sesión</h2>
        <LoginForm />
      </LoginCard>

      <AuthFooter />
    </AuthBackground>
  );
}
