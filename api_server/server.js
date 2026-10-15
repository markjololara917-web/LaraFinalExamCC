
const express = require("express");
const cors = require("cors");

const app = express();
const PORT = 3000;

app.use(
  cors({
    origin: [
      "http://localhost:5000",
      "http://127.0.0.1:5000",
      "http://localhost:8080",
      "http://127.0.0.1:8080",
    ],
  })
);

app.get("/api/tiktok-oembed", async (req, res) => {
  try {
    const videoUrl = req.query.url;

    if (!videoUrl) {
      return res.status(400).json({
        error: "Missing TikTok video URL",
      });
    }

    const parsedUrl = new URL(videoUrl);

    if (
      parsedUrl.protocol !== "https:" ||
      !(
        parsedUrl.hostname === "tiktok.com" ||
        parsedUrl.hostname.endsWith(".tiktok.com")
      ) ||
      !parsedUrl.pathname.includes("/video/")
    ) {
      return res.status(400).json({
        error: "Invalid TikTok video URL",
      });
    }

    const apiUrl = new URL(
      "https://www.tiktok.com/oembed"
    );

    apiUrl.searchParams.set("url", videoUrl);

    const response = await fetch(apiUrl, {
      headers: {
        Accept: "application/json",
      },
      signal: AbortSignal.timeout(15000),
    });

    const body = await response.text();

    if (!response.ok) {
      return res.status(response.status).json({
        error: "TikTok API request failed",
        status: response.status,
        details: body.slice(0, 2000),
      });
    }

    let data;

    try {
      data = JSON.parse(body);
    } catch {
      return res.status(502).json({
        error: "TikTok returned invalid JSON",
      });
    }

    return res.json(data);
  } catch (error) {
    console.error("TikTok API error:", error.message);

    return res.status(502).json({
      error: "Unable to retrieve TikTok metadata",
      details: error.message,
    });
  }
});

app.listen(PORT, () => {
  console.log(
    `TikTok API proxy running at http://localhost:${PORT}`
  );
});