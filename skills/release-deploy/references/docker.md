# Docker image or container

Build and, on explicit intent, publish a container image. A full image build is
an expensive action; run it once at this boundary.

## Prerequisites

- The pre-release checklist passed
- A `Dockerfile` or compose file in the repository
- The intended image name and tag, confirmed with the user
- A target registry, if publishing

## Steps

1. Read the `Dockerfile`; confirm the base image and that no secret is baked in
2. Confirm `.dockerignore` excludes secrets, `.git`, and local env files
3. Build the image once with the confirmed name and tag
4. Run the image locally to confirm it starts and serves its documented entry
5. If publishing, confirm the registry and that a push is intended, then push
   only on explicit request
6. If a compose file starts several services, start only the one needed to
   verify; do not start the whole stack for validation

## Validation

- The image builds without error
- A container starts and responds on its documented port or command
- No secret or local env file is present inside the image

## Explicit-intent gate

- Never push an image to a registry without a direct request
- Never tag as `latest` on a public registry without confirmation
- Never build with `--no-cache` or rebuild unrelated images for a small change

## Common failures

- Secrets copied in via a broad `COPY .` with no `.dockerignore`
- The image builds but the entry command is wrong
- Registry authentication missing; report it, do not store credentials
