
export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/") {
      return Response.json({
        service: "iPad Security Alerts",
        status: "online",
        message: "خدمة استقبال التنبيهات جاهزة"
      });
    }

    if (request.method !== "POST" || url.pathname !== "/event") {
      return new Response("Not found", { status: 404 });
    }

    if (!env.ALERT_URL || !env.WEBHOOK_SECRET) {
      return new Response("Server configuration missing", {
        status: 500
      });
    }

    let event;

    try {
      event = await request.json();
    } catch {
      return new Response("Invalid JSON", { status: 400 });
    }

    const response = await fetch(env.ALERT_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Webhook-Secret": env.WEBHOOK_SECRET
      },
      body: JSON.stringify(event)
    });

    return Response.json(
      { forwarded: response.ok },
      { status: response.ok ? 200 : 502 }
    );
  }
};
