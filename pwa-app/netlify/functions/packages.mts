import type { Context, Config } from "@netlify/functions";

// Package search — proxies the joblist's package-search feed so a new job can
// be started from the installer / TechMapp package the joblist already has on
// file (emailed packages are filed there automatically), instead of someone
// finding and uploading the PDF by hand. The joblist key stays server-side;
// the feed URL sits next to the material-list intake URL already configured in
// JOBLIST_API_URL (…/.netlify/functions/material-list → …/package-search).
// The response carries short-lived signed links the browser downloads directly.
export default async (req: Request, context: Context) => {
  const base = process.env.JOBLIST_API_URL;
  const key = process.env.JOBLIST_API_KEY;
  if (!base || !key) {
    return new Response(JSON.stringify({ ok: false, configured: false, error: "Joblist not connected" }), { status: 503 });
  }
  const feed = process.env.JOBLIST_PACKAGES_URL || base.replace(/material-list\/?$/, "package-search");
  const params = new URL(req.url).searchParams;
  const job = params.get("job") || "";   // one joblist job's package (Truck Report)
  const q = (params.get("q") || "").slice(0, 60);
  try {
    const upstream = await fetch(feed + "?" + new URLSearchParams(job ? { job } : { q }), {
      headers: { Authorization: `Bearer ${key}` },
    });
    const text = await upstream.text();
    return new Response(text, {
      status: upstream.status,
      headers: { "Content-Type": "application/json", "Cache-Control": "no-store" },
    });
  } catch (err: any) {
    return new Response(JSON.stringify({ ok: false, error: err?.message || "fetch failed" }), { status: 502 });
  }
};

export const config: Config = {
  path: "/api/packages",
};
