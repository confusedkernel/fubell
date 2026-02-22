// Acknowledgement page layout (supports both Chinese and English).
// Per thesissample.doc: heading in 標楷體, body in 新細明體/Times New Roman.

#import "config.typ": font-zh, font-zh, font-en

#let acknowledgement-page(
  content: [],
  lang: "zh",
) = {
  let heading-text = if lang == "zh" { "致謝" } else { "Acknowledgements" }

  page(numbering: "i")[
    #set text(font: font-en + font-zh)

    #set align(center)
    #text(size: 18pt, weight: "bold", font: font-en + font-zh)[#heading-text]
    #v(1.5em)

    #set align(left)
    #set par(first-line-indent: 2em, leading: 1.5em)
    #content
  ]
}
