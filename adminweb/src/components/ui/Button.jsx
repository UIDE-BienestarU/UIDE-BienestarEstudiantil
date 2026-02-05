export default function Button({
  children,
  variant = "primary",
  type = "button",
  onClick,
  className = "",
}) {
  const base =
    "px-4 py-2 rounded-md font-semibold transition focus:outline-none";

  const variants = {
    primary: "bg-[#96004B] text-white hover:bg-[#7a003d]",
    secondary: "bg-[#003366] text-white hover:bg-[#002244]",
    warning: "bg-[#F2A900] text-black hover:bg-[#d99800]",
    ghost: "bg-transparent text-[#96004B] hover:bg-[#96004B]/10",
  };

  return (
    <button
      type={type}
      onClick={onClick}
      className={`${base} ${variants[variant]} ${className}`}
    >
      {children}
    </button>
  );
}
