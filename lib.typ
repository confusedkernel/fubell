// Fubell — NTU thesis template for Typst.
//
// Usage:
//   #import "@preview/fubell:0.1.0": thesis
//   #show: thesis.with( ... )

#import "src/config.typ"
#import "src/cover.typ": cover-page
#import "src/certification.typ": certification-page
#import "src/front-matter-page.typ": front-matter-page
#import "src/outline-page.typ": outline-page

#let thesis(
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
  acknowledgement-zh: none,
  acknowledgement-en: none,
  // -- Options --
  lang: "zh", // "zh" or "en" — controls outline titles and document language
  committee-count: 4,
  bibliography-file: none,
  watermark: none, // path to watermark image (e.g. "watermark.pdf")
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
    ..if watermark != none {
      (background: place(top + right, dx: -2.5cm, dy: 2.5cm, image(watermark, width: 3.5cm)))
    },
  )

  // -- Typography --
  set text(
    size: config.body-size,
    font: config.font-en + config.font-zh,
    lang: lang,
    ..if lang == "zh" { (region: "tw") },
  )
  set par(leading: if lang == "zh" { config.line-spacing-zh } else { config.line-spacing-en })

  // -- Heading style --
  let chapter-prefix = if lang == "zh" { "第" } else { "Chapter " }
  let chapter-suffix = if lang == "zh" { "章 " } else { " " }
  let chapter-num-fmt = if lang == "zh" { "一" } else { "1" }
  let thesis-numbering = (..nums) => {
    let nums = nums.pos()
    if nums.len() == 1 {
      chapter-prefix + numbering(chapter-num-fmt, nums.first()) + chapter-suffix
    } else {
      numbering("1.1", ..nums) + " "
    }
  }
  set heading(numbering: thesis-numbering)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1em)
    align(center, text(size: config.heading-size, weight: "bold", font: config.font-en + config.font-zh)[
      #if it.numbering != none {
        counter(heading).display(thesis-numbering)
      }
      #it.body
    ])
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
  if acknowledgement-zh != none {
    front-matter-page(heading-text: "致謝", content: acknowledgement-zh, lang: "zh")
  }
  if acknowledgement-en != none {
    front-matter-page(heading-text: "Acknowledgements", content: acknowledgement-en, lang: "en")
  }

  // 4. Chinese abstract (中文摘要)
  front-matter-page(
    heading-text: "摘要",
    content: abstract-zh,
    keywords: keywords.zh,
    lang: "zh",
  )

  // 5. English abstract (英文摘要)
  front-matter-page(
    heading-text: "Abstract",
    content: abstract-en,
    keywords: keywords.en,
    lang: "en",
  )

  // 6. Table of contents, list of figures, list of tables
  {
    let toc-title = if lang == "zh" { "目錄" } else { "Table of Contents" }
    let lof-title = if lang == "zh" { "圖目錄" } else { "List of Figures" }
    let lot-title = if lang == "zh" { "表目錄" } else { "List of Tables" }

    outline-page(toc-title, depth: 3)
    outline-page(lof-title, target: figure.where(kind: image))
    outline-page(lot-title, target: figure.where(kind: table))
  }

  // ================================================================
  // Main matter
  // ================================================================

  // Reset to Arabic page numbering for main content
  set page(numbering: "1")
  counter(page).update(1)

  body

  // ================================================================
  // Back matter — bibliography
  // ================================================================

  if bibliography-file != none {
    let bib-title = if lang == "zh" { "參考文獻" } else { "References" }
    pagebreak(weak: true)
    set bibliography(title: bib-title)
    show bibliography: set heading(numbering: none)
    show bibliography: set text(lang: "en")
    show heading.where(level: 1): it => {
      align(center, text(size: config.heading-size, weight: "bold")[#it.body])
      v(1.5em)
    }
    bibliography-file
  }
}
