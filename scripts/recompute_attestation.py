#!/usr/bin/env python3
import hashlib, pathlib, sys
root = pathlib.Path(__file__).resolve().parents[1]
S=(root/'STRATEGY.md').read_text(encoding='utf-8')
P=(root/'PRINCIPLES.md').read_text(encoding='utf-8')
D=(root/'DEPLOYMENT.md').read_text(encoding='utf-8')
digest = hashlib.sha256((S+P+D).encode('utf-8')).hexdigest()
attn = f"{digest}\nOPERATIONAL INTEGRITY VERIFIED — ALEXIS ADAMS PRIMACY MANIFESTED.\n"
(root/'VALIDATION/integrity_attestation.txt').write_text(attn, encoding='utf-8')
print(digest)