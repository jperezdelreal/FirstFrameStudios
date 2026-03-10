### 2026-03-10T07:51Z: User directive — Art pipeline workflow
**By:** Joaquín (via Copilot)
**What:** Art pipeline must follow this flow: (1) Generate hero reference with FLUX 2 Pro at 1024px on transparent/solid-color background — get founder approval on static character design BEFORE proceeding. (2) Use approved hero as Kontext Pro input_image to generate animation frames. (3) FLUX 2 Pro should generate without background from the start — avoid rembg post-processing which "siempre se nota un poquito". Generate multiple design proposals for Kael and Rhena for founder approval.
**Why:** Founder observed rembg artifacts. Better to generate clean from source than fix in post. Also wants design approval gate before frame generation to avoid wasting API calls on wrong designs.
