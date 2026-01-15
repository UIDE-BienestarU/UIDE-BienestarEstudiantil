# HU-01 – Autenticación con credenciales institucionales

**Como** estudiante UIDE  
**Quiero** iniciar sesión en la aplicación usando mis credenciales institucionales  
**Para** acceder de forma segura sin crear nuevas credenciales  

## Criterios de Aceptación (Gherkin)

Escenario: Inicio de sesión exitoso  
Dado que estoy en la pantalla de inicio  
Cuando ingreso mi usuario y contraseña institucionales correctos  
Entonces el sistema me autentica y muestra el menú principal  

Escenario: Credenciales incorrectas  
Dado que ingreso credenciales incorrectas  
Cuando presiono "Iniciar sesión"  
Entonces el sistema muestra el mensaje "Usuario o contraseña incorrectos"  

Escenario: Persistencia de sesión  
Dado que he iniciado sesión exitosamente  
Cuando la aplicación se cierra o se reinicia  
Entonces el sistema mantiene la sesión activa hasta que cierre sesión o expire el token  

Escenario: Cierre de sesión  
Dado que estoy autenticado  
Cuando presiono "Cerrar sesión" y confirmo la acción  
Entonces el sistema elimina la sesión y me redirige a la pantalla de inicio  
