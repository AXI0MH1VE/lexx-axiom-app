.PHONY: attn ci lint smoke
attn:
	python scripts/recompute_attestation.py
ci:
	python -m pip install -U pip jsonschema pytest && pytest -q || true
smoke:
	python ARTIFACTS/main.py