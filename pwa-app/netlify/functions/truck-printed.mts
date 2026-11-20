import type { Context, Config } from "@netlify/functions";

// Truck Report "Printed" tick — forwards to the joblist's material-printed
// endpoint so the tick is the same one the joblist's Material Lists board
// shows (jobs.ml_printed_at). The truck-report feed returns it as `printedAt`.
// The joblist key stays server-side; the URL sits next to the material-list
// intake URL in JOBLIST_API_URL (…/material-list → …/material-printed).
//
// POST { jobIds: [<joblist job id>, …], printed: true | false }
export default async (req: Request, context: Context) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ ok: false, error: "Method not allowed" }), { status: 405 });
  }
  const base = process.env.JOBLIST_API_URL;
  const key = process.env.JOBLIST_API_KEY;
  if (!base || !key) {
    return new Response(JSON.stringify({ ok: false, configured: false, error: "Joblist not connected" }), { status: 503 });
  }
  const target = process.env.JOBLIST_PRINTED_URL || base.replace(/material-list\/?$/, "material-printed");
  try {
    const upstream = await fetch(target, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${key}` },
      body: await req.text(),
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
  path: "/api/truck-printed",
};
