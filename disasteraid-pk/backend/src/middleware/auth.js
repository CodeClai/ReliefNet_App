const jwt = require('jsonwebtoken');

module.exports = (role) => {
  return (req, res, next) => {
    const token = req.headers?.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'No token' });

    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = decoded;

      // If role required, check it
      if (role && decoded.role!== role && decoded.role!== 'admin') {
        return res.status(403).json({ error: 'Forbidden' });
      }

      next();
    } catch (e) {
      return res.status(401).json({ error: 'Invalid token' });
    }
  };
};