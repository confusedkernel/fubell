# Changelog

## Unreleased

- Added font profile support in `thesis.with(...)` with `font-profile: "submission" | "web" | "portable"`.
- Added optional `font-en` and `font-zh` overrides for custom fallback stacks.
- Reduced duplicated unknown-font warnings by avoiding repeated font stack application in heading styles.
- Added a CLI diagnostics guide in `README.md` for checking effective font config and fallback issues.
- Added `certification-pdf`, `certification-pdf-page`, and `certification-pdf-fit` options to replace the auto-generated certification page with a scanned PDF.

## 0.1.0 - 2026-02-23

- Set up a Typst Universe-conventional package scaffold.
- Added a modular NTU thesis MVP template with bilingual front matter.
- Added a starter thesis project under `template/`.
- Made acknowledgement pages optional (default `none`, rendered only when provided).

