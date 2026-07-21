# Privacy and provenance

A public repository exposes everything in history, not only the current tree.
Check what is being published and where it came from.

## Privacy

- Scan added and changed lines for secrets, keys, tokens, and seed material
- Scan for personal data: names, emails, phone numbers, addresses
- Scan for internal identifiers: hostnames, internal URLs, ticket numbers,
  employer or client names
- Check example and fixture files for real-looking accounts or credentials
- Check committed data files and binaries for embedded private content
- A secret already committed to history is still exposed after removal from the
  tree; flag it for rotation, not only deletion

## Provenance

- Confirm copied code is permitted for redistribution under the project license
- Confirm attribution is present where a source requires it
- Confirm bundled assets (fonts, images, data) carry compatible licenses
- Treat code of unknown origin as a blocking provenance question
- Treat generated code as untrusted until reviewed for both correctness and
  license

## Failure behavior

- Any detected secret or private datum is a blocking finding and a human-review
  item; recommend rotation where a credential was exposed
- Any unclear license or provenance is a blocking finding until resolved
