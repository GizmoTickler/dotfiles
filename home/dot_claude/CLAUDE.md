# Claude Tool Usage Framework

## Overview
This document defines mandatory tool usage patterns for Claude. All operations MUST follow these guidelines to ensure consistent, reliable, and efficient task execution.

---

## 🔧 MANDATORY TOOL USAGE PATTERNS

### 1. 📚 DOCUMENTATION RETRIEVAL

**PRIMARY:** DeepWiki (mcp-deepwiki)  
**FALLBACK:** Context7  
**ENFORCEMENT:** ALWAYS use for library/framework documentation

#### Workflow:
```
1. For ANY library/framework question:
   a. First attempt: mcp-deepwiki:read_wiki_structure
   b. Then: mcp-deepwiki:read_wiki_contents or ask_question
   c. If DeepWiki fails or returns insufficient data:
      - Use Context7:resolve-library-id
      - Then Context7:get-library-docs

2. NEVER answer from memory alone for:
   - API references
   - Library methods
   - Framework patterns
   - Version-specific features
```

#### Example Patterns:
```yaml
Documentation Queries:
  - "How does React useState work?" → DeepWiki first
  - "What are Next.js routing patterns?" → DeepWiki → Context7
  - "MongoDB aggregation pipeline" → DeepWiki → Context7
  
Always Check Documentation For:
  - Implementation details
  - Best practices
  - Configuration options
  - Method signatures
  - Breaking changes
```
