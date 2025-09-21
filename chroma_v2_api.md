# ChromaDB v2 API Quick Reference

This document serves as an internal quick reference for interacting with the ChromaDB v2 API, based on direct inspection of the server's OpenAPI documentation (`/docs`).

**Author**: Project Manager
**Date**: 2025-09-21

---

## 1. Key Discovery

A significant amount of development time was spent attempting to use the `/api/v1/...` endpoints, which were referenced in older online documentation and community packages.

**It is now confirmed that the latest version of the ChromaDB server has completely deprecated the v1 API.** All interactions must use the `/api/v2/...` endpoints.

---

## 2. Query Endpoint

This is the most critical endpoint for our RAG (Retrieval-Augmented Generation) functionality.

-   **Method**: `POST`

-   **URL Structure**:
    ```
    /api/v2/tenants/{tenant}/databases/{database}/collections/{collection_id}/query
    ```

-   **Default Parameters**:
    -   `tenant`: `default_tenant`
    -   `database`: `default_database`
    -   `collection_id`: The name of the collection (e.g., `etf_collection`).

-   **Example URL**:
    ```
    http://localhost:8000/api/v2/tenants/default_tenant/databases/default_database/collections/etf_collection/query
    ```

-   **Request Body (JSON)**:
    ```json
    {
      "query_embeddings": [
        [0.1, 0.2, -0.05, ... , 0.n]
      ],
      "n_results": 10
    }
    ```
    *Note: `query_embeddings` expects an array of vectors. For a single query, it should be `[vector]`.*

---
*This document should be the primary source of truth for any manual HTTP interactions with the ChromaDB server.*
