"""
PipelineCheckpoint · Skeleton v2.0
Fuente: [E 03 Estrategia 1 · F16] — checkpointing por stage para pipelines multi-stage.
Uso: importar en el script principal del agente · instanciar en S0 · llamar save_stage() al final de cada stage.

Requisito: Python 3.9+ · solo stdlib (json, hashlib, time, pathlib, datetime) · usa el filesystem local.
"""

import json
import hashlib
import time
from pathlib import Path
from datetime import datetime, timezone
from typing import Any


class PipelineCheckpoint:
    """
    Serializa y recupera el estado de cada stage en runs/<run_id>/checkpoints/.
    Permite resume desde el último stage válido si el run cae.
    TTL: checkpoints > 7 días se limpian automáticamente en clean_old().
    """

    TTL_SECONDS = 86400 * 7  # 7 días

    def __init__(self, run_id: str, base_dir: str = "runs"):
        self.run_id = run_id
        self.checkpoints_dir = Path(base_dir) / run_id / "checkpoints"
        self.checkpoints_dir.mkdir(parents=True, exist_ok=True)
        self.error_log = Path(base_dir) / run_id / "error_log.md"
        if not self.error_log.exists():
            self.error_log.write_text("# Error Log\n", encoding="utf-8")

    # ─────────────────────────────────────────────
    # WRITE
    # ─────────────────────────────────────────────

    def save_stage(self, stage: int, state: dict) -> Path:
        """
        Serializa el estado del stage.
        state debe incluir:
          - "result": output principal del stage
          - "metadata": {"model": str, "duration_s": int}
          - "summary": str comprimido (para recovery sin re-leer todo)
        """
        compressed = self._compress(state)
        compressed["stage"] = stage
        compressed["saved_at"] = datetime.now(timezone.utc).isoformat()
        compressed["checksum"] = self._checksum(compressed["result"])

        path = self.checkpoints_dir / f"stage_{stage:02d}.json"
        path.write_text(
            json.dumps(compressed, ensure_ascii=False, indent=2),
            encoding="utf-8"
        )
        return path

    # ─────────────────────────────────────────────
    # READ
    # ─────────────────────────────────────────────

    def load_last_valid(self) -> tuple[int, dict]:
        """
        Devuelve (stage_number, state) del último checkpoint válido.
        Si no hay checkpoints → (0, {}).
        """
        checkpoints = sorted(self.checkpoints_dir.glob("stage_*.json"))
        if not checkpoints:
            return 0, {}

        # Iterar desde el más reciente al más antiguo buscando un válido
        for path in reversed(checkpoints):
            try:
                data = json.loads(path.read_text(encoding="utf-8"))
                if self._verify_checksum(data):
                    stage_num = int(path.stem.split("_")[1])
                    return stage_num, data
            except (json.JSONDecodeError, KeyError, ValueError):
                self._log_error(f"Checkpoint corrupto: {path.name} · skipping")
                continue

        return 0, {}

    def load_stage(self, stage: int) -> dict | None:
        """Carga un stage específico. None si no existe o está corrupto."""
        path = self.checkpoints_dir / f"stage_{stage:02d}.json"
        if not path.exists():
            return None
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            return data if self._verify_checksum(data) else None
        except (json.JSONDecodeError, KeyError):
            return None

    def exists(self, stage: int) -> bool:
        return (self.checkpoints_dir / f"stage_{stage:02d}.json").exists()

    # ─────────────────────────────────────────────
    # COMPRESSION · descarta ruido · preserva esencial
    # ─────────────────────────────────────────────

    def _compress(self, state: dict) -> dict:
        """
        Mantiene solo: resultado final + metadata crítica + resumen comprimido.
        Descarta: historial de conversación raw, tool outputs intermedios.
        Ahorra 60-70% de tamaño [E 03 F16].
        """
        return {
            "result": state.get("result"),
            "metadata": state.get("metadata", {}),
            "summary": state.get("summary", ""),
        }

    # ─────────────────────────────────────────────
    # INTEGRIDAD
    # ─────────────────────────────────────────────

    def _checksum(self, result: Any) -> str:
        content = json.dumps(result, sort_keys=True, ensure_ascii=False)
        return hashlib.sha256(content.encode()).hexdigest()[:12]

    def _verify_checksum(self, data: dict) -> bool:
        if "checksum" not in data or "result" not in data:
            return False
        return self._checksum(data["result"]) == data["checksum"]

    # ─────────────────────────────────────────────
    # MANTENIMIENTO
    # ─────────────────────────────────────────────

    def clean_old(self) -> int:
        """Elimina checkpoints con más de TTL_SECONDS de antigüedad. Retorna N eliminados."""
        cutoff = time.time() - self.TTL_SECONDS
        removed = 0
        for path in self.checkpoints_dir.glob("stage_*.json"):
            if path.stat().st_mtime < cutoff:
                path.unlink()
                removed += 1
        return removed

    def summary(self) -> list[dict]:
        """Lista todos los checkpoints con su metadata."""
        result = []
        for path in sorted(self.checkpoints_dir.glob("stage_*.json")):
            try:
                data = json.loads(path.read_text(encoding="utf-8"))
                result.append({
                    "stage": data.get("stage"),
                    "saved_at": data.get("saved_at"),
                    "model": data.get("metadata", {}).get("model"),
                    "duration_s": data.get("metadata", {}).get("duration_s"),
                    "summary": data.get("summary", ""),
                    "valid": self._verify_checksum(data),
                })
            except (json.JSONDecodeError, KeyError):
                result.append({"stage": path.stem, "valid": False})
        return result

    # ─────────────────────────────────────────────
    # ERRORES
    # ─────────────────────────────────────────────

    def _log_error(self, message: str) -> None:
        ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
        with self.error_log.open("a", encoding="utf-8") as f:
            f.write(f"\n## {ts}\n{message}\n")


# ─────────────────────────────────────────────────────────────────────────────
# USO EN AGENTES GENERADOS POR ALAN-4AI
# ─────────────────────────────────────────────────────────────────────────────
#
# S0 - inicializar:
#   checkpoint = PipelineCheckpoint(run_id, base_dir="output/{nombre}/runs")
#
# Fin de cada stage:
#   checkpoint.save_stage(N, {
#       "result": stage_output,
#       "metadata": {"model": "<snapshot-exacto-que-usaste>", "duration_s": 45},
#       "summary": "Resumen de una línea del output"
#   })
#
# Si el run cae y se reanuda:
#   last_stage, last_state = checkpoint.load_last_valid()
#   # Ejecutar desde last_stage + 1
#
# Al terminar:
#   for s in checkpoint.summary():
#       print(s["stage"], s["model"], s["valid"])
#   checkpoint.clean_old()  # batch nocturno opcional
#
# Nota: registra en "model" el snapshot EXACTO del modelo (nunca un alias dinámico).
# Corre sobre tu Claude Code (plan Max/Pro o API propia); no hay cobro aparte.
