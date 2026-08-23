const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const META_PHONE_NUMBER_ID = process.env.META_PHONE_NUMBER_ID;
const META_ACCESS_TOKEN = process.env.META_ACCESS_TOKEN;

// ── Health check endpoint ───────────────────────────────────────────────────
app.get('/api/whatsapp/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ── Send WhatsApp Message Endpoint ──────────────────────────────────────────
app.post('/api/whatsapp/send', async (req, res) => {
  const { to, message } = req.body;

  if (!to || !message) {
    return res.status(400).json({ error: 'Missing required fields: to, message' });
  }

  // Check credentials
  if (!META_PHONE_NUMBER_ID || !META_ACCESS_TOKEN) {
    console.error('Error: META_PHONE_NUMBER_ID or META_ACCESS_TOKEN missing in .env file!');
    return res.status(500).json({
      error: 'Backend missing Meta API credentials in .env file.',
    });
  }

  // Format recipient phone number for Meta (strip + and spaces)
  const formattedTo = to.replace(/\+/g, '').replace(/\s/g, '');

  try {
    const metaUrl = `https://graph.facebook.com/v18.0/${META_PHONE_NUMBER_ID}/messages`;
    
    const response = await axios.post(
      metaUrl,
      {
        messaging_product: 'whatsapp',
        recipient_type: 'individual',
        to: formattedTo,
        type: 'text',
        text: {
          preview_url: false,
          body: message,
        },
      },
      {
        headers: {
          Authorization: `Bearer ${META_ACCESS_TOKEN}`,
          'Content-Type': 'application/json',
        },
      }
    );

    console.log(`[WhatsApp Success] Sent message to ${to}: Message ID ${response.data?.messages?.[0]?.id}`);
    res.json({ success: true, metaResponse: response.data });
  } catch (error) {
    const errorDetails = error.response?.data || error.message;
    console.error(`[WhatsApp Error] Failed sending to ${to}:`, errorDetails);
    res.status(error.response?.status || 500).json({
      error: 'Failed to send WhatsApp message via Meta Cloud API',
      details: errorDetails,
    });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Cafe POS WhatsApp Backend running on http://localhost:${PORT}`);
  console.log(`- Health Check: http://localhost:${PORT}/api/whatsapp/health`);
  console.log(`- Send Message: http://localhost:${PORT}/api/whatsapp/send`);
});
