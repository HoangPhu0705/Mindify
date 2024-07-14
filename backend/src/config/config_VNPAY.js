require('dotenv').config();

const configVNP = {
    vnp_TmnCode: process.env.VNP_TMNCODE,
    vnp_HashSecret: process.env.VNP_HASHSECRET,
    vnp_Url: process.env.VNP_URL,
    vnp_ReturnUrl: process.env.VNP_RETURN_URL
}

module.exports = { configVNP }

// VNP_TMNCODE = 'QI175EPT'
// VNP_HASHSECRET = '3MF54PG26IDXQMISGJQ4MQU13PXD8TJN'
// VNP_URL = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html'