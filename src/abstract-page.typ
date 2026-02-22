// Abstract page layout (supports both Chinese and English).
// Per thesissample.doc: title in 標楷體, body in 新細明體/Times New Roman.

#import "config.typ": font-zh, font-zh, font-en

#let abstract-page(
  title: "",
  content: [],
  keywords: (),
  lang: "zh",
) = {
  let heading-text = if lang == "zh" { "摘要" } else { "Abstract" }
  let keywords-label = if lang == "zh" { "關鍵字：" } else { "Keywords: " }
  let keywords-sep = if lang == "zh" { "、" } else { ", " }

  page(numbering: "i")[
    #set text(font: font-en + font-zh)

    #set align(center)
    #text(size: 18pt, weight: "bold", font: font-en + font-zh)[#heading-text]
    #v(1.5em)

    #set align(left)
    #set par(first-line-indent: 2em, leading: 1.5em)
    #content

    #v(2em)
    #set par(first-line-indent: 0em)
    #text(weight: "bold")[#keywords-label]
    #keywords.join(keywords-sep)
  ]
}
