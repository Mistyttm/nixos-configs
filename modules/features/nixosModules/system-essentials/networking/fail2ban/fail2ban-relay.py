#!/usr/bin/env python3
import hmac
import http.server
import json
import os
import subprocess
import sys

TOKEN = open(os.environ["TOKEN_FILE"]).read().strip()


class Handler(http.server.BaseHTTPRequestHandler):
    def _auth(self):
        got = self.headers.get("Authorization", "").removeprefix("Bearer ")
        return hmac.compare_digest(got, TOKEN)

    def _chain(self, name):
        subprocess.run(["iptables", "-N", f"f2b-{name}"], check=False)
        subprocess.run(
            [
                "sh",
                "-c",
                f"iptables -C INPUT -j f2b-{name} 2>/dev/null || iptables -I INPUT -j f2b-{name}",
            ],
            check=False,
        )

    def do_POST(self):
        if not self._auth():
            self.send_response(401)
            self.end_headers()
            return

        length = int(self.headers.get("Content-Length", 0))
        try:
            body = json.loads(self.rfile.read(length))
            name, ip = body["jail"], body["ip"]
        except Exception:
            self.send_response(400)
            self.end_headers()
            return

        # basic sanity check on jail name to prevent shell/arg injection
        if not name.isalnum() or not all(c.isdigit() or c == "." for c in ip):
            self.send_response(400)
            self.end_headers()
            return

        if self.path == "/ban":
            self._chain(name)
            subprocess.run(
                ["iptables", "-I", f"f2b-{name}", "1", "-s", ip, "-j", "DROP"],
                check=False,
            )
        elif self.path == "/unban":
            subprocess.run(
                ["iptables", "-D", f"f2b-{name}", "-s", ip, "-j", "DROP"], check=False
            )
        else:
            self.send_response(404)
            self.end_headers()
            return

        self.send_response(200)
        self.end_headers()

    def log_message(self, format, *args):
        sys.stderr.write(("%s - - " + format + "\n") % (self.client_address[0], *args))


if __name__ == "__main__":
    addr = os.environ.get("BIND_ADDR", "10.100.0.1")
    port = int(os.environ.get("BIND_PORT", "9898"))
    http.server.HTTPServer((addr, port), Handler).serve_forever()
