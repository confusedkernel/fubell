# Fubell

A [Typst](https://typst.app) thesis template for **National Taiwan University** (國立臺灣大學).

Inspired by the [ntu-thesis](https://github.com/tzhuan/ntu-thesis) LaTeX template.

The name is a reference to Fu Bell (傅鐘) in NTU, in case you haven't realized it yet :)

## Quick Start

```bash
typst init @preview/fubell:0.1.0 my-thesis
cd my-thesis
typst compile main.typ
```

Or clone this repository and compile the example directly:

```bash
typst compile template/main.typ
```

## Project Structure

```
fubell/
├── lib.typ                  # Package entrypoint (exports `thesis`)
├── src/
│   ├── config.typ           # Page geometry, fonts, spacing defaults
│   ├── cover.typ            # Cover page layout
│   ├── certification.typ    # Oral defense certification page
│   ├── abstract-page.typ    # Abstract page (zh/en)
│   └── acknowledgement-page.typ
├── template/                # Scaffolded into user projects
│   ├── main.typ             # Thesis entry point (edit this)
│   ├── refs.bib             # Bibliography
│   └── content/
│       ├── abstract-zh.typ
│       ├── abstract-en.typ
│       ├── acknowledgement-zh.typ
│       ├── acknowledgement-en.typ
│       └── chapters/
│           └── introduction.typ
├── typst.toml               # Package manifest
├── ROADMAP.md               # Development roadmap
└── CHANGELOG.md
```

## Usage

```typst
#import "@preview/fubell:0.1.0": thesis

#show: thesis.with(
  university: (zh: "國立臺灣大學", en: "National Taiwan University"),
  college:    (zh: "電機資訊學院", en: "College of EECS"),
  institute:  (zh: "資訊工程學系", en: "Dept. of CSIE"),
  title: (
    zh: "論文中文標題",
    en: "Thesis English Title",
  ),
  author:  (zh: "王小明", en: "Xiao-Ming Wang"),
  advisor: (zh: "陳大文 博士", en: "Da-Wen Chen, Ph.D."),
  student-id: "R12345678",
  degree: "master", // or "phd"
  lang: "zh", // or "en" — controls outline titles and document language
  date: (year-zh: "113", year-en: "2024", month-zh: "6", month-en: "June"),
  keywords: (
    zh: ("關鍵字一", "關鍵字二"),
    en: ("keyword one", "keyword two"),
  ),

  abstract-zh: include "content/abstract-zh.typ",
  abstract-en: include "content/abstract-en.typ",
  acknowledgement-zh: include "content/acknowledgement-zh.typ",
  acknowledgement-en: include "content/acknowledgement-en.typ",

  bibliography-file: bibliography("refs.bib"),
)

#include "content/chapters/introduction.typ"
```

## Language

The `lang` option (default `"zh"`) controls the document language and structural titles (Table of Contents, List of Figures, List of Tables). Set `lang: "en"` for English headings. Cover and certification pages remain bilingual regardless of this setting.

## Fonts

The template uses **Times New Roman** for English text and **標楷體 (BiauKai)** for Chinese text, matching NTU's formatting requirements. If these fonts are not installed, Typst will fall back to bundled alternatives.

## License

[MIT-0](LICENSE) — use freely, no attribution required.
