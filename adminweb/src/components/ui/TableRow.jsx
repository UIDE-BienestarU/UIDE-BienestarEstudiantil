export default function TableRow({ children }) {
  return (
    <tr className="border-b hover:bg-gray-50 transition">
      {children}
    </tr>
  );
}
