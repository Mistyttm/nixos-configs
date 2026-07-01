#!/usr/bin/env python3
import hmac
import http.server
import ipaddress
import json
import os
import re
import subprocess
import sys

TOKEN = open(os.environ["TOKEN_FILE"]).read().strip()
ALLOWED_PEER = os.environ.get("ALLOWED_PEER", "10.100.0.2")

JAIL_NAME_RE = re.compile(r"^[a-zA-Z0-9_-]{1,32}$")


class Handler(http.server.BaseHTTPRequestHandler):
    def _auth(self):
        got = self.headers.get("Authorization", "").removeprefix("Bearer ")
        return hmac.compare_digest(got, TOKEN)

    def _validate(self, name, ip):
        if not JAIL_NAME_RE.match(name):
            return False
        try:
            ipaddress.ip_address(ip)
        except ValueError:
            return False
        return True

    def _rule_exists(self, name, ip):
        result = subprocess.run(
            ["iptables", "-C", f"f2b-{name}", "-s", ip, "-j", "DROP"],
        )
        return result.returncode == 0

    def do_POST(self):
        # application-level peer restriction, independent of firewall state
        if self.client_address[0] != ALLOWED_PEER:
            self.send_response(403)
            self.end_headers()
            return

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

        if not self._validate(name, ip):
            self.send_response(400)
            self.end_headers()
            return

        try:
            if self.path == "/ban":
                if not self._rule_exists(name, ip):
                    subprocess.run(
                        ["iptables", "-I", f"f2b-{name}", "1", "-s", ip, "-j", "DROP"],
                        check=True,
                    )
            elif self.path == "/unban":
                subprocess.run(
                    ["iptables", "-D", f"f2b-{name}", "-s", ip, "-j", "DROP"],
                    check=True,
                )
            else:
                self.send_response(404)
                self.end_headers()
                return
        except subprocess.CalledProcessError as e:
            sys.stderr.write(f"iptables command failed: {e}\n")
            self.send_response(500)
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
