String buildFileUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return 'https://api-prod.uidehub.tech$path';
}
