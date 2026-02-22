// Fubell — NTU thesis template for Typst.
//
// Usage:
//   #import "@preview/fubell:0.1.0": thesis
//   #show: thesis.with( ... )

#import "src/config.typ"
#import "src/cover.typ": cover-page
#import "src/certification.typ": certification-page
#import "src/abstract-page.typ": abstract-page
#import "src/acknowledgement-page.typ": acknowledgement-page

#let thesis(
  // -- Bilingual metadata --
  university: (zh: "國立臺灣大學", en: "National Taiwan University"),
  college: (zh: "", en: ""),
  institute: (zh: "", en: ""),
  title: (zh: "", en: ""),
  author: (zh: "", en: ""),
  advisor: (zh: "", en: ""),
  student-id: "",
  degree: "master", // "master" or "phd"
  date: (year-zh: "", year-en: "", month-zh: "", month-en: ""),
  keywords: (zh: (), en: ()),

  // -- Front matter content --
  abstract-zh: [],
  abstract-en: [],
  acknowledgement-zh: [],
  acknowledgement-en: [],

  // -- Options --
  lang: "zh", // "zh" or "en" — controls outline titles and document language
  committee-count: 4,
  bibliography-file: none,

  // -- Body --
  body,
) = {
  // -- Document metadata --
  set document(
    title: title.en,
    author: author.en,
  )

  // -- Page setup --
  set page(
    paper: "a4",
    margin: (
      top: config.margin-top,
      bottom: config.margin-bottom,
      left: config.margin-left,
      right: config.margin-right,
    ),
  )

  // -- Typography --
  // Body uses 新細明體 (PMingLiU) for Chinese, Times New Roman for English
  set text(
    size: config.body-size,
    font: config.font-en + config.font-zh,
    lang: lang,
    ..if lang == "zh" { (region: "tw") },
  )
  set par(leading: config.line-spacing)

  // -- Heading style --
  // Headings use 標楷體 for Chinese per NTU format
  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1em)
    text(size: config.heading-size, weight: "bold", font: config.font-en + config.font-zh)[#it]
    v(0.8em)
  }
  show heading.where(level: 2): it => {
    v(0.8em)
    text(size: config.subheading-size, weight: "bold", font: config.font-en + config.font-zh)[#it]
    v(0.5em)
  }

  // ================================================================
  // Front matter
  // ================================================================

  // 1. Cover page (書名頁)
  cover-page(
    university: university,
    college: college,
    institute: institute,
    title: title,
    author: author,
    advisor: advisor,
    degree: degree,
    date: date,
  )

  // 2. Certification page (口試委員會審定書)
  certification-page(
    university: university,
    author: author,
    title: title,
    institute: institute,
    student-id: student-id,
    degree: degree,
    date: date,
    committee-count: committee-count,
  )

  // 3. Acknowledgements (致謝)
  acknowledgement-page(content: acknowledgement-zh, lang: "zh")
  acknowledgement-page(content: acknowledgement-en, lang: "en")

  // 4. Chinese abstract (中文摘要)
  abstract-page(
    title: title.zh,
    content: abstract-zh,
    keywords: keywords.zh,
    lang: "zh",
  )

  // 5. English abstract (英文摘要)
  abstract-page(
    title: title.en,
    content: abstract-en,
    keywords: keywords.en,
    lang: "en",
  )

  // 6. Table of contents (目次)
  {
    let toc-title = if lang == "zh" { "目錄" } else { "Table of Contents" }
    let lof-title = if lang == "zh" { "圖目錄" } else { "List of Figures" }
    let lot-title = if lang == "zh" { "表目錄" } else { "List of Tables" }

    page(numbering: "i")[
      #outline(title: [#toc-title], depth: 3)
    ]

    // 7. List of figures (圖次)
    page(numbering: "i")[
      #outline(title: [#lof-title], target: figure.where(kind: image))
    ]

    // 8. List of tables (表次)
    page(numbering: "i")[
      #outline(title: [#lot-title], target: figure.where(kind: table))
    ]
  }

  // ================================================================
  // Main matter (論文本文)
  // ================================================================

  // Reset to Arabic page numbering for main content
  set page(numbering: "1")
  counter(page).update(1)

  body

  // ================================================================
  // Back matter — bibliography (參考文獻)
  // ================================================================

  if bibliography-file != none {
    pagebreak(weak: true)
    bibliography-file
  }
}
