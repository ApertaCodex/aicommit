#!/usr/bin/env python3
"""Tiny OpenAI-compatible stub used by the provider-error tests.

Usage: stub_server.py <responses.json> <port_file> <request_log>

responses.json is a JSON list of {"status": int, "body": <json|string>}.
Request N is answered with entry N; the last entry repeats once exhausted.
Each request's JSON payload is appended to request_log (one line per request)
so tests can count calls and inspect the request shape.
"""
import json
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

responses_path, port_file, log_path = sys.argv[1:4]
with open(responses_path) as fh:
    RESPONSES = json.load(fh)
COUNT = 0


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):  # noqa: N802 (http.server naming)
        global COUNT
        length = int(self.headers.get("Content-Length") or 0)
        payload = self.rfile.read(length).decode("utf-8", "replace")
        with open(log_path, "a") as fh:
            fh.write(payload.replace("\n", " ") + "\n")
        entry = RESPONSES[min(COUNT, len(RESPONSES) - 1)]
        COUNT += 1
        body = entry.get("body", "")
        raw = body if isinstance(body, str) else json.dumps(body)
        data = raw.encode()
        self.send_response(int(entry.get("status", 200)))
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, *_args):
        pass


server = HTTPServer(("127.0.0.1", 0), Handler)
with open(port_file + ".tmp", "w") as fh:
    fh.write(str(server.server_address[1]))
import os  # noqa: E402

os.replace(port_file + ".tmp", port_file)
server.serve_forever()
