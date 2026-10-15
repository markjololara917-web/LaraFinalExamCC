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

// Prevent repeated requests for the same video
// from calling TikTok on every popup opening.
const cache = new Map();
const CACHE_DURATION = 10 * 60 * 1000;

app.get("/api/tiktok-oembed", async (req, res) => {
  try {
    const videoUrl = req.query.url;

    if (typeof videoUrl !== "string" || !videoUrl.trim()) {
      return res.status(400).json({
        error: "Missing TikTok video URL",
      });
    }

    let parsedUrl;

    try {
      parsedUrl = new URL(videoUrl);
    } catch {
      return res.status(400).json({
        error: "Invalid video URL",
      });
    }

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

    // Use the canonical URL as the cache key.
    const cacheKey = parsedUrl.href;

    const cached = cache.get(cacheKey);

    if (cached && cached.expiresAt > Date.now()) {
      return res.json(cached.data);
    }

    if (cached) {
      cache.delete(cacheKey);
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

    if (response.status === 429) {
  console.warn("TikTok rate limit reached.");

  // Temporarily avoid repeated requests for this video.
  cache.set(cacheKey, {
    data: {
      error: "TikTok rate limit reached",
      message: "Please try again later.",
      status: 429,
    },
    expiresAt: Date.now() + 60 * 1000,
  });

  return res.status(429).json(cache.get(cacheKey).data);
}

    if (!response.ok) {
      console.error(
        "TikTok API HTTP error:",
        response.status,
        body.slice(0, 500)
      );

      return res.status(502).json({
        error: "TikTok API request failed",
        upstreamStatus: response.status,
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

    // Cache only successful responses.
    cache.set(cacheKey, {
      data,
      expiresAt: Date.now() + CACHE_DURATION,
    });

    return res.json(data);
  } catch (error) {
    console.error("TikTok API error:", error.message);

    return res.status(502).json({
      error: "Unable to retrieve TikTok metadata",
      message:
        "Check your connection and try again later.",
    });
  }
});

app.listen(PORT, () => {
  console.log(
    "TikTok API proxy running at http://localhost:" + PORT
  );
});
