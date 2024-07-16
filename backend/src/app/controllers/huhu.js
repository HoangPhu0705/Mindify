const { assignAdminRole } = require('../service/haha');

const assignAdminRoleController = async (req, res) => {
  const { uid } = req.body;
  try {
    const message = await assignAdminRole(uid);
    res.status(200).json({ message });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = { assignAdminRoleController };
