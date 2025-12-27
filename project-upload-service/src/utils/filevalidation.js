const limits = {
    image: 2 * 1024 * 1024,       // 2 MB
    video: 100 * 1024 * 1024,     // 100 MB
    code: 150 * 1024 * 1024,      // 150 MB (ZIP/GZ)
    document: 50 * 1024 * 1024,   // 50 MB (PDF/DOC)
    default: 20 * 1024 * 1024     // 20 MB
  };
  
  const getLimitByMime = (mime) => {
    if (mime.startsWith('image/')) return limits.image;
    if (mime.startsWith('video/')) return limits.video;
    if (mime === 'application/pdf' || mime.includes('word') || mime.includes('presentation')) return limits.document;
    if (mime.includes('zip') || mime.includes('compressed') || mime.includes('tar')) return limits.code;
    return limits.default;
  };
  
  module.exports = { getLimitByMime };