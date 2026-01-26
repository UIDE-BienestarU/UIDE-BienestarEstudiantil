import { FiSearch } from 'react-icons/fi';

export default function AvisosSearch({ value, onChange }) {
  return (
    <div className="search-wrapper">
      <FiSearch className="search-icon" />
      <input
        type="text"
        placeholder="Buscar por título, descripción, autor o palabras clave..."
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="search-input"
      />
    </div>
  );
}