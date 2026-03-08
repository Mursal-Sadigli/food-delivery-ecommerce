const Message = require('../models/Message');
const Order = require('../models/Order');

// @desc    Get all messages for current user
// @route   GET /api/chat
// @access  Private
const getMessages = async (req, res) => {
  try {
    // For simplicity, we get messages where user is sender or receiver (if defined)
    // Or just all messages sent by this user and responses to them
    const messages = await Message.find({
      $or: [
        { sender: req.user._id },
        { receiver: req.user._id }
      ]
    }).sort({ createdAt: 1 });
    
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: 'Mesajlar gətirilərkən xəta baş verdi' });
  }
};

// @desc    Send a message
// @route   POST /api/chat
// @access  Private
const sendMessage = async (req, res) => {
  const { content } = req.body;

  if (!content) {
    return res.status(400).json({ message: 'Mesaj mətni boş ola bilməz' });
  }

  try {
    const message = await Message.create({
      sender: req.user._id,
      content,
      isAdmin: req.user.role === 'admin'
    });

    // AI Response Simulation
    setTimeout(async () => {
      let aiContent = "Salam! Mən sizin AI asistentinizəm. Sizə necə kömək edə bilərəm?";
      const lowerContent = content.toLowerCase();

      if (lowerContent.includes('sifariş') || lowerContent.includes('status')) {
        const lastOrder = await Order.findOne({ user: req.user._id }).sort({ createdAt: -1 });
        if (lastOrder) {
          aiContent = `Sizin sonuncu sifarişinizin (#${lastOrder._id.toString().substring(18)}) statusu hazırda: "${lastOrder.status}"-dır.`;
        } else {
          aiContent = "Sizin hələ ki heç bir sifarişiniz yoxdur.";
        }
      } else if (lowerContent.includes('refund') || lowerContent.includes('geri qaytar')) {
        aiContent = "Sifarişi geri qaytarmaq üçün Profil bölməsində həmin sifarişə daxil olub 'Refund' düyməsinə klikləyə bilərsiniz. Qeyd edək ki, artıq çatdırılmış sifarişlər üçün geri qaytarılma müddəti 24 saatdır.";
      } else if (lowerContent.includes('gecikmə') || lowerContent.includes('gecikir')) {
        aiContent = "Üzr istəyirik! Tıxac və ya restoranın sıxlığı səbəbindən gecikmə ola bilər. Mən dərhal kuryerlə əlaqə saxlamanız üçün tətbiqdəki 'Kuryerlə Danış' funksiyasını məsləhət görürəm.";
      } else if (lowerContent.includes('problem') || lowerContent.includes('xəta')) {
        aiContent = "Yaşadığınız problem üçün üzr istəyirik. Zəhmət olmasa problemin detallarını və varsa şəklini çəkib bura göndərin, mən canlı dəstək komandasına (Human Agent) məlumat verim.";
      }

      await Message.create({
        sender: null, // AI as sender
        receiver: req.user._id,
        content: aiContent,
        isAdmin: true
      });
    }, 1000);

    res.status(201).json(message);
  } catch (error) {
    console.error('Chat error:', error);
    res.status(500).json({ message: 'Mesaj göndərilərkən xəta baş verdi' });
  }
};

module.exports = {
  getMessages,
  sendMessage,
};
