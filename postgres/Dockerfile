FROM pgvector/pgvector:0.8.5-pg17-bookworm AS pgvector

FROM postgres:17.4

COPY --from=pgvector /usr/lib/postgresql/17/lib/vector.so /usr/lib/postgresql/17/lib/
COPY --from=pgvector /usr/share/postgresql/17/extension/vector* /usr/share/postgresql/17/extension/
