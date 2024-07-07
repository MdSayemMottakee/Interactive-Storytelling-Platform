const { onRequest } = require("firebase-functions/v2/https");
const cors = require("cors")({ origin: true });
const request = require("request");

exports.getImage = onRequest((req, res) => {
  cors(req, res, () => {
    const imageUrl = req.query.imageUrl; // The URL of the image passed as a query parameter
    if (!imageUrl) {
      return res.status(400).send("Missing imageUrl query parameter");
    }

    request({
      url: imageUrl,
      method: "GET"
    }).on('response', (response) => {
      // Ensure the response headers allow CORS
      res.set({
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS, PUT, DELETE",
        "Access-Control-Allow-Headers": "Content-Type, X-Auth-Token, Origin, Authorization"
      });
    }).pipe(res);
  });
});
