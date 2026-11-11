"""Local Ollama. The model is loaded for the run and unloaded before exit."""

from __future__ import annotations

import json
import subprocess
import time
import urllib.error
import urllib.request
from pathlib import Path

from eldgrim_agent.paths import LOGS, MODEL

HOST = "http://127.0.0.1:11434"


class OllamaError(RuntimeError):
    pass


def healthy() -> bool:
    try:
        with urllib.request.urlopen(HOST + "/api/tags", timeout=3) as response:
            return response.status == 200
    except (OSError, urllib.error.URLError):
        return False


def ensure_server() -> subprocess.Popen[bytes] | None:
    """Start ollama serve only when nothing is already listening. The caller stops what this started."""
    if healthy():
        return None
    log_path = LOGS / "ollama.log"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    handle = log_path.open("ab")
    process = subprocess.Popen(
        ["ollama", "serve"],
        stdin=subprocess.DEVNULL,
        stdout=handle,
        stderr=subprocess.STDOUT,
        start_new_session=True,
    )
    deadline = time.monotonic() + 30
    while time.monotonic() < deadline:
        if healthy():
            return process
        if process.poll() is not None:
            raise OllamaError("Ollama exited before it accepted requests.")
        time.sleep(0.4)
    process.terminate()
    raise OllamaError("Ollama did not become ready.")


def chat(messages: list[dict[str, str]], *, num_predict: int) -> str:
    body = {
        "model": MODEL,
        "messages": messages,
        "stream": False,
        "think": False,
        "keep_alive": "10m",
        "options": {"temperature": 0.8, "num_predict": num_predict, "num_ctx": 8192},
    }
    try:
        return _post_chat(body)
    except OllamaError as exc:
        if "think" not in str(exc).lower() and "400" not in str(exc):
            raise
        body.pop("think")
        return _post_chat(body)


def unload() -> None:
    payload = json.dumps({"model": MODEL, "keep_alive": 0, "prompt": ""}).encode()
    request = urllib.request.Request(
        HOST + "/api/generate",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=60):
            return
    except (OSError, urllib.error.URLError):
        return


def stop_server(process: subprocess.Popen[bytes] | None) -> None:
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=10)
    except subprocess.TimeoutExpired:
        process.kill()


def _post_chat(body: dict) -> str:
    payload = json.dumps(body).encode()
    request = urllib.request.Request(
        HOST + "/api/chat",
        data=payload,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=300) as response:
            data = json.loads(response.read().decode())
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode(errors="replace")[:300]
        raise OllamaError(f"Ollama rejected the request ({exc.code}): {detail}") from exc
    except (OSError, urllib.error.URLError, TimeoutError) as exc:
        raise OllamaError(f"Ollama request failed: {exc}") from exc
    message = data.get("message") or {}
    text = str(message.get("content") or "").strip()
    if not text:
        raise OllamaError("Ollama returned an empty message.")
    return text


def log_path() -> Path:
    return LOGS / "ollama.log"
