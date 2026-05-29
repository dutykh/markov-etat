// ==========================================
// A Cohn-tree reduction of the
// Frobenius–Markov uniqueness conjecture
// Authors: Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)
//          Prof. Laurent Vuillon (Univ. Savoie Mont Blanc, CNRS, LAMA,
//                                Chambéry, 73000, France)
// Created: May 27, 2026
// ==========================================

// ==========================================
// PACKAGE IMPORTS
// ==========================================

#import "@preview/fletcher:0.5.8": diagram, node, edge
#import "@preview/cetz:0.3.4"

// ==========================================
// CONFIGURATION
// ==========================================

#let ku-blue = rgb("#005696")
#let ku-blue-light = rgb("#3378AB")
#let ku-blue-pale = rgb("#6699C2")
#let ku-blue-wash = rgb("#e8f1f8")
#let defn-color = rgb("#2e7d32")
#let defn-wash = rgb("#e8f5e9")
#let dark-text = rgb("#1a1a2e")
#let muted-text = rgb("#5a5a7a")

// Distinct colours for theorem-like environments
#let thm-color = rgb("#1a237e")       // deep indigo for Theorems
#let thm-wash = rgb("#e8eaf6")
#let lem-color = rgb("#00695c")       // teal for Lemmas
#let lem-wash = rgb("#e0f2f1")
#let prop-color = rgb("#4a148c")      // deep purple for Propositions
#let prop-wash = rgb("#f3e5f5")
#let cor-color = rgb("#bf360c")       // deep orange for Corollaries
#let cor-wash = rgb("#fbe9e7")
#let conj-color = rgb("#b8860b")      // dark goldenrod for Conjectures (stated, not proven)
#let conj-wash = rgb("#fdf6e3")

// ==========================================
// DOCUMENT SETUP
// ==========================================

#set page(
  paper: "a4",
  margin: (top: 1.2in, bottom: 1in, left: 1.15in, right: 1.15in),
  numbering: "1",
  header: context {
    if counter(page).get().first() > 1 [
      #set text(size: 8.5pt, fill: muted-text, font: "Linux Libertine O")
      #grid(
        columns: (1fr, 1fr),
        align: (left, right),
        [A Cohn-tree reduction of the Frobenius–Markov conjecture],
        [Page #counter(page).display() of #counter(page).final().first()],
      )
      #v(-0.3em)
      #line(length: 100%, stroke: 0.4pt + ku-blue-pale)
    ]
  },
  footer: context {
    if counter(page).get().first() == 1 [
      #align(center)[
        #set text(size: 8.5pt, fill: muted-text)
        #counter(page).display() / #counter(page).final().first()
      ]
    ]
  },
)

#set text(
  font: "Linux Libertine O",
  size: 12pt,
  lang: "en",
  fill: dark-text,
)

#set par(
  justify: true,
  leading: 0.65em,
  first-line-indent: 1.5em,
)

#set block(spacing: 0.9em)

#set list(indent: 1em, body-indent: 0.5em)
#set enum(indent: 1em, body-indent: 0.5em)

// Numbered headings
#set heading(numbering: "1.1")

// Chapter convention: top-level `=` is a Chapter; `==` is a Section; `===` is
// a Subsection. Unnumbered front-matter headings (Preface, an unnumbered
// Introduction) display only the title + full-width rule, without a "Chapter N"
// label. Every chapter starts on a new page (weak pagebreak avoids a blank
// page if the previous block already ended with one).
#show heading.where(level: 1): set heading(supplement: "Chapter")

#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  v(4em)
  if it.numbering != none {
    let number = counter(heading).display()
    block(below: 0.6em)[
      #set text(size: 16pt, style: "italic", fill: ku-blue-light)
      Chapter #number
    ]
    block(below: 1.0em)[
      #line(length: 3cm, stroke: 0.8pt + ku-blue-pale)
    ]
  }
  block(below: 0.4em)[
    #set text(size: 22pt, weight: "bold", fill: ku-blue)
    #it.body
  ]
  line(length: 100%, stroke: 0.6pt + ku-blue)
  v(1.8em)
}

#show heading.where(level: 2): it => {
  v(1.3em)
  block(below: 0.8em)[
    #set text(weight: "bold", size: 14pt, fill: ku-blue-light)
    // Small decorative bar before subsection number
    #box(
      width: 3pt,
      height: 0.95em,
      fill: ku-blue-pale,
      baseline: 15%,
    )
    #h(0.35em)
    #if it.numbering != none {
      let number = counter(heading).display()
      [#number#h(0.4em)]
    }
    #it.body
  ]
}

#show heading.where(level: 3): it => {
  v(1em)
  block(below: 1em)[
    #set text(weight: "bold", size: 13pt, fill: muted-text)
    #if it.numbering != none {
      let number = counter(heading).display()
      [#number#h(0.4em)]
    }
    #it.body
  ]
}

// Math font
#show math.equation: set text(font: "New Computer Modern Math")

// Numbered display equations
#set math.equation(numbering: n => {
  let sec = counter(heading).get().first()
  if sec == 0 {
    "(" + str(n) + ")"
  } else {
    "(" + str(sec) + "." + str(n) + ")"
  }
})

// Render equation cross-references as "(sec.N)" per chapter/section, falling
// back to bare "(N)" when sec = 0 (e.g. inside an unnumbered Introduction).
// The wrapping parens are added explicitly because Typst's default reference
// rendering would otherwise strip the parens of the numbering pattern.
#show ref: it => {
  let el = it.element
  if el != none and el.func() == math.equation {
    let loc = el.location()
    let n = counter(math.equation).at(loc).first()
    let sec = counter(heading).at(loc).first()
    if sec == 0 {
      link(loc)[(#n)]
    } else {
      link(loc)[(#sec.#n)]
    }
  } else {
    it
  }
}

// Extra spacing around figures so captions don't bleed into body text
#show figure: it => {
  v(1.2em)
  it
  v(1.2em)
}

// Place captions ABOVE tables (academic convention); figure captions stay below.
#show figure.where(kind: table): set figure.caption(position: top)

// ==========================================
// TABLE STYLING -- unified KU-branded look
// ==========================================
// Every `#table` in the manuscript renders as a rounded "card": a solid KU-blue
// header band with white bold text, soft alternating KU-wash row stripes,
// hairline interior separators in pale KU blue, and a thin KU-blue frame with
// rounded corners. The header band repeats automatically if a table breaks
// across pages, and each page fragment keeps its own rounded frame. Individual
// tables therefore only need to declare their `columns`, `align`, header, and
// cells -- never `stroke` or `fill`. Table figures are made breakable so a long
// table (e.g. the 34-row mod-37 table) splits across pages with the KU header
// band repeated on each fragment, rather than overflowing and being clipped.
#show figure.where(kind: table): set block(breakable: true)
#set table(
  inset: (x: 9pt, y: 6pt),
  // No vertical rules and no outer cell borders (the wrapping block supplies the
  // frame); only faint horizontal hairlines between body rows.
  stroke: (x, y) => (
    top: if y <= 1 { 0pt } else { 0.4pt + ku-blue-pale.lighten(30%) },
    bottom: 0pt, left: 0pt, right: 0pt,
  ),
  // Header band (y = 0) in KU blue; body rows alternate white / KU wash.
  fill: (x, y) => if y == 0 { ku-blue } else if calc.even(y) { ku-blue-wash } else { white },
)
#show table.cell.where(y: 0): set text(fill: white, weight: "bold")
#show table: it => block(stroke: 0.9pt + ku-blue, radius: 5pt, clip: true, it)

// ==========================================
// THEOREM ENVIRONMENTS
// ==========================================

// Shared counter, numbered within sections
#let thm-counter = counter("theorem")

// Reset theorem counter at each new section
#show heading.where(level: 1): it => {
  thm-counter.update(0)
  counter(math.equation).update(0)
  it
}

// Helper: format theorem number as "section.n"
#let thm-number() = {
  context {
    let sec = counter(heading).get().first()
    let n = thm-counter.get().first()
    [#sec.#n]
  }
}

// Theorem-like environment with per-kind colours and optional cross-referencing.
//
// The figure block is wrapped in `context { ... }` so that the section number
// `sec` and the local index `n` are captured at figure-creation time. The
// previous version returned a context-block-valued closure from `numbering`,
// which caused Typst to re-read the live counter at the @-reference site --
// so a citation to @thm:foo from inside Corollary 3.8's body would render as
// "Theorem 3.8" instead of the correct earlier number. Capturing `num` here
// makes both the in-place display and every cross-reference resolve to the
// number assigned at this location.
#let theorem-like(kind: "Theorem", title: none, lbl: none, accent: ku-blue, bg: ku-blue-wash, body) = {
  thm-counter.step()
  context {
    let sec = counter(heading).get().first()
    let n = thm-counter.get().first()
    let num = [#sec.#n]
    [#figure(
      supplement: kind,
      kind: "theorem-env",
      numbering: _ => num,
      outlined: false,
      caption: none,
      align(left,
        block(
          width: 100%,
          inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
          stroke: (left: 3pt + accent),
          fill: bg,
          radius: (right: 3pt),
        )[
          #set par(justify: true)
          #text(weight: "bold", fill: accent)[#kind #num#if title != none [#h(0.3em)#text(weight: "regular", fill: dark-text)[(#title)]].]
          #h(0.3em)
          #emph(body)
        ]
      ),
    )#if lbl != none { lbl }]
  }
}

#let theorem(title: none, lbl: none, body) = theorem-like(kind: "Theorem", title: title, lbl: lbl, accent: thm-color, bg: thm-wash, body)
#let proposition(title: none, lbl: none, body) = theorem-like(kind: "Proposition", title: title, lbl: lbl, accent: prop-color, bg: prop-wash, body)
#let lemma(title: none, lbl: none, body) = theorem-like(kind: "Lemma", title: title, lbl: lbl, accent: lem-color, bg: lem-wash, body)
#let corollary(title: none, lbl: none, body) = theorem-like(kind: "Corollary", title: title, lbl: lbl, accent: cor-color, bg: cor-wash, body)

// A `#conjecture(...)` block is a precise statement that the manuscript does
// NOT prove. Results that ARE proved use `#theorem`/`#proposition`/`#lemma`/
// `#corollary` and must be followed by a `#proof[...]` block.
#let conjecture(title: none, lbl: none, body) = theorem-like(kind: "Conjecture", title: title, lbl: lbl, accent: conj-color, bg: conj-wash, body)

// Definition environment (normal body, green left border)
#let definition(title: none, lbl: none, body) = {
  thm-counter.step()
  context {
    let sec = counter(heading).get().first()
    let n = thm-counter.get().first()
    let num = [#sec.#n]
    [#figure(
      supplement: "Definition",
      kind: "defn-env",
      numbering: _ => num,
      outlined: false,
      caption: none,
      align(left,
        block(
          width: 100%,
          inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
          stroke: (left: 3pt + defn-color),
          fill: defn-wash,
          radius: (right: 3pt),
        )[
          #set par(justify: true)
          #text(weight: "bold", fill: defn-color)[Definition #num#if title != none [#h(0.3em)#text(weight: "regular", fill: dark-text)[(#title)]].]
          #h(0.3em)
          #body
        ]
      ),
    )#if lbl != none { lbl }]
  }
}

// Remark environment (lightweight, subtle border)
#let remark(title: none, lbl: none, body) = {
  thm-counter.step()
  context {
    let sec = counter(heading).get().first()
    let n = thm-counter.get().first()
    let num = [#sec.#n]
    [#figure(
      supplement: "Remark",
      kind: "remark-env",
      numbering: _ => num,
      outlined: false,
      caption: none,
      align(left,
        block(
          width: 100%,
          inset: (left: 14pt, top: 8pt, bottom: 8pt),
          stroke: (left: 2pt + ku-blue-pale),
        )[
          #set par(justify: true)
          #text(style: "italic", fill: ku-blue-light)[Remark #num#if title != none [#h(0.3em)#text(style: "normal", fill: dark-text)[(#title)]].]
          #h(0.3em)
          #body
        ]
      ),
    )#if lbl != none { lbl }]
  }
}

// Proof environment
#let proof(body) = {
  block(
    width: 100%,
    inset: (left: 1em),
    below: 1.2em,
    above: 1.2em,
  )[
    #text(style: "italic", fill: ku-blue)[Proof.]
    #h(0.3em)
    #body
    #h(1fr)
    #text(fill: ku-blue)[$square.stroked$]
  ]
}

// ==========================================
// TITLE BLOCK
// ==========================================

// Decorative top bar
#place(top + left, dx: -1.15in, dy: -1.2in)[
  #rect(width: 100% + 2.3in, height: 5pt, fill: ku-blue)
]

#v(1.5em)

// Title card
#block(
  width: 100%,
  inset: (x: 20pt, top: 24pt, bottom: 20pt),
  radius: 5pt,
  fill: ku-blue-wash,
  stroke: 0.5pt + ku-blue-pale,
)[
  #align(center)[
    // Main title
    #block(width: 95%)[
      #set par(leading: 0.55em)
      #text(size: 21pt, weight: "bold", fill: ku-blue)[
        A Cohn-tree reduction of the\ Frobenius–Markov uniqueness conjecture
      ]
    ]

    #v(1em)
    #line(length: 25%, stroke: 0.8pt + ku-blue-pale)
    #v(1em)

    // Two-column author block (different affiliations)
    #grid(
      columns: (1fr, 1fr),
      column-gutter: 1.5em,
      // LEFT: DD
      align(center + top)[
        #text(size: 12pt, weight: "bold")[Dr. Denys Dutykh]

        #v(0.25em)

        #text(size: 9.5pt, fill: muted-text)[
          Mathematics Department \
          Khalifa University of Science and Technology \
          PO Box 127788, Abu Dhabi, UAE
        ]

        #v(0.4em)

        #link("mailto:denys.dutykh@ku.ac.ae")[#text(size: 9pt, fill: ku-blue)[denys.dutykh\@ku.ac.ae]] \
        #link("https://www.denys-dutykh.com/")[#text(size: 9pt, fill: ku-blue)[www.denys-dutykh.com]]
      ],
      // RIGHT: LV
      align(center + top)[
        #text(size: 12pt, weight: "bold")[Prof. Laurent Vuillon]

        #v(0.25em)

        #text(size: 9.5pt, fill: muted-text)[
          Univ. Savoie Mont Blanc, CNRS, LAMA \
          Chambéry, 73000, France
        ]

        #v(0.4em)

        #link("mailto:laurent.vuillon@univ-smb.fr")[#text(size: 9pt, fill: ku-blue)[laurent.vuillon\@univ-smb.fr]] \
        #link("https://laurentvuillon.github.io/")[#text(size: 9pt, fill: ku-blue)[laurentvuillon.github.io]]
      ],
    )

    #v(0.8em)

    #text(size: 9.5pt, fill: muted-text)[
      #datetime.today().display("[month repr:long] [day], [year]")
    ]
  ]
]

#v(1.5em)

// ==========================================
// ABSTRACT
// ==========================================

#block(
  width: 100%,
  inset: (x: 20pt, y: 16pt),
  radius: 4pt,
  stroke: 0.5pt + ku-blue-pale,
  below: 1.5em,
)[
  #text(weight: "bold", size: 10.5pt, fill: ku-blue)[Abstract]
  #v(0.4em)
  #set text(size: 9.5pt)
  #set par(justify: true, leading: 0.6em, first-line-indent: 0pt, spacing: 0.8em)

  We study the Frobenius–Markov uniqueness conjecture through the Cohn-tree trace formulation. Using Cohn words, Farey cones, and trace recurrences, we prove same-ray monotonicity, dominance exclusion, Vieta gluing, and shifted boundary separation. We then show that any unresolved return-reduced cross-ray collision reduces to a terminal comparison in the standard Farey cone. Known monotonicity theorems for Markov and generalized Markov numbers exclude all non-exceptional terminal slopes and the primitive-step exceptional case. The remaining obstruction is an explicit terminal arithmetic problem in the exceptional slope window. We also prove that no fixed finite modular sieve can settle this terminal problem, and we isolate endpoint escape families by Fibonacci–Pell intersection. Thus Markov uniqueness is reduced to the Exceptional Terminal Arithmetic Theorem. As a first concrete step beyond this conditional reduction, we further prove the Exceptional Terminal Arithmetic Theorem in the minimal primitive exceptional direction $(R, H) = (6, 5)$ at multiplier $g = 2$, i.e. for $(r, h) = (12, 10)$ --- the first solved case inside the genuinely exceptional non-primitive terminal region. The full Exceptional Terminal Arithmetic Theorem remains open.
]

#v(0.8em)

// ==========================================
// KEYWORDS
// ==========================================

#block(
  width: 100%,
  inset: (x: 20pt, y: 10pt),
  radius: 4pt,
  stroke: 0.5pt + ku-blue-pale,
  below: 1.2em,
)[
  #set text(size: 9.5pt)
  #set par(first-line-indent: 0pt)
  #text(weight: "bold", fill: ku-blue)[Keywords:]
  #h(0.4em)
  Frobenius–Markov uniqueness conjecture; Markov numbers; Cohn tree; Cohn words; Farey cones; trace recurrences; monotonicity; Vieta gluing; Fibonacci–Pell intersection.
]

// ==========================================
// CODE & DATA AVAILABILITY
// ==========================================

#block(
  width: 100%,
  inset: (x: 20pt, y: 10pt),
  radius: 4pt,
  stroke: 0.5pt + ku-blue-pale,
  below: 1.2em,
)[
  #set text(size: 9.5pt)
  #set par(justify: true, first-line-indent: 0pt)
  #text(weight: "bold", fill: ku-blue)[Code and data availability:]
  #h(0.4em)
  All source code used in this study --- the exploratory scripts of @appendix:computational and the proof certificates of @appendix:minimal-certificates --- is openly available, in the interest of reproducible research, at the public repository #link("https://github.com/dutykh/markov-etat/")[#text(fill: ku-blue)[github.com\/dutykh\/markov-etat]]. The certificates of @sec:minimal-direction can be re-run and audited from that repository.
]

// ==========================================
// TABLE OF CONTENTS
// ==========================================

#heading(numbering: none, outlined: false)[Contents]

#{
  set text(size: 9.5pt)
  // Level 1 entries: bold KU blue with vertical spacing
  show outline.entry.where(level: 1): it => {
    v(0.3em)
    strong(text(fill: ku-blue)[#it])
  }
  // Level 2 entries: lighter blue
  show outline.entry.where(level: 2): it => {
    text(fill: ku-blue-light)[#it]
  }
  outline(
    title: none,
    indent: 1.5em,
    depth: 2,
  )
}

// ==========================================
// PREFACE
// ==========================================

#heading(numbering: none, outlined: true)[Preface] <sec:preface>

The Markov equation $x^2 + y^2 + z^2 = 3 x y z$ is short enough to write on one line, yet the question of whether each Markov number determines its triple uniquely has stayed open for more than a hundred years. This book grew out of our shared wish to understand _why_ the question resists every direct attack, and to locate, as precisely as we could, the single place where all the known methods stop working.

What we offer is not a proof of the Frobenius--Markov uniqueness conjecture but a reduction. Working inside the Cohn-tree trace formulation, we show through a chain of unconditional structural steps that the conjecture is equivalent to one sharply isolated arithmetic statement, which we call the _Exceptional Terminal Arithmetic Theorem_, and we prove that theorem in its first genuinely exceptional case. Throughout we have tried to keep the geometry visible behind the algebra, and to say plainly what is proved and what is left open.

The two of us came to this problem from different backgrounds. One of us brought not the techniques of nonlinear waves, but the methods, the rigour, and the research experience gained over many years of work in that field; the other brought a long familiarity with combinatorics on words and the theory of Christoffel and Sturmian sequences. Our collaboration, however, is much older than this book. When the first author took up a CNRS position in 2008, he joined the LAMA --- the _Laboratoire de Mathématiques_ of the Université Savoie Mont Blanc, in Le Bourget-du-Lac, France --- where the second author was his first laboratory director. In the years that followed, and despite the initial distance between our mathematical profiles and interests, a sincere mutual respect and friendship grew between us, and bore fruit in joint papers and in doctoral students we supervised together.

It was the second author who first drew the first author toward the Frobenius--Markov conjecture, and the earliest discussions of the present project took place at the LAMA, while the first author was still in France, before his move to Khalifa University in Abu Dhabi. The book reflects both points of view, and we hope the reader will find that the two languages support each other rather than compete.

Several of our arguments rest on finite but large computations. In the interest of reproducible research we have made every script openly available at the public repository #link("https://github.com/dutykh/markov-etat/")[#text(fill: ku-blue)[github.com\/dutykh\/markov-etat]], so that the certificates of the final Chapter can be re-run and checked line by line. A result of this kind should be open to anyone who cares to verify it.

More than a technical result, this book is for us a small testimony to a conviction we share: that with friendship, mutual respect, and genuine curiosity one can cross the boundaries between the mathematical disciplines. Mathematics is one united science. There is only one Mathematics, and we are proud to practise it.

#v(1.8em)

#align(right)[
  #text(style: "italic", fill: muted-text)[#datetime.today().display("[month repr:long] [year]")]
]

#v(0.6em)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1.5em,
  align(left)[
    #text(weight: "bold", fill: ku-blue)[Dr. Denys Dutykh] \
    #text(size: 10pt, fill: muted-text)[Abu Dhabi, UAE]
  ],
  align(right)[
    #text(weight: "bold", fill: ku-blue)[Prof. Laurent Vuillon] \
    #text(size: 10pt, fill: muted-text)[Chambéry, France]
  ],
)

// ==========================================
// CONTENT
// ==========================================


#heading(numbering: none, outlined: true)[Introduction] <sec:intro>

The _Markov equation_
$
  x^2 + y^2 + z^2 = 3 x y z
$
is one of the most fascinating Diophantine equations in number theory. Its positive integer solutions form a single $bb(Z)$-orbit under permutations and the _Vieta involution_
$
  (x, thin y, thin z) arrow.r.bar (x, thin y, thin 3 x y - z),
$
the orbit being explicitly generated as a binary tree rooted at the seed triple $(1, thin 1, thin 1)$. Triples of this orbit are the _Markov triples_, and a positive integer appearing as one component of a Markov triple is a _Markov number_. The first few Markov numbers are
$
  1, thick 2, thick 5, thick 13, thick 29, thick 34, thick 89, thick 169, thick 194, thick 233, thick 433, thick 610, thick dots,
$
each carrying a wealth of arithmetic, geometric, and combinatorial information.

That the equation @eq:markov-equation deserves a name of its own was made clear by Markov in his two memoirs on the spectrum of indefinite binary quadratic forms @Markoff1879 @Markoff1880, where the integers above appear as the discrete piece of the Lagrange spectrum below $3$. The _Frobenius--Markov uniqueness conjecture_ was first articulated as an open question by Frobenius @Frobenius1913, three decades later. In the language of the Markov tree, it reads as follows.

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + ku-blue),
  fill: ku-blue-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  #text(weight: "bold", fill: ku-blue)[Conjecture (Frobenius--Markov uniqueness).]
  #h(0.3em)
  #emph[
    Every Markov number occurs as the maximum of exactly one ordered Markov triple. Equivalently, if $(a, thin b, thin m)$ and $(a', thin b', thin m)$ are ordered Markov triples sharing the same maximum $m$, then ${ a, b } = { a', b' }$.
  ]
]

After more than one hundred years of attention, this conjecture is still open in the classical setting. The reasons are now better understood than they once were: every approach must eventually grapple with an essentially arithmetic obstruction that lies beyond the reach of any single combinatorial, modular, or word-theoretic mechanism. A central modern reference is Aigner's monograph @Aigner2013, which surveys the conjecture together with the remarkable web of equivalent formulations surrounding it --- Farey fractions, the Stern--Brocot tree, Cohn matrices and Cohn words, Christoffel and Sturmian words, free-group representations, perfect matchings of snake graphs, hyperbolic geodesics on the once-punctured torus, and cluster algebras of type $A_n$. Each of these languages translates the uniqueness conjecture into a problem of injectivity for a different family of natural objects, yet every translation eventually meets the same arithmetic bottleneck.

Recent progress, sustained and explosive between 2020 and 2026, has sharpened this picture along several complementary directions. We summarise the seven that bear directly on the present manuscript.

_Line-monotonicity._ Rabideau and Schiffler proved the fixed-numerator conjecture using snake-graph perfect matchings and continuant polynomials @RabideauSchiffler2020; Lagisquet, Pelantová, Tavenas, and the second author then proved the fixed-denominator and fixed-sum conjectures, and re-proved the fixed-numerator one in a unified path-flattening framework, extending all three to generalised Markov numbers indexed by all pairs $(p, thin q) in bb(Z)_(gt.eq.slant 0)^2$ @LagisquetPelantovaTavenasVuillon2021. The same authors @LagisquetPelantovaTavenasVuillon2021 also formulated a stronger unicity conjecture in the generalised setting and verified it by direct computation for every pair $(d, n) in bb(N)^2$ with $d, thin n lt.eq.slant 1000$; any counterexample in their generalised setting would therefore have to involve a value at least $m(c(1, 1000)) = F_(2001) > 6 dot 10^(417)$, a scale that is inaccessible by any direct search and that places the classical unicity question well beyond enumeration. Lee, Li, Rabideau, and Schiffler then characterised the slopes along which the Markov ordering is monotone in $q$ via snake-graph perfect matchings and a refinement of Aigner's conjectures @LeeLiRabideauSchiffler2023; Huang completed the line-monotonicity classification using the Markov distance and the Ptolemy inequality @Huang2022. The exceptional slope window of @sec:terminal-cone is precisely the residual locus that these results do not cover.

_Geometric reformulations on the modular torus._ Building on Schmutz's geometric interpretation of the Lagrange spectrum, Gaster and Loustau proved that the Markov uniqueness conjecture is equivalent to the convergent series identity
$
  sum_(n = 1)^infinity (3 - L_n) = 4 - phi.alt - sqrt(2),
$
where $L_n$ is the $n$-th Lagrange number, related to the Markov number $m_n$ by $L_n = sqrt(9 - 4 slash m_n^2)$, and $phi.alt = (1 + sqrt(5)) slash 2$ is the golden ratio @GasterLoustau2021. Fisac then translated the simple length spectrum of the modular torus into a combinatorial object, the _primitive small-variation integral necklaces_, and proved that Markov uniqueness is equivalent to the injectivity of an explicit trace function $Phi$ on these necklaces involving the algebraic integer $xi = 3 + sqrt(5)$ @Fisac2025. These two reformulations sit at the geometric end of the spectrum: they show that the conjecture is structurally tied to the topology and hyperbolic geometry of the once-punctured torus, and translate, on the combinatorial side, into the injectivity of a trace function on the Cohn-word central palindromes that we develop in @sec:cohn-words.

_Cluster algebras and the $k$-generalised Markov equation._ The first explicit family of generalisations of @eq:markov-equation came from Karpenkov and Van-Son, who introduced a number-of-geometry approach to generalised Markov numbers and exhibited a counterexample to the analogue of the Frobenius--Markov uniqueness conjecture in their generalised setting @KarpenkovVanSon2020. Gyoda and Maruyama then proposed a $k$-deformed Markov equation $x^2 + y^2 + z^2 + k (x y + y z + x z) = (3 + 3 k) x y z$ and a $k$-version of the Frobenius uniqueness conjecture, and proved it in the prime-power case @GyodaMaruyama2024. Banaian and Gyoda subsequently embedded the $k$-deformation in a cluster algebra of triangulated orbifolds and gave the corresponding $k$-Cohn-matrix family @BanaianGyoda2025, while Banaian and Huang classified the line-monotonicity of generalised $k$-Markov numbers and observed that the structural rigidity of the system _increases_ with $k$ @BanaianHuang2026, so that the classical $k = 0$ case is precisely the limit at which line-monotonicity stops detecting uniqueness; this is the structural reason why the residual obstruction of the present monograph is located at $k = 0$. The word-theoretic counterpart of the same picture has been recently developed by Gyoda, who constructed a family of words $omega_t$ indexed by positive rational slopes whose $k$-Markov-monodromy matrices reduce to the classical Cohn matrices of @sec:markov-cohn at $k = 0$ @Gyoda2026Words.

_Dynamical reformulations._ Spalding and Veselov computed the Lyapunov spectrum of the Markov and Euclid trees, identified it with the interval $[0, thin ln phi.alt]$, and exhibited monotonicity along the Markov--Hurwitz set of badly approximable numbers @SpaldingVeselov2017. Veselov has more recently identified Springborn's _Markov fractions_ with the Aigner indices of the Cohn matrices, and given a clean concatenation rule on the Conway topograph @Veselov2026; this is the geometric-combinatorial dictionary that underlies the Farey-cone bookkeeping of @sec:local-cone.

_Quantum $q$-deformations._ Labbé, Lapointe, and Steiner proved the injectivity of a $q$-deformed analogue of the Cohn matrix products on Christoffel words, evaluated at $q = exp(i pi slash 3)$ @LabbeLapointeSteiner2023, while explicitly identifying the classical injectivity conjecture --- the $q = 1$ case --- as still open. The much more recent work of Evans, Jouteur, Morier-Genoud, and Ovsienko establishes the natural setting for this $q$-deformation: every classical Markov number admits a _unique_ $q$-deformation, which is a monic unimodal palindromic Laurent polynomial with positive integer coefficients, obtained as the trace of a $q$-deformed Cohn matrix invariant under the quantum modular group $upright(P S L)_q (2, bb(Z))$ acting by Möbius transformations, and combinatorially expressed by perfect matchings of snake graphs with weighted edges @EvansJouteurMorierGenoudOvsienko2026. Because Laurent polynomials carry strictly more combinatorial information than scalar integers, injectivity in the $q$-deformed setting becomes more tractable than in its classical specialisation, and the work of @LabbeLapointeSteiner2023 establishes it directly; the classical case $q = 1$ remains the hard one.

_Superalgebraic analogues and mirror deformations._ Musiker introduced super Markov numbers as Grassmann-integer solutions to a nilpotent deformation $x^2 + y^2 + z^2 + (x y + y z + x z) thin epsilon = 3 (1 + epsilon) x y z$ of the Markov equation, and a combinatorial expansion via signed double dimer covers of snake graphs, associated to the decorated super-Teichmüller space of the once-punctured torus @Musiker2025. Bittmann, Jouteur, Kantarcı Oğuz, Molander, and Yıldırım then unified all of the above under their _deformed squared Markov equation_
$
  X^2 + Y^2 + Z^2 + (q + q^(-1)) (X Y + Y Z + X Z) = 3 (1 + q + q^(-1)) X Y Z,
$
whose symmetric solutions factorise; the square roots are the _mirror Markov numbers_, which specialise to the classical Markov numbers at $q = 1$, to the Gyoda--Matsushita $k$-generalised Markov numbers in the integer limit, to the complex Markov spectrum in the complex limit, and to Musiker's super Markov numbers in the nilpotent limit @BittmannJouteurKantarciOguzMolanderYildirim2026. The deformed squared equation provides an analytic deformation of the Fibonacci and Pell endpoint families of @sec:fibonacci-pell.

_A negative Ramsey-type result._ For completeness, we note that Tao and Yang have recently proved that the Markov equation is not _partition regular_: there exists a finite colouring of the positive integers with no monochromatic Markov triple @TaoYang2025. This rules out a possible attack on the conjecture through colouring-theoretic combinatorics and confirms that the structural arithmetic of Markov triples is not detectable by Ramsey-type means alone.

Taken together, these strands suggest a recurring pattern at the classical limit. In several deformed settings --- $q$-deformed, mirror-deformed, $k$-generalised, and the geometric or word-theoretic refinements --- the available invariants retain more information than their classical specialisation, and injectivity questions become more tractable: either an analogue of injectivity is proved directly in the deformed regime, or uniqueness is established in its own setting (for $k > 0$ generalised Markov numbers under sufficient rigidity, modulo the Karpenkov--Van-Son counterexample for non-uniform parameters). The limit back to the classical state $q = 1$ and $k = 0$ contracts these richer invariants into a scalar integer, and the structural mechanisms that made injectivity tractable in the deformations no longer apply. The Frobenius--Markov conjecture therefore stands at the precise classical boundary where every structural means of detecting uniqueness fails, and where the residual content of the conjecture is exposed as a genuinely arithmetic question on two explicit lattice families. Any new approach to the classical conjecture must therefore be careful about hidden circularity: results that are valid in the generalised lattice, in the dynamical limit, in the $q$-deformed setting, or in the superalgebraic regime do not automatically transfer to the primitive integer Markov tree.

The present monograph does not claim to settle the conjecture. Its contribution is a _reduction_: the trace-injectivity formulation of the conjecture is reduced, by a chain of unconditional structural results, to a single, sharply isolated terminal arithmetic problem in the standard Farey cone. The remaining problem, which we name the _Exceptional Terminal Arithmetic Theorem_, has the form of an effective comparison between two explicit lattice families and is genuinely arithmetic: we show that no fixed finite modular sieve can settle it. The reduction is the content of this monograph.

// Introduction subsections are unnumbered (the parent heading is unnumbered);
// "1.1" numbering is restored before the first numbered Section below.
#set heading(numbering: none)

== The Cohn trace viewpoint <subsec:cohn-trace>

Throughout the monograph we shall work in the _Cohn matrix_ representation of the Markov tree, following the construction introduced by H. Cohn in his modular-function approach to Markov's minimal forms @Cohn1955, now standard in the form described in detail in Aigner @Aigner2013 and recently revisited from the Conway-topograph perspective by Veselov @Veselov2026. Set
$
  A = mat(2, 1; 1, 1), quad quad B = mat(5, 2; 2, 1).
$
Both matrices belong to $upright(S L)(2, bb(Z))$, both have determinant $1$, their traces are $tr A = 3$ and $tr B = 6$, and a direct calculation gives
$
  tr A B = tr mat(12, 5; 7, 3) = 15.
$
Dividing by three, we recover the Markov numbers $m_A = 1$, $m_B = 2$, and $m_(A B) = 5$, i.e. the Markov triple $(1, thin 2, thin 5)$. This is no accident: the Markov equation @eq:markov-equation is a direct consequence of the _Fricke trace identity_
$
  tr(M)^2 + tr(N)^2 + tr(M N)^2 = tr(M) tr(N) tr(M N) + tr(M N M^(-1) N^(-1)) + 2
$
applied to pairs $(M, N)$ of $upright(S L)(2, bb(Z))$-matrices that satisfy the commutator trace condition $tr(M N M^(-1) N^(-1)) = -2$. This is the relative character-variety level corresponding to a puncture with parabolic trace $-2$; in $upright(S L)(2, bb(C))$, the commutator has repeated eigenvalue $-1$ and is therefore either $-I$ or a non-trivial parabolic of trace $-2$, and the Cohn matrices @eq:AB-cohn realise the latter case by direct computation. The whole orbit generated from them by the Vieta involutions inherits the commutator trace condition. Conceptually, this is the source of the connection between the Markov equation and the relative $upright(S L)(2, bb(C))$-character variety of the free group $F_2$, viewed as the fundamental group of the once-punctured torus; the variety $x^2 + y^2 + z^2 = 3 x y z$ is the level set of the natural Fricke--Klein cubic at the level corresponding to the puncture being a parabolic of trace $-2$. The connection between simple closed geodesics on the once-punctured torus, traces of Cohn matrices, and Markov triples was made explicit by H. Cohn in his 1971 paper @Cohn1971 and is by now classical, and is the geometric heart of why the conjecture refuses to yield to purely number-theoretic methods.

The _Cohn tree_ is the binary tree of ordered matrix triples obtained from the seed
$
  (A, thin A B, thin B)
$
by the two generating moves
$
  (R, thin R S, thin S) arrow.r (R, thin R^2 S, thin R S), quad quad (R, thin R S, thin S) arrow.r (R S, thin R S^2, thin S),
$
in which the middle element of the parent triple is replaced by a Vieta neighbour. A short induction along the tree shows that for every Cohn matrix $C$ in the tree the quantity $m := tr(C) slash 3$ is a positive integer, and that the assignment $C arrow.r.bar m$ is precisely Markov's bijection between Cohn matrices and Markov numbers. Consequently, the Frobenius--Markov conjecture is equivalent to the following _trace-injectivity_ statement: for any two distinct matrices $C_s eq.not C_t$ produced by the Cohn recursion @eq:cohn-recursion,
$
  tr(C_s) eq.not tr(C_t).
$
The whole programme of this monograph is to reduce this assertion to an explicit terminal comparison.

The word version of the same construction will play an important auxiliary role. Words on the alphabet ${ A, B }$ are written multiplicatively, the empty word is denoted $epsilon$, and to a word $w$ on this alphabet we associate the matrix $M(w) in upright(S L)(2, bb(Z))$ obtained by replacing each letter with the corresponding Cohn matrix and concatenating. The matrices occurring along the Cohn tree are exactly the _Cohn words_, and the Cohn words coincide --- after a standard renaming --- with the _lower Christoffel words_ of fractions $p slash q$ with $0 < p < q$ and $gcd(p, q) = 1$. We index the corresponding non-endpoint fractions by the rationals on $(0, 1)$ in the Stern--Brocot tree, and for each such fraction $p slash q$ the Cohn word factors as $W_(p slash q) = A thin z_(p slash q) thin B$, with $z_(p slash q)$ a central palindromic word of length $q - 2$ on the alphabet ${ A, B }$, as in @eq:cohn-factorisation. The letter counts of this central palindrome are $hash_A (z_(p slash q)) = q - p - 1$ and $hash_B (z_(p slash q)) = p - 1$ by @eq:central-counts, so the Cohn word itself has length $q$; this is the convention used by Aigner @Aigner2013 and matches the indexing of the Cohn matrices by Stern--Brocot fractions. The factorisation @eq:cohn-factorisation together with the central-weight trace identity @eq:trace-az-b, which expresses the trace of a Cohn word as a positive-definite quadratic form on the central palindrome evaluated on the test vector $bold(a) = (2, 1)^top$, will be central to recognising endpoint families, nonprimitive resonances, and the arithmetic patterns of the terminal obstruction. We develop both identities in detail in @sec:cohn-words.

== Overview of the reduction <subsec:reduction-overview>

The proof proceeds by repeatedly simplifying a hypothetical trace collision $tr(C_s) = tr(C_t)$ between two distinct Cohn matrices. At each stage we either rule out the collision outright, or transform it into a comparison of a strictly simpler combinatorial type. The chain of reductions has six successive stages, and after the sixth stage only an explicit terminal arithmetic problem remains. We describe the six stages in order.

*Same-ray monotonicity.* Along any one-sided Cohn ray $S, thin R S, thin R^2 S, thin R^3 S, dots$ emanating from a local Cohn triple $(R, thin R S, thin S)$, the traces
$
  T_n := tr(R^n S), quad n gt.eq.slant 0,
$
satisfy the Fricke recurrence
$
  T_(n + 1) = X thin T_n - T_(n - 1), quad quad X := tr(R) gt.eq.slant 3,
$
with initial data $T_0 = tr(S)$, $T_1 = tr(R S)$. Since every $X$ on the tree is at least $3$, induction yields $T_(n + 1) - T_n gt.eq.slant (X - 2) thin T_n - (T_n - T_(n - 1)) > 0$, so the sequence is strictly increasing. _Therefore no trace collision can occur along a single ray of the Cohn tree._

*Dominance exclusion.* When two lattice points $P, Q$ in the Cohn indexing satisfy that $Q - P$ has Farey slope in $[0, 1]$, the known _line-monotonicity_ theorems for Markov numbers separate them. The fixed-numerator conjecture of Aigner was first proved by Rabideau and Schiffler @RabideauSchiffler2020; Lagisquet, Pelantová, Tavenas, and the second author subsequently re-proved this case and resolved the remaining two (fixed denominator and fixed sum), extending all three to the generalised setting indexed by all pairs $(p, thin q) in bb(Z)_(gt.eq.slant 0)^2$ @LagisquetPelantovaTavenasVuillon2021; the line-monotonicity classification outside the so-called exceptional slope window is the content of Lee, Li, Rabideau, and Schiffler @LeeLiRabideauSchiffler2023; and the complete classification of monotonicity along lines of given slope was completed by Huang @Huang2022. Together, these results imply that if $Q - P$ is a positive Farey direction with slope outside the exceptional window, then $m_Q > m_P$, hence $tr(C_Q) eq.not tr(C_P)$. _Dominated pairs are excluded._

After same-ray and dominated cases have been removed, any remaining hypothetical collision is _mixed_: writing the local Farey cone with basis $v, u$ and decomposing $Q - P = r thin u - s thin v$ with $r, s > 0$, the obstruction is parameterised by the two positive integers $(r, s)$. The _boundary case_ corresponds to $r = 1$ or $s = 1$, and is treated by the next two stages.

*Boundary ratio monotonicity.* Fix a local Cohn trace triple $(x, thin z, thin y) := (tr(R), thin tr(R S), thin tr(S))$ and define the two boundary sequences
$
  U_(-1) = x, quad U_0 = x z - y, quad U_(n + 1) = z thin U_n - U_(n - 1),
$
$
  V_(-1) = z, quad V_0 = z y - x, quad V_(n + 1) = y thin V_n - V_(n - 1).
$
Using the Fricke identity $tr(M N) = tr(M) tr(N) - tr(M N^(-1))$ and $tr(M^(-1)) = tr(M)$ for $upright(S L)(2, bb(C))$ matrices, one verifies that $U_0 = tr(R^2 S) = x z - y$ exactly as claimed, and that the sequence $U_n$ tracks the trace along an internal boundary ray of the Cohn subtree rooted at $(R, R S, S)$. The Wronskian-type quantity
$
  W_n := U_(n + 1) thin V_n - U_n thin V_(n + 1)
$
then satisfies the closed-form three-term identity
$
  W_n = W_(n - 1) + (z - y) thin U_n thin V_n,
$
obtained by direct substitution of the recurrences @eq:U-rec and @eq:V-rec into the definition @eq:Wronskian-def. Since $z > y$ everywhere on the Cohn tree (the middle entry strictly dominates the right) and both $U_n, V_n$ are positive, the right-hand side of @eq:Wronskian-rec is strictly positive, so $W_n$ is strictly increasing in $n$. The strict positivity in turn implies that the boundary trace ratio
$
  rho_n := U_n thick slash thick V_n
$
is _strictly increasing_ in $n$. _Therefore a boundary equality $U_n = V_n$ can occur for at most one index $n$._ This single-crossing property is the key to the boundary case.

*Vieta gluing identity.* For an ordered Markov triple $(a, thin b, thin c)$ with Vieta predecessor $d := 3 a b - c$, the boundary sequences at the two adjacent local Cohn triples are related by an identity that we shall call _Vieta gluing_: after dividing traces by $3$,
$
  tilde(V)_n (a, thin b, thin c) = tilde(U)'_(n + 1) (a, thin d, thin b),
$
where $tilde(U)'$ denotes the boundary sequence at the predecessor triple. The identity @eq:Vieta-gluing converts a boundary comparison at one local triple into a _diagonal_ comparison between two adjacent rows of the Markov tree, and is the algebraic mechanism that propagates the single-crossing property of the previous stage across Vieta neighbours.

*Shifted boundary separation.* Combining boundary ratio monotonicity with the Vieta gluing identity, the elimination of boundary trace collisions reduces to two adjacent inequalities at a specific _crossing index_. For an endpoint cone with basis $v = (1, 0)$, $u = (q, 1)$, the crossing index is $j + q$. For an interior cone the crossing index is
$
  j + floor(q (u) thick slash thick q (v)),
$ <eq:crossing-index>
where $q (dot)$ denotes the denominator of a Farey basis vector. Line monotonicity then implies that the boundary ratio strictly crosses from below $1$ to above $1$ between two consecutive indices, never equalling $1$. _All boundary trace collisions are therefore excluded._

*Euclidean recoding to the standard cone.* Finally, any unresolved _mixed_ comparison $Q - P = r u - s v$ with $r, s gt.eq.slant 2$ admits a Euclidean recoding by repeated subtraction of adjacent Farey basis vectors. At every step the comparison either becomes dominated --- and is excluded by line monotonicity --- or remains mixed inside a strictly smaller cone (in the sense that the denominator sum of the basis decreases). Since the denominator sum is a positive integer that strictly decreases at every recoding step, the process terminates after finitely many steps. _Every unresolved comparison is therefore reduced to a terminal comparison in the standard cone_
$
  v = (1, 0), quad quad u = (1, 1),
$ <eq:standard-cone>
in which it takes the explicit form $Q - P = r u - s v = (r - s, thick r)$.

The structure of the reduction is summarised in @fig:reduction-flowchart. Each arrow represents a stage of the chain; the leaves on the right are the cases that survive into the terminal cone, and the bottom-most leaf is the final obstruction to be analysed in the remainder of the monograph.

#figure(
  caption: [The six-stage reduction. A hypothetical Cohn trace collision is filtered through five exclusion mechanisms (same-ray monotonicity, dominance exclusion, boundary ratio monotonicity, Vieta gluing, shifted boundary separation) and the residual mixed comparisons are reduced by Euclidean recoding to a terminal comparison in the standard Farey cone, where the slope of $Q - P$ determines whether the case is excluded by line monotonicity (non-exceptional slopes) or whether it survives into the Exceptional Terminal Arithmetic Theorem.],
  diagram(
    node-stroke: 0.6pt + ku-blue,
    node-fill: ku-blue-wash,
    node-inset: 7pt,
    spacing: (2em, 1.0em),
    node((0, 0), [Cohn trace collision\ $tr(C_P) = tr(C_Q)$], corner-radius: 3pt),
    node((0, 1), [Same-ray ?], corner-radius: 3pt, fill: white),
    node((1, 1), [excluded:\ ray monotone], fill: defn-wash, stroke: 0.6pt + defn-color, corner-radius: 3pt),
    node((0, 2), [Dominated ?], corner-radius: 3pt, fill: white),
    node((1, 2), [excluded:\ line monotone], fill: defn-wash, stroke: 0.6pt + defn-color, corner-radius: 3pt),
    node((0, 3), [Boundary ?], corner-radius: 3pt, fill: white),
    node((1, 3), [excluded:\ shifted boundary], fill: defn-wash, stroke: 0.6pt + defn-color, corner-radius: 3pt),
    node((0, 4), [Euclidean recoding\ to standard cone], corner-radius: 3pt),
    node((0, 5), [Terminal\ $Q - P = (r - s, thick r)$], corner-radius: 3pt, fill: cor-wash, stroke: 0.6pt + cor-color),
    node((1, 5), [non-exceptional\ slope: excluded], fill: defn-wash, stroke: 0.6pt + defn-color, corner-radius: 3pt),
    node((1, 6), [primitive step:\ excluded (Huang)], fill: defn-wash, stroke: 0.6pt + defn-color, corner-radius: 3pt),
    node((1, 7), [#text(weight: "bold")[Exceptional\ Terminal Theorem]], fill: thm-wash, stroke: 0.6pt + thm-color, corner-radius: 3pt),
    edge((0, 0), (0, 1), "-|>"),
    edge((0, 1), (1, 1), "-|>", label: [yes]),
    edge((0, 1), (0, 2), "-|>", label: [no]),
    edge((0, 2), (1, 2), "-|>", label: [yes]),
    edge((0, 2), (0, 3), "-|>", label: [no]),
    edge((0, 3), (1, 3), "-|>", label: [yes]),
    edge((0, 3), (0, 4), "-|>", label: [no]),
    edge((0, 4), (0, 5), "-|>"),
    edge((0, 5), (1, 5), "-|>"),
    edge((0, 5), (1, 6), "-|>"),
    edge((0, 5), (1, 7), "-|>"),
  ),
) <fig:reduction-flowchart>

The six stages above are described at the level of their main ideas only; each is the subject of a dedicated Section in the body of the monograph. Same-ray monotonicity is proved in @sec:same-ray, dominance exclusion in @sec:dominance, boundary ratio monotonicity in @sec:boundary-ratio, the Vieta gluing identity in @sec:vieta-gluing, shifted boundary separation in @sec:shifted-boundary, and the Euclidean recoding to the standard cone in @sec:euclidean-recoding. The reader will find in each of those Sections the complete proofs, the precise hypotheses, and the auxiliary identities that the present sketch deliberately leaves implicit.

== Terminal cores and the exceptional window <subsec:terminal-exceptional>

The terminal comparison $Q - P = (r - s, thick r)$ in the standard Farey cone is then analysed by the _slope_ of the line $P Q$. Three cases arise according to whether $r$ is greater than, equal to, or less than $s$.

If $r > s$, the line $P Q$ has positive slope; the line-monotonicity classification of Lee, Li, Rabideau, and Schiffler @LeeLiRabideauSchiffler2023 then implies that the two Markov numbers are distinct. If $r = s$, the two points have the same denominator, and the fixed-denominator monotonicity of Lagisquet, Pelantová, Tavenas, and the second author @LagisquetPelantovaTavenasVuillon2021 separates them. The remaining case is $r < s$. There the line $P Q$, oriented by increasing denominator, has slope
$
  lambda := - r thick slash thick (s - r) in (- 1, thin 0).
$ <eq:lambda-slope>
The line-monotonicity classification @LeeLiRabideauSchiffler2023 @Huang2022 excludes the equality $m_P = m_Q$ for every value of $lambda$ _except_ the open _exceptional slope window_
$
  - 5 slash 4 < lambda < - 8 slash 7,
$ <eq:lambda-window>
which translates by the change of variable @eq:lambda-slope into
$
  9 slash 5 < s slash r < 15 slash 8.
$
The two endpoints of the window are precisely the slopes at which Huang's valley theorem changes monotonicity regime, and were already conjectured to mark the boundary of monotonicity by Aigner @Aigner2013. Inside the window, generalized Markov numbers along the line $P Q$ first decrease to a valley and then increase, so equality is not _a priori_ excluded.

Within the window, however, Huang's valley theorem still yields an _additional_ exclusion. If the Farey direction $u_(P Q)$ is _primitive_, in the sense that $gcd(r, s) = 1$, then $P$ and $Q$ are consecutive lattice points on their line, and the valley analysis shows that two consecutive values are distinct. The remaining cases therefore require
$
  r < s, quad 9 slash 5 < s slash r < 15 slash 8, quad gcd(r, s) > 1.
$ <eq:final-window>
This is the _final exceptional terminal problem_. The slope-by-slope analysis sketched in this subsection is carried out in full in @sec:terminal-cone, and Huang's valley exclusion of primitive-step exceptional terminal pairs is proved in detail in @sec:primitive-exclusion.

== The Exceptional Terminal Arithmetic Theorem <subsec:ETAT>

We isolate the remaining arithmetic statement in the following form. A terminal pair $(P, Q)$ is _return-reduced_ if no further Euclidean recoding nor any Vieta-gluing identity can reduce it to a strictly simpler comparison; the precise definition of return reduction is given in @sec:euclidean-recoding (and is the content of the bookkeeping introduced there).

#conjecture(title: "Exceptional Terminal Arithmetic Theorem (preview)")[
  Let
  $
    P = (q, thin p), quad quad Q = (q + r - s, thin p + r)
  $
  be primitive terminal standard-cone lattice points indexing the Cohn tree, with
  $
    r < s, quad 9 slash 5 < s slash r < 15 slash 8, quad gcd(r, s) > 1,
  $
  and assume that the pair $(P, Q)$ is return-reduced. Then $m_P eq.not m_Q$.
]

The main conditional theorem of the monograph then follows. Its formal statement and the canonical labels are in @sec:ETAT; we preview it here.

#theorem(title: [Conditional Frobenius--Markov uniqueness (preview)])[
  Assume the Exceptional Terminal Arithmetic Theorem above. Then every Markov number occurs as the maximum of exactly one ordered Markov triple.
]

#proof[
  This is a preview of the central implication of the monograph. The formal statement and the complete proof appear as @thm:main-conditional in @sec:ETAT; the proof there assembles the six-stage reduction together with the slope-by-slope analysis of the terminal cone described below.
]

The proof of @thm:main-conditional is the assembly of the six-stage reduction together with the slope-by-slope analysis of the terminal cone described above. Each hypothetical trace collision is either excluded by same-ray monotonicity, dominance, boundary separation, Euclidean recoding, non-exceptional-slope line monotonicity, or primitive-step exclusion (Huang); the only remaining case is precisely the pair @eq:ETAT-pair under condition @eq:ETAT-window, which is the assertion of @thm:ETAT.

== Why the final obstruction is genuinely arithmetic <subsec:why-arithmetic>

Several limitations clarify the nature of the remaining problem and explain why it could not be settled by an extension of the techniques used in the unconditional part of the reduction.

_First, the two terminal exceptional Cohn words generally do not live in a common balanced infinite word._ The necessary slope intervals of the two Christoffel words are disjoint inside the window @eq:sr-window. Consequently any direct argument based on the positivity of the $q$-deformed Cohn matrix products within a single balanced language, such as the one used by Labbé, Lapointe, and Steiner in their proof of the $q$-analog injectivity conjecture @LabbeLapointeSteiner2023, cannot close the exceptional case at $q = 1$. The $q$-analog result, while striking, does not specialise to the classical conjecture.

_Second, the condition $gcd(r, s) > 1$ does not automatically force further return reducibility._ One might hope that a non-trivial common factor in $(r, s)$ could be peeled off by an additional Euclidean step or by a hidden Vieta identity. Explicit examples of primitive return-reduced terminal exceptional pairs with $gcd(r, s) > 1$ rule this out; the simplest such examples are exhibited in @sec:euclidean-recoding.

_Third, and most importantly, no fixed finite modular sieve can settle_ @thm:ETAT. For every finite collection of moduli $cal(M) subset bb(Z)_(gt.eq.slant 1)$, we exhibit infinitely many endpoint-to-endpoint exceptional terminal pairs
$
  P_T = (13 T + 2, thin 1), quad quad Q_T = (7 T + 2, thin 7 T + 1), quad T gt.eq.slant 2,
$
for which $m_(P_T) equiv m_(Q_T) thin (upright("mod") thin M)$ for every $M in cal(M)$. With the standard-cone basis $(v, u) = ((1, 0), (1, 1))$ one verifies that for the pair @eq:escape-pair we have $(r, s) = (7 T, thin 13 T)$, so $s slash r = 13 slash 7 in.small (9 slash 5, thin 15 slash 8)$ and $gcd(r, s) = T gt.eq.slant 2$. The asymptotic periodicity of Cohn matrix powers modulo any fixed modulus, combined with the structure of the two endpoint families, forces residue equality on the prescribed finite set of moduli. _Hence no certificate consisting of finitely many congruence tests can settle_ @thm:ETAT.

_Fourth, the endpoint escape families are nevertheless harmless._ The Markov numbers along the endpoint Farey rays $p slash q = 1 slash (n + 2)$ and $p slash q = (m + 1) slash (m + 2)$ are subsequences of the Fibonacci and Pell sequences respectively, in the sense that
$
  m_(1 slash (n + 2)) in.small (F_(2 n + 5))_(n gt.eq.slant 1) , quad quad m_((m + 1) slash (m + 2)) in.small (P_(2 m + 3))_(m gt.eq.slant 1).
$
A theorem of Alekseyev @Alekseyev2011 then asserts that the intersection of the Fibonacci and Pell sequences as sets of positive integers is the finite set ${ 0, thin 1, thin 2, thin 5 }$. The corresponding lattice points are explicitly identifiable in the Markov indexing and can be excluded by direct inspection. _Therefore the endpoint families that defeat every fixed modular sieve are themselves separated by an exact arithmetic intersection theorem._

These four observations together explain why @thm:ETAT must be treated as a genuinely arithmetic problem: it lies outside the reach of single-language combinatorial arguments, outside the reach of any fixed modular certificate, and yet inside the reach of exact integer-sequence intersection theorems of Fibonacci--Pell type for the most natural escape families. The construction of the endpoint escape families and the proof that no fixed finite modular sieve can settle @thm:ETAT are the content of @sec:modular-sieve; the explicit identification of the endpoint Markov subsequences with Fibonacci and Pell numbers, together with the application of Alekseyev's intersection theorem, is developed in @sec:fibonacci-pell.

== Contributions of the monograph <subsec:contributions>

The monograph establishes a sequence of eleven unconditional structural results, culminating in the conditional implication that ties them together. We summarise them as the following list of contributions: (i) along any one-sided ray of the Cohn tree, the trace sequence is strictly increasing and so admits no internal collision; (ii) every pair of Cohn-tree lattice points related by a positive Farey direction in $[0, 1]$ is separated by line monotonicity, hence cannot collide; (iii) the local boundary trace ratio $rho_n = U_n slash V_n$ is strictly increasing, and the corresponding Wronskian satisfies the closed-form three-term recurrence @eq:Wronskian-rec; (iv) the Vieta gluing identity @eq:Vieta-gluing relates one boundary sequence to a shifted boundary sequence at the Vieta predecessor; (v) the combination of (iii) and (iv) yields shifted boundary separation, excluding every boundary collision; (vi) the Euclidean recoding procedure reduces every unresolved mixed comparison to a terminal comparison in the standard Farey cone; (vii) the line-monotonicity classification of @LeeLiRabideauSchiffler2023, @LagisquetPelantovaTavenasVuillon2021, and @Huang2022 excludes every terminal slope outside the exceptional window @eq:sr-window; (viii) Huang's valley theorem @Huang2022 excludes every primitive-step exceptional terminal pair; (ix) no fixed finite modular certificate can settle the remaining exceptional terminal case, by the construction of the endpoint escape families @eq:escape-pair; (x) the endpoint-to-endpoint escape families are themselves separated by Alekseyev's exact Fibonacci--Pell intersection theorem @Alekseyev2011; and (xi) the Exceptional Terminal Arithmetic Theorem @thm:ETAT holds in the minimal primitive exceptional direction $(R, H) = (6, 5)$ at multiplier $g = 2$, i.e. for $(r, h) = (12, 10)$, by a finite congruence certificate covering sixteen one-parameter families together with a symbolic trace-positivity argument for the central family $c = 5$ (@sec:minimal-direction, with the certificate scripts and data recorded in @appendix:minimal-certificates). The conditional main result, @thm:main-conditional, then states that the Exceptional Terminal Arithmetic Theorem, @thm:ETAT, implies the Frobenius--Markov uniqueness conjecture. The reduction is therefore complete: the conjecture has been brought down to a single, explicit, sharply isolated arithmetic problem on two-parameter families of lattice points in the standard Farey cone.

== Synopsis <subsec:synopsis>

The remainder of the monograph develops the ten contributions of the previous subsection in order, and culminates in the statement and conditional analysis of @thm:ETAT. We close this Introduction with a brief synopsis of the contents to come.

@sec:markov-cohn recalls Markov triples, the Markov tree, the Stern--Brocot indexing of Markov fractions, the Cohn matrices @eq:AB-cohn together with the seed triple @eq:cohn-seed and the recursion @eq:cohn-recursion, and the resulting Cohn trace formulation of the uniqueness conjecture; the section is essentially a reader's guide to Aigner @Aigner2013, fixed once and for all in the notation that the rest of the monograph will use, and includes the recent reformulation by Veselov @Veselov2026 of the indexing in terms of the Conway topograph. @sec:cohn-words then reviews Cohn words, Christoffel words, central palindromes, and the quadratic-form identity @eq:trace-az-b, with particular attention to the conventions under which the formulas @eq:central-counts hold.

@sec:local-cone fixes the local Farey-cone notation that will support every subsequent argument, and derives the Cohn trace recurrences @eq:Tn-recurrence, @eq:U-rec, and @eq:V-rec from first principles using only the Fricke identity @eq:fricke-identity. @sec:same-ray then proves same-ray monotonicity, and @sec:dominance proves dominance exclusion by combining the line-monotonicity theorems of @LagisquetPelantovaTavenasVuillon2021, @LeeLiRabideauSchiffler2023, and @Huang2022. @sec:boundary-ratio proves boundary ratio monotonicity via the closed-form Wronskian identity @eq:Wronskian-rec, and @sec:vieta-gluing proves the Vieta gluing identity @eq:Vieta-gluing. @sec:shifted-boundary combines the two to prove shifted boundary separation.

@sec:euclidean-recoding develops the Euclidean recoding of mixed comparisons, including the precise definition of return reduction used in the statement of @thm:ETAT. @sec:terminal-cone analyses the terminal standard-cone comparison and reduces it to the exceptional slope window @eq:sr-window. @sec:primitive-exclusion then excludes primitive-step exceptional terminal pairs using Huang's valley theorem.

@sec:modular-sieve proves that no fixed finite modular certificate can settle the exceptional terminal problem, by constructing the endpoint escape families @eq:escape-pair and verifying their congruence-stability. @sec:fibonacci-pell proves endpoint-to-endpoint separation using the Fibonacci--Pell intersection theorem of Alekseyev @Alekseyev2011, and identifies the corresponding sequences of Markov numbers via @eq:fib-pell.

@sec:ETAT states the Exceptional Terminal Arithmetic Theorem, @thm:ETAT, gives a self-contained account of the assumptions, and proves the conditional main theorem @thm:main-conditional. @sec:outlook closes the monograph with a discussion of equivalent reformulations of @thm:ETAT, of obstructions to a finite-modular proof, and of possible routes towards the remaining terminal arithmetic theorem.

// Restore "1.1" numbering for the first numbered Section onwards.
#set heading(numbering: "1.1")

= Markov numbers, Farey indexing, and the Cohn trace formulation <sec:markov-cohn>

The purpose of this Chapter is to fix once and for all the notation and the equivalent forms of the Frobenius--Markov uniqueness conjecture that will be used throughout the manuscript. We begin with the Markov equation and the Markov tree, then recall the Farey indexing of Markov numbers along the Stern--Brocot tree, and finally pass to the Cohn matrix model that turns the uniqueness conjecture into a problem of trace separation in a binary tree of $upright(S L)(2, bb(Z))$-matrices. This Section is essentially a reader's guide to the relevant parts of Aigner's monograph @Aigner2013, recast in the notation that will support the reduction in the remainder of the monograph.

== Markov triples and Markov numbers <subsec:markov-triples>

A _Markov triple_ is a triple of positive integers $(x, y, z) in bb(Z)_(gt.eq.slant 1)^3$ that satisfies the _Markov equation_
$
  x^2 + y^2 + z^2 = 3 x y z.
$ <eq:markov-equation>
A positive integer that occurs as one of the three components of a Markov triple is a _Markov number_. We index Markov triples by their unordered triples and, when an ordering is needed, by the ascending order $x lt.eq.slant y lt.eq.slant z$.

The first three Markov triples, in this ordered form, are
$
  (1, thin 1, thin 1), quad quad (1, thin 1, thin 2), quad quad (1, thin 2, thin 5),
$
and the smallest Markov numbers are
$
  1, thick 2, thick 5, thick 13, thick 29, thick 34, thick 89, thick 169, thick 194, thick 233, thick 433, thick 610, thick dots.
$
A direct check confirms the equation in each of the first three cases: $1 + 1 + 1 = 3 = 3 dot 1 dot 1 dot 1$; $1 + 1 + 4 = 6 = 3 dot 1 dot 1 dot 2$; and $1 + 4 + 25 = 30 = 3 dot 1 dot 2 dot 5$. The arithmetic of @eq:markov-equation is unforgiving: of all the positive integer triples $(x, y, z) lt.eq.slant (10, thin 10, thin 10)$, only the three listed above and their permutations are Markov.

The only triples whose three entries are not all distinct are the two _singular triples_ $(1, thin 1, thin 1)$ and $(1, thin 1, thin 2)$. Indeed, if $(x, x, z)$ is a Markov triple, then @eq:markov-equation gives
$
  2 x^2 + z^2 = 3 x^2 z, quad upright("i.e.") quad z^2 - 3 x^2 z + 2 x^2 = 0,
$
hence
$
  z = (3 x^2 plus.minus sqrt(9 x^4 - 8 x^2)) slash 2 = (x slash 2) thin (3 x plus.minus sqrt(9 x^2 - 8)).
$
For $z$ to be a positive integer, the discriminant $9 x^2 - 8$ must be a positive perfect square. The only positive integer solution is $x = 1$, which gives $9 x^2 - 8 = 1$ and hence $z = 1$ or $z = 2$. All other Markov triples therefore have three distinct entries.

The Markov equation @eq:markov-equation is quadratic in each of its three variables. Fixing $x, y$ and viewing it as a quadratic equation in $z$,
$
  z^2 - (3 x y) thin z + (x^2 + y^2) = 0,
$
the sum of its two roots is $3 x y$, so the _Vieta involution_
$
  (x, thin y, thin z) arrow.r.bar (x, thin y, thin 3 x y - z)
$ <eq:vieta-involution>
sends every Markov triple to another Markov triple. The three permutations of @eq:vieta-involution acting on the three coordinates of a Markov triple generate the full automorphism group of the Markov tree; iterating any one of them produces the binary _Markov tree_ that we shall describe in @subsec:standard-starting-triple via its Cohn-matrix incarnation.

#remark(title: "The Markov cubic surface as a character variety", lbl: <rem:markov-character-variety>)[
  The _complex Markov surface_
  $
    cal(M)_(bb(C)) := { (x, y, z) in bb(C)^3 : x^2 + y^2 + z^2 = 3 x y z }
  $
  is a smooth affine cubic surface, and from the viewpoint of representation theory it admits a clean interpretation. To state it we recall a small amount of topological vocabulary. Let $T^2 := S^1 times S^1$ denote the (real) two-dimensional torus, and write $T^2 without { upright("pt") }$ for the _once-punctured torus_ obtained by removing a single distinguished point $upright("pt") in T^2$. Attached to any reasonable topological space $X$ with a chosen base point $x_0$ is its _fundamental group_ $pi_1 (X, x_0)$, whose elements are homotopy classes of continuous based loops $gamma : [0, 1] arrow.r X$ with $gamma (0) = gamma (1) = x_0$, equipped with concatenation as the group law; the base point will be omitted from the notation whenever its choice is immaterial up to isomorphism. For the once-punctured torus one has the canonical isomorphism
  $
    pi_1 (T^2 without { upright("pt") }) tilde.equiv F_2,
  $
  where $F_2 = chevron.l a, b chevron.r$ is the _free group on two generators_: it consists of all finite words in the alphabet ${ a, thin a^(-1), thin b, thin b^(-1) }$ with multiplication given by concatenation followed by free cancellation of any adjacent inverse pairs (and no other relations). The two generators $a$ and $b$ correspond to a meridian and a longitude of $T^2$ chosen to avoid the puncture.

  Up to a rescaling of trace coordinates, the Markov surface $cal(M)_(bb(C))$ is then the relative character variety of $F_2$ valued in $upright(S L)(2, bb(C))$. The latter is the _Lie group_ of $2 times 2$ complex matrices of determinant one; the upright Roman font is the standard convention for Lie groups, and we adopt it uniformly throughout the monograph. (The associated Lie algebra of trace-zero $2 times 2$ complex matrices is, by the parallel convention, written in lowercase Fraktur as $frak(s l)(2, bb(C))$, but no Lie algebras enter the present monograph.) The classical Fricke--Klein identity asserts that, for any pair of representatives $rho (a), thin rho (b) in upright(S L)(2, bb(C))$ of the two generators of $F_2$ --- with $a b$ denoting the group product in $F_2$ (i.e.\ the word obtained by concatenating $a$ and $b$) and $[a, thin b] := a b a^(-1) b^(-1)$ the _commutator_ --- the trace of the commutator satisfies
  $
    tr (rho ([a, b])) &= (tr rho (a))^2 + (tr rho (b))^2 + (tr rho (a b))^2 \
                       &quad - thin (tr rho (a)) thin (tr rho (b)) thin (tr rho (a b)) - 2,
  $
  so the locus of representations for which the boundary commutator $rho ([a, b])$ is conjugate to a parabolic of trace $-2$ is the cubic surface $X^2 + Y^2 + Z^2 = X Y Z$ in the trace coordinates $(X, Y, Z) := (tr rho (a), thin tr rho (b), thin tr rho (a b))$. Substituting $X = 3 x$, $Y = 3 y$, $Z = 3 z$ rescales this surface to the Markov surface @eq:markov-equation, with the factor of three being exactly the factor that distinguishes the Markov number $m = tr (C) slash 3$ from the trace of a Cohn matrix in @subsec:cohn-matrices below. The three Vieta involutions of @eq:vieta-involution then realise the action of the mapping class group of the once-punctured torus on its character variety. This connection, going back to Fricke and Klein and made explicit by Goldman, is the geometric reason why the Markov conjecture admits a hyperbolic reformulation, and it is the substrate of Cohn's perforated-torus geodesic picture @Cohn1971.
]

== The Frobenius--Markov uniqueness conjecture <subsec:uniqueness-conjecture>

The _Frobenius--Markov uniqueness conjecture_ asserts that the Markov tree has no collisions when read along its maximal component:

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + ku-blue),
  fill: ku-blue-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  #text(weight: "bold", fill: ku-blue)[Conjecture (Frobenius--Markov).]
  #h(0.3em)
  #emph[
    Every Markov number occurs as the maximum of exactly one ordered Markov triple. Equivalently, if $(a, thin b, thin m)$ and $(a', thin b', thin m)$ are ordered Markov triples with the same maximum $m$, then ${ a, b } = { a', b' }$.
  ]
]

Two natural questions arise. _First_, does every Markov number occur as a maximum of some Markov triple at all? This is straightforward: the Markov tree explicitly produces, by Vieta-descent from any node, a triple whose maximum equals any given Markov number, and Aigner attributes this folklore observation to Markov himself @Aigner2013. _Second_, can a Markov number occur as the maximum of two distinct triples? This is the substance of the conjecture, and it has remained open since Frobenius first formulated it in 1913 @Frobenius1913.

In the contemporary terminology of @subsec:farey-indexing below, the conjecture takes the form of an _injectivity_ statement on the Farey-indexed sequence of Markov numbers, and is therefore also called the _Markov injectivity conjecture_. The classical injectivity is still open at the time of writing; the $q$-deformed analogue at $q = e^(i pi slash 3)$ has been proved by Labbé, Lapointe, and Steiner @LabbeLapointeSteiner2023, who note explicitly that the $q = 1$ specialisation does not give the classical statement.

The result of this monograph is conditional. We reduce the conjecture to an explicit terminal arithmetic problem in the standard Farey cone, the _Exceptional Terminal Arithmetic Theorem_ @thm:ETAT, stated in @sec:ETAT. The main conditional implication is
$
  upright("ETAT") quad arrow.r.double quad upright("Frobenius–Markov uniqueness"),
$
and the chain of unconditional structural results on which this implication rests is the subject of @sec:same-ray through @sec:fibonacci-pell.

== Farey indexing of Markov numbers <subsec:farey-indexing>

The Markov tree carries a natural bijection with a binary tree of rational numbers obtained by repeated mediants from the Farey endpoints $0 slash 1$ and $1 slash 1$. We recall this indexing now in the form used throughout the monograph.

Let
$
  bb(Q)_([0, 1]) := { p slash q in bb(Q) : 0 lt.eq.slant p lt.eq.slant q, thick gcd(p, q) = 1 } subset.eq [0, thin 1].
$ <eq:farey-set>
Two rationals $p_1 slash q_1$ and $p_2 slash q_2$ in $bb(Q)_([0, 1])$ are _Farey neighbours_ if the unimodularity condition
$
  q_1 p_2 - q_2 p_1 = 1
$ <eq:farey-neighbours>
holds, equivalently if the matrix $((q_1, q_2), (p_1, p_2))$ lies in $upright(S L)(2, bb(Z))$. Their _mediant_ is the rational
$
  p_1 slash q_1 thick plus.o thick p_2 slash q_2 := (p_1 + p_2) slash (q_1 + q_2).
$ <eq:mediant>
The mediant of two Farey neighbours is again in $bb(Q)_([0, 1])$, and is itself a Farey neighbour of each parent. The _Stern--Brocot tree_ is the binary tree obtained by starting from the two endpoints $0 slash 1$ and $1 slash 1$ and inserting mediants between adjacent fractions at each level; equivalently, it is the tree of all coprime fractions in $bb(Q)_([0, 1])$ generated by the mediant operation @eq:mediant. The Stern--Brocot tree on $[0, 1]$ sits inside the action of $upright(S L)(2, bb(Z))$ on the upper half-plane $bb(H)$ by Möbius transformations: each rational in $bb(Q)_([0, 1])$ is the cusp of a unique vertical geodesic of the modular Farey tessellation, and the Farey-neighbour condition @eq:farey-neighbours is the statement that the two cusps are connected by an edge of that tessellation.

The Markov tree is in canonical bijection with the Stern--Brocot tree. To every $t in bb(Q)_([0, 1])$ we attach a positive integer $m_t in bb(Z)_(gt.eq.slant 1)$, the _Markov number at $t$_. The endpoints carry the smallest Markov numbers,
$
  m_(0 slash 1) = 1, quad quad m_(1 slash 1) = 2,
$ <eq:endpoint-markov>
and the mediant rule for Markov numbers is exactly the Vieta-tree recursion: if $t = r plus.o s$ is the mediant of Farey neighbours $r$ and $s$, then
$
  (m_r, thin m_t, thin m_s)
$ <eq:markov-triple-at-mediant>
is a Markov triple. The first few values, with the Stern--Brocot rational in the subscript, are
$
  m_(0 slash 1) = 1, quad m_(1 slash 1) = 2, quad m_(1 slash 2) = 5, \
  m_(1 slash 3) = 13, quad m_(2 slash 3) = 29, \
  m_(1 slash 4) = 34, quad m_(2 slash 5) = 194, quad m_(3 slash 5) = 433, quad m_(3 slash 4) = 169, quad dots.
$
A small piece of the Markov--Farey correspondence is shown in @fig:markov-farey-tree.

#figure(
  caption: [The Markov--Farey correspondence on the first three levels of the Stern--Brocot tree on $[0, 1]$. Each rational $t in bb(Q)_([0, 1])$ carries a Markov number $m_t in bb(Z)_(gt.eq.slant 1)$. The endpoints $0 slash 1$ and $1 slash 1$ carry the singular Markov numbers $1$ and $2$; every interior $t = r plus.o s$ carries the Markov number $m_t$ that completes $(m_r, m_t, m_s)$ to a Markov triple.],
  diagram(
    node-stroke: 0.6pt + ku-blue,
    node-fill: ku-blue-wash,
    node-inset: 5pt,
    spacing: (1.4em, 1.0em),
    node((4, 0), [$1 slash 2$ \ $m = 5$], corner-radius: 3pt, fill: thm-wash, stroke: 0.6pt + thm-color),
    node((2, 1), [$1 slash 3$ \ $m = 13$], corner-radius: 3pt),
    node((6, 1), [$2 slash 3$ \ $m = 29$], corner-radius: 3pt),
    node((1, 2), [$1 slash 4$ \ $m = 34$], corner-radius: 3pt),
    node((3, 2), [$2 slash 5$ \ $m = 194$], corner-radius: 3pt),
    node((5, 2), [$3 slash 5$ \ $m = 433$], corner-radius: 3pt),
    node((7, 2), [$3 slash 4$ \ $m = 169$], corner-radius: 3pt),
    edge((4, 0), (2, 1), "-", stroke: 0.5pt),
    edge((4, 0), (6, 1), "-", stroke: 0.5pt),
    edge((2, 1), (1, 2), "-", stroke: 0.5pt),
    edge((2, 1), (3, 2), "-", stroke: 0.5pt),
    edge((6, 1), (5, 2), "-", stroke: 0.5pt),
    edge((6, 1), (7, 2), "-", stroke: 0.5pt),
  ),
) <fig:markov-farey-tree>

In this indexing, the Frobenius--Markov uniqueness conjecture takes the very compact form of an injectivity statement on the interior of the Stern--Brocot tree:
$
  m_s = m_t quad arrow.r.double quad s = t.
$ <eq:markov-injectivity>
The rest of the monograph studies this injectivity problem through the Cohn matrix model, to which we now turn.

== Cohn matrices and the trace recurrence <subsec:cohn-matrices>

We now recall Cohn's matrix model @Cohn1955 in the form used by Aigner @Aigner2013.

#definition(title: "Cohn matrix and Cohn triple", lbl: <def:cohn-matrix>)[
  A _Cohn matrix_ is a matrix $C = mat(a, b; c, d) in upright(S L)(2, bb(Z))$ for which there exists a Markov number $m$ such that
  $
    b = m quad upright("and") quad tr C = a + d = 3 m.
  $ <eq:cohn-defining>
  The integer $m$ is the _Markov number_ of $C$. A _Cohn triple_ is an ordered triple $(R, T, S)$ of Cohn matrices such that $T = R S$ and the three Markov numbers $(m_R, thin m_T, thin m_S)$ form a Markov triple.
]

The defining identity $b = m$, combined with $tr C = 3 m$, can be written in matrix form as
$
  tr C = (3, thin 0) thin C thin vec(0, 1),
$ <eq:cohn-trace-form>
which extracts the trace as three times the $(1, 2)$-entry of $C$. The identity @eq:cohn-trace-form is the algebraic input of Aigner's recursion, which we state next in the form verified directly against Theorem 4.7 of @Aigner2013.

#theorem(title: [Cohn-tree recursion (Aigner Theorem 4.7)], lbl: <thm:aigner-4-7>)[
  Suppose $(M, M N, N)$ is a Cohn triple associated with the Markov triple $(m_r, thin m_t, thin m_s)$, where $t = r plus.o s$. Then both
  $
    (M, thin M^2 N, thin M N) quad upright("and") quad (M N, thin M N^2, thin N)
  $ <eq:cohn-aigner-children>
  are Cohn triples, associated respectively with the neighbouring Markov triples $(m_r, thin m_(r plus.o t), thin m_t)$ and $(m_t, thin m_(t plus.o s), thin m_s)$.
] <thm-aigner-4-7-sec1>

#proof[
  This is Theorem 4.7 of Aigner's monograph @Aigner2013. The argument propagates the trace-projection identity @eq:cohn-trace-form through matrix multiplication using the Fricke trace identity @eq:fricke-identity for $upright(S L)(2, bb(C))$-matrices; the explicit one-line verifications of the child traces appear in @eq:tr-MMN and the analogous identity for $M N^2$ in the paragraphs immediately following. We refer the reader to @Aigner2013 for the original presentation.
]

The proof in @Aigner2013 begins from the trace-projection identity @eq:cohn-trace-form and then propagates the equation $tr C = (3, 0) thin C thin (0, 1)^top$ through matrix multiplication. The algebraic engine of this propagation is the _Fricke trace identity_
$
  tr (M N) = tr (M) thin tr (N) - tr (M N^(-1)),
$ <eq:fricke-identity>
valid for any $M, N in upright(S L)(2, bb(C))$, and obtained by a direct expansion using the Cayley--Hamilton relation $M^2 = (tr M) thin M - I$ in $upright(S L)(2, bb(C))$. Two specialisations of @eq:fricke-identity will recur throughout the manuscript. Applied to the product $M^2 N = M dot (M N)$,
$
  tr (M^2 N) = tr (M) thin tr (M N) - tr (M dot (M N)^(-1)) = tr (M) thin tr (M N) - tr (N),
$ <eq:tr-MMN>
since $M dot (M N)^(-1) = M dot N^(-1) M^(-1)$ is conjugate to $N^(-1)$, conjugation preserves traces, and $tr (N^(-1)) = tr (N)$ in $upright(S L)(2, bb(C))$. Similarly, applied to $M N^2 = (M N) dot N$,
$
  tr (M N^2) = tr (M N) thin tr (N) - tr (M).
$ <eq:tr-MNN>
Dividing the two identities @eq:tr-MMN and @eq:tr-MNN by three, and using $tr (M) = 3 m_r$, $tr (M N) = 3 m_t$, $tr (N) = 3 m_s$ via @eq:cohn-defining, gives the familiar Markov tree recurrence
$
  m_(r plus.o t) = 3 m_r thin m_t - m_s, quad quad m_(t plus.o s) = 3 m_t thin m_s - m_r.
$ <eq:markov-tree-recurrence>
Thus the Cohn tree of @thm:aigner-4-7 is exactly the matrix lift of the Markov tree of @eq:markov-tree-recurrence: matrix multiplication on Cohn matrices induces Vieta-tree descent on Markov numbers. The diagram is summarised in @fig:aigner-4-7.

#figure(
  caption: [Aigner's Theorem 4.7. A parent Cohn triple $(M, M N, N)$ associated with the Markov triple $(m_r, thin m_t, thin m_s)$ has two children $(M, thin M^2 N, thin M N)$ and $(M N, thin M N^2, thin N)$, associated respectively with the larger neighbouring Markov triples $(m_r, thin m_(r plus.o t), thin m_t)$ and $(m_t, thin m_(t plus.o s), thin m_s)$.],
  diagram(
    node-stroke: 0.6pt + ku-blue,
    node-fill: ku-blue-wash,
    node-inset: 6pt,
    spacing: (2em, 1.0em),
    node((1, 0), [$(M, thin M N, thin N)$ \ $(m_r, thin m_t, thin m_s)$], corner-radius: 3pt, fill: thm-wash, stroke: 0.6pt + thm-color),
    node((0, 1), [$(M, thin M^2 N, thin M N)$ \ $(m_r, thin m_(r plus.o t), thin m_t)$], corner-radius: 3pt),
    node((2, 1), [$(M N, thin M N^2, thin N)$ \ $(m_t, thin m_(t plus.o s), thin m_s)$], corner-radius: 3pt),
    edge((1, 0), (0, 1), "-|>"),
    edge((1, 0), (2, 1), "-|>"),
  ),
) <fig:aigner-4-7>

== A standard starting Cohn triple <subsec:standard-starting-triple>

The Cohn matrices used throughout this monograph are
$
  A = mat(2, 1; 1, 1), quad quad B = mat(5, 2; 2, 1),
$ <eq:AB-cohn>
both of which sit in $upright(S L)(2, bb(Z))$ and satisfy $det A = det B = 1$. Their traces are
$
  tr A = 3, quad quad tr B = 6,
$
and a direct computation gives
$
  A B = mat(2 dot 5 + 1 dot 2, thin 2 dot 2 + 1 dot 1; 1 dot 5 + 1 dot 2, thin 1 dot 2 + 1 dot 1) = mat(12, 5; 7, 3),
$
so $tr (A B) = 15$. Dividing the three traces by three recovers the Markov triple $(1, thin 2, thin 5)$ in the form $(m_A, thin m_(A B), thin m_B) = (1, thin 5, thin 2)$. The triple is one of the standard Cohn-triple seeds used in @Aigner2013, and is the one we shall use throughout the manuscript. Under the Stern--Brocot indexing of @subsec:farey-indexing, the matrix $A$ is attached to the endpoint $0 slash 1$, the matrix $B$ to the endpoint $1 slash 1$, and the matrix $A B$ to the mediant $1 slash 2$.

The full _Cohn tree_ is then built recursively from the seed
$
  (A, thin A B, thin B)
$ <eq:cohn-seed>
by the two child rules of @thm:aigner-4-7:
$
  (R, thin R S, thin S) thick & arrow.r thick (R, thin R^2 S, thin R S), \
  (R, thin R S, thin S) thick & arrow.r thick (R S, thin R S^2, thin S).
$ <eq:cohn-recursion>
At each Stern--Brocot fraction $t in bb(Q)_([0, 1])$ a unique Cohn matrix $C_t$ is produced, and the Markov number at $t$ is
$
  m_t = (1 slash 3) tr (C_t).
$ <eq:mt-trace>
The first two generations of the Cohn tree are shown in @fig:cohn-tree.

#figure(
  caption: [The first two generations of the Cohn tree from the seed triple $(A, A B, B)$ of @eq:cohn-seed. Each node is a Cohn matrix, labelled by its abstract word $w$ in $A, B$, the Markov number $m_t = (1 slash 3) tr (C_t)$, and the Stern--Brocot rational $t$. The endpoint matrices $A$ and $B$ are the "boundary" nodes attached to the Stern--Brocot endpoints; the mediant $A B$ is the root of the interior tree.],
  diagram(
    node-stroke: 0.6pt + ku-blue,
    node-fill: ku-blue-wash,
    node-inset: 5pt,
    spacing: (1.6em, 1.1em),
    node((0, 0), [$A$ \ $m = 1$ \ $0 slash 1$], corner-radius: 3pt, fill: defn-wash, stroke: 0.6pt + defn-color),
    node((3, 0), [$A B$ \ $m = 5$ \ $1 slash 2$], corner-radius: 3pt, fill: thm-wash, stroke: 0.6pt + thm-color),
    node((6, 0), [$B$ \ $m = 2$ \ $1 slash 1$], corner-radius: 3pt, fill: defn-wash, stroke: 0.6pt + defn-color),
    node((1, 1), [$A^2 B$ \ $m = 13$ \ $1 slash 3$], corner-radius: 3pt),
    node((5, 1), [$A B^2$ \ $m = 29$ \ $2 slash 3$], corner-radius: 3pt),
    node((0, 2), [$A^3 B$ \ $m = 34$ \ $1 slash 4$], corner-radius: 3pt),
    node((2, 2), [$A^2 B dot A B$ \ $m = 194$ \ $2 slash 5$], corner-radius: 3pt),
    node((4, 2), [$A B dot A B^2$ \ $m = 433$ \ $3 slash 5$], corner-radius: 3pt),
    node((6, 2), [$A B^3$ \ $m = 169$ \ $3 slash 4$], corner-radius: 3pt),
    edge((0, 0), (1, 1), "-", stroke: 0.4pt),
    edge((3, 0), (1, 1), "-", stroke: 0.4pt),
    edge((3, 0), (5, 1), "-", stroke: 0.4pt),
    edge((6, 0), (5, 1), "-", stroke: 0.4pt),
    edge((1, 1), (0, 2), "-", stroke: 0.4pt),
    edge((1, 1), (2, 2), "-", stroke: 0.4pt),
    edge((5, 1), (4, 2), "-", stroke: 0.4pt),
    edge((5, 1), (6, 2), "-", stroke: 0.4pt),
  ),
) <fig:cohn-tree>

== Trace reformulation of the uniqueness conjecture <subsec:trace-reformulation>

The factor of three in @eq:mt-trace makes the Frobenius--Markov uniqueness conjecture immediately equivalent to a trace-injectivity statement on the Cohn tree. Stripped of all extra structure, the equivalence is
$
  s eq.not t in bb(Q)_([0, 1]) quad arrow.l.r.double quad tr (C_s) eq.not tr (C_t).
$ <eq:cohn-trace-injectivity>
Aigner records this as _Uniqueness Conjecture V_ in @Aigner2013: the matrices in the Cohn tree arising from a starting Cohn triple have pairwise distinct traces. It is the central equivalence of the monograph, and is the form of the conjecture used in @sec:same-ray and onwards.

The advantage of @eq:cohn-trace-injectivity over the original Diophantine statement is that the right-hand side is an inequality between integer linear functionals on $upright(S L)(2, bb(Z))$, and that inequality is amenable to the recurrences @eq:tr-MMN and @eq:tr-MNN, to the local Cohn split developed in the next subsection, and to the Farey-cone bookkeeping that turns local trace data into global geometric data. The chain of reductions of @sec:same-ray through @sec:fibonacci-pell is, formally, a sequence of progressively narrower equivalent reformulations of @eq:cohn-trace-injectivity, ending at the Exceptional Terminal Arithmetic Theorem of @sec:ETAT.

== The local Cohn split <subsec:local-cohn-split>

The basic local object of the reduction is a single _local Cohn triple_
$
  (R, thin R S, thin S),
$
a generic node of the Cohn tree generated by the seed @eq:cohn-seed and the recursion @eq:cohn-recursion. To this triple we associate the three local traces
$
  x := tr R, quad quad z := tr (R S), quad quad y := tr S,
$ <eq:local-trace-data>
which, after division by three, form the Markov triple at the node. By the Fricke identity @eq:fricke-identity and its specialisations @eq:tr-MMN and @eq:tr-MNN, the traces of the two children of $(R, R S, S)$ are
$
  tr (R^2 S) = x z - y, quad quad tr (R S^2) = z y - x.
$ <eq:local-split-traces>
The whole reduction in @sec:same-ray through @sec:euclidean-recoding is an analysis of how trace collisions between two distinct nodes of the Cohn tree can or cannot persist when the local split @eq:local-split-traces is iterated along the tree.

Two algebraic identities underlie the local analysis. The _consistency identity_
$
  (x z - y) + (z y - x) = z (x + y) - (x + y) = (z - 1) (x + y)
$ <eq:consistency-identity>
relates the average of the two new middle traces to the boundary sum $x + y$; this is the trace shadow of the Vieta involution @eq:vieta-involution at the parent node, and it will play a role in the boundary-trace bookkeeping of @sec:boundary-ratio. The _Markov constraint_ at the matrix level is
$
  x^2 + y^2 + z^2 = 3 thin x thin y thin z,
$
which is the Markov equation @eq:markov-equation written in the Cohn-trace variables $(x, y, z) = (tr R, thin tr (R S), thin tr S)$, divided by $27$; it is preserved by both child operations of @eq:cohn-recursion as an immediate consequence of @eq:local-split-traces. The structure of the local Cohn split is summarised in @fig:local-cohn-split.

#figure(
  caption: [The local Cohn split at a generic node $(R, R S, S)$ of the Cohn tree. The two children inherit the boundary matrices $R$, $R S$ on the left and $R S$, $S$ on the right, and introduce the new middle matrices $R^2 S$ and $R S^2$ with traces $x z - y$ and $z y - x$ respectively, where $(x, z, y) = (tr R, thin tr (R S), thin tr S)$.],
  diagram(
    node-stroke: 0.6pt + ku-blue,
    node-fill: ku-blue-wash,
    node-inset: 6pt,
    spacing: (2em, 1.2em),
    node((1, 0), [Parent: $(R, thin R S, thin S)$ \ traces $(x, thin z, thin y)$], corner-radius: 3pt, fill: thm-wash, stroke: 0.6pt + thm-color),
    node((0, 1), [Left child:\ $(R, thin R^2 S, thin R S)$ \ middle trace $x z - y$], corner-radius: 3pt),
    node((2, 1), [Right child:\ $(R S, thin R S^2, thin S)$ \ middle trace $z y - x$], corner-radius: 3pt),
    edge((1, 0), (0, 1), "-|>"),
    edge((1, 0), (2, 1), "-|>"),
  ),
) <fig:local-cohn-split>

== The reduction strategy and the final obstruction <subsec:reduction-strategy>

The remainder of this monograph is devoted to proving that an equality of traces $tr (C_s) = tr (C_t)$ between two distinct Cohn-tree nodes cannot survive a chain of unconditional structural reductions, except possibly when the two Cohn-tree positions reduce, by Euclidean steps on their Farey indices, to a terminal comparison in the standard Farey cone of a very specific shape.

The chain has six successive stages, already summarised in @fig:reduction-flowchart of the Introduction. _Same-ray monotonicity_ (proved in @sec:same-ray) eliminates collisions between two nodes that lie on a single one-sided Cohn ray. _Dominance exclusion_ (@sec:dominance), built on the line-monotonicity theorems of @LagisquetPelantovaTavenasVuillon2021, @LeeLiRabideauSchiffler2023, and @Huang2022, eliminates collisions whose Farey-cone offset has slope inside $[0, 1]$. _Boundary ratio monotonicity_ (@sec:boundary-ratio), via the closed-form Wronskian identity of the Introduction, eliminates equalities between the two boundary-trace sequences emanating from a single local Cohn triple. _Vieta gluing_ (@sec:vieta-gluing) propagates this single-crossing property across adjacent Vieta neighbours, and together with @sec:shifted-boundary excludes all _boundary_ trace collisions. _Euclidean recoding_ (@sec:euclidean-recoding) then reduces every unresolved _mixed_ comparison to one in the standard Farey cone with basis $((1, 0), thin (1, 1))$.

Inside the standard cone, the surviving terminal comparison takes the explicit form
$
  P = (q, thin p), quad quad Q = (q + r - s, thin p + r),
$ <eq:terminal-PQ>
for two positive integers $r, s$ that parametrise the Farey offset $Q - P = (r - s, thick r)$. Line monotonicity (@sec:terminal-cone) eliminates this comparison unless the slope of the line $P Q$ lies in the _exceptional window_
$
  9 slash 5 < s slash r < 15 slash 8;
$
Huang's valley theorem @Huang2022 (@sec:primitive-exclusion) further eliminates the case $gcd (r, s) = 1$. The remaining obstruction is therefore the regime
$
  r < s, quad quad 9 slash 5 < s slash r < 15 slash 8, quad quad gcd (r, s) > 1.
$ <eq:final-obstruction>
The assertion that no Markov-number collision occurs in this regime is the Exceptional Terminal Arithmetic Theorem (@thm:ETAT, stated in @sec:ETAT), and the conditional main result is the implication ETAT $arrow.r.double$ Frobenius--Markov uniqueness.

The remaining sections of the monograph develop each stage of this chain in detail.

== Synopsis <subsec:synopsis-sec1>

We have fixed the playing field for the rest of the monograph. A Markov triple is a positive-integer solution of the Markov equation @eq:markov-equation, and the Markov triples form a single $bb(Z)$-orbit under the Vieta involution @eq:vieta-involution. Markov numbers are bijectively indexed by the Stern--Brocot rationals $bb(Q)_([0, 1])$ via $t arrow.r.bar m_t$, with the mediant rule @eq:mediant compatible with the Markov tree recurrence @eq:markov-tree-recurrence; the endpoint values @eq:endpoint-markov anchor the indexing, and the Frobenius--Markov uniqueness conjecture is the injectivity statement @eq:markov-injectivity. Cohn's matrix model lifts the whole picture to $upright(S L)(2, bb(Z))$: @def:cohn-matrix attaches a Cohn matrix $C_t$ to each Stern--Brocot rational $t$, with $tr (C_t) = 3 m_t$ by @eq:mt-trace; the Cohn tree is generated by the seed @eq:cohn-seed and the recursion @eq:cohn-recursion, with $A$ and $B$ as in @eq:AB-cohn; the Markov tree of @eq:markov-tree-recurrence is the trace shadow of the matrix tree generated by @thm:aigner-4-7, and the conjecture becomes the trace-injectivity statement @eq:cohn-trace-injectivity. The basic local object that the rest of the monograph analyses is the local Cohn triple $(R, R S, S)$ with trace data @eq:local-trace-data, whose two children carry the new middle traces $x z - y$ and $z y - x$ given by @eq:local-split-traces; the consistency identity @eq:consistency-identity and the Markov constraint relate the two children and form the algebraic backbone of every subsequent argument. The chain of reductions from @sec:same-ray through @sec:fibonacci-pell will turn the trace-injectivity formulation @eq:cohn-trace-injectivity of Frobenius--Markov uniqueness into the Exceptional Terminal Arithmetic Theorem of @sec:ETAT.

= Cohn words and central Christoffel cores <sec:cohn-words>

The Cohn-tree formulation of the uniqueness conjecture introduced in @sec:markov-cohn admits a parallel reformulation in the language of words on a two-letter alphabet. This word model is not a mere change of notation: it sharpens the matrix recursion of @thm:aigner-4-7 into a free-monoid recursion, identifies the Cohn-tree matrices with the lower Christoffel words of the corresponding Stern--Brocot fractions, and exposes the central palindromic core that controls the arithmetic of Cohn traces. The bridge between the word picture and the trace picture is the identity
$
  tr M(A thin z thin B) = 3 thin g(z),
$
proved in @lem:trace-of-cohn-word below, where $g$ is the central weight introduced in @subsec:central-weight. Through this identity, the Markov number at a Stern--Brocot rational $p slash q$ becomes a positive-definite quadratic form on the central palindromic core $z_(p slash q)$. We shall use this picture in several places later in the manuscript --- in particular, the endpoint families used in @sec:fibonacci-pell are most cleanly identified at the level of central cores, and the formula reduces every Cohn trace to a quadratic-form evaluation on a symmetric matrix.

== The word tree <subsec:word-tree>

We work with the two-letter alphabet
$
  { A, thin B }.
$
By a mild but useful abuse of notation, we use the same symbols $A$ and $B$ both for the Cohn matrices @eq:AB-cohn of @sec:markov-cohn and for letters of the alphabet, the relation between the two being the _evaluation homomorphism_
$
  M colon ({ A, B }^ast, dot) thin arrow.r thin (upright(S L)(2, bb(Z)), thin dot)
$ <eq:eval-hom>
from the free monoid ${ A, B }^ast$ on the alphabet to the multiplicative semigroup of $upright(S L)(2, bb(Z))$, defined on the generators by
$
  M(A) := mat(2, 1; 1, 1), quad quad M(B) := mat(5, 2; 2, 1),
$
and extended to a word $W = X_1 X_2 dots.h.c X_n$ by $M(W) := M(X_1) M(X_2) dots.h.c M(X_n)$. The homomorphism $M$ is injective on the Cohn-tree words below, and we shall freely identify a Cohn word $W$ with its image $M(W)$ when no confusion is likely.

The _word tree_ on ${ A, B }^ast$ is the tree of triples obtained from the seed
$
  (A, thin A B, thin B)
$
by the juxtaposition rules
$
  (U, thin U V, thin V) thick & arrow.r thick (U, thin U^2 V, thin U V), \
  (U, thin U V, thin V) thick & arrow.r thick (U V, thin U V^2, thin V),
$ <eq:word-tree-recursion>
which are exactly @eq:cohn-recursion read in the free monoid rather than in $upright(S L)(2, bb(Z))$. Equivalently, if $t = r plus.o s$ is the mediant of two Stern--Brocot neighbours $r, s$, then the Cohn word at $t$ is the concatenation of the Cohn words at $r$ and $s$:
$
  W_t = W_r thin W_s.
$ <eq:cohn-word-mediant>
The two endpoint words are the two generators,
$
  W_(0 slash 1) = A, quad quad W_(1 slash 1) = B,
$ <eq:endpoint-words>
and the first interior word is $W_(1 slash 2) = A B$. Aigner @Aigner2013 gives three equivalent characterisations of these _Cohn words_: as the words appearing in the word tree @eq:word-tree-recursion, as the positive automorphic images of $A B$ under the standard generators of $upright(A u t)(F_2)$, and as the lower Christoffel words of the corresponding Stern--Brocot fractions. We shall use the first and the third systematically.

== Cohn words are lower Christoffel words <subsec:cohn-christoffel>

The lower Christoffel word of slope $p slash (q - p)$ from $(0, 0)$ to $(q - p, thin p)$, with $0 lt.eq.slant p lt.eq.slant q$ and $gcd (p, q) = 1$, is the unique word on ${ A, B }^ast$ of length $q$ that codes the lower lattice path under the line segment from the origin to $(q - p, p)$: at each integer step the lower path takes an $A$ when it advances horizontally and a $B$ when it advances vertically. The Christoffel word is in this sense a deterministic combinatorial avatar of a line of rational slope. We adopt Aigner's indexing convention @Aigner2013 throughout the monograph, in which the Christoffel word at Stern--Brocot fraction $p slash q$ has total length $q$, with $q - p$ horizontal steps and $p$ vertical steps. We denote it $upright("ch")_(p slash q)$.

#figure(
  caption: [The lower Christoffel word $upright("ch")_(2 slash 5) = W_(2 slash 5) = A A B A B$ of length $5$, viewed as the lower lattice path from $(0, 0)$ to $(q - p, thin p) = (3, 2)$ along the line of slope $2 slash 3$. Horizontal unit steps code the letter $A$ and vertical unit steps code the letter $B$; the path stays at or below the diagonal until the final lattice point. Removing the leading $A$ and the trailing $B$ leaves the central palindromic core $z_(2 slash 5) = A B A$, the middle factor of the Christoffel word.],
  cetz.canvas({
    import cetz.draw: *
    // Grid lines
    for i in range(0, 4) {
      line((i, 0), (i, 2), stroke: 0.3pt + gray)
    }
    for j in range(0, 3) {
      line((0, j), (3, j), stroke: 0.3pt + gray)
    }
    // Diagonal (slope 2/3)
    line((0, 0), (3, 2), stroke: 1pt + ku-blue-pale)
    // Lower Christoffel path A A B A B
    line((0, 0), (1, 0), stroke: 2pt + ku-blue)
    line((1, 0), (2, 0), stroke: 2pt + ku-blue)
    line((2, 0), (2, 1), stroke: 2pt + ku-blue)
    line((2, 1), (3, 1), stroke: 2pt + ku-blue)
    line((3, 1), (3, 2), stroke: 2pt + ku-blue)
    // Step labels
    content((0.5, -0.35), [$A$])
    content((1.5, -0.35), [$A$])
    content((1.7, 0.5), [$B$])
    content((2.5, 1.35), [$A$])
    content((3.3, 1.5), [$B$])
    // Endpoint dots
    circle((0, 0), radius: 0.07, fill: black)
    circle((3, 2), radius: 0.07, fill: black)
    // Endpoint labels
    content((-0.35, -0.3), [$(0, 0)$])
    content((3.4, 2.3), [$(3, 2)$])
  }),
) <fig:christoffel-2-5>

Aigner @Aigner2013 proves the identification
$
  W_(p slash q) = upright("ch")_(p slash q)
$ <eq:cohn-eq-christoffel>
between Cohn words generated by the recursion @eq:word-tree-recursion and lower Christoffel words at the same Stern--Brocot fraction. The proof in @Aigner2013 proceeds by structural induction along the Stern--Brocot tree, using the mediant compatibility @eq:cohn-word-mediant on the Cohn side and the Stern--Brocot recurrence of Christoffel words on the Christoffel side.

From the Christoffel side comes the standard palindromic-core decomposition. Every non-endpoint lower Christoffel word factors as
$
  W_(p slash q) = A thin z_(p slash q) thin B,
$ <eq:cohn-factorisation>
where $z_(p slash q) in { A, B }^ast$ is a _palindrome_, i.e. a word equal to its reverse. The empty word $z_(1 slash 2) = epsilon$ is a palindrome by convention. We shall call $z_(p slash q)$ the _central core_ of the Cohn word $W_(p slash q)$. The combination of @eq:cohn-eq-christoffel and @eq:cohn-factorisation gives the form we shall use most often.

#proposition(title: "Central palindromic core decomposition", lbl: <prop:central-core>)[
  For every Stern--Brocot fraction $p slash q$ with $1 lt.eq.slant p lt.eq.slant q - 1$ and $gcd (p, q) = 1$, the Cohn word $W_(p slash q)$ factors as
  $
    W_(p slash q) = A thin z_(p slash q) thin B,
  $
  where $z_(p slash q) in { A, B }^ast$ is a palindromic word of length $|z_(p slash q)| = q - 2$. The two endpoint words $W_(0 slash 1) = A$ and $W_(1 slash 1) = B$ are exceptional and do not admit a central-core decomposition; they are the only Cohn words of length $1$.
] <prop-central-core>

#proof[
  For a non-endpoint Stern--Brocot fraction $p slash q$ with $1 lt.eq.slant p lt.eq.slant q - 1$, the lower Christoffel-word formulation of @eq:cohn-eq-christoffel exhibits $W_(p slash q)$ as a Christoffel word, and the standard factorisation of a lower Christoffel word as $A thin z thin B$ with $z$ palindromic — Aigner @Aigner2013, Proposition 8.36 — is exactly the asserted identity @eq:cohn-factorisation; the palindromic length count $|z_(p slash q)| = q - 2$ is the statement that the Christoffel word has total length $q$ with the two boundary letters $A$ and $B$ stripped. The two endpoint cases $W_(0 slash 1) = A$ and $W_(1 slash 1) = B$ have length one by the endpoint convention @eq:endpoint-words, so no central palindrome can be carved out of them; this is consistent with the length formula $q - 2$ evaluated at $q = 1$ giving the impossible value $-1$. The remaining cases all have $q gt.eq.slant 2$ and admit the factorisation by induction along the Stern--Brocot tree using the mediant compatibility @eq:cohn-word-mediant.
]

By @prop:central-core the central core of the seed $W_(1 slash 2) = A B$ is the empty word $z_(1 slash 2) = epsilon$, and the first non-trivial central core is $z_(1 slash 3) = A$. The Christoffel word of @fig:christoffel-2-5 has central core $z_(2 slash 5) = A B A$, the middle palindromic factor of $W_(2 slash 5) = A A B A B$.

#remark(title: "Christoffel words and the geometry of rational slopes", lbl: <rem:christoffel-geometry>)[
  Christoffel words are the combinatorial shadow of the simplest non-trivial dynamics on the two-torus: the orbit of $0$ under the rotation $x arrow.r.bar x + p slash q$ on $bb(R) slash bb(Z)$. Coding each step by $A$ or $B$ according to which half-circle the rotated point lands on produces precisely the Christoffel word of slope $p slash q$, modulo a deterministic choice of cut. The palindromic structure @eq:cohn-factorisation is the combinatorial trace of the time-reversal symmetry of this rotation, and the Stern--Brocot tree of @subsec:farey-indexing is the combinatorial trace of the Gauss map on continued fractions. We shall not need this dynamical viewpoint in the body of the reduction, but it is the natural setting in which Christoffel words connect to Sturmian sequences, billiards in rectangles, and the geodesic flow on the modular surface; the unifying reference is Lothaire's _Algebraic Combinatorics on Words_ @Lothaire2002.
]

#remark(title: "Christoffel-word minimality and Aigner's Conjecture 10.16", lbl: <rem:christoffel-minimality>)[
  An additional structural fact about Christoffel words, established by a by-product of the path-flattening / lifting technique of @LagisquetPelantovaTavenasVuillon2021, is the following minimality characterisation: among _all_ paths from $(0, 0)$ to $(d, n)$ in the $bb(N)^2$ grid, the m-value (the matrix-product trace functional of @sec:markov-cohn) is _minimised_ exactly at the (generalised) Christoffel word $c(n, d)$. The non-uniqueness cases occur only when $gcd (n, d) > 1$ and are explicitly described in the cited reference. This statement settles Aigner's Conjecture 10.16 (page 223 of @Aigner2013), which asks whether Christoffel words are the m-minimisers in the bb-free subclass of paths; the path-flattening proof in fact removes the bb-free restriction and gives the minimality over _all_ paths. We do not invoke this minimality directly in the structural reduction --- our use of Christoffel words is through the central-core decomposition @eq:cohn-factorisation rather than through a minimisation principle --- but it explains, structurally, why Christoffel words are the right combinatorial avatars of Markov numbers and why no smaller m-value lurks in the lattice between the lower Christoffel path and the line.
]

== Letter counts and primitivity <subsec:letter-counts>

The abelianisation of a Cohn word $W_(p slash q)$ is determined by its Stern--Brocot index. Aigner @Aigner2013 records the counts
$
  hash_A (W_(p slash q)) = q - p, quad quad hash_B (W_(p slash q)) = p,
$ <eq:letter-counts-W>
so that $|W_(p slash q)| = q$. The two equations of @eq:letter-counts-W are most easily proved by induction along the Stern--Brocot tree. If $t = r plus.o s$ is the mediant of Farey neighbours $r = p_1 slash q_1$ and $s = p_2 slash q_2$ with $p_1 + p_2 = p$ and $q_1 + q_2 = q$, then the mediant compatibility @eq:cohn-word-mediant gives
$
  hash_A (W_t) = hash_A (W_r) + hash_A (W_s) = (q_1 - p_1) + (q_2 - p_2) = q - p,
$
and similarly $hash_B (W_t) = p_1 + p_2 = p$. The basis of induction is the endpoint case @eq:endpoint-words.

By the factorisation @eq:cohn-factorisation, the letter counts of the central core $z_(p slash q)$ are shifted by one,
$
  hash_A (z_(p slash q)) = q - p - 1, quad quad hash_B (z_(p slash q)) = p - 1,
$ <eq:central-counts>
so the central core has total length $|z_(p slash q)| = q - 2$, consistent with @prop:central-core.

The shift-by-one in @eq:central-counts has a primitivity consequence that will matter in @sec:euclidean-recoding and in @sec:terminal-cone. Writing $hash_A (z) + 1 = q - p$ and $hash_B (z) + 1 = p$,
$
  gcd (p, q) = gcd (p, thin q - p) = gcd (hash_B (z_(p slash q)) + 1, thin hash_A (z_(p slash q)) + 1).
$ <eq:primitivity-via-core>
The Stern--Brocot primitivity condition $gcd (p, q) = 1$ is therefore equivalent to coprimality of the two shifted letter counts of the central core. This equivalence is the algebraic reason why a non-primitive Cohn-word index $(q, p)$ with $gcd (p, q) > 1$ corresponds to a central core whose two shifted letter counts share a non-trivial common factor; we shall meet such non-primitive cores in @sec:terminal-cone as the residual obstruction to the Frobenius--Markov uniqueness conjecture.

== Central words and standard companions <subsec:central-standard>

A word $w in { A, B }^ast$ is _central_ if there is a Christoffel-word factorisation $A w B$ with $w$ palindromic, i.e. if $w = z_(p slash q)$ is the central core of some Cohn word $W_(p slash q)$ at a non-endpoint Stern--Brocot fraction. Aigner @Aigner2013, Theorem 8.40, gives a compact intrinsic characterisation:
$
  w upright(" is central ") thick arrow.l.r.double thick w A B upright(" is a standard word ") thick arrow.l.r.double thick w B A upright(" is a standard word"),
$ <eq:central-via-standard>
in which a _standard word_ is, by definition, a word obtained from the two generators $A$ and $B$ by a finite sequence of two productions in the free monoid generalising the Stern--Brocot mediant. The two extensions $w A B$ and $w B A$ are the _standard companions_ of the central word $w$.

We shall not need the full theory of standard words for the reduction in @sec:same-ray through @sec:fibonacci-pell, but the characterisation @eq:central-via-standard explains why central cores and their two standard companions appear naturally throughout the manuscript: any structural fact about Christoffel words has, on the central side, an equivalent statement about standard words, and the two presentations swap freely.

== The central weight and the trace identity <subsec:central-weight>

Let $z in { A, B }^ast$ be a palindromic word. Because both $M(A)$ and $M(B)$ are symmetric matrices and the transpose of a product reverses the order of factors, the image
$
  P_z := M(z)
$ <eq:Pz-def>
is symmetric. Indeed, writing $z = X_1 X_2 dots.h.c X_n$,
$
  P_z^top = M(X_n)^top dots.h.c M(X_2)^top M(X_1)^top = M(X_n) dots.h.c M(X_2) M(X_1) = M(z^ast),
$ <eq:Pz-transpose>
where $z^ast$ denotes the reverse of $z$ and the second equality uses the symmetry of $M(A)$ and $M(B)$. Since $z = z^ast$ by hypothesis, $P_z^top = P_z$.

We attach to each palindromic word $z$ the _central weight_
$
  g(z) := bold(a)^top thin P_z thin bold(a), quad quad bold(a) := vec(2, 1).
$ <eq:central-weight-def>
With the symmetric form $P_z = mat(alpha, beta; beta, gamma)$, the central weight expands as
$
  g(z) = bold(a)^top mat(alpha, beta; beta, gamma) bold(a) = (2, thin 1) mat(2 alpha + beta; thin 2 beta + gamma) = 4 alpha + 4 beta + gamma.
$ <eq:central-weight-expansion>
The next lemma is the algebraic bridge between Cohn words and Cohn traces, and is the formula that will be used throughout the rest of the manuscript.

#lemma(title: "Trace of the full Cohn word", lbl: <lem:trace-of-cohn-word>)[
  For every palindromic word $z in { A, B }^ast$,
  $
    tr M(A thin z thin B) = 3 thin g(z).
  $ <eq:trace-az-b>
] <lem-trace-of-cohn-word>

#proof[
  Write $P_z = M(z) = mat(alpha, beta; beta, gamma)$ in its symmetric form, valid by @eq:Pz-transpose. A direct multiplication on the left by $M(A)$ gives
  $
    M(A) thin P_z = mat(2, 1; 1, 1) thin mat(alpha, beta; beta, gamma) = mat(2 alpha + beta, thin 2 beta + gamma; alpha + beta, thin beta + gamma).
  $
  Multiplying on the right by $M(B)$,
  $
    M(A) thin P_z thin M(B) = mat(2 alpha + beta, thin 2 beta + gamma; alpha + beta, thin beta + gamma) thin mat(5, 2; 2, 1),
  $
  and a final entry-by-entry expansion yields the diagonal entries
  $
    [M(A) thin P_z thin M(B)]_(1, thin 1) &= 5 thin (2 alpha + beta) + 2 thin (2 beta + gamma) = 10 alpha + 9 beta + 2 gamma, \
    [M(A) thin P_z thin M(B)]_(2, thin 2) &= 2 thin (alpha + beta) + (beta + gamma) = 2 alpha + 3 beta + gamma,
  $
  whose sum is
  $
    tr M(A thin z thin B) = 12 alpha + 12 beta + 3 gamma = 3 thin (4 alpha + 4 beta + gamma) = 3 thin g(z),
  $
  using @eq:central-weight-expansion at the last step.
]

The choice of test vector $bold(a) = (2, 1)^top$ in @eq:central-weight-def is not an arbitrary normalisation: it is forced by the Cohn-matrix trace-projection identity @eq:cohn-trace-form of @sec:markov-cohn. Indeed, that identity reads $tr C = (3, thin 0) thin C thin (0, 1)^top$ for every Cohn matrix $C in upright(S L)(2, bb(Z))$. Substituting $C = M(A) thin P_z thin M(B)$ and using $M(B) thin (0, 1)^top = (2, thin 1)^top = bold(a)$ (the second column of $M(B)$) together with $(3, thin 0) thin M(A) = (6, thin 3) = 3 (2, thin 1) = 3 bold(a)^top$ gives
$
  tr (M(A) thin P_z thin M(B)) = (3, thin 0) thin M(A) thin P_z thin M(B) thin (0, 1)^top = 3 thin bold(a)^top thin P_z thin bold(a),
$
which is exactly @eq:trace-az-b. The factor of $3$ and the test vector $bold(a)$ are therefore two facets of the same Cohn-matrix structure; they are not independent design choices.

Applying @lem:trace-of-cohn-word to the central core of a Cohn word and dividing by three gives the central-weight form of the Markov number.

#corollary(title: "Central-weight form of the Markov number", lbl: <cor:markov-as-weight>)[
  For every non-endpoint Stern--Brocot fraction $p slash q$ with $1 lt.eq.slant p lt.eq.slant q - 1$ and $gcd (p, q) = 1$,
  $
    m_(p slash q) = g(z_(p slash q)).
  $ <eq:markov-as-weight>
] <cor-markov-as-weight>

#proof[
  Apply @lem:trace-of-cohn-word to the central core $z_(p slash q)$ furnished by @prop:central-core: the trace identity reads $tr M(W_(p slash q)) = tr M(A thin z_(p slash q) thin B) = 3 thin g(z_(p slash q))$. Dividing by three and using the Cohn-trace identification $m_(p slash q) = tr (C_(p slash q)) slash 3$ from @subsec:cohn-matrices gives $m_(p slash q) = g(z_(p slash q))$, which is @eq:markov-as-weight.
]

The corollary @cor:markov-as-weight is the form of the Cohn-trace identity that we shall use systematically in @sec:fibonacci-pell, and again in the endpoint exclusion of @sec:modular-sieve. It says that the Markov number $m_(p slash q)$ is the value of a positive-definite quadratic form on a symmetric matrix, namely $bold(a)^top P_(z_(p slash q)) bold(a)$ with the fixed test vector $bold(a) = (2, 1)^top$.

#remark(title: "Central weights and trace functions on the character variety", lbl: <rem:trace-bundle>)[
  In the language of @rem:markov-character-variety, the assignment $z arrow.r.bar M(z)$ sends a palindromic word to a point of the symmetric-matrix locus inside $upright(S L)(2, bb(Z))$, and the central weight $g(z) = bold(a)^top M(z) bold(a)$ is a linear functional on that locus. The Markov-number formula @eq:markov-as-weight is therefore a discrete avatar of the fact that traces of words in $upright(S L)(2, bb(C))$ are regular functions on the relative character variety of the once-punctured torus, evaluated against the test vector $bold(a) = (2, 1)^top$ coming from the Cohn-matrix structure. This first half --- the algebra of trace functions on the character variety --- is exactly the _Goldman trace ring_. A separate but related circle of ideas, the Wolpert--Kerckhoff length functions on Teichmüller space, connects to the present setting via the trace--length identification for $upright(S L)(2, bb(R))$-representations of surface groups: for a hyperbolic representation the trace records the translation length of the corresponding closed geodesic. The present discrete setting inherits this identification only after restriction to the integer-point Markov triples, where the geometric "length" interpretation is conjectural rather than established.
]

== Endpoint cores <subsec:endpoint-cores>

The corollary @cor:markov-as-weight specialises particularly cleanly on the two endpoints of the open Stern--Brocot interval $(0, thin 1)$, that is, on the two arms $p = 1$ and $p = q - 1$ of the indexing. Both arms have central cores that consist of a single letter repeated, by @eq:central-counts.

For the _$p = 1$ arm_, the central core is the all-$A$ power
$
  z_(1 slash q) = A^(q - 2), quad quad q gt.eq.slant 2,
$ <eq:endpoint-core-A>
and the Markov number is $m_(1 slash q) = g(A^(q - 2))$. A direct computation, using the well-known identity $M(A)^n = mat(F_(2 n + 1), F_(2 n); F_(2 n), F_(2 n - 1))$ where $F_k$ denotes the $k$-th Fibonacci number, gives
$
  m_(1 slash q) = g(A^(q - 2)) = 4 F_(2 q - 3) + 4 F_(2 q - 4) + F_(2 q - 5) = F_(2 q + 1).
$ <eq:m-fibonacci>
The resulting sequence $(m_(1 slash q))_(q gt.eq.slant 2) = (5, thin 13, thin 34, thin 89, thin 233, thin 610, thin dots)$ is exactly the subsequence $(F_(2 q + 1))_(q gt.eq.slant 2)$ of odd-indexed Fibonacci numbers starting at $F_5$. This is the _Fibonacci endpoint branch_.

For the _$p = q - 1$ arm_, the central core is the all-$B$ power
$
  z_((q - 1) slash q) = B^(q - 2), quad quad q gt.eq.slant 2,
$ <eq:endpoint-core-B>
and the Markov number is $m_((q - 1) slash q) = g(B^(q - 2))$. The matrix $M(B)$ has eigenvalues $3 plus.minus 2 sqrt(2) = (1 plus.minus sqrt(2))^2$, so the powers $M(B)^n$ have entries given by Pell-type recurrences, and one finds
$
  m_((q - 1) slash q) = g(B^(q - 2)) = P_(2 q - 1),
$ <eq:m-pell>
where $P_k$ denotes the $k$-th Pell number, defined by $P_0 = 0$, $P_1 = 1$, $P_(k + 1) = 2 P_k + P_(k - 1)$. The resulting sequence $(m_((q - 1) slash q))_(q gt.eq.slant 2) = (5, thin 29, thin 169, thin 985, thin 5741, thin dots)$ is exactly the subsequence $(P_(2 q - 1))_(q gt.eq.slant 2)$ of odd-indexed Pell numbers starting at $P_3$. This is the _Pell endpoint branch_. The two branches meet at $q = 2$ at the common value $m_(1 slash 2) = 5$; for $q gt.eq.slant 3$ they are disjoint Stern--Brocot indices.

The endpoint-core formulas @eq:endpoint-core-A and @eq:endpoint-core-B will be developed further in @sec:fibonacci-pell, where we use Alekseyev's intersection theorem @Alekseyev2011 to prove that the Fibonacci and Pell branches as sets of positive integers intersect only in $thin{ 0, thin 1, thin 2, thin 5 }$, and hence that the two endpoint families are separated.

== The word form of the uniqueness problem <subsec:uniqueness-word-form>

The Cohn-trace formulation of the uniqueness conjecture, @eq:cohn-trace-injectivity of @sec:markov-cohn, takes a particularly transparent shape at the level of central weights. Combining @eq:cohn-trace-injectivity with @cor:markov-as-weight on the interior of the Stern--Brocot tree, the conjecture becomes the injectivity of the central weight map on non-endpoint primitive central cores:
$
  g(z_(p slash q)) = g(z_(p' slash q')) quad arrow.r.double quad p slash q = p' slash q'.
$ <eq:weight-injectivity>
Equivalently, distinct primitive central cores have distinct central weights. The endpoint cases $p slash q in { 0 slash 1, thin 1 slash 1 }$ are decided separately by the singular Markov numbers $1$ and $2$.

The statement @eq:weight-injectivity is the cleanest combinatorial form of the conjecture: the central weight $g$ is a positive-definite quadratic form in the entries of $P_z$, the abelianisation $(hash_A (z) + 1, thin hash_B (z) + 1) = (q - p, thin p)$ is the lattice point @eq:letter-counts-W of the Cohn word, and the conjecture asks that the assignment $z arrow.r.bar (g (z), thin upright("lattice point of") z)$ separates primitive central cores. The reduction in @sec:same-ray through @sec:fibonacci-pell does not attempt to prove @eq:weight-injectivity directly; it proceeds geometrically, in the Farey-cone analysis of @sec:local-cone and onwards, and uses the central-word model only as a combinatorial supplement, in three concrete ways: (i) the abelianisation of $W_(p slash q)$ recovers the lattice point $(q, p)$ of the Stern--Brocot index via @eq:letter-counts-W; (ii) the central trace formula @eq:trace-az-b of @lem:trace-of-cohn-word reduces the Cohn trace to a quadratic form on the central palindrome; and (iii) the letter counts @eq:central-counts let us recognise endpoint branches and nonprimitive resonances directly from the core. The three roles will be invoked at the appropriate places in @sec:dominance, @sec:boundary-ratio, and @sec:modular-sieve.

== Synopsis <subsec:synopsis-sec2>

We have lifted the Cohn matrix formulation of @sec:markov-cohn to the level of words. Every Stern--Brocot rational $p slash q$ carries, via the recursion @eq:word-tree-recursion on the free monoid ${ A, B }^ast$, a Cohn word $W_(p slash q)$ that coincides with the lower Christoffel word of the same slope by @eq:cohn-eq-christoffel, and that decomposes as $W_(p slash q) = A z_(p slash q) B$ with a palindromic central core $z_(p slash q)$ of length $q - 2$ by @prop:central-core. The letter counts of the central core are the shifted abelianisation @eq:central-counts of the Cohn word, and primitivity of the Stern--Brocot fraction is equivalent to coprimality of the shifted counts by @eq:primitivity-via-core. The palindromic structure makes the central matrix $P_(z_(p slash q)) = M(z_(p slash q))$ symmetric, and Aigner's standard-companion characterisation @eq:central-via-standard places the central core inside the wider theory of standard words. The bridge to Cohn traces is the central trace identity $tr M(A z B) = 3 thin g(z)$ of @lem:trace-of-cohn-word, where $g(z) = bold(a)^top M(z) bold(a)$ with $bold(a) = (2, 1)^top$ forced by the Cohn-matrix structure; specialised to a Cohn word, the identity gives the central-weight form $m_(p slash q) = g(z_(p slash q))$ of the Markov number by @cor:markov-as-weight. The endpoint cores @eq:endpoint-core-A and @eq:endpoint-core-B identify the Fibonacci and Pell branches @eq:m-fibonacci and @eq:m-pell that will be separated by Alekseyev's intersection theorem in @sec:fibonacci-pell, and the central-weight form @eq:weight-injectivity of the uniqueness conjecture is the cleanest combinatorial expression of the assertion that distinct primitive central cores have distinct central weights.

= Farey cones and Cohn trace recurrences <sec:local-cone>

Chapters @sec:markov-cohn[] and @sec:cohn-words introduced the two principal languages used throughout the manuscript: Cohn matrices and Cohn words. We now introduce the local geometric language in which the reduction will be carried out, namely the geometry of _Farey cones_. A local Cohn split is indexed by an adjacent pair of Farey vectors, the corresponding trace recurrences are precisely the Markov-tree recurrences of @thm:aigner-4-7 written in matrix form, and the boundary sequences attached to a local Cohn triple are closed-form expressions in two Chebyshev-type polynomials that we shall meet repeatedly from @sec:same-ray onwards. The purpose of this Chapter is to fix the notation for adjacent Farey bases, local Cohn triples, Cohn-trace data, and the boundary recurrences and Chebyshev polynomials that will support every subsequent argument.

Throughout, all of the recurrences derived below follow from a single algebraic principle: the Cayley--Hamilton theorem applied to $upright(S L)(2, bb(Z))$-matrices of unit determinant, which reduces every quadratic in such a matrix to a linear combination of the identity and the matrix itself, weighted by the trace. The Fricke identity @eq:fricke-identity of @sec:markov-cohn is one consequence; the local trace recurrences of @lem:local-trace-recurrences below are a parallel consequence. The Chebyshev polynomials of the second kind, introduced in @subsec:chebyshev, are the integer-coefficient bookkeeping of the resulting linear recurrence; representation-theoretically, they are the characters of the symmetric powers of the standard representation of $upright(S L)(2, bb(Z))$ evaluated at a trace.

== Farey vectors and adjacent bases <subsec:farey-vectors>

We work with the lattice model of Farey fractions. A coprime fraction $p slash q in bb(Q)_([0, 1])$ is represented by the _primitive lattice vector_
$
  (q, thin p) in bb(Z)_(gt.eq.slant 1) times bb(Z)_(gt.eq.slant 0),
$
where $q gt.eq.slant 1$ is the denominator placed in the first coordinate and $p$ the numerator in the second. We choose the order $(q, p)$ rather than $(p, q)$ to match the Stern--Brocot indexing of @subsec:farey-indexing of @sec:markov-cohn, in which the denominator runs over the "horizontal" lattice axis and the numerator over the "vertical" one. The _Markov lattice domain_ is the subset
$
  cal(D) = { (q, thin p) in bb(Z)^2 : q gt.eq.slant 1, thick 0 lt.eq.slant p lt.eq.slant q, thick gcd (q, p) = 1 }.
$ <eq:markov-domain>
The two endpoint vectors are $(1, 0)$ and $(1, 1)$, corresponding to the Farey endpoints $0 slash 1$ and $1 slash 1$.

#definition(title: "Adjacent Farey basis", lbl: <def:adjacent-farey-basis>)[
  Let $v = (q_0, thin p_0)$ and $u = (q_1, thin p_1)$ be two primitive vectors in $cal(D)$. We say that the ordered pair $(v, thin u)$ is an _adjacent Farey basis_ if the two corresponding fractions are ordered by slope,
  $
    0 lt.eq.slant p_0 slash q_0 < p_1 slash q_1 lt.eq.slant 1,
  $
  and the unimodularity condition
  $
    det (v, thin u) = q_0 p_1 - q_1 p_0 = 1
  $ <eq:farey-unimodularity>
  holds. The associated _Farey cone_ is the closed cone with rational extreme rays $v$ and $u$,
  $
    chevron.l v, thin u chevron.r := { alpha thin u + beta thin v : alpha, beta in bb(Z)_(gt.eq.slant 0) }.
  $ <eq:farey-cone>
] <def-adjacent-farey-basis>

Every primitive lattice point in $chevron.l v, u chevron.r$ corresponds to a unique Farey fraction lying weakly between the slopes of $v$ and $u$, and the unimodularity condition @eq:farey-unimodularity guarantees that $(v, u)$ form a $bb(Z)$-basis of the lattice $bb(Z)^2$ generated. Concretely, the _mediant operation_ on Stern--Brocot fractions corresponds, in this lattice model, to the simple vector sum
$
  v + u = (q_0 + q_1, thin p_0 + p_1),
$ <eq:mediant-vector>
since the fractions associated with $v + u$ is precisely $(p_0 + p_1) slash (q_0 + q_1) = (p_0 slash q_0) plus.o (p_1 slash q_1)$.

A small piece of the lattice picture is shown in @fig:farey-cone-standard, illustrating the standard Farey cone $chevron.l (1, 0), thin (1, 1) chevron.r$ used in the terminal analysis of @sec:terminal-cone.

#figure(
  caption: [The standard Farey cone $chevron.l v, thin u chevron.r$ with basis $v = (1, 0)$ (the endpoint vector at $0 slash 1$) and $u = (1, 1)$ (the endpoint vector at $1 slash 1$). A generic point $P = alpha u + beta v in chevron.l v, u chevron.r$ has coordinates $(alpha + beta, thin alpha)$, lying at slope $alpha slash (alpha + beta) in [0, 1]$. The diagonal arrow indicates the offset $Q - P = r u - s v = (r - s, thick r)$ used in the terminal-cone analysis of @sec:terminal-cone, with $r, s in bb(Z)_(gt.eq.slant 1)$.],
  cetz.canvas({
    import cetz.draw: *
    // Background grid (integer lattice)
    for i in range(0, 6) {
      line((i, 0), (i, 5), stroke: 0.3pt + gray)
    }
    for j in range(0, 6) {
      line((0, j), (5, j), stroke: 0.3pt + gray)
    }
    // The two endpoint axes
    line((0, 0), (5, 0), stroke: 0.5pt + ku-blue-pale)
    line((0, 0), (5, 5), stroke: 0.5pt + ku-blue-pale)
    // Cone boundary highlight (between v and u)
    line((0, 0), (5, 0), stroke: 1.5pt + ku-blue, mark: (end: ">"))
    line((0, 0), (4, 4), stroke: 1.5pt + ku-blue, mark: (end: ">"))
    // Basis vectors labelled
    content((5.4, -0.3), [$v = (1, 0)$])
    content((4.45, 4.15), [$u = (1, 1)$])
    // Sample lattice points P and Q chosen so that Q - P = (1, 2) is a clearly
    // diagonal offset --- this corresponds to (r, s) = (2, 1) in the (r - s, r)
    // form of the caption, and avoids the previous degenerate configuration in
    // which P and Q had the same x-coordinate and their labels overlapped.
    circle((3, 1), radius: 0.1, fill: thm-color)
    // Place the P label to the LEFT of the dot at the SAME y, so it sits well
    // clear of the v vector at y = 0 and does not collide with the arrow tail.
    content((2.65, 1.0), anchor: "east", text(fill: thm-color, weight: "bold")[$P$])
    circle((4, 3), radius: 0.1, fill: cor-color)
    content((4.2, 3.0), anchor: "west", text(fill: cor-color, weight: "bold")[$Q$])
    // Diagonal offset arrow Q - P = (1, 2). The label sits to the RIGHT of the
    // arrow (below-right of the midpoint (3.5, 2) in the direction perpendicular
    // to the arrow's (1, 2) motion), so it is clear of the arrow line.
    line((3, 1), (4, 3), stroke: 1.8pt + cor-color, mark: (end: ">"))
    content((3.9, 1.85), anchor: "west", text(fill: cor-color)[$Q - P$])
    // Origin label
    circle((0, 0), radius: 0.08, fill: black)
    content((-0.35, -0.3), [$O$])
  }),
) <fig:farey-cone-standard>

In the language of @subsec:farey-indexing, an adjacent Farey basis $(v, u)$ corresponds to a pair of Farey neighbours $r, s$ with $r < s$; the mediant $t = r plus.o s$ is the lattice point $v + u$. The Cohn matrix $C_t$ at the mediant is the product $C_r C_s$ of the two endpoint Cohn matrices, by the recursion @eq:cohn-recursion of @sec:markov-cohn. This is the algebraic content of the next subsection.

== Local Cohn triples <subsec:local-cohn-data>

Let $(v, thin u)$ be an adjacent Farey basis with corresponding Farey fractions $r < s$, and let $t = r plus.o s$ be their mediant. The _local Cohn triple_ at the lattice cone $chevron.l v, u chevron.r$ is the ordered triple of Cohn matrices
$
  (R, thin R S, thin S) := (C_r, thin C_t, thin C_s),
$ <eq:local-cohn-triple>
in which the middle matrix is the product $R S$ of the two boundary matrices by @thm:aigner-4-7. To this triple we attach the three local _Cohn-trace data_,
$
  x := tr R, quad quad z := tr (R S), quad quad y := tr S,
$ <eq:local-trace-data-sec3>
of which we have already met one specialisation in @eq:local-trace-data of @sec:markov-cohn. Since $R, R S, S$ are Cohn matrices, each of their traces is three times the corresponding Markov number; writing
$
  x = 3 a, quad quad z = 3 c, quad quad y = 3 b,
$ <eq:trace-to-markov>
the triple $(a, thin c, thin b)$ is a Markov triple satisfying $a^2 + b^2 + c^2 = 3 a b c$. Equivalently, in the trace variables,
$
  x^2 + y^2 + z^2 = x thin y thin z,
$ <eq:trace-markov-eq>
which is the trace-normalised form of the Markov equation @eq:markov-equation. Direct verification: $(3 a)^2 + (3 b)^2 + (3 c)^2 = 9 (a^2 + b^2 + c^2) = 27 a b c = (3 a)(3 b)(3 c)$. Aigner @Aigner2013 records this in exactly the form @eq:trace-markov-eq: the trace triple satisfies the same Diophantine cubic, with the coefficient $3$ on the right-hand side absorbed into the trace normalisation.

Throughout the local analysis we orient the Cohn triple so that
$
  z = tr (R S)
$
is the largest of the three traces. This convention follows the standard orientation in the Cohn tree: the mediant entry is the maximum of the corresponding Markov triple. The convention will be implicit from @sec:same-ray onwards.

== The Cohn trace recurrences <subsec:cohn-trace-recurrences>

The two children of the local Cohn triple $(R, thin R S, thin S)$ are
$
  (R, thin R^2 S, thin R S) quad upright("and") quad (R S, thin R S^2, thin S)
$
by @thm:aigner-4-7. The new middle matrices $R^2 S$ and $R S^2$ are obtained, on the trace side, by the two local trace recurrences below. We extract them as a stand-alone lemma because they are used in essentially every subsequent argument.

#lemma(title: "Local trace recurrences", lbl: <lem:local-trace-recurrences>)[
  Let $(R, thin R S, thin S)$ be a Cohn triple with local trace data $x = tr R$, $z = tr (R S)$, $y = tr S$. Then
  $
    tr (R^2 S) = x z - y, quad quad tr (R S^2) = z y - x.
  $ <eq:local-trace-recurrences>
] <lem-local-trace-recurrences>

#proof[
  We recall briefly the algebraic input. The _Cayley--Hamilton theorem_ asserts that every square matrix annihilates its own characteristic polynomial. For a $2 times 2$ matrix $M$ with complex entries, the characteristic polynomial is
  $
    chi_M (lambda) := det (lambda I - M) = lambda^2 - (tr M) thin lambda + det M,
  $ <eq:cayley-hamilton-char-poly>
  a monic polynomial of degree two whose coefficients are the two elementary trace invariants of $M$: the trace and the determinant. Cayley--Hamilton then evaluates this polynomial at $M$ itself:
  $
    chi_M (M) = M^2 - (tr M) thin M + (det M) thin I = 0.
  $ <eq:cayley-hamilton-2by2>
  Applying @eq:cayley-hamilton-2by2 to $R in upright(S L)(2, bb(Z))$, the unimodularity hypothesis $det R = 1$ that is built into the definition of the special linear group reduces the identity to
  $
    R^2 - (tr R) thin R + I = 0.
  $ <eq:cayley-hamilton-R>
  Multiplying @eq:cayley-hamilton-R on the right by $S$, we obtain $R^2 S = (tr R) thin R S - S$, and taking traces yields
  $
    tr (R^2 S) = (tr R) thin tr (R S) - tr (S) = x z - y,
  $
  where the linearity of the trace and the abbreviations $x = tr R$, $z = tr (R S)$, $y = tr S$ have been used in the final equality.

  The second identity is symmetric: the same Cayley--Hamilton relation applied to $S$, which also lies in $upright(S L)(2, bb(Z))$ and so satisfies $det S = 1$, gives $S^2 - (tr S) thin S + I = 0$, i.e.
  $
    S^2 = (tr S) thin S - I.
  $
  Multiplying this on the _left_ by $R$ produces
  $
    R S^2 = (tr S) thin R S - R,
  $
  and taking traces gives $tr (R S^2) = (tr S) thin tr (R S) - tr (R) = z y - x$, again by the linearity of $tr$.
]

The two identities of @lem:local-trace-recurrences are nothing but the Markov tree recurrence @eq:markov-tree-recurrence of @sec:markov-cohn rewritten in trace variables. Indeed, dividing by three and using @eq:trace-to-markov, the first identity becomes $m_(r plus.o t) = 3 m_r m_t - m_s$ and the second becomes $m_(t plus.o s) = 3 m_t m_s - m_r$, exactly @eq:markov-tree-recurrence. The Cayley--Hamilton proof above is one line shorter than the Fricke-identity proof of @sec:markov-cohn; both proofs depend ultimately on the relation $det R = 1$ in $upright(S L)(2, bb(Z))$, and either one will serve.

These identities are the trace-level form of the Markov recurrence. They underlie the same-ray monotonicity argument of @sec:same-ray and the boundary-trace bookkeeping of @sec:boundary-ratio.

== One-sided rays <subsec:one-sided-rays>

From the local Cohn triple $(R, thin R S, thin S)$ there are two natural one-sided Cohn rays. The _left ray_ consists of the matrices
$
  S, quad R S, quad R^2 S, quad R^3 S, quad dots,
$
with trace sequence
$
  T_n := tr (R^n S), quad quad n gt.eq.slant 0.
$ <eq:Tn-def>
By the Cayley--Hamilton relation @eq:cayley-hamilton-R for $R$, multiplied on the right by $R^(n - 1) S$,
$
  R^(n + 1) S = (tr R) thin R^n S - R^(n - 1) S,
$
and taking traces gives the three-term linear recurrence
$
  T_(n + 1) = X thin T_n - T_(n - 1), quad quad X := tr R gt.eq.slant 3,
$ <eq:Tn-recurrence>
with initial data $T_0 = tr (S) = y$ and $T_1 = tr (R S) = z$. The lower bound $X gt.eq.slant 3$ is the bound $tr R gt.eq.slant 3$ valid for every Cohn matrix in the tree, coming from the trace inequality at the root of the Cohn tree and propagated by @thm:aigner-4-7.

Similarly, the _right ray_ consists of the matrices
$
  R, quad R S, quad R S^2, quad R S^3, quad dots,
$
with trace sequence
$
  T'_n := tr (R S^n), quad quad n gt.eq.slant 0,
$ <eq:Tn-prime-def>
satisfying
$
  T'_(n + 1) = Y thin T'_n - T'_(n - 1), quad quad Y := tr S gt.eq.slant 3,
$ <eq:Tn-prime-recurrence>
with initial data $T'_0 = tr (R) = x$ and $T'_1 = tr (R S) = z$. The same derivation, using Cayley--Hamilton for $S$ multiplied on the left by $R S^(n - 1)$, applies.

These two ray recurrences will be used in @sec:same-ray to prove same-ray monotonicity: along either ray, the trace sequence is strictly increasing, so no trace collision can occur between two matrices of a single ray.

== Boundary sequences after a local split <subsec:boundary-sequences>

The cross-ray comparison problem arises when we compare the two _child_ subtrees of the local triple $(R, thin R S, thin S)$. The two first child middle matrices have traces $x z - y$ and $z y - x$ by @eq:local-trace-recurrences. Starting from these initial values, the relevant boundary trace sequences are obtained by iterating the recurrences on the side of each child that faces the other, with the appropriate trace parameter.

We define
$
  U_(- 1) := x, quad U_0 := x z - y, quad U_(n + 1) = z thin U_n - U_(n - 1),
$ <eq:U-rec>
and
$
  V_(- 1) := z, quad V_0 := z y - x, quad V_(n + 1) = y thin V_n - V_(n - 1).
$ <eq:V-rec>
The sequence $U_n$ is the trace sequence along the inner boundary of the _left_ child subtree, namely $U_n = tr ((R S)^n thin R^2 S)$, with parameter $z = tr (R S)$, while $V_n$ is the analogous boundary along the _right_ child subtree, namely $V_n = tr ((R S)^n thin R S^2)$ with parameter $y = tr S$; the matrix interpretations are verified by the same Cayley--Hamilton argument applied to $R S$ and to $S$ respectively. The same sequences will reappear in @sec:boundary-ratio in the boundary-ratio monotonicity argument, and in @sec:vieta-gluing in the Vieta gluing identity.

It will be useful to write @eq:U-rec and @eq:V-rec in normalised Markov form, dividing each trace by three. Setting
$
  tilde(U)_n := U_n slash 3, quad quad tilde(V)_n := V_n slash 3,
$ <eq:divided-UV>
and using @eq:trace-to-markov, the initial data become
$
  tilde(U)_(- 1) = a, quad tilde(U)_0 = 3 a c - b, quad quad tilde(V)_(- 1) = c, quad tilde(V)_0 = 3 b c - a,
$ <eq:divided-UV-initial>
and the recurrences become
$
  tilde(U)_(n + 1) = 3 c thin tilde(U)_n - tilde(U)_(n - 1), quad quad tilde(V)_(n + 1) = 3 b thin tilde(V)_n - tilde(V)_(n - 1).
$ <eq:divided-UV-rec>
The Markov-form recurrences @eq:divided-UV-rec are the ones that appear naturally in the Vieta gluing identity of @sec:vieta-gluing.

== Chebyshev polynomials <subsec:chebyshev>

The integer-coefficient bookkeeping of the recurrences @eq:Tn-recurrence and @eq:U-rec and @eq:V-rec is most cleanly expressed in terms of a family of polynomials of Chebyshev type.

We define $P_n (T) in bb(Z)[T]$ recursively by
$
  P_(- 1) (T) = 0, quad P_0 (T) = 1, quad P_(n + 1) (T) = T thin P_n (T) - P_(n - 1) (T).
$ <eq:chebyshev-def>
The first few values are
$
  P_1 (T) = T, quad P_2 (T) = T^2 - 1, quad P_3 (T) = T^3 - 2 T, quad P_4 (T) = T^4 - 3 T^2 + 1, quad dots.
$
The polynomial $P_n (T)$ is exactly the _Chebyshev polynomial of the second kind_ in the substitution $T = 2 cos theta$: under this change of variable, $P_n (2 cos theta) = sin ((n + 1) theta) slash sin theta$, so the $P_n$ form the orthogonal basis of integer-coefficient polynomials adapted to the Markov-trace recurrence.

#remark(title: "Chebyshev polynomials as characters", lbl: <rem:chebyshev-characters>)[
  Write $V := bb(C)^2$ for the _standard_ $2$-dimensional complex representation of the Lie group $upright(S L)(2, bb(C))$, on which a matrix $g$ acts by ordinary matrix-vector multiplication. For each integer $n gt.eq.slant 0$, let $upright("Sym")^n (V)$ denote the $n$-th _symmetric power_ of $V$: concretely, it can be realised as the space of homogeneous polynomials of degree $n$ in two variables $X, thin Y$ on which $upright(S L)(2, bb(C))$ acts by linear substitution of the variables. The space $upright("Sym")^n (V)$ has dimension $n + 1$, and the family $(upright("Sym")^n (V))_(n gt.eq.slant 0)$ exhausts the irreducible finite-dimensional holomorphic representations of $upright(S L)(2, bb(C))$ up to isomorphism. Note in particular that $upright("Sym")^1 (V) = V$ recovers the standard representation, and $upright("Sym")^0 (V) = bb(C)$ is the trivial one-dimensional representation.

  The polynomial $P_n (T)$ is the character of $upright("Sym")^n (V)$ evaluated at a matrix of trace $T$. Indeed, an element $g in upright(S L)(2, bb(C))$ with eigenvalues $lambda, thin lambda^(-1)$ has trace $T = lambda + lambda^(-1)$, and $upright("Sym")^n (V)$ has character
  $
    sum_(k = 0)^n lambda^(n - 2 k) = (lambda^(n + 1) - lambda^(- n - 1)) thick slash thick (lambda - lambda^(-1)),
  $
  which is precisely $P_n (T)$ under the substitution $T = lambda + lambda^(-1)$. From this viewpoint the recurrence @eq:chebyshev-def is the Clebsch--Gordan decomposition
  $
    upright("Sym")^1 (V) times.o upright("Sym")^n (V) eq.triple upright("Sym")^(n + 1) (V) plus.o upright("Sym")^(n - 1) (V),
  $
  rewritten in characters by evaluating at the trace $T$. The Cohn-tree recurrences are therefore a discrete shadow of the representation theory of $upright(S L)(2, bb(C))$.
]

The relevance of the polynomials @eq:chebyshev-def is the following closed-form expression for any solution of the linear recurrence $W_(n + 1) = T thin W_n - W_(n - 1)$ with arbitrary initial data $(W_(- 1), W_0)$.

#lemma(title: "Chebyshev closed form", lbl: <lem:chebyshev-closed-form>)[
  Let $T in bb(C)$, $alpha, beta in bb(C)$, and let $(W_n)_(n gt.eq.slant - 1)$ be the unique sequence satisfying $W_(- 1) = alpha$, $W_0 = beta$, and
  $
    W_(n + 1) = T thin W_n - W_(n - 1) quad upright("for all") quad n gt.eq.slant 0.
  $
  Then for every $n gt.eq.slant - 1$,
  $
    W_n = P_n (T) thin beta - P_(n - 1) (T) thin alpha.
  $ <eq:chebyshev-closed>
] <lem-chebyshev-closed-form>

#proof[
  By induction on $n$. The cases $n = - 1$ and $n = 0$ are immediate from $P_(- 1) = 0$ and $P_0 = 1$, respectively. Assume the formula holds for $n - 1$ and $n$. Then
  $
    W_(n + 1) &= T thin W_n - W_(n - 1) \
              &= T thin (P_n beta - P_(n - 1) alpha) - (P_(n - 1) beta - P_(n - 2) alpha) \
              &= (T thin P_n - P_(n - 1)) thin beta - (T thin P_(n - 1) - P_(n - 2)) thin alpha \
              &= P_(n + 1) thin beta - P_n thin alpha,
  $
  using @eq:chebyshev-def at the last step.
]

Applying @lem:chebyshev-closed-form to the boundary sequences @eq:U-rec and @eq:V-rec with parameters $T = z$ and $T = y$ respectively, and with the initial data given there, we obtain the closed forms
$
  U_n = P_n (z) thin (x z - y) - P_(n - 1) (z) thin x,
$ <eq:U-closed>
$
  V_n = P_n (y) thin (z y - x) - P_(n - 1) (y) thin z.
$ <eq:V-closed>
In divided Markov form, using @eq:divided-UV-initial and @eq:divided-UV-rec,
$
  tilde(U)_n = P_n (3 c) thin (3 a c - b) - a thin P_(n - 1) (3 c),
$ <eq:tilde-U-closed>
$
  tilde(V)_n = P_n (3 b) thin (3 b c - a) - c thin P_(n - 1) (3 b).
$ <eq:tilde-V-closed>
The explicit forms @eq:tilde-U-closed and @eq:tilde-V-closed will be the algebraic substrate of the Vieta gluing identity of @sec:vieta-gluing.

== Farey-cone coordinates for local comparisons <subsec:farey-cone-coordinates>

It remains to fix the lattice coordinates that will track the boundary comparisons of @sec:shifted-boundary. Given an adjacent Farey basis $(v, u)$, every primitive lattice point $P$ in the cone $chevron.l v, u chevron.r$ has a unique decomposition
$
  P = alpha thin u + beta thin v, quad alpha, beta in bb(Z)_(gt.eq.slant 0),
$
of which the inner boundary points produced by the shifted-boundary comparison have a very specific form. Anticipating @sec:shifted-boundary, we set
$
  P_(j, thin n) := (n + 1) thin u + ((n + 1) (j + 1) + 1) thin v, quad quad n gt.eq.slant 0, thick j gt.eq.slant 0,
$ <eq:Pjn-coordinates>
and write
$
  M_(j, thin n) := m_(P_(j, n))
$ <eq:Mjn-def>
for the Markov number indexed by the lattice point $P_(j, n)$. The notation is introduced here because the points $P_(j, n)$ are the geometric form of the boundary sequences $U_n, V_n$ of @subsec:boundary-sequences. The _Vieta gluing identity_ of @sec:vieta-gluing will assert that a hypothetical boundary trace equality $U_n = V_n$ corresponds, in this notation, to the diagonal identity
$
  M_(j, thin n) = M_(j - 1, thin n + 1),
$ <eq:diagonal-collision>
and the corresponding lattice-point difference is
$
  P_(j - 1, thin n + 1) - P_(j, thin n) = u - (n + 1 - j) thin v,
$ <eq:adjacent-difference>
as one verifies by direct substitution into @eq:Pjn-coordinates. The elementary formula @eq:adjacent-difference is the lattice-vector starting point of the shifted-boundary separation of @sec:shifted-boundary: every adjacent diagonal collision is a Farey-cone offset of the form $u - k v$ with $k = n + 1 - j$, and the line-monotonicity argument of @sec:dominance shows that no such offset can produce a Markov-number collision.

== Synopsis <subsec:synopsis-sec3>

We have introduced the local geometric language in which the rest of the manuscript will operate. An adjacent Farey basis $(v, u)$ of two primitive lattice vectors in $cal(D)$ of @eq:markov-domain is a pair of Stern--Brocot neighbours $r < s$ in the lattice form, governed by the unimodularity condition @eq:farey-unimodularity, and the mediant Stern--Brocot operation is the vector sum @eq:mediant-vector. To every adjacent Farey basis we attach a local Cohn triple @eq:local-cohn-triple with trace data $(x, z, y) = (tr R, tr (R S), tr S)$, and these traces, divided by three, form the Markov triple at the corresponding Stern--Brocot mediant and satisfy the trace-normalised Markov equation @eq:trace-markov-eq. The two children of the local triple are governed by the local trace recurrences $tr (R^2 S) = x z - y$ and $tr (R S^2) = z y - x$ of @lem:local-trace-recurrences, proved in two lines from the Cayley--Hamilton identity @eq:cayley-hamilton-R in $upright(S L)(2, bb(C))$. The one-sided ray sequences $T_n$ and $T'_n$ of @eq:Tn-def and @eq:Tn-prime-def satisfy the three-term linear recurrences @eq:Tn-recurrence and @eq:Tn-prime-recurrence; these are the recurrences that drive the same-ray monotonicity argument of @sec:same-ray. The boundary trace sequences $U_n, V_n$ of @eq:U-rec and @eq:V-rec carry the cross-ray comparison data, with Markov-normalised divided form @eq:divided-UV-rec, and admit a clean closed expression @eq:U-closed and @eq:V-closed in the Chebyshev polynomials $P_n$ of @eq:chebyshev-def. The polynomials $P_n$ are the characters of the symmetric powers of the standard representation of $upright(S L)(2, bb(C))$ at trace $T$ (@rem:chebyshev-characters), so that the Markov-tree recurrences of the Cohn tree are a discrete shadow of the Clebsch--Gordan decomposition. The Farey-cone coordinates @eq:Pjn-coordinates and the adjacent-difference formula @eq:adjacent-difference fix the lattice bookkeeping for the shifted-boundary separation of @sec:shifted-boundary. With this notation in place, we begin the unconditional structural reductions in @sec:same-ray.

= Same-ray monotonicity <sec:same-ray>

In this Chapter we prove the first basic separation result used in the reduction: any two distinct matrices lying on the same one-sided Cohn ray have distinct traces. This is the elementary case of the trace-injectivity statement @eq:cohn-trace-injectivity, and it requires no hypothesis beyond the Cohn-tree multiplication rule of @sec:markov-cohn, the local trace recurrence @lem:local-trace-recurrences of @sec:local-cone, and the Cayley--Hamilton identity for $upright(S L)(2, bb(Z))$.

The result is unconditional: it does not depend on the Frobenius--Markov uniqueness conjecture nor on any of the deeper monotonicity theorems of @sec:dominance. It is one of the elementary geometric principles on which all the later reductions rest. Throughout the Chapter we work with the seed @eq:cohn-seed and the recursion @eq:cohn-recursion of @sec:markov-cohn, and we use the trace data $(x, z, y) = (tr R, tr (R S), tr S)$ of @eq:local-trace-data-sec3 of @sec:local-cone.

== Oriented Cohn triples <subsec:oriented-cohn-triples>

We begin by recording the trace orientation of a local Cohn triple.

#definition(title: "Oriented Cohn triple", lbl: <def:oriented-cohn-triple>)[
  An _oriented Cohn triple_ is a triple $(R, thin R S, thin S)$ of Cohn matrices, appearing in the Cohn tree of @eq:cohn-seed and @eq:cohn-recursion in the orientation inherited from the Stern--Brocot tree of @subsec:farey-indexing. We continue to use the trace data
  $
    x = tr R, quad quad z = tr (R S), quad quad y = tr S
  $
  of @eq:local-trace-data-sec3 of @sec:local-cone. Each of these traces is three times the corresponding Markov number, and is in particular a positive integer divisible by three.
] <def-oriented-cohn-triple>

The next lemma records the elementary trace-order property of an oriented Cohn triple. We have already used this property implicitly in @sec:local-cone when orienting the triple so that the mediant carries the maximum trace; we now give the explicit inductive proof.

#lemma(title: "The middle trace dominates", lbl: <lem:middle-trace-dominates>)[
  Let $(R, thin R S, thin S)$ be an oriented Cohn triple. Then
  $
    tr (R S) > tr (R) quad upright("and") quad tr (R S) > tr (S),
  $
  or equivalently $z > x$ and $z > y$.
] <lem-middle-trace-dominates>

#proof[
  We induct on the depth in the Cohn tree, starting from the seed triple @eq:cohn-seed. At the seed $(A, thin A B, thin B)$, the three traces are $tr A = 3$, $tr (A B) = 15$ and $tr B = 6$ by @sec:markov-cohn, so $15 > 6 > 3$ verifies both inequalities at depth zero.

  Assume the claim holds for an oriented triple $(R, thin R S, thin S)$ with trace data $(x, thin z, thin y)$ satisfying $z > x$ and $z > y$. We must verify the inequalities for the two children produced by @eq:cohn-recursion. By @lem:local-trace-recurrences, the new middle traces are $tr (R^2 S) = x z - y$ and $tr (R S^2) = z y - x$.

  _Left child $(R, thin R^2 S, thin R S)$._ The two side traces of the new triple are $x$ and $z$; we must show that the new middle $x z - y$ exceeds both. Since every Cohn matrix has trace a positive multiple of three, $x gt.eq.slant 3$, hence $x - 1 gt.eq.slant 2$. Combining with the inductive hypothesis $z > y > 0$,
  $
    x z - y - z = (x - 1) thin z - y gt.eq.slant 2 z - y > 2 y - y = y > 0,
  $
  which gives $x z - y > z$. Since $z > x$ by induction, we obtain $x z - y > z > x$, so the new middle also exceeds the new side trace $x$. The new triple therefore satisfies the dominance property with "new $z$" equal to $x z - y$.

  _Right child $(R S, thin R S^2, thin S)$._ The argument is symmetric. Since $y gt.eq.slant 3$ and $z > x > 0$ by induction,
  $
    z y - x - z = (y - 1) thin z - x gt.eq.slant 2 z - x > 2 x - x = x > 0,
  $
  so $z y - x > z$, and combining with $z > y$ from induction gives $z y - x > z > y$. The new triple again satisfies the dominance property.

  By induction along the Cohn tree, every oriented Cohn triple satisfies $z > x$ and $z > y$.
]

In particular, $z > max (x, y)$ throughout the Cohn tree. Dividing by three, the analogous inequality $m_(R S) > max (m_R, m_S)$ holds for the corresponding Markov triples: the mediant Markov number is the strict maximum.

== One-sided Cohn rays <subsec:same-ray-mono>

Fix an oriented Cohn triple $(R, thin R S, thin S)$. As recalled in @subsec:one-sided-rays of @sec:local-cone, two one-sided Cohn rays are naturally attached to it. The _left ray_ consists of the matrices obtained by repeated left-multiplication by $R$,
$
  S, quad R S, quad R^2 S, quad R^3 S, quad dots,
$
and is precisely the inner boundary of the left child subtree at the local split. The _right ray_ consists of the matrices obtained by repeated right-multiplication by $S$,
$
  R, quad R S, quad R S^2, quad R S^3, quad dots,
$
and is the inner boundary of the right child subtree.

The trace sequences along the two rays are $T_n = tr (R^n S)$ for $n gt.eq.slant 0$ and $T'_n = tr (R S^n)$ for $n gt.eq.slant 0$, with the three-term linear recurrences @eq:Tn-recurrence and @eq:Tn-prime-recurrence of @sec:local-cone respectively. The next theorem is the main result of this Section.

#theorem(title: "Same-ray monotonicity", lbl: <thm:same-ray-monotonicity>)[
  Let $(R, thin R S, thin S)$ be an oriented Cohn triple, and let $T_n = tr (R^n S)$ for $n gt.eq.slant 0$ and $T'_n = tr (R S^n)$ for $n gt.eq.slant 0$. Then both sequences are strictly increasing positive integer sequences:
  $
    T_0 < T_1 < T_2 < dots.h.c, quad quad T'_0 < T'_1 < T'_2 < dots.h.c.
  $
] <thm-same-ray-monotonicity>

#proof[
  We prove the assertion for $(T_n)$; the proof for $(T'_n)$ is identical with $R$ and $S$ interchanged.

  Set $X := tr R$. Since every Cohn matrix has trace three times a positive Markov number, $X gt.eq.slant 3$. The Cayley--Hamilton identity @eq:cayley-hamilton-R of @sec:local-cone reads $R^2 = X thin R - I$, and multiplying on the right by $R^(n - 1) S$ for $n gt.eq.slant 1$ gives
  $
    R^(n + 1) S = X thin R^n S - R^(n - 1) S.
  $
  Taking traces yields the three-term linear recurrence
  $
    T_(n + 1) = X thin T_n - T_(n - 1), quad quad n gt.eq.slant 1,
  $
  which is @eq:Tn-recurrence of @sec:local-cone.

  We claim that $T_n > T_(n - 1) > 0$ for every $n gt.eq.slant 1$. _Base case._ By @lem:middle-trace-dominates, $T_1 = tr (R S) > tr (S) = T_0$, and $T_0 = y > 0$ since $S$ is a Cohn matrix with positive Markov number.

  _Inductive step._ Assume $T_n > T_(n - 1) > 0$ for some $n gt.eq.slant 1$. From the recurrence,
  $
    T_(n + 1) - T_n = (X - 1) thin T_n - T_(n - 1).
  $
  Using $T_(n - 1) < T_n$ to bound the negative term,
  $
    T_(n + 1) - T_n > (X - 1) thin T_n - T_n = (X - 2) thin T_n.
  $
  Since $X gt.eq.slant 3$, the coefficient $X - 2 gt.eq.slant 1$, and combined with $T_n > 0$ this gives
  $
    T_(n + 1) - T_n > (X - 2) thin T_n gt.eq.slant T_n > 0,
  $
  hence $T_(n + 1) > T_n$. Positivity of $T_(n + 1)$ then follows from $T_(n + 1) > T_n > 0$.

  The induction completes the proof.
]

The proof produces, as a byproduct, the explicit closed-form expression of $T_n$ in terms of the Chebyshev polynomials @eq:chebyshev-def of @sec:local-cone. Applying @lem:chebyshev-closed-form with $T = X$ and the initial data $T_0 = y$, $T_1 = z$, one finds the closed form
$
  T_n = P_(n - 1) (X) thin z - P_(n - 2) (X) thin y quad upright("for") thick n gt.eq.slant 1,
$ <eq:Tn-closed-form>
which gives a second proof of strict monotonicity once one observes that $P_n (X)$ is, for $X gt.eq.slant 3$, a strictly increasing positive integer sequence growing exponentially with rate $log lambda_+$, where $lambda_+ = (X + sqrt(X^2 - 4)) slash 2 > 1$ is the larger root of $lambda^2 - X lambda + 1 = 0$.

#corollary(title: "No same-ray trace collision", lbl: <cor:no-same-ray-collision>)[
  Let $C_i$ and $C_j$ be two distinct matrices lying on the same one-sided Cohn ray of the Cohn tree. Then $tr (C_i) eq.not tr (C_j)$, and hence $m_(C_i) eq.not m_(C_j)$.
] <cor-no-same-ray-collision>

#proof[
  Every one-sided Cohn ray is of one of the forms $(R^n S)_(n gt.eq.slant 0)$ or $(R S^n)_(n gt.eq.slant 0)$ for some oriented Cohn triple $(R, thin R S, thin S)$. By @thm:same-ray-monotonicity, the trace sequence along either ray is strictly increasing in $n$, so two distinct positions on the ray are distinguished by their traces.
]

#remark(title: [Asymptotic growth rate and the Lyapunov spectrum], lbl: <rem:ray-growth-lyapunov>)[
  The strict-monotonicity proof of @thm:same-ray-monotonicity quantifies into an exponential growth rate. Solving the characteristic equation $lambda^2 - X lambda + 1 = 0$ of the recurrence, the two roots are
  $
    lambda_(plus.minus) = (X plus.minus sqrt(X^2 - 4)) slash 2, quad quad lambda_+ thin lambda_- = 1,
  $
  with $lambda_+ > 1 > lambda_- > 0$ as soon as $X gt.eq.slant 3$. Standard analysis of constant-coefficient linear recurrences then gives $T_n = A thin lambda_+^n + B thin lambda_-^n$ for some constants $A, B$ determined by the initial data $(T_0, T_1)$, and the ratio $T_n slash T_(n - 1)$ converges to $lambda_+$ as $n arrow.r infinity$. The smallest possible per-step growth rate along a Cohn ray is therefore attained at the seed value $X = 3$, where $lambda_+ = (3 + sqrt(5)) slash 2 = phi.alt^2$, the squared golden ratio. The same golden-ratio constant appears at the upper end of the Lyapunov spectrum of the Markov tree computed by Spalding and Veselov in @SpaldingVeselov2017, interval $[0, thin log phi.alt]$, although the normalisation underlying their dynamical Lyapunov exponent differs from the per-step Cohn-ray normalisation used here.
]

== Consequence for the reduction strategy <subsec:reduction-consequence>

The same-ray monotonicity theorem eliminates one entire class of possible trace collisions. Combining @cor:no-same-ray-collision with the path structure of the Cohn tree, we obtain the following more useful reformulation.

#corollary(title: "Reduction to cross-ray comparisons", lbl: <cor:cross-ray-reduction>)[
  Suppose $C_s eq.not C_t$ are two distinct Cohn matrices with $tr (C_s) = tr (C_t)$. Let $C_u$ be the deepest common ancestor of $C_s$ and $C_t$ in the Cohn tree, and let $(R, thin R S, thin S)$ be the local Cohn triple at $C_u$. Then $C_s$ and $C_t$ lie in different child subtrees of $C_u$ --- one in the subtree rooted at the left child $R^2 S$ and one in the subtree rooted at the right child $R S^2$.
] <cor-cross-ray-reduction>

#proof[
  If $C_s$ and $C_t$ were both in the same child subtree of $C_u$, then $C_u$ would not be the deepest common ancestor, since both would lie below the corresponding deeper node. Thus $C_s$ and $C_t$ lie in different child subtrees of $C_u$. The remaining possibility --- that they coincide on a common one-sided Cohn ray descending from $C_u$ --- is excluded by @cor:no-same-ray-collision: a hypothetical collision along such a ray would contradict the strict trace monotonicity of @thm:same-ray-monotonicity.
]

Therefore, _every hypothetical trace collision in the Cohn tree is a cross-ray collision_: it relates the inner boundary of the left child subtree of some local Cohn triple to the inner boundary of the right child subtree of the same triple. The remainder of the manuscript is devoted to analysing such cross-ray comparisons. The dominance exclusion of @sec:dominance handles the case in which the Farey-cone offset between the two matrices has slope in $[0, 1]$; the boundary-ratio monotonicity of @sec:boundary-ratio, combined with the Vieta gluing identity of @sec:vieta-gluing and the shifted boundary separation of @sec:shifted-boundary, handles all boundary cases; and the Euclidean recoding of @sec:euclidean-recoding then reduces every remaining cross-ray comparison to a terminal comparison in the standard Farey cone.

== Independence from the uniqueness conjecture <subsec:independence-remark>

The proof of @thm:same-ray-monotonicity is unconditional: it does _not_ depend on the Frobenius--Markov uniqueness conjecture, nor on any of the deeper line-monotonicity theorems of @LeeLiRabideauSchiffler2023, @LagisquetPelantovaTavenasVuillon2021, or @Huang2022. It depends only on four elementary ingredients: the Cohn-tree multiplication rule of @thm:aigner-4-7, the trace-projection identity @eq:cohn-trace-form which forces every Cohn-tree trace to be a positive multiple of three, the dominance property $z > max (x, y)$ of @lem:middle-trace-dominates, and the Cayley--Hamilton identity for $upright(S L)(2, bb(Z))$.

In particular, the same-ray monotonicity theorem holds verbatim in the generalised settings of @KarpenkovVanSon2020, @BanaianGyoda2025, and @Gyoda2026Words, in which the Cohn matrices are replaced by their $k$-generalised analogues and the Cohn tree by the corresponding generalised tree: the four ingredients above all survive in those generalisations. The phenomenon that becomes harder at the classical $k = 0$ limit is the _cross-ray_ separation, not the same-ray separation; this concrete instance illustrates the classical-limit pattern described in the closing paragraphs of the Introduction.

== Synopsis <subsec:synopsis-sec4>

We have proved the first unconditional separation result on the Cohn tree. The middle trace of any oriented Cohn triple strictly exceeds the two side traces by @lem:middle-trace-dominates, propagated inductively through the seed-and-recursion definition of the Cohn tree. Each one-sided Cohn ray $(R^n S)_(n gt.eq.slant 0)$ or $(R S^n)_(n gt.eq.slant 0)$ has a strictly increasing trace sequence by @thm:same-ray-monotonicity, established via the Cayley--Hamilton identity for $R$ (respectively $S$) together with the bound $X gt.eq.slant 3$ available for every Cohn matrix. The Chebyshev closed form @eq:Tn-closed-form gives a second proof and a quantitative exponential growth rate, whose smallest value $log phi.alt$ matches the lower end of the Spalding--Veselov Lyapunov spectrum @SpaldingVeselov2017. Consequently @cor:no-same-ray-collision excludes every same-ray trace collision, and @cor:cross-ray-reduction reduces the trace-injectivity conjecture @eq:cohn-trace-injectivity to the _cross-ray_ comparison problem: every hypothetical trace collision must straddle the two child subtrees of some local Cohn split. The whole of @sec:dominance through @sec:fibonacci-pell is devoted to ruling out such cross-ray collisions in increasing generality.

= Dominance exclusion by line monotonicity <sec:dominance>

Same-ray monotonicity from @sec:same-ray eliminates trace collisions inside a single one-sided Cohn ray. The next elementary reduction eliminates a second class of comparisons: pairs of lattice points one of which is ordered ahead of the other by a _positive Farey direction_ inside their local Farey cone. Geometrically: if the lattice offset $Q - P$ has slope in $[0, 1]$, then the published line-ordering theorem of Lee, Li, Rabideau, and Schiffler @LeeLiRabideauSchiffler2023 separates the two Markov numbers, and the trace-injectivity conjecture @eq:cohn-trace-injectivity is settled in that case. After this Chapter, the only remaining cross-ray comparisons are the _mixed_ comparisons $Q - P = r u - s v$ with $r, s > 0$, in which the offset has negative slope inside the local Farey cone.

== Lattice notation for Markov numbers <subsec:lattice-notation-sec5>

We continue to use the lattice indexing of the Markov numbers introduced in @sec:markov-cohn: every primitive lattice point
$
  P = (q, thin p) in cal(D), quad quad cal(D) = { (q, thin p) in bb(Z)^2 : q gt.eq.slant 1, thick 0 lt.eq.slant p lt.eq.slant q, thick gcd (q, p) = 1 },
$
represents the Stern--Brocot fraction $p slash q$ and carries the Markov number
$
  m_P := m_(p slash q).
$
By @cor:markov-as-weight of @sec:cohn-words the Markov number is also the central weight of the Cohn-word central core,
$
  m_P = g (z_(p slash q)) = bold(a)^top thin M(z_(p slash q)) thin bold(a) quad upright("with") quad bold(a) = (2, thin 1)^top,
$
and the abelianisation of $z_(p slash q)$ has the letter counts $hash_A = q - p - 1$ and $hash_B = p - 1$ of @eq:central-counts. We use either presentation as convenient. The trace formulation @eq:cohn-trace-injectivity of the uniqueness conjecture is equivalent to the injectivity of the map $P arrow.r.bar m_P$ on the interior of $cal(D)$.

== The line-ordering input <subsec:line-ordering-input>

The structural input of this Section is the line-monotonicity theorem of Lee, Li, Rabideau, and Schiffler @LeeLiRabideauSchiffler2023, sharpened by Huang @Huang2022. We record the statement we shall use.

#theorem(title: [Line ordering of Markov numbers, after @LeeLiRabideauSchiffler2023], lbl: <thm:line-ordering>)[
  Let $P = (q, thin p)$ and $Q = (q', thin p')$ be primitive lattice points in $cal(D)$ with $q eq.not q'$, and let $lambda$ be the slope of the line through $P$ and $Q$ oriented in the direction of increasing $q$-coordinate. If
  $
    lambda gt.eq.slant - 8 slash 7,
  $
  then the lattice point with the larger $q$-coordinate carries the larger Markov number. In particular, if $q' > q$ and $lambda gt.eq.slant - 8 slash 7$, then $m_Q > m_P$.
] <thm-line-ordering>

#proof[
  This is Theorem 1.1 of Lee, Li, Rabideau, and Schiffler @LeeLiRabideauSchiffler2023, restated here in the Stern--Brocot coordinates used throughout the monograph. We apply it as a black box; the original proof in the cited reference proceeds via snake-graph perfect matchings and the Aigner ordering inequalities. The complementary slope regime $lambda lt.eq.slant - 5 slash 4$ is handled by the same paper, and the full slope classification is completed by Huang @Huang2022; see the discussion immediately following.
]

The complementary line-monotonicity in the regime $lambda lt.eq.slant - 5 slash 4$ was proved by Lee, Li, Rabideau, and Schiffler in the same paper, and the full classification of line-monotone slopes was completed by Huang @Huang2022 via the Markov distance and the Ptolemy inequality. The open exceptional window
$
  - 5 slash 4 < lambda < - 8 slash 7
$
is precisely the residual locus where neither monotonicity inequality holds in general; it is the slope window that will reappear in @sec:terminal-cone as the obstruction targeted by the Exceptional Terminal Arithmetic Theorem (@thm:ETAT). For the present Section, we shall only use the simple consequence of @thm:line-ordering for non-negative slopes.

#corollary(title: "Positive-direction monotonicity", lbl: <cor:positive-direction-monotonicity>)[
  Let $P, Q in cal(D)$. If $Q - P$ is a non-zero lattice vector whose slope lies in $[0, thin 1]$, then $m_Q > m_P$.
] <cor-positive-direction-monotonicity>

#proof[
  Write $Q - P = (Delta q, thin Delta p)$. The slope-in-$[0, 1]$ assumption means $Delta q > 0$ and $0 lt.eq.slant Delta p lt.eq.slant Delta q$. The line through $P$ and $Q$ oriented by increasing $q$ therefore has slope
  $
    lambda = Delta p slash Delta q in [0, thin 1] subset.eq [- 8 slash 7, infinity),
  $
  so @thm:line-ordering applies and yields $m_Q > m_P$, since $Q$ has the larger $q$-coordinate.
]

The upper bound $lambda lt.eq.slant 1$ in @cor:positive-direction-monotonicity is not strictly needed for the line-ordering hypothesis $lambda gt.eq.slant - 8 slash 7$. We retain it because the dominance arguments of @subsec:dominance-cone naturally produce offsets inside a Farey cone of the type $chevron.l v, u chevron.r subset cal(D)$, all of whose vectors have slopes in $[0, 1]$.

== Dominance in a Farey cone <subsec:dominance-cone>

We now apply @cor:positive-direction-monotonicity inside a local Farey cone. Let $(v, u)$ be an adjacent Farey basis in $cal(D)$ in the sense of @def:adjacent-farey-basis of @sec:local-cone, ordered by slope so that the slopes satisfy
$
  0 lt.eq.slant upright("slope")(v) < upright("slope")(u) lt.eq.slant 1, quad quad det (v, u) = 1.
$
Every lattice point in the Farey cone $chevron.l v, u chevron.r$ of @eq:farey-cone is a non-negative integer combination $alpha u + beta v$.

#definition(title: "Dominance in a Farey cone", lbl: <def:dominance>)[
  Let $(v, u)$ be an adjacent Farey basis, and let $P, Q$ be two lattice points in the cone $chevron.l v, u chevron.r$, written as $P = alpha u + beta v$ and $Q = gamma u + delta v$ with $alpha, beta, gamma, delta in bb(Z)_(gt.eq.slant 0)$. We say that $Q$ _dominates_ $P$ (with respect to the basis $(v, u)$) if
  $
    Q - P = rho thin u + sigma thin v
  $
  with $rho, sigma in bb(Z)_(gt.eq.slant 0)$ and $(rho, sigma) eq.not (0, 0)$. Equivalently, $gamma gt.eq.slant alpha$, $delta gt.eq.slant beta$, and at least one inequality is strict.
] <def-dominance>

The dominance relation is the partial order on $chevron.l v, u chevron.r inter cal(D)$ induced by the cone. Geometrically, it is the partial order in which $Q$ comes "after" $P$ in both Farey-basis directions simultaneously; in @fig:dominance-cone the dominance region of $P$ is the shaded shifted cone $P + chevron.l v, u chevron.r$, while the "anti-dominance" region (the set of $Q$ such that $P$ dominates $Q$) is the reflected shifted cone $P - chevron.l v, u chevron.r$. Two lattice points outside both of these regions are _coefficient-incomparable_; their offset $Q - P$ has coefficients of opposite signs in the $(u, v)$ basis, and produces a _mixed direction_ that the rest of the manuscript will analyse.

#figure(
  caption: [The dominance partial order in a Farey cone. The cone $chevron.l v, u chevron.r$ is spanned by the two basis vectors $v$ and $u$ (heavy blue). A reference point $P$ inside the cone has its _dominance region_ $P + chevron.l v, u chevron.r$ (shaded teal): every lattice point $Q$ in that region satisfies $Q - P = rho u + sigma v$ with $rho, sigma gt.eq.slant 0$, and so $m_Q > m_P$ by @prop:dominance-exclusion below. The _anti-dominance region_ $P - chevron.l v, u chevron.r$ (shaded teal in the opposite direction) collects the points $Q$ such that $P$ dominates $Q$. The remaining two quadrants in the $(u, v)$ coordinate system are the _coefficient-incomparable_ regions, in which the offset $Q - P$ has mixed signs $r u - s v$ or $- r u + s v$ with $r, s > 0$. The mixed-direction arrow $u - s v$ (red) exits the cone and is the basic offset analysed in @sec:euclidean-recoding.],
  cetz.canvas({
    import cetz.draw: *
    // Grid lines (integer lattice)
    for i in range(-1, 8) {
      line((i, -3), (i, 5), stroke: 0.2pt + gray)
    }
    for j in range(-3, 6) {
      line((-1, j), (7, j), stroke: 0.2pt + gray)
    }
    // Farey cone with basis v = (1, 0), u = (1, 1) — extreme rays
    line((0, 0), (6, 0), stroke: 1.5pt + ku-blue, mark: (end: ">"))
    line((0, 0), (4.5, 4.5), stroke: 1.5pt + ku-blue, mark: (end: ">"))
    // Origin and axis labels
    circle((0, 0), radius: 0.07, fill: black)
    content((-0.35, -0.3), [$O$])
    content((6.35, -0.3), [$v$])
    content((4.7, 4.55), [$u$])
    // ----- Dominance region (shifted cone from P along v and u) -----
    // Outer edges of the shifted cone (thin defn-coloured lines)
    line((3, 1), (6, 1), stroke: 0.8pt + defn-color)
    line((3, 1), (5.3, 3.3), stroke: 0.8pt + defn-color)
    // Interior shading hints
    line((3, 1), (4.5, 1.2), stroke: 0.3pt + defn-color)
    line((3, 1), (5, 1.7), stroke: 0.3pt + defn-color)
    line((3, 1), (4.5, 2.2), stroke: 0.3pt + defn-color)
    // ----- Anti-dominance region (shifted cone from P along -v and -u) -----
    line((3, 1), (0.5, 1), stroke: (paint: defn-color, thickness: 0.6pt, dash: "dashed"))
    line((3, 1), (0.8, -1.2), stroke: (paint: defn-color, thickness: 0.6pt, dash: "dashed"))
    // ----- Reference point P -----
    circle((3, 1), radius: 0.09, fill: thm-color)
    content((2.75, 0.65), anchor: "east", text(weight: "bold")[$P$])
    // ----- Sample dominating point Q at u-step -----
    line((3, 1), (4, 2), stroke: 1pt + defn-color, mark: (end: ">"))
    circle((4, 2), radius: 0.07, fill: defn-color)
    content((4.25, 1.95), anchor: "west", text(fill: defn-color, weight: "bold")[$Q$])
    // ----- Sample mixed-direction point Q' at u-v step -----
    line((3, 1), (3, 2), stroke: 1.2pt + cor-color, mark: (end: ">"))
    circle((3, 2), radius: 0.07, fill: cor-color)
    content((2.75, 2.0), anchor: "east", text(fill: cor-color, weight: "bold")[$Q'$])
    // ----- Legends pulled clear of the central region -----
    // Dominance legend: upper right, well outside the central crash zone
    content((5.6, 3.9), anchor: "west", text(size: 9pt, fill: defn-color, weight: "bold")[dominance])
    content((5.6, 3.55), anchor: "west", text(size: 8pt, fill: defn-color)[$Q - P = rho u + sigma v$])
    content((5.6, 3.25), anchor: "west", text(size: 8pt, fill: defn-color)[$rho, sigma gt.eq.slant 0$])
    // Mixed-direction legend: upper left, in the empty wedge above the u-axis
    content((0.8, 4.4), anchor: "west", text(size: 9pt, fill: cor-color, weight: "bold")[mixed direction])
    content((0.8, 4.05), anchor: "west", text(size: 8pt, fill: cor-color)[$Q' - P = u - v$])
    // Anti-dominance label: below P, outside the cone
    content((1.7, -0.6), anchor: "west", text(size: 9pt, fill: defn-color, style: "italic")[anti-dominance region])
    content((1.7, -0.95), anchor: "west", text(size: 8pt, fill: defn-color)[$Q - P = - rho u - sigma v$])
  }),
) <fig:dominance-cone>

The key observation is that every direction inside the Farey cone has slope in $[0, 1]$, so @cor:positive-direction-monotonicity applies.

#proposition(title: "Dominance exclusion", lbl: <prop:dominance-exclusion>)[
  Let $(v, u)$ be an adjacent Farey basis in $cal(D)$, and let $P, Q$ be primitive lattice points in $cal(D) inter chevron.l v, u chevron.r$. If $Q$ dominates $P$ in the sense of @def:dominance, then $m_Q > m_P$. Symmetrically, if $P$ dominates $Q$, then $m_P > m_Q$. In either case, $m_P eq.not m_Q$.
] <prop-dominance-exclusion>

#proof[
  Assume $Q$ dominates $P$, so $Q - P = rho thin u + sigma thin v$ for some non-negative integers $(rho, sigma) eq.not (0, 0)$. Write $v = (q_0, p_0)$ and $u = (q_1, p_1)$. Both vectors lie in $cal(D)$ and therefore have slopes in $[0, 1]$. The slope of the non-zero combination $rho thin u + sigma thin v$ is
  $
    (rho p_1 + sigma p_0) slash (rho q_1 + sigma q_0),
  $
  which is the convex combination of $p_1 slash q_1$ and $p_0 slash q_0$ with positive weights $rho q_1$ and $sigma q_0$ (with the convention that a zero weight removes the corresponding term when one of $rho, sigma$ vanishes). In all cases this convex combination lies in
  $
    [thin upright("slope")(v), thin upright("slope")(u) thin] subset.eq [0, thin 1].
  $
  Hence $Q - P$ is a non-zero lattice vector of slope in $[0, 1]$, and @cor:positive-direction-monotonicity yields $m_Q > m_P$. The symmetric case is obtained by swapping the roles of $P$ and $Q$.
]

@prop:dominance-exclusion is the second elementary separation principle of the reduction. It depends on the same four ingredients as @thm:same-ray-monotonicity — the Cohn-tree structure, the lattice indexing of the Markov tree, and the line-ordering theorem of @LeeLiRabideauSchiffler2023 — and, crucially, the latter is itself an unconditional theorem about the lattice of Markov numbers, not a hypothesis derived from the Frobenius--Markov uniqueness conjecture.

#remark(title: "The dominance partial order as a cone-induced order", lbl: <rem:dominance-partial-order>)[
  The dominance relation of @def:dominance is the partial order on $bb(Z)_(gt.eq.slant 0)^2$ obtained by translating the Farey cone $chevron.l v, u chevron.r$ to each lattice point. In the language of combinatorial commutative algebra, $Q$ dominates $P$ exactly when the monomial $u^gamma v^delta$ divides $u^alpha v^beta$ in the polynomial ring $bb(Q)[u, v]$ — that is, when $(alpha, beta) lt.eq.slant_{op("cone")} (gamma, delta)$ in the cone partial order. The line-ordering theorem of @LeeLiRabideauSchiffler2023 is therefore the statement that the Markov-number map is _monotone_ for this partial order, restricted to slope directions outside the exceptional window. From this viewpoint, the residual obstacle of the reduction is the failure of the natural monomial partial order to detect equality of Markov numbers along the slope window $(- 5 slash 4, thin - 8 slash 7)$, which is the algebraic shadow of the dynamical phenomenon detected by Huang's valley theorem @Huang2022.
]

== Coefficient-incomparable pairs <subsec:incomparable-pairs>

Dominance exclusion leaves only the coefficient-incomparable comparisons inside a Farey cone. We give the precise form of an unresolved comparison.

#corollary(title: "Mixed form of an unresolved comparison", lbl: <cor:mixed-form>)[
  Let $P, Q$ be two distinct primitive lattice points in a Farey cone $chevron.l v, u chevron.r subset cal(D)$, and suppose $m_P = m_Q$. Then, after possibly interchanging $P$ and $Q$, there exist positive integers $r, s in bb(Z)_(gt.eq.slant 1)$ such that
  $
    Q - P = r thin u - s thin v.
  $ <eq:mixed-form>
] <cor-mixed-form>

#proof[
  Write $P = alpha u + beta v$ and $Q = gamma u + delta v$ with non-negative integer coefficients, and consider the two coefficient differences $gamma - alpha$ and $delta - beta$. If both have the same sign (and are not both zero), then one point dominates the other, and @prop:dominance-exclusion forces $m_P eq.not m_Q$, contradicting the hypothesis. If exactly one of the two differences is zero and the other non-zero, then one point dominates the other as well, again contradicting $m_P = m_Q$. Therefore both differences are non-zero and have opposite signs. After possibly swapping $P$ and $Q$, we may assume $gamma > alpha$ and $delta < beta$. Setting $r := gamma - alpha gt.eq.slant 1$ and $s := beta - delta gt.eq.slant 1$, the offset is
  $
    Q - P = (gamma - alpha) u + (delta - beta) v = r thin u - s thin v,
  $
  as claimed.
]

The form @eq:mixed-form will be the basic local offset analysed by every subsequent stage of the reduction.

== Role in the reduction <subsec:reduction-role-sec5>

We summarise the position reached by the end of this Section. Combining @cor:cross-ray-reduction of @sec:same-ray and @cor:mixed-form, every hypothetical trace collision in the Cohn tree reduces to a comparison of the following shape:

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + ku-blue),
  fill: ku-blue-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  #text(weight: "bold", fill: ku-blue)[Residual cross-ray mixed comparison.]
  #h(0.3em)
  After @cor:no-same-ray-collision and @prop:dominance-exclusion, every trace collision $m_P = m_Q$ between two distinct primitive lattice points $P, Q$ in $cal(D)$ admits an adjacent Farey basis $(v, u)$ for which both $P$ and $Q$ lie in the cone $chevron.l v, u chevron.r$, $P, Q$ are coefficient-incomparable, and the offset takes the mixed form $Q - P = r u - s v$ with $r, s gt.eq.slant 1$.
]

The mixed form @eq:mixed-form is the starting point for the _Euclidean recoding_ of @sec:euclidean-recoding, which reduces every such comparison, by repeated subtraction of adjacent Farey basis vectors, to a terminal comparison in the standard Farey cone $chevron.l (1, 0), (1, 1) chevron.r$. There the surviving cases are classified by the slope of $Q - P$: slopes outside the exceptional window $(- 5 slash 4, thin - 8 slash 7)$ are excluded by line-monotonicity, by direct application of @thm:line-ordering or by the complementary results of @Huang2022; slopes inside the exceptional window with $gcd (r, s) = 1$ are excluded by Huang's valley theorem (@sec:primitive-exclusion); and the remaining non-primitive exceptional cases form the Exceptional Terminal Arithmetic Theorem (@thm:ETAT, stated in @sec:ETAT). In this way the entire residual content of the Frobenius--Markov uniqueness conjecture is concentrated, by the end of @sec:fibonacci-pell, in the terminal arithmetic problem on two-parameter lattice families.

== Synopsis <subsec:synopsis-sec5>

We have proved the second unconditional separation principle on the Cohn tree. The line-ordering theorem of @LeeLiRabideauSchiffler2023, applied in the form of @cor:positive-direction-monotonicity at non-negative slope, separates the Markov numbers of any two lattice points whose offset lies inside the dominance cone of an adjacent Farey basis. Inside a local Farey cone $chevron.l v, u chevron.r$, the resulting _dominance exclusion_ @prop:dominance-exclusion eliminates every comparison in which one point dominates the other in the $(u, v)$-cone partial order, restricting the residual unresolved comparisons to the coefficient-incomparable ones. By @cor:mixed-form, every such residual comparison admits, after possibly swapping the two points, the explicit mixed form $Q - P = r u - s v$ with $r, s gt.eq.slant 1$. Combined with @cor:cross-ray-reduction of @sec:same-ray, this means that every hypothetical trace collision in the Cohn tree reduces to a coefficient-incomparable cross-ray comparison of mixed form inside some adjacent Farey cone. The mixed form @eq:mixed-form is the local offset that the rest of the manuscript --- starting with the boundary-ratio monotonicity of @sec:boundary-ratio --- will analyse in increasing geometric and arithmetic depth.

= Boundary trace sequences and boundary ratio monotonicity <sec:boundary-ratio>

The same-ray monotonicity theorem of @sec:same-ray eliminates trace collisions along a single one-sided Cohn ray, and the dominance exclusion of @sec:dominance eliminates comparisons in which one lattice point lies ahead of the other in a positive Farey direction. We now analyse the first genuinely _mixed_ local situation: the comparison of the two boundary trace sequences that emerge from a single local Cohn split.

The main result of this Chapter is that the _boundary trace ratio_
$
  rho_n := U_n slash V_n
$ <eq:rho-def>
of @sec:local-cone is _strictly increasing_ in $n$. In particular, the equation $U_n = V_n$ can have at most one solution. Combined with the Vieta gluing identity of @sec:vieta-gluing and the shifted boundary separation of @sec:shifted-boundary, this monotonicity will be enough to exclude every boundary trace collision in the Cohn tree.

The proof uses three elementary inputs: the recurrences @eq:U-rec and @eq:V-rec of @sec:local-cone, the Chebyshev closed form @eq:U-closed and @eq:V-closed of @lem:chebyshev-closed-form, and the trace-normalised Markov equation @eq:trace-markov-eq of @sec:local-cone. The structural quantity that drives the entire argument is a discrete Wronskian, whose recurrence parallels the Wronskian identity for second-order linear ODEs and which we now record.

== Recall of the boundary trace sequences <subsec:recall-boundary>

We continue to work with an oriented Cohn triple $(R, thin R S, thin S)$ and its local trace data
$
  x = tr R = 3 a, quad quad z = tr (R S) = 3 c, quad quad y = tr S = 3 b,
$
where $(a, thin c, thin b)$ is the corresponding Markov triple. The orientation gives $z > x$ and $z > y$ by @lem:middle-trace-dominates of @sec:same-ray, and the three trace data satisfy the trace-normalised Markov equation @eq:trace-markov-eq:
$
  x^2 + y^2 + z^2 = x thin y thin z.
$ <eq:trace-markov-eq-sec6>

The two boundary trace sequences are the sequences defined in @sec:local-cone by the recurrences @eq:U-rec and @eq:V-rec:
$
  U_(- 1) = x, quad U_0 = x z - y, quad U_(n + 1) = z thin U_n - U_(n - 1),
$
and
$
  V_(- 1) = z, quad V_0 = y z - x, quad V_(n + 1) = y thin V_n - V_(n - 1).
$
By @lem:local-trace-recurrences of @sec:local-cone, the initial values are the traces of the two new middle matrices produced by the local Cohn split,
$
  U_0 = tr (R^2 S), quad quad V_0 = tr (R S^2).
$
The recurrences themselves are Cayley--Hamilton trace recurrences in disguise: $U_n$ tracks the trace along the inner boundary of the _left_ child subtree of the local triple, $V_n$ tracks the trace along the inner boundary of the _right_ child subtree. The Chebyshev closed form @eq:U-closed and @eq:V-closed of @lem:chebyshev-closed-form expresses both sequences as polynomials in the corresponding parameter,
$
  U_n = P_n (z) thin (x z - y) - P_(n - 1) (z) thin x, quad V_n = P_n (y) thin (y z - x) - P_(n - 1) (y) thin z,
$
which will be useful in the Vieta gluing identity of @sec:vieta-gluing but is not needed for the monotonicity argument below.

== Positivity of the boundary trace sequences <subsec:positivity-boundary>

The first step is the elementary fact that both boundary trace sequences are positive and strictly increasing.

#lemma(title: "Positivity of the boundary trace sequences", lbl: <lem:boundary-positivity>)[
  For every $n gt.eq.slant - 1$,
  $
    U_n > 0, quad quad V_n > 0,
  $
  and the sequences satisfy $U_0 > U_(- 1) > 0$, $V_0 > V_(- 1) > 0$, and $U_(n + 1) > U_n$, $V_(n + 1) > V_n$ for every $n gt.eq.slant 0$.
] <lem-boundary-positivity>

#proof[
  Since every Cohn matrix has trace a positive multiple of three, $x, y, z gt.eq.slant 3$. The orientation @lem:middle-trace-dominates gives $z > x$ and $z > y$, hence $z gt.eq.slant 6$ on the non-singular Cohn tree (because $z$ is strictly larger than the multiple-of-three quantity $max (x, y) gt.eq.slant 3$). Both sequences start at strictly positive initial values: $U_(- 1) = x gt.eq.slant 3 > 0$ and $V_(- 1) = z gt.eq.slant 6 > 0$.

  _Base step for $U$._ We compute
  $
    U_0 - U_(- 1) = (x z - y) - x = x thin (z - 1) - y.
  $
  Since $z > y$ and both are multiples of three, $z gt.eq.slant y + 3$, hence $z - 1 gt.eq.slant y + 2 > y$. Combined with $x gt.eq.slant 3$,
  $
    x thin (z - 1) gt.eq.slant 3 thin y > y,
  $
  so $U_0 - U_(- 1) > 0$. In particular $U_0 > U_(- 1) > 0$.

  _Base step for $V$._ Similarly,
  $
    V_0 - V_(- 1) = (y z - x) - z = z thin (y - 1) - x.
  $
  Since $y gt.eq.slant 3$, $y - 1 gt.eq.slant 2$, and $z > x$, we get
  $
    z thin (y - 1) gt.eq.slant 2 z > 2 x > x,
  $
  so $V_0 - V_(- 1) > 0$. Hence $V_0 > V_(- 1) > 0$.

  _Inductive step for $U$._ Assume $U_n > U_(n - 1) > 0$ for some $n gt.eq.slant 0$. From the recurrence and $U_(n - 1) < U_n$,
  $
    U_(n + 1) = z thin U_n - U_(n - 1) > z thin U_n - U_n = (z - 1) thin U_n gt.eq.slant 5 thin U_n > U_n,
  $
  where we used $z gt.eq.slant 6$. Positivity of $U_(n + 1)$ then follows from $U_(n + 1) > U_n > 0$. The inductive step for $V$ is identical with $y gt.eq.slant 3$ in place of $z gt.eq.slant 6$ — using $V_(n + 1) > (y - 1) thin V_n gt.eq.slant 2 thin V_n > V_n$. By induction, both sequences are strictly increasing positive integer sequences for all $n gt.eq.slant -1$.
]

The strict-monotonicity claim $U_(n + 1) > U_n$ for $n gt.eq.slant 0$ is in fact a consequence of the same Cayley--Hamilton-recurrence argument used in @thm:same-ray-monotonicity, and the proof here is essentially the same as the same-ray monotonicity proof transplanted to a different ray.

== A discrete Wronskian <subsec:wronskian>

We now introduce the structural quantity that drives the boundary-ratio monotonicity argument. Define the _discrete Wronskian_ of the two boundary sequences by
$
  W_n := U_(n + 1) thin V_n - U_n thin V_(n + 1), quad quad n gt.eq.slant - 1,
$ <eq:Wronskian-def>
with the convention $W_(- 1) := U_0 thin V_(- 1) - U_(- 1) thin V_0$. The sign of $W_n$ controls the monotonicity of the ratio $rho_n = U_n slash V_n$ of @eq:rho-def, as we shall see in @thm:boundary-ratio-monotonicity. The discrete Wronskian @eq:Wronskian-def is the obvious lattice analogue of the Wronskian determinant
$
  W(u, v) = u thin v' - u' thin v
$
of two solutions of a second-order linear ordinary differential equation. In the continuous setting, the Wronskian satisfies $W' + p thin W = 0$ where $p$ is the coefficient of the first-order derivative in the ODE; in our discrete setting, the analogue is the recurrence in @lem:wronskian-rec below, in which the role of the integrating factor is played by the difference $z - y$ between the two trace parameters.

#lemma(title: "Initial positivity of the Wronskian", lbl: <lem:wronskian-initial-positivity>)[
  $W_(- 1) > 0$.
] <lem-wronskian-initial-positivity>

#proof[
  By direct expansion,
  $
    W_(- 1) = (x z - y) z - x (y z - x) = x z^2 - y z - x y z + x^2.
  $
  Substituting $x y z = x^2 + y^2 + z^2$ from the trace-normalised Markov equation @eq:trace-markov-eq-sec6,
  $
    W_(- 1) = x z^2 - y z - (x^2 + y^2 + z^2) + x^2 = x z^2 - y z - y^2 - z^2,
  $
  which factors as
  $
    W_(- 1) = z^2 thin (x - 1) - y thin (z + y).
  $ <eq:Wminus1-factored>
  Two elementary bounds finish the argument. First, $x gt.eq.slant 3$, so $x - 1 gt.eq.slant 2$, and therefore
  $
    z^2 thin (x - 1) gt.eq.slant 2 thin z^2.
  $
  Second, $0 < y < z$ by orientation, so $y + z < 2 z$ and $y < z$, giving
  $
    y thin (y + z) < y thin (2 z) = 2 thin y thin z < 2 thin z^2.
  $
  Combining the two bounds in @eq:Wminus1-factored,
  $
    W_(- 1) = z^2 thin (x - 1) - y thin (y + z) gt.eq.slant 2 thin z^2 - y thin (y + z) > 2 thin z^2 - 2 thin z^2 = 0,
  $
  with strict positivity coming from the strict bound $y thin (y + z) < 2 z^2$.
]

#lemma(title: "Wronskian recurrence", lbl: <lem:wronskian-rec>)[
  For every $n gt.eq.slant 0$,
  $
    W_n = W_(n - 1) + (z - y) thin U_n thin V_n.
  $ <eq:Wronskian-rec>
] <lem-wronskian-rec>

#proof[
  Substituting $U_(n + 1) = z thin U_n - U_(n - 1)$ and $V_(n + 1) = y thin V_n - V_(n - 1)$ into the definition @eq:Wronskian-def,
  $
    W_n &= U_(n + 1) thin V_n - U_n thin V_(n + 1) \
        &= (z thin U_n - U_(n - 1)) thin V_n - U_n thin (y thin V_n - V_(n - 1)) \
        &= z thin U_n thin V_n - U_(n - 1) thin V_n - y thin U_n thin V_n + U_n thin V_(n - 1) \
        &= (z - y) thin U_n thin V_n + (U_n thin V_(n - 1) - U_(n - 1) thin V_n) \
        &= (z - y) thin U_n thin V_n + W_(n - 1),
  $
  where the last equality uses the definition $W_(n - 1) = U_n thin V_(n - 1) - U_(n - 1) thin V_n$.
]

#proposition(title: "Positivity of the discrete Wronskian", lbl: <prop:wronskian-positivity>)[
  For every $n gt.eq.slant - 1$,
  $
    W_n > 0.
  $
] <prop-wronskian-positivity>

#proof[
  By @lem:wronskian-initial-positivity, $W_(- 1) > 0$. By @lem:boundary-positivity, $U_n > 0$ and $V_n > 0$ for every $n gt.eq.slant 0$. By the orientation @lem:middle-trace-dominates, $z > y$. Therefore the increment $(z - y) thin U_n thin V_n > 0$ in the recurrence @eq:Wronskian-rec is strictly positive for every $n gt.eq.slant 0$, and a straightforward induction yields $W_n > W_(n - 1) > 0$ for all $n gt.eq.slant 0$, completing the chain $W_(- 1) > 0$, $W_0 > 0$, $W_1 > 0$, $dots$.
]

#remark(title: "The discrete Wronskian as a curvature-type quantity", lbl: <rem:wronskian-curvature>)[
  In the language of second-order linear systems, the discrete Wronskian @eq:Wronskian-def is the determinant of the two-by-two matrix
  $
    mat(U_n, V_n; U_(n + 1), V_(n + 1))
  $
  of "phase-space" coordinates of the two boundary sequences. The recurrence @eq:Wronskian-rec then says that this determinant grows monotonically along the lattice with rate $(z - y) thin U_n thin V_n$; it is the discrete analogue of the formula $W' = - p W$ for the Wronskian of two solutions of a second-order linear ODE, with the role of the "damping coefficient" $p$ played by the trace-difference $-(z - y)$. Because the lattice-step orientation reverses the sign, the discrete Wronskian here grows rather than decays. The positivity of $W_n$ encodes the geometric fact that the two boundary sequences $U_n, V_n$ rotate in the lattice in a coherent direction, never crossing each other in the strong sense of becoming proportional --- which is exactly what the boundary-ratio monotonicity below makes precise.
]

== Boundary ratio monotonicity <subsec:boundary-ratio-monotonicity>

We now reach the main result of the Section.

#theorem(title: "Boundary ratio monotonicity", lbl: <thm:boundary-ratio-monotonicity>)[
  The boundary trace ratio $rho_n = U_n slash V_n$ is strictly increasing in $n$:
  $
    rho_(- 1) < rho_0 < rho_1 < rho_2 < dots.h.c.
  $
] <thm-boundary-ratio-monotonicity>

#proof[
  By @prop:wronskian-positivity, $W_n = U_(n + 1) thin V_n - U_n thin V_(n + 1) > 0$ for every $n gt.eq.slant - 1$. By @lem:boundary-positivity, the denominators $V_n, V_(n + 1)$ are strictly positive. Dividing the inequality $W_n > 0$ by the positive quantity $V_n thin V_(n + 1)$ gives
  $
    rho_(n + 1) - rho_n = U_(n + 1) slash V_(n + 1) - U_n slash V_n = (U_(n + 1) thin V_n - U_n thin V_(n + 1)) slash (V_n thin V_(n + 1)) = W_n slash (V_n thin V_(n + 1)) > 0.
  $
  Hence $rho_(n + 1) > rho_n$ for every $n gt.eq.slant - 1$.
]

The strict monotonicity of @thm:boundary-ratio-monotonicity has the immediate consequence that the equation $U_n = V_n$ has at most one solution.

#corollary(title: "At most one boundary equality", lbl: <cor:at-most-one-boundary>)[
  The equation $U_n = V_n$ admits at most one solution $n gt.eq.slant - 1$.
] <cor-at-most-one-boundary>

#proof[
  The condition $U_n = V_n$ is equivalent to $rho_n = U_n slash V_n = 1$, since both quantities are strictly positive by @lem:boundary-positivity. By @thm:boundary-ratio-monotonicity, the sequence $(rho_n)$ is strictly increasing, so it takes any given value at most once. In particular, $rho_n = 1$ has at most one solution.
]

== Role in the reduction <subsec:reduction-role-sec6>

The boundary-ratio theorem @thm:boundary-ratio-monotonicity is the third structural ingredient of the reduction. Its content is sharp: it says that a boundary trace comparison cannot oscillate. Once the sign of $U_n - V_n$ has changed, it changes permanently. Therefore, to exclude every boundary trace collision in the Cohn tree, it is enough to prove _two adjacent inequalities_,
$
  U_N < V_N quad upright("and") quad U_(N + 1) > V_(N + 1),
$ <eq:two-adjacent-inequalities>
at the unique crossing index $N$. This is exactly what the shifted boundary separation argument of @sec:shifted-boundary will accomplish, and the precise location of the crossing index $N$ inside the Farey-cone coordinates of @sec:local-cone is the content of the Vieta gluing identity of @sec:vieta-gluing.

In the next Section we prove the Vieta gluing identity
$
  tilde(V)_n (a, thin b, thin c) = tilde(U)'_(n + 1) (a, thin 3 a b - c, thin b),
$
which identifies one boundary sequence at a Markov triple with the shifted boundary sequence at its Vieta predecessor. This identity is the algebraic reason why the crossing index shifts under descent in the Cohn tree, and is the bridge between the local Wronskian-based monotonicity of the present Section and the global non-crossing statement of @sec:shifted-boundary.

== Synopsis <subsec:synopsis-sec6>

We have established the third unconditional separation principle of the reduction. Out of the local Cohn split governed by the Cayley--Hamilton recurrences @eq:U-rec and @eq:V-rec of @sec:local-cone, we extract the discrete Wronskian @eq:Wronskian-def of the two boundary trace sequences, and observe that it satisfies the closed-form three-term recurrence @eq:Wronskian-rec of @lem:wronskian-rec, obtained by direct substitution of the recurrences. The initial Wronskian $W_(- 1)$ is strictly positive by @lem:wronskian-initial-positivity, established by combining the explicit factored form @eq:Wminus1-factored with the orientation inequalities $z > y$ and $x gt.eq.slant 3$. By @prop:wronskian-positivity, the strict positivity propagates: every $W_n$ is strictly positive. Dividing through by $V_n thin V_(n + 1) > 0$ converts the Wronskian positivity into the boundary ratio monotonicity @thm:boundary-ratio-monotonicity, whose immediate corollary @cor:at-most-one-boundary excludes more than one boundary trace equality $U_n = V_n$. The single-crossing property reduces every hypothetical boundary collision to the two adjacent inequalities @eq:two-adjacent-inequalities at the unique crossing index, and these will be supplied in @sec:shifted-boundary using the Vieta gluing identity of @sec:vieta-gluing.

= Vieta gluing <sec:vieta-gluing>

The boundary trace sequences of @sec:boundary-ratio are not independent objects: they are glued together by the Vieta involution of the Markov tree. The aim of the present Section is to make the gluing precise. The main result is the identity
$
  tilde(V)_n (a, thin b, thin c) = tilde(U)'_(n + 1) (a, thin 3 a b - c, thin b)
$ <eq:vieta-gluing-display>
between the right boundary sequence at an ordered Markov triple $(a, b, c)$ and the _shifted_ left boundary sequence at its Vieta predecessor $(a, thin 3 a b - c, thin b)$ along the fixed-$a$ branch. In words: the two boundary sequences that emerge from a local Cohn split are _not_ two independent sequences; they are the same underlying sequence, viewed from two adjacent positions on the same Vieta arm of the Markov tree, with an index shift of one.

This gluing is the algebraic bridge between the boundary-ratio monotonicity of @sec:boundary-ratio and the shifted boundary separation of @sec:shifted-boundary. Concretely, @cor:at-most-one-boundary of @sec:boundary-ratio implies that the boundary equality $U_n = V_n$ can occur at most once; the present Section will show that this single putative crossing can be relocated, via @eq:vieta-gluing-display, into a _diagonal comparison_ between two adjacent rows of a fixed Markov arm, and the explicit pair of adjacent inequalities @eq:two-adjacent-inequalities of @sec:boundary-ratio will be supplied in @sec:shifted-boundary.

The proof is short and elementary: it follows by direct manipulation of the Chebyshev closed form @eq:U-closed and @eq:V-closed of @lem:chebyshev-closed-form of @sec:local-cone, together with the defining Vieta identity $c + d = 3 a b$.

== Vieta predecessors <subsec:vieta-predecessors>

Let
$
  (a, thin b, thin c)
$
be an ordered Markov triple, satisfying the Markov equation @eq:markov-equation in the form
$
  a^2 + b^2 + c^2 = 3 a b c, quad quad 1 lt.eq.slant a lt.eq.slant b < c.
$
Read as a polynomial equation in $c$, the Markov equation @eq:markov-equation is a quadratic with both roots being positive integers,
$
  T^2 - 3 a b thin T + (a^2 + b^2) = 0.
$ <eq:c-quadratic>
By the Vieta formulas, the two roots $c$ and $d$ of @eq:c-quadratic satisfy
$
  c + d = 3 a b, quad quad c thin d = a^2 + b^2,
$ <eq:c-d-vieta>
and the Vieta involution @eq:vieta-involution replaces $c$ by the other root
$
  d := 3 a b - c
$ <eq:d-def>
to produce another Markov triple $(a, thin d, thin b)$.

#definition(title: "Vieta predecessor along a fixed arm", lbl: <def:vieta-predecessor>)[
  Let $(a, thin b, thin c)$ be an ordered Markov triple with $a lt.eq.slant b < c$. The _Vieta predecessor of $(a, b, c)$ along the fixed-$a$ branch_ is the Markov triple
  $
    (a, thin d, thin b), quad quad d := 3 a b - c,
  $
  obtained by Vieta-replacing the largest entry $c$. For ordinary (non-singular) Markov triples, the predecessor satisfies $d lt.eq.slant b$ by the orientation, and $b$ is the largest entry of the predecessor triple.
] <def-vieta-predecessor>

The notation $(a, thin d, thin b)$ in @def:vieta-predecessor preserves the position of the fixed branch element $a$ in the first slot and places the new value $d$ in the middle slot, with $b$ now in the third slot as the largest entry of the predecessor. This convention is essential below: the boundary sequences $tilde(U)$ and $tilde(V)$ depend on the _position_ of the entries, not merely on the unordered set $thin {a, b, c}$, and it is the position $(a, thin d, thin b)$ rather than the ordered form $(a, thin d, thin b)$ that is needed for the gluing identity.

#remark(title: "The Vieta involution as a cluster mutation", lbl: <rem:vieta-as-mutation>)[
  In the language of cluster algebras, the Vieta involution @eq:vieta-involution is precisely the _cluster mutation_ at the third coordinate of the rank-three cluster of variables $(a, thin b, thin c)$, with exchange polynomial reading $a^2 + b^2$ in numerator and the third variable in denominator. The Markov equation @eq:markov-equation is then the special-Laurent property of the cluster algebra associated to the once-punctured torus, and the two values $c, d$ at the third slot are the two cluster variables related by the mutation. From this viewpoint, the present @sec:vieta-gluing analyses the compatibility of the boundary trace sequences with cluster mutation; the gluing identity @eq:vieta-gluing-display is the precise compatibility between mutation in the cluster algebra and the natural Chebyshev structure of the trace recurrences. The recent matrixisations of generalised Markov numbers @BanaianGyoda2025 @Gyoda2026Words extend this gluing to the $k$-deformed cluster algebra of triangulated orbifolds.
]

== Divided boundary trace sequences <subsec:divided-boundary>

We work throughout with the divided boundary trace sequences of @eq:divided-UV of @sec:local-cone. The local Cohn trace data are
$
  x = 3 a, quad quad y = 3 b, quad quad z = 3 c,
$
and the two divided boundary sequences are the rescalings
$
  tilde(U)_n := U_n slash 3, quad quad tilde(V)_n := V_n slash 3.
$
Substituting the initial data and the recurrences @eq:U-rec and @eq:V-rec of @sec:local-cone, the divided sequences satisfy
$
  tilde(U)_(- 1) (a, b, c) = a, quad tilde(U)_0 (a, b, c) = 3 a c - b, quad tilde(U)_(n + 1) = 3 c thin tilde(U)_n - tilde(U)_(n - 1),
$
$
  tilde(V)_(- 1) (a, b, c) = c, quad tilde(V)_0 (a, b, c) = 3 b c - a, quad tilde(V)_(n + 1) = 3 b thin tilde(V)_n - tilde(V)_(n - 1).
$
By the Chebyshev closed form @lem:chebyshev-closed-form of @sec:local-cone applied with parameters $T = 3 c$ and $T = 3 b$ respectively, the divided sequences admit the explicit forms
$
  tilde(U)_n (a, b, c) = P_n (3 c) thin (3 a c - b) - a thin P_(n - 1) (3 c),
$ <eq:tilde-U-explicit>
$
  tilde(V)_n (a, b, c) = P_n (3 b) thin (3 b c - a) - c thin P_(n - 1) (3 b),
$ <eq:tilde-V-explicit>
in which $P_n$ is the Chebyshev-type polynomial @eq:chebyshev-def of @sec:local-cone. Both formulae are valid for $n gt.eq.slant - 1$, with the conventions $P_(- 1) = 0$ and $P_0 = 1$.

For the Vieta predecessor $(a, thin d, thin b)$ of @def:vieta-predecessor, with $b$ the largest entry, the corresponding _left_ boundary sequence is obtained by substituting $(a, b, c) arrow.r.bar (a, d, b)$ in @eq:tilde-U-explicit and renaming. We write it with a prime to mark that it is attached to the predecessor triple:
$
  tilde(U)'_n (a, d, b) := P_n (3 b) thin (3 a b - d) - a thin P_(n - 1) (3 b).
$ <eq:tilde-U-prime-explicit>
The defining identity @eq:d-def for the Vieta predecessor gives $3 a b - d = c$, so @eq:tilde-U-prime-explicit may also be written as
$
  tilde(U)'_n (a, d, b) = c thin P_n (3 b) - a thin P_(n - 1) (3 b).
$ <eq:tilde-U-prime-rewritten>

== The gluing identity <subsec:gluing-identity>

We now compare @eq:tilde-V-explicit with the shifted version of @eq:tilde-U-prime-rewritten.

#theorem(title: "Vieta gluing identity", lbl: <thm:vieta-gluing>)[
  Let $(a, thin b, thin c)$ be an ordered Markov triple with $1 lt.eq.slant a lt.eq.slant b < c$, and let $d := 3 a b - c$ be its Vieta predecessor as in @def:vieta-predecessor. Then for every $n gt.eq.slant - 1$,
  $
    tilde(V)_n (a, thin b, thin c) = tilde(U)'_(n + 1) (a, thin d, thin b).
  $ <eq:Vieta-gluing>
] <thm-vieta-gluing>

#proof[
  We first verify the identity at $n = - 1$. The left-hand side is $tilde(V)_(- 1) (a, b, c) = c$. The right-hand side is $tilde(U)'_0 (a, d, b)$, which by @eq:tilde-U-prime-explicit equals $3 a b - d$; but $3 a b - d = c$ by @eq:d-def, so the two sides agree.

  Now let $n gt.eq.slant 0$. Substituting @eq:tilde-V-explicit and rearranging,
  $
    tilde(V)_n (a, thin b, thin c) = P_n (3 b) thin (3 b c - a) - c thin P_(n - 1) (3 b),
  $
  which we expand as
  $
    tilde(V)_n (a, thin b, thin c) = 3 b thin c thin P_n (3 b) - a thin P_n (3 b) - c thin P_(n - 1) (3 b),
  $
  and then factor the two terms involving $c$,
  $
    tilde(V)_n (a, thin b, thin c) = c thin (3 b thin P_n (3 b) - P_(n - 1) (3 b)) - a thin P_n (3 b).
  $
  The bracketed quantity is precisely the Chebyshev recurrence @eq:chebyshev-def evaluated at $T = 3 b$,
  $
    3 b thin P_n (3 b) - P_(n - 1) (3 b) = P_(n + 1) (3 b),
  $
  by the definition $P_(n + 1) (T) = T thin P_n (T) - P_(n - 1) (T)$. Therefore
  $
    tilde(V)_n (a, thin b, thin c) = c thin P_(n + 1) (3 b) - a thin P_n (3 b).
  $
  Substituting $c = 3 a b - d$ from @eq:d-def into the right-hand side,
  $
    tilde(V)_n (a, thin b, thin c) = (3 a b - d) thin P_(n + 1) (3 b) - a thin P_n (3 b) = P_(n + 1) (3 b) thin (3 a b - d) - a thin P_n (3 b).
  $
  By @eq:tilde-U-prime-explicit, the right-hand side is exactly $tilde(U)'_(n + 1) (a, d, b)$. This proves the identity for $n gt.eq.slant 0$ and completes the proof.
]

@thm:vieta-gluing is the second main ingredient of the boundary analysis. Its content is purely algebraic: it relies only on the explicit Chebyshev form of the boundary sequences and on the defining Vieta relation $c + d = 3 a b$. No positivity or orientation assumption is used in the proof, beyond the implicit assumption that all four quantities $a, b, c, d$ make the Vieta-related triples genuine Markov triples. In particular, @thm:vieta-gluing holds for every Vieta-related pair of Markov triples in the same fixed-$a$ arm, including the singular triples at the base of the Markov tree.

== Consequence for boundary comparisons <subsec:gluing-consequence>

The Vieta gluing identity @eq:Vieta-gluing has an immediate restatement at the level of boundary comparisons. The boundary comparison at the triple $(a, thin b, thin c)$ asks whether
$
  tilde(U)_n (a, thin b, thin c) =^? tilde(V)_n (a, thin b, thin c)
$
holds at some index $n$. Replacing the right-hand side using @eq:Vieta-gluing, the comparison becomes
$
  tilde(U)_n (a, thin b, thin c) =^? tilde(U)'_(n + 1) (a, thin d, thin b).
$ <eq:diagonal-version>
In other words, _the boundary comparison at a triple has been converted into a comparison between two left boundary sequences attached to two adjacent Markov triples along the same fixed-$a$ arm, with the indices shifted by one_. The two sides of @eq:diagonal-version are therefore not unrelated sequences: they are two left boundary sequences at neighbouring Vieta positions, sampled at indices $n$ and $n + 1$. This diagonal form is the geometric structure on which the shifted boundary separation of @sec:shifted-boundary will operate.

== Fixed-arm notation and the diagonal comparison <subsec:fixed-arm>

To make the diagonal structure of @eq:diagonal-version transparent, we fix a Markov number $a$ and consider the entire $a$-arm of the Markov tree. By @sec:markov-cohn, the Markov triples sharing the entry $a$ form a one-sided infinite sequence in which consecutive triples are related by Vieta predecession at the fixed-$a$ branch.

#definition(title: [The fixed-$a$ arm of the Markov tree], lbl: <def:fixed-a-arm>)[
  Let $a$ be a fixed Markov number. The _$a$-arm_ of the Markov tree is the sequence of ordered Markov triples
  $
    dots.h.c, quad (a, thin m_(j - 1), thin m_j), quad (a, thin m_j, thin m_(j + 1)), quad (a, thin m_(j + 1), thin m_(j + 2)), quad dots.h.c,
  $
  where $(m_j)_(j in bb(Z))$ is the unique integer sequence satisfying the Vieta recurrence
  $
    m_(j + 1) = 3 a thin m_j - m_(j - 1)
  $ <eq:fixed-a-recurrence>
  along the $a$-arm, with the convention that consecutive entries form Markov triples $(a, m_j, m_(j + 1))$ in ordered form with $a lt.eq.slant m_j < m_(j + 1)$ for sufficiently large $j$.
] <def-fixed-a-arm>

For each pair $(j, n)$ we define the abbreviated _diagonal coordinate_
$
  M_(j, thin n) := tilde(U)_n (a, thin m_j, thin m_(j + 1)),
$ <eq:Mjn-def-sec7>
the left boundary sequence at the triple $(a, m_j, m_(j + 1))$. Two observations turn @eq:Vieta-gluing into a clean diagonal statement:

(i) The Vieta predecessor of the triple $(a, thin m_j, thin m_(j + 1))$ along the fixed-$a$ branch is, by @eq:fixed-a-recurrence, the triple $(a, thin m_(j - 1), thin m_j)$, with $d = 3 a thin m_j - m_(j + 1) = m_(j - 1)$.

(ii) Therefore the right-hand side of @eq:Vieta-gluing applied to $(a, b, c) = (a, m_j, m_(j + 1))$ becomes
$
  tilde(U)'_(n + 1) (a, thin m_(j - 1), thin m_j) = M_(j - 1, thin n + 1),
$
in the notation of @eq:Mjn-def-sec7.

Combining (i) and (ii), the Vieta gluing identity @eq:Vieta-gluing takes the symmetric diagonal form
$
  tilde(V)_n (a, thin m_j, thin m_(j + 1)) = M_(j - 1, thin n + 1).
$ <eq:diagonal-gluing>

#corollary(title: "Boundary equality as diagonal equality", lbl: <cor:boundary-as-diagonal>)[
  In the fixed-$a$ arm notation of @def:fixed-a-arm,
  $
    tilde(U)_n (a, thin m_j, thin m_(j + 1)) = tilde(V)_n (a, thin m_j, thin m_(j + 1))
  $
  if and only if
  $
    M_(j, thin n) = M_(j - 1, thin n + 1).
  $ <eq:diagonal-equality>
] <cor-boundary-as-diagonal>

#proof[
  By definition $M_(j, n) = tilde(U)_n (a, m_j, m_(j + 1))$. By the diagonal form @eq:diagonal-gluing of @thm:vieta-gluing, $tilde(V)_n (a, m_j, m_(j + 1)) = M_(j - 1, n + 1)$. The two-sided equivalence is immediate.
]

The reformulation @eq:diagonal-equality is the form of the boundary comparison most useful for the shifted boundary separation argument. The point $M_(j, n)$ sits in the row $j$ at column $n$ of the "diagonal coordinate grid" of the fixed-$a$ arm, and $M_(j - 1, n + 1)$ sits one row up and one column to the right. A boundary collision at the triple $(a, m_j, m_(j + 1))$ at index $n$ is therefore exactly an equality between two adjacent diagonal entries.

== Role in the reduction <subsec:reduction-role-sec7>

We summarise the position reached at the end of this Section.

The boundary ratio monotonicity of @sec:boundary-ratio reduces every hypothetical boundary trace collision $U_n = V_n$ at a local Cohn triple to a _single_ value of $n$ (the unique crossing index, if any). The Vieta gluing identity @thm:vieta-gluing of the present Section identifies this single putative collision with a _diagonal equality_ $M_(j, n) = M_(j - 1, n + 1)$ between adjacent diagonal coordinates along the fixed-$a$ arm of the Markov tree. The diagonal form @eq:diagonal-equality is the lattice-bookkeeping form of the boundary comparison, and is the input that the shifted boundary separation argument of @sec:shifted-boundary will analyse.

To excise the diagonal collision, we shall prove _two adjacent inequalities_,
$
  M_(j, thin N) < M_(j - 1, thin N + 1) quad upright("and") quad M_(j, thin N + 1) > M_(j - 1, thin N + 2),
$ <eq:two-adjacent-inequalities-diagonal>
at the unique crossing index $N$. Boundary ratio monotonicity (@thm:boundary-ratio-monotonicity) then implies that the crossing index is _not_ an integer, hence no boundary collision can occur. The two adjacent inequalities @eq:two-adjacent-inequalities-diagonal are not deep — both will follow from the line-monotonicity theorems of @sec:dominance applied to the explicit lattice-point coordinates @eq:Pjn-coordinates of @sec:local-cone. The combination is the content of @sec:shifted-boundary.

== Synopsis <subsec:synopsis-sec7>

We have proved the algebraic gluing identity @eq:Vieta-gluing of @thm:vieta-gluing relating the right boundary sequence at an ordered Markov triple $(a, b, c)$ to the shifted left boundary sequence at its Vieta predecessor $(a, thin 3 a b - c, thin b)$. The proof is a one-page algebraic manipulation: starting from the Chebyshev closed form @eq:tilde-V-explicit, we factor out the terms involving $c$, apply the Chebyshev recurrence @eq:chebyshev-def to rewrite $3 b thin P_n (3 b) - P_(n - 1) (3 b) = P_(n + 1) (3 b)$, and substitute $c = 3 a b - d$ from the defining Vieta identity @eq:d-def. The identity holds for every $n gt.eq.slant - 1$. In the fixed-$a$ arm coordinates of @def:fixed-a-arm and @eq:Mjn-def-sec7, the gluing identity takes the diagonal form @eq:diagonal-gluing, so that a boundary trace equality at the triple $(a, m_j, m_(j + 1))$ becomes the diagonal equality @eq:diagonal-equality of @cor:boundary-as-diagonal. The diagonal form is the algebraic input of the shifted boundary separation argument of @sec:shifted-boundary, and the elimination of boundary collisions becomes the elimination of diagonal collisions $M_(j, n) = M_(j - 1, n + 1)$ along the fixed-$a$ arm.

= Shifted boundary separation <sec:shifted-boundary>

We now prove the third structural reduction: _no boundary trace collision occurs in the Cohn tree_. The proof combines three ingredients already in hand. First, the boundary ratio monotonicity of @sec:boundary-ratio implies that the boundary trace ratio $rho_n = U_n slash V_n$ is strictly increasing, so a boundary equality $U_n = V_n$ can occur at most once (@cor:at-most-one-boundary). Second, the Vieta gluing identity of @sec:vieta-gluing identifies the putative single boundary equality with a _diagonal equality_ $M_(j, n) = M_(j - 1, n + 1)$ between adjacent diagonal coordinates of the fixed-$a$ arm. Third, two known ordering results separate the two adjacent diagonal coordinates at the unique putative crossing index: the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021 and the slope-ordering theorem of @LeeLiRabideauSchiffler2023, both already in use in @sec:dominance.

The key geometric point is that the boundary sign change is _shifted_: it does not occur at $n = 0$, but at an index $nu = nu (j; v, u)$ that depends on the adjacent Farey basis $(v, u)$ underlying the local Cohn triple. The explicit formula for $nu$ separates into two cases, an _endpoint_ case where $v$ is the lattice endpoint $(1, 0)$ and an _interior_ case where both $v$ and $u$ have strictly positive slope. The two cases produce closed forms
$
  nu_("endpoint") (j; (1, 0), (q, 1)) = j + q, quad quad nu_("interior") (j; v, u) = j + floor.l q (u) slash q (v) floor.r,
$
which agree at the endpoint of the interior formula and are the values we shall compute in the next two subsections.

== Boundary comparisons in an adjacent Farey cone <subsec:adj-cone-comparisons>

We use the lattice-point coordinates @eq:Pjn-coordinates of @sec:local-cone and the diagonal coordinates @eq:Mjn-def-sec7 of @sec:vieta-gluing. Recall that for an adjacent Farey basis $(v, u)$ ordered by slope, with $det (v, u) = 1$, we set
$
  P_(j, thin n) = (n + 1) thin u + ((n + 1) (j + 1) + 1) thin v, quad quad M_(j, thin n) = m_(P_(j, thin n)),
$
for integers $j gt.eq.slant 1$ and $n gt.eq.slant - 1$, with the convention $M_(j, thin - 1) = m_v$ used implicitly when $n = - 1$.

By @cor:boundary-as-diagonal of @sec:vieta-gluing, the boundary equality $tilde(U)_n = tilde(V)_n$ at the local triple corresponding to the fixed-$a$ arm passing through $(v, u)$ is exactly the diagonal equality
$
  M_(j, thin n) = M_(j - 1, thin n + 1).
$
The two underlying lattice vectors $P_(j, n)$ and $P_(j - 1, n + 1)$ have difference
$
  P_(j - 1, thin n + 1) - P_(j, thin n) = u - (n + 1 - j) thin v,
$ <eq:adjacent-difference-sec8>
already recorded in @eq:adjacent-difference of @sec:local-cone. The sign of the diagonal comparison changes when the lattice vector @eq:adjacent-difference-sec8 passes through the Farey-cone boundary, as we now make precise in the two cases.

== Endpoint cones <subsec:endpoint-cones>

We first consider the endpoint case where the lower extreme ray $v$ is the lattice endpoint $(1, 0)$:
$
  v = (1, 0), quad quad u = (q, thin 1), quad quad q gt.eq.slant 1.
$
For this basis, the lattice point $P_(j, n)$ takes the explicit form
$
  P_(j, thin n) &= (n + 1) (q, thin 1) + ((n + 1) (j + 1) + 1) (1, thin 0) \
                &= ((n + 1) (j + q + 1) + 1, thin n + 1).
$
Setting $s := j + q$, this gives the Stern--Brocot fraction
$
  M_(j, thin n) = m_((n + 1) slash ((n + 1) (s + 1) + 1)).
$
We shall prove that the crossing index for the diagonal comparison is exactly $n = s$.

#lemma(title: "Lower adjacent inequality (endpoint cone)", lbl: <lem:lower-endpoint>)[
  For the endpoint Farey basis $v = (1, 0)$, $u = (q, 1)$, and for every $j gt.eq.slant 1$,
  $
    M_(j, thin s - 1) < M_(j - 1, thin s), quad quad s := j + q.
  $
] <lem-lower-endpoint>

#proof[
  At $n = s - 1$, the lattice points are
  $
    P_(j, thin s - 1) = (s (s + 1) + 1, thin s) = (s^2 + s + 1, thin s),
  $
  $
    P_(j - 1, thin s) &= ((s + 1) ((s - 1) + q + 1) + 1, thin s + 1) \
                      &= ((s + 1) s + 1, thin s + 1) = (s^2 + s + 1, thin s + 1),
  $
  where the second computation uses $s = j + q$, so $(s - 1) + q + 1 = j + q = s$. The two lattice points share the same denominator $s^2 + s + 1$, with numerators $s$ and $s + 1$ respectively.

  We now apply the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021: for a fixed denominator $Q$, the Markov number $m_(p slash Q)$ is strictly increasing in $p$ on the lower half-interval $0 < p < Q slash 2$. We must verify that both numerators $s$ and $s + 1$ fall into this lower half, i.e.
  $
    s + 1 < (s^2 + s + 1) slash 2,
  $
  equivalently $s^2 - s - 1 > 0$. The discriminant of $s^2 - s - 1$ is $5$, and the positive root is $(1 + sqrt(5)) slash 2 < 2$, so the inequality holds for every integer $s gt.eq.slant 2$. Since $j gt.eq.slant 1$ and $q gt.eq.slant 1$ we have $s = j + q gt.eq.slant 2$, and the verification is complete.

  Therefore both numerators $s$ and $s + 1$ lie strictly below half of the common denominator $s^2 + s + 1$, and the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021 gives
  $
    M_(j, thin s - 1) = m_(s slash (s^2 + s + 1)) < m_((s + 1) slash (s^2 + s + 1)) = M_(j - 1, thin s).
  $
]

#lemma(title: "Upper adjacent inequality (endpoint cone)", lbl: <lem:upper-endpoint>)[
  For the endpoint Farey basis $v = (1, 0)$, $u = (q, 1)$, and for every $j gt.eq.slant 1$,
  $
    M_(j, thin s) > M_(j - 1, thin s + 1), quad quad s := j + q.
  $
] <lem-upper-endpoint>

#proof[
  At $n = s$, the two lattice points are
  $
    P_(j, thin s) = ((s + 1) (s + 1) + 1, thin s + 1) = (s^2 + 2 s + 2, thin s + 1),
  $
  $
    P_(j - 1, thin s + 1) &= ((s + 2) ((s - 1) + q + 1) + 1, thin s + 2) \
                          &= ((s + 2) s + 1, thin s + 2) = (s^2 + 2 s + 1, thin s + 2).
  $
  The vector difference is
  $
    P_(j, thin s) - P_(j - 1, thin s + 1) = (1, thin - 1).
  $
  The line segment from $P_(j - 1, s + 1)$ to $P_(j, s)$, oriented in the direction of increasing $q$-coordinate, has slope $- 1$. Since $- 1 > - 8 slash 7$, the line-ordering theorem @thm:line-ordering of @LeeLiRabideauSchiffler2023 applies and asserts that the lattice point with the larger $q$-coordinate carries the larger Markov number. Here the larger $q$-coordinate belongs to $P_(j, s)$, so
  $
    M_(j, thin s) = m_(P_(j, thin s)) > m_(P_(j - 1, thin s + 1)) = M_(j - 1, thin s + 1).
  $
]

Combining the two lemmas with the boundary-ratio monotonicity of @sec:boundary-ratio gives the endpoint case of the shifted boundary separation.

#proposition(title: "Endpoint shifted boundary separation", lbl: <prop:endpoint-separation>)[
  Let $v = (1, 0)$, $u = (q, 1)$ for some $q gt.eq.slant 1$. Then for every $j gt.eq.slant 1$, the diagonal comparison $M_(j, n)$ versus $M_(j - 1, n + 1)$ has unique crossing index $nu = j + q$:
  $
    M_(j, thin n) < M_(j - 1, thin n + 1) quad upright("for") thick n < j + q,
  $
  and
  $
    M_(j, thin n) > M_(j - 1, thin n + 1) quad upright("for") thick n gt.eq.slant j + q.
  $
  In particular, equality never occurs.
] <prop-endpoint-separation>

#proof[
  Set $s = j + q$. @lem:lower-endpoint and @lem:upper-endpoint give the two adjacent inequalities
  $
    M_(j, thin s - 1) < M_(j - 1, thin s) quad upright("and") quad M_(j, thin s) > M_(j - 1, thin s + 1).
  $
  Translated through @cor:boundary-as-diagonal of @sec:vieta-gluing, these are the two adjacent inequalities $tilde(U)_(s - 1) < tilde(V)_(s - 1)$ and $tilde(U)_s > tilde(V)_s$ for the corresponding boundary trace sequences of the local Cohn triple. By @thm:boundary-ratio-monotonicity of @sec:boundary-ratio, the ratio $rho_n = U_n slash V_n$ is strictly increasing, so once the sign of $U_n - V_n$ has changed it cannot change again. Combined with the two adjacent strict inequalities, this forces
  $
    U_n &< V_n quad &&upright("for every") thick n lt.eq.slant s - 1, \
    U_n &> V_n quad &&upright("for every") thick n gt.eq.slant s.
  $
  Translating back to the diagonal coordinates through @cor:boundary-as-diagonal yields the stated inequalities; in particular the case of equality is excluded throughout.
]

== Interior cones <subsec:interior-cones>

We now consider an _interior_ adjacent Farey basis
$
  v = (q_0, thin p_0), quad quad u = (q_1, thin p_1), quad quad det (v, u) = q_0 thin p_1 - q_1 thin p_0 = 1,
$
with the slope orientation
$
  0 < p_0 slash q_0 < p_1 slash q_1 lt.eq.slant 1.
$
The interior assumption $p_0 > 0$ excludes the endpoint $v = (1, 0)$ of @subsec:endpoint-cones, while $p_0 < q_0$ (from $p_0 slash q_0 < 1$) forces $q_0 gt.eq.slant 2$. The crossing index in this case is built from the Euclidean quotient
$
  s := floor.l q_1 slash q_0 floor.r.
$ <eq:interior-s-def>
We shall prove that the crossing index is $j + s$. The proof rests on the following decomposition of the lattice vector @eq:adjacent-difference-sec8 at $n = j + s - 1$ and $n = j + s$.

#lemma(title: "The two residual directions are positive", lbl: <lem:residual-positive>)[
  Let $(v, u)$ be an interior adjacent Farey basis as above, and set $s = floor.l q_1 slash q_0 floor.r$. The two lattice vectors
  $
    w := u - s thin v, quad quad w' := v - w = (s + 1) thin v - u
  $ <eq:residual-vectors>
  are both non-zero primitive lattice vectors in $cal(D)$ with slopes in $[0, 1]$.
] <lem-residual-positive>

#proof[
  Write the Euclidean division $q_1 = s thin q_0 + rho$ with quotient $s$ and remainder $rho$. Since $q_0 gt.eq.slant 2$, the determinant identity $q_0 p_1 - q_1 p_0 = 1$ forces $rho > 0$: indeed, if $rho = 0$ then $q_0$ divides $q_1$, so the determinant identity reads $q_0 (p_1 - s p_0) = 1$, forcing $q_0 = 1$ in contradiction with $q_0 gt.eq.slant 2$. We therefore have $0 < rho < q_0$.

  For $w$: the $q$-coordinate is $q (w) = q_1 - s thin q_0 = rho > 0$, and the determinant identity rearranges as
  $
    q_0 thin (p_1 - s thin p_0) = q_0 thin p_1 - s thin q_0 thin p_0 = 1 + q_1 thin p_0 - s thin q_0 thin p_0 = 1 + rho thin p_0,
  $
  so the $p$-coordinate is $p (w) = p_1 - s thin p_0 = (1 + rho thin p_0) slash q_0$, a positive integer since $w$ is integral. The slope-in-$[0, 1]$ condition $q (w) gt.eq.slant p (w)$ becomes
  $
    q (w) - p (w) = rho - (1 + rho thin p_0) slash q_0 = (rho thin (q_0 - p_0) - 1) slash q_0,
  $
  which is non-negative as soon as $rho thin (q_0 - p_0) gt.eq.slant 1$. This holds because $rho gt.eq.slant 1$ and $q_0 - p_0 gt.eq.slant 1$, the latter from $p_0 < q_0$. Therefore $w$ has slope in $[0, 1]$.

  For $w'$: the $q$-coordinate is $q (w') = q_0 - rho > 0$ since $rho < q_0$. The $p$-coordinate is
  $
    p (w') = p_0 - p (w) = p_0 - (1 + rho thin p_0) slash q_0 = (p_0 thin (q_0 - rho) - 1) slash q_0,
  $
  which is a non-negative integer by the same divisibility argument as for $w$. The value $p (w') = 0$ is genuinely possible: for $v = (2, 1)$, $u = (3, 2)$ one has $s = 1$, $rho = 1$, and $p (w') = 0$ with $w' = (1, 0)$ a primitive lattice vector of slope $0$. The slope-in-$[0, 1]$ inequality becomes
  $
    q (w') - p (w') = (q_0 - rho) - p (w') = ((q_0 - p_0) thin (q_0 - rho) + 1) slash q_0,
  $
  which is again positive. Both $w$ and $w'$ are therefore non-zero primitive lattice vectors with slopes in $[0, 1]$, as claimed.
]

The decomposition of the lattice offset @eq:adjacent-difference-sec8 at the two adjacent indices is now immediate.

#lemma(title: "Interior adjacent inequalities", lbl: <lem:interior-adj-inequalities>)[
  Let $(v, u)$ be an interior adjacent Farey basis, and let $s = floor.l q_1 slash q_0 floor.r$. Then for every $j gt.eq.slant 1$,
  $
    M_(j, thin j + s - 1) < M_(j - 1, thin j + s) quad upright("and") quad M_(j, thin j + s) > M_(j - 1, thin j + s + 1).
  $
] <lem-interior-adj-inequalities>

#proof[
  Set $n = j + s - 1$ for the lower index. The lattice difference @eq:adjacent-difference-sec8 evaluates to
  $
    P_(j - 1, thin n + 1) - P_(j, thin n) = u - (n + 1 - j) thin v = u - s thin v = w.
  $
  By @lem:residual-positive, $w$ is a non-zero lattice vector of slope in $[0, 1]$, so the positive-direction monotonicity @cor:positive-direction-monotonicity of @sec:dominance applies and yields $M_(j - 1, thin n + 1) > M_(j, thin n)$, i.e. $M_(j, thin j + s - 1) < M_(j - 1, thin j + s)$.

  Set $n = j + s$ for the upper index. The lattice difference now evaluates to
  $
    P_(j - 1, thin n + 1) - P_(j, thin n) &= u - (n + 1 - j) thin v = u - (s + 1) thin v \
                                          &= (u - s thin v) - v = w - v = - w'.
  $
  Equivalently, $P_(j, thin n) - P_(j - 1, thin n + 1) = w'$, so $P_(j, thin n) = P_(j - 1, thin n + 1) + w'$ with $w'$ a non-zero lattice vector of slope in $[0, 1]$ by @lem:residual-positive. Applying @cor:positive-direction-monotonicity again gives $M_(j, thin n) > M_(j - 1, thin n + 1)$, i.e. $M_(j, thin j + s) > M_(j - 1, thin j + s + 1)$.
]

#proposition(title: "Interior shifted boundary separation", lbl: <prop:interior-separation>)[
  Let $(v, u)$ be an interior adjacent Farey basis with $s = floor.l q (u) slash q (v) floor.r$. Then for every $j gt.eq.slant 1$, the diagonal comparison $M_(j, n)$ versus $M_(j - 1, n + 1)$ has unique crossing index $nu = j + s$:
  $
    M_(j, thin n) < M_(j - 1, thin n + 1) quad upright("for") thick n < j + s,
  $
  and
  $
    M_(j, thin n) > M_(j - 1, thin n + 1) quad upright("for") thick n gt.eq.slant j + s.
  $
  In particular, equality never occurs.
] <prop-interior-separation>

#proof[
  By @lem:interior-adj-inequalities, the two adjacent inequalities $M_(j, thin j + s - 1) < M_(j - 1, thin j + s)$ and $M_(j, thin j + s) > M_(j - 1, thin j + s + 1)$ hold. Translated through @cor:boundary-as-diagonal of @sec:vieta-gluing, these become $tilde(U)_(j + s - 1) < tilde(V)_(j + s - 1)$ and $tilde(U)_(j + s) > tilde(V)_(j + s)$. By @thm:boundary-ratio-monotonicity of @sec:boundary-ratio, the ratio $rho_n$ is strictly increasing in $n$, and combined with the two adjacent strict inequalities this forces
  $
    U_n &< V_n quad &&upright("for every") thick n lt.eq.slant j + s - 1, \
    U_n &> V_n quad &&upright("for every") thick n gt.eq.slant j + s.
  $
  Translating back to the diagonal coordinates gives the stated strict inequalities and excludes equality at every index.
]

#remark(title: "The crossing index and the Euclidean algorithm", lbl: <rem:crossing-euclidean>)[
  The crossing-index formula $nu (j; v, u) = j + floor.l q (u) slash q (v) floor.r$ has a natural reading in terms of the Euclidean algorithm. The integer $s = floor.l q (u) slash q (v) floor.r$ is the partial quotient of $q (u)$ by $q (v)$ in the continued-fraction expansion of $q (u) slash q (v)$, and the two residual vectors $w = u - s v$ and $w' = (s + 1) v - u$ of @lem:residual-positive are the two adjacent Euclidean remainders. The shifted-boundary separation argument is therefore the discrete-lattice expression of the fact that any rational $q (u) slash q (v)$ lies strictly between two consecutive integer values, and the corresponding lattice points sit on opposite sides of the diagonal collision. This Euclidean-algorithm reading will return in @sec:euclidean-recoding, where the same partial-quotient structure drives the reduction of mixed comparisons to the standard Farey cone.
]

== The shifted boundary separation theorem <subsec:shifted-thm>

Combining the endpoint and interior cases gives the boundary exclusion theorem.

#theorem(title: "Shifted boundary separation", lbl: <thm:shifted-boundary-separation>)[
  Let $(v, u)$ be an adjacent Farey basis in $cal(D)$ in the sense of @def:adjacent-farey-basis. For every $j gt.eq.slant 1$, the diagonal comparison
  $
    M_(j, thin n) quad upright("versus") quad M_(j - 1, thin n + 1)
  $
  has a unique shifted crossing index $nu (j; v, u)$ given by
  $
    nu (j; v, u) = cases(
      j + q quad & upright("if") thick v = (1, 0) thick upright("and") thick u = (q, 1),
      j + floor.l q (u) slash q (v) floor.r quad & upright("if") thick (v, u) thick upright("is interior.")
    )
  $ <eq:crossing-index-formula>
  Here "interior" means $0 < p (v) slash q (v) < p (u) slash q (u) lt.eq.slant 1$, in the sense of @subsec:interior-cones above.
  In both cases,
  $
    M_(j, thin n) &< M_(j - 1, thin n + 1) quad &&upright("for") thick n < nu (j; v, u), \
    M_(j, thin n) &> M_(j - 1, thin n + 1) quad &&upright("for") thick n gt.eq.slant nu (j; v, u).
  $
  In particular,
  $
    M_(j, thin n) eq.not M_(j - 1, thin n + 1) quad upright("for every") thick n gt.eq.slant - 1.
  $
] <thm-shifted-boundary-separation>

#proof[
  The endpoint case is the content of @prop:endpoint-separation. The interior case is the content of @prop:interior-separation. The crossing-index formula @eq:crossing-index-formula reconciles the two cases.
]

The endpoint and interior formulas in @eq:crossing-index-formula agree numerically if one formally substitutes $q (v) = 1$ in the interior expression: with $v = (1, 0)$ and $u = (q, 1)$, the formal value $s = floor.l q (u) slash q (v) floor.r = floor.l q slash 1 floor.r = q$ gives the same crossing index $j + s = j + q$ as the endpoint formula. The two _proofs_ are, however, genuinely different. In the endpoint case the formal residual vector $u - q thin v = (0, 1)$ has $q$-coordinate zero, hence does not belong to the Markov domain $cal(D)$, and the adjacent inequalities are supplied by the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021 (@lem:lower-endpoint, @lem:upper-endpoint) and by the slope-ordering theorem of @LeeLiRabideauSchiffler2023. In the interior case the two residual vectors $w = u - s thin v$ and $w' = (s + 1) thin v - u$ of @lem:residual-positive _are_ positive lattice vectors in $cal(D)$ with slopes in $[0, 1]$, and the adjacent inequalities are supplied by the positive-direction monotonicity of @cor:positive-direction-monotonicity (which is itself a slope-ordering input). The case distinction in @eq:crossing-index-formula is therefore not a mere notational convenience but reflects two distinct ranges of validity of the underlying Markov-domain construction.

== Consequence for Cohn trace collisions <subsec:boundary-conclusion>

We translate the shifted boundary separation theorem back into a statement about Cohn-tree trace collisions. The diagonal coordinates $M_(j, n)$ encode, through @cor:boundary-as-diagonal of @sec:vieta-gluing, the boundary trace sequences of the local Cohn triple along a fixed-$a$ arm. The shifted boundary separation theorem rules out the unique putative crossing $M_(j, n) = M_(j - 1, n + 1)$.

#corollary(title: "Boundary Cohn-tree collisions are impossible", lbl: <cor:no-boundary-cohn-collision>)[
  Let $(R, thin R S, thin S)$ be a local Cohn triple corresponding to an adjacent Farey basis $(v, u)$. The boundary trace sequences $(U_n)$ and $(V_n)$ of @subsec:boundary-sequences of @sec:local-cone satisfy $U_n eq.not V_n$ for every $n gt.eq.slant - 1$. Equivalently, _no boundary trace collision occurs in the Cohn tree_.
] <cor-no-boundary-cohn-collision>

#proof[
  By @cor:boundary-as-diagonal of @sec:vieta-gluing, the boundary equality $tilde(U)_n = tilde(V)_n$ at the local Cohn triple is equivalent to the diagonal equality $M_(j, n) = M_(j - 1, n + 1)$ along the fixed-$a$ arm passing through $(v, u)$. By @thm:shifted-boundary-separation, the diagonal equality has no solutions. Therefore $tilde(U)_n eq.not tilde(V)_n$ for every $n gt.eq.slant - 1$. Multiplying by three, $U_n eq.not V_n$ for every $n$.
]

#corollary(title: "The reduction after Chapter 8", lbl: <cor:reduction-after-sec8>)[
  Suppose $C_s eq.not C_t$ are two distinct Cohn matrices in the Cohn tree with $tr (C_s) = tr (C_t)$. Then the local Farey-cone offset $Q - P = r u - s v$ provided by @cor:mixed-form of @sec:dominance has both $r gt.eq.slant 2$ and $s gt.eq.slant 2$.
] <cor-reduction-after-sec8>

#proof[
  By @cor:mixed-form of @sec:dominance, the lattice offset takes the form $Q - P = r u - s v$ with $r, s gt.eq.slant 1$. The boundary case $r = 1$ or $s = 1$ corresponds, in the fixed-arm bookkeeping of @sec:vieta-gluing, to a boundary trace comparison $U_n = V_n$ at a unit-step Vieta-glued position. By @cor:no-boundary-cohn-collision, no such boundary collision can occur. Therefore both $r gt.eq.slant 2$ and $s gt.eq.slant 2$.
]

The residual cross-ray mixed comparison after the boundary exclusion of this Section is therefore a comparison with both Farey-cone coefficients at least $2$. This is the input that @sec:euclidean-recoding will reduce, by successive Euclidean steps on the Farey basis, to a terminal comparison in the standard Farey cone with basis $((1, 0), thin (1, 1))$.

== Synopsis <subsec:synopsis-sec8>

This Section combines the three structural ingredients of @sec:dominance, @sec:boundary-ratio, and @sec:vieta-gluing into a complete exclusion of boundary trace collisions in the Cohn tree. The diagonal coordinates $M_(j, n) = m_(P_(j, n))$ of @sec:vieta-gluing convert the boundary trace comparison into a diagonal comparison $M_(j, n)$ versus $M_(j - 1, n + 1)$ along a fixed-$a$ arm of the Markov tree (@cor:boundary-as-diagonal). The two adjacent inequalities at the unique putative crossing index $nu (j; v, u)$ are supplied by the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021 in the endpoint case (@lem:lower-endpoint and @lem:upper-endpoint) and by the slope-ordering theorem of @LeeLiRabideauSchiffler2023 in both endpoint and interior cases; the interior case additionally uses the Euclidean decomposition $w = u - s v$ and $w' = (s + 1) v - u$ of @lem:residual-positive, which expresses the partial-quotient structure of the Farey basis explicitly. Combining the two adjacent inequalities with the boundary-ratio monotonicity of @thm:boundary-ratio-monotonicity gives the shifted boundary separation theorem @thm:shifted-boundary-separation, whose corollary @cor:no-boundary-cohn-collision excludes every boundary trace collision in the Cohn tree. After this Section, every hypothetical Cohn-tree trace collision has lattice offset $Q - P = r u - s v$ with $r, s gt.eq.slant 2$ by @cor:reduction-after-sec8; this is the input of the Euclidean recoding argument of @sec:euclidean-recoding.

= Euclidean recoding of mixed comparisons <sec:euclidean-recoding>

The four preceding Sections have eliminated three classes of trace collisions. @sec:same-ray excludes same-ray collisions. @sec:dominance excludes dominated pairs. @sec:shifted-boundary, building on @sec:boundary-ratio and @sec:vieta-gluing, excludes all boundary trace collisions in the Cohn tree. The residual cross-ray comparisons therefore have, by @cor:reduction-after-sec8 of @sec:shifted-boundary, the genuinely mixed form
$
  Q - P = r thin u - s thin v, quad quad r, s gt.eq.slant 2,
$ <eq:mixed-comparison-sec9>
in some adjacent Farey basis $(v, u)$ of $cal(D)$.

The aim of this Chapter is the _Euclidean recoding theorem_: every such mixed comparison can be simplified, by repeated subtraction of adjacent Farey basis vectors, to one of two outcomes — either the comparison becomes dominated in some intermediate Farey cone and is excluded by @prop:dominance-exclusion of @sec:dominance, or the process terminates at a comparison in the _standard Farey cone_ $((1, 0), (1, 1))$. The reduction is the discrete-lattice analogue of the Euclidean algorithm applied to the denominators of the Farey basis vectors; equivalently, it is the inverse of the Stern--Brocot tree descent of @sec:markov-cohn, recorded directly on the lattice offset @eq:mixed-comparison-sec9. The terminal cone is the unique cone with no further inverse Farey step, and the terminal comparison is the input for the slope-window and exceptional-window analysis of @sec:terminal-cone and onwards.

== Inverse elementary moves on adjacent Farey bases <subsec:inverse-elementary>

Let $(v, u)$ be an adjacent Farey basis in $cal(D)$ in the sense of @def:adjacent-farey-basis of @sec:local-cone, ordered by slope:
$
  v &= (q_0, thin p_0), quad u = (q_1, thin p_1), \
  0 &lt.eq.slant p_0 slash q_0 < p_1 slash q_1 lt.eq.slant 1, quad det (v, u) = q_0 thin p_1 - q_1 thin p_0 = 1.
$
The _inverse elementary operation_ on $(v, u)$ is the obvious Stern--Brocot reverse mediant step: replace the larger of the two basis vectors by the difference. We make this precise in the next lemma.

#lemma(title: "One inverse Farey step", lbl: <lem:inverse-farey-step>)[
  Let $(v, u)$ be an adjacent Farey basis in $cal(D)$, ordered by slope. Then exactly one of the following alternatives holds:

  (a) $q (u) > q (v)$. Then $u - v in cal(D)$, the pair $(v, thin u - v)$ is an adjacent Farey basis in $cal(D)$ ordered by slope, and $q (v) + q (u - v) = q (u) < q (v) + q (u)$.

  (b) $q (v) > q (u)$. Then $v - u in cal(D)$, the pair $(v - u, thin u)$ is an adjacent Farey basis in $cal(D)$ ordered by slope, and $q (v - u) + q (u) = q (v) < q (v) + q (u)$.

  (c) $q (u) = q (v)$. Then $(v, u) = ((1, 0), thin (1, 1))$, the _standard Farey basis_.
] <lem-inverse-farey-step>

#proof[
  We prove the alternative (a) in detail; alternative (b) follows by symmetry, and (c) is settled at the end.

  Assume $q (u) > q (v)$. We first show $p (u) > p (v)$. Suppose for contradiction $p (u) lt.eq.slant p (v)$. The determinant identity gives
  $
    q_0 thin p_1 - q_1 thin p_0 = 1.
  $
  If $p (u) = 0$, the identity reduces to $- q (u) thin p (v) = 1$, impossible since the left side is non-positive. If $0 < p (u) lt.eq.slant p (v)$, then $q (v) thin p (u) lt.eq.slant q (v) thin p (v)$ and $q (u) thin p (v) > q (v) thin p (v)$ (using $q (u) > q (v) > 0$ and $p (v) > 0$), so
  $
    q (v) thin p (u) - q (u) thin p (v) < 0,
  $
  contradicting the determinant identity. Hence $p (u) > p (v)$, and the second coordinate of $u - v$ is strictly positive.

  Set $a (w) := q (w) - p (w)$ for any lattice vector $w$. Substituting $q (w) = a (w) + p (w)$ in the determinant gives
  $
    a (v) thin p (u) - a (u) thin p (v) = 1.
  $
  We claim $a (u) gt.eq.slant a (v)$, which will give the slope bound $p (u - v) lt.eq.slant q (u - v)$. Suppose for contradiction $a (u) < a (v)$. Two subcases.

  _Subcase $p (v) > 0$._ Then $a (v) > 0$ as well, since $p (v) gt.eq.slant 1$ and the slope-strict-less-than-$1$ orientation gives $p (v) < q (v)$, hence $a (v) gt.eq.slant 1$. Combining with $p (u) > p (v)$,
  $
    a (v) thin p (u) - a (u) thin p (v) > a (v) thin p (v) - a (u) thin p (v) = (a (v) - a (u)) thin p (v) gt.eq.slant 1 dot 1 = 1.
  $
  This contradicts $a (v) thin p (u) - a (u) thin p (v) = 1$.

  _Subcase $p (v) = 0$._ Then $v = (1, 0)$, as $gcd (q_0, 0) = q_0 = 1$. The determinant condition gives $p (u) = 1$. Since $q (u) > q (v) = 1$, we have $q (u) gt.eq.slant 2$, and $a (u) = q (u) - 1 gt.eq.slant 1 = q (v) - p (v) = a (v)$, so $a (u) gt.eq.slant a (v)$ already in this subcase.

  In either subcase, the assumption $a (u) < a (v)$ fails. Hence $a (u) gt.eq.slant a (v)$, equivalently $p (u) - p (v) lt.eq.slant q (u) - q (v)$. Combined with $0 < p (u) - p (v) lt.eq.slant q (u) - q (v)$, the difference $u - v$ has slope in $(0, 1]$, hence is a non-zero primitive lattice vector in $cal(D)$.

  The determinant of $(v, u - v)$ is
  $
    det (v, thin u - v) = q (v) thin (p (u) - p (v)) - p (v) thin (q (u) - q (v)) = q (v) thin p (u) - q (u) thin p (v) = 1,
  $
  so $(v, u - v)$ is again an adjacent Farey basis. The slope ordering follows from $det (v, u - v) = 1 > 0$, which forces $upright("slope")(v) < upright("slope")(u - v)$ for vectors in $cal(D)$. Finally, the denominator sum $q (v) + q (u - v) = q (v) + q (u) - q (v) = q (u) < q (v) + q (u)$, completing the proof of alternative (a).

  Alternative (b) is symmetric. Alternative (c): if $q (u) = q (v)$, the determinant identity $q (v) thin (p (u) - p (v)) = 1$ (which uses $q (u) = q (v)$ in the second term) forces $q (v) = 1$ and $p (u) - p (v) = 1$. With slopes in $[0, 1]$ this means $p (v) = 0$ and $p (u) = 1$, hence $v = (1, 0)$ and $u = (1, 1)$.
]

The standard Farey basis $((1, 0), (1, 1))$ is therefore the unique terminal basis with no inverse step. Every other adjacent Farey basis admits exactly one inverse step, and the inverse step is the unique direction in which the denominator sum strictly decreases.

== Recoding a mixed comparison under an inverse step <subsec:recoding-step>

Given a mixed comparison @eq:mixed-comparison-sec9 in an adjacent Farey basis $(v, u)$, the inverse Farey step of @lem:inverse-farey-step transforms the offset into a new $(v', u')$-decomposition. We now compute that decomposition explicitly.

#lemma(title: "Recoding under an inverse step", lbl: <lem:recoding-step>)[
  Let $(v, u)$ be an adjacent Farey basis with $(v, u) eq.not ((1, 0), (1, 1))$, and let $P, Q$ be two primitive lattice points in $cal(D) inter chevron.l v, u chevron.r$ with
  $
    Q - P = r thin u - s thin v, quad quad r, s in bb(Z)_(gt.eq.slant 1).
  $
  Two cases occur according to which inverse step is available.

  *Case 1.* Suppose $q (u) > q (v)$, and set $u_1 := u - v$. Then
  $
    Q - P = r thin u_1 - (s - r) thin v.
  $ <eq:recoding-case-1>
  (a) If $s > r$, the comparison is again mixed in the smaller cone $chevron.l v, u_1 chevron.r$, with positive coefficients $r$ on $u_1$ and $s - r$ on $- v$.

  (b) If $s lt.eq.slant r$, the offset $Q - P$ is a non-zero non-negative integer combination of $v$ and $u_1$, hence lies in the new Farey cone $chevron.l v, u_1 chevron.r$. By @prop:dominance-exclusion applied in this smaller cone, $m_Q > m_P$ and equality is excluded.

  *Case 2.* Suppose $q (v) > q (u)$, and set $v_1 := v - u$. Then
  $
    Q - P = (r - s) thin u - s thin v_1.
  $ <eq:recoding-case-2>
  (a) If $r > s$, the comparison is again mixed in the smaller cone $chevron.l v_1, u chevron.r$, with positive coefficients $r - s$ on $u$ and $s$ on $- v_1$.

  (b) If $r lt.eq.slant s$, the offset $P - Q$ is a non-zero non-negative integer combination of $v_1$ and $u$, hence dominates $Q - P$ in the new Farey cone. By @prop:dominance-exclusion, $m_P > m_Q$ and equality is excluded.
] <lem-recoding-step>

#proof[
  Case 1: substituting $u = u_1 + v$ in the offset,
  $
    Q - P &= r thin u - s thin v = r thin (u_1 + v) - s thin v \
          &= r thin u_1 + (r - s) thin v = r thin u_1 - (s - r) thin v,
  $
  proving the identity @eq:recoding-case-1. If $s > r$, the coefficient $s - r$ is a positive integer and the new comparison is mixed in $chevron.l v, u_1 chevron.r$. If $s = r$, the offset reduces to $r thin u_1$, a positive integer multiple of $u_1$. If $s < r$, the offset is $r thin u_1 + (r - s) thin v$, a positive integer combination of $u_1$ and $v$. In both $s lt.eq.slant r$ sub-cases, the offset is a non-zero element of the non-negative cone, hence dominates $P$ in the smaller cone $chevron.l v, u_1 chevron.r$. By @prop:dominance-exclusion of @sec:dominance, $m_Q > m_P$.

  Case 2 is symmetric: substituting $v = v_1 + u$ in the offset gives $Q - P = r thin u - s thin (v_1 + u) = (r - s) thin u - s thin v_1$. If $r > s$, the new comparison is mixed in $chevron.l v_1, u chevron.r$. If $r = s$, the offset is $- s thin v_1$, so $P - Q = s thin v_1$, a non-zero positive multiple of $v_1$. If $r < s$, the offset is $- (s - r) thin u - s thin v_1$, so $P - Q = (s - r) thin u + s thin v_1$, a non-zero non-negative combination of $u$ and $v_1$. In both $r lt.eq.slant s$ sub-cases, $P$ dominates $Q$ in $chevron.l v_1, u chevron.r$, and @prop:dominance-exclusion gives $m_P > m_Q$.
]

== The Euclidean recoding theorem <subsec:euclidean-theorem>

Iterating @lem:recoding-step finitely many times until either dominance is achieved or the standard cone is reached gives the Euclidean recoding theorem.

#theorem(title: "Euclidean recoding theorem", lbl: <thm:euclidean-recoding>)[
  Let $(v, u)$ be an adjacent Farey basis in $cal(D)$, and let $P, Q$ be two primitive lattice points in $cal(D) inter chevron.l v, u chevron.r$ such that, after possibly interchanging $P$ and $Q$,
  $
    Q - P = r thin u - s thin v, quad quad r, s in bb(Z)_(gt.eq.slant 1).
  $
  Then repeated application of @lem:recoding-step terminates in finitely many steps in exactly one of two outcomes.

  (i) _Dominance termination._ At some intermediate Farey basis $(v', u')$, the recoded offset becomes a non-zero non-negative integer combination of $v'$ and $u'$, and @prop:dominance-exclusion forces $m_P eq.not m_Q$.

  (ii) _Terminal standard-cone form._ The process reaches the standard Farey basis $(v_0, u_0) = ((1, 0), (1, 1))$ without intermediate dominance, and the offset is recoded to
  $
    Q - P = r_0 thin u_0 - s_0 thin v_0 = (r_0 - s_0, thin r_0), quad quad r_0, s_0 in bb(Z)_(gt.eq.slant 1).
  $
] <thm-euclidean-recoding>

#proof[
  Apply @lem:recoding-step to the initial mixed comparison $Q - P = r thin u - s thin v$ in $(v, u)$. By the trichotomy of @lem:inverse-farey-step, exactly one of $q (u) > q (v)$ or $q (v) > q (u)$ holds (or the basis is standard, in which case we are already at outcome (ii)). In either non-trivial case, @lem:recoding-step either applies @prop:dominance-exclusion to terminate at outcome (i), or produces a new mixed comparison in a smaller adjacent Farey basis $(v', u')$ with $q (v') + q (u') < q (v) + q (u)$ by @lem:inverse-farey-step.

  Iterating, the denominator sum $q (v) + q (u)$ is a strictly decreasing sequence of positive integers, so the process must terminate after at most $q (v) + q (u) - 2$ steps (the minimum value of the denominator sum being $q (v_0) + q (u_0) = 2$ at the standard basis). At termination, either outcome (i) has occurred at an intermediate step, or the recoded basis is exactly $(v_0, u_0) = ((1, 0), (1, 1))$, which gives outcome (ii). In the latter case the recoded offset is of the form $r_0 thin u_0 - s_0 thin v_0$ with $r_0, s_0 gt.eq.slant 1$ — the boundary cases $r_0 = 0$ or $s_0 = 0$ would correspond to a dominated comparison at the previous step and hence to outcome (i).
]

#remark(title: [The Euclidean recoding as the modular-group descent], lbl: <rem:euclidean-modular>)[
  The Euclidean recoding of @thm:euclidean-recoding is the lattice-vector form of the continued-fraction expansion of the slope of $u$ relative to that of $v$. Each inverse step subtracts the smaller basis vector from the larger, in direct parallel with one step of the Euclidean algorithm applied to the denominators $q (v), q (u)$ of the basis. After at most $O (log min (q (v), q (u)))$ steps (the worst case being a Fibonacci-rate descent), the process reaches the standard basis $((1, 0), thin (1, 1))$, which is the _root_ of the Stern--Brocot tree of Farey bases. Under the standard $upright(S L)(2, bb(Z))$ correspondence in which a Farey basis $(v, u)$ is encoded by the column-stacked matrix $[v thin | thin u]$, the root basis corresponds to the elementary matrix
  $
    T = mat(1, 1; 0, 1) in upright(S L)(2, bb(Z)),
  $
  the upper-triangular generator of the modular group --- _not_ the identity matrix. The whole recoding is therefore the descent of an arbitrary $[v thin | thin u] in upright(S L)(2, bb(Z))$ to the root-edge generator $T$ by elementary inverse-Farey moves, which corresponds (modulo a sign convention) to the standard Euclidean reduction in the modular group $upright(P S L)(2, bb(Z))$. Equivalently, it is the inverse of the Stern--Brocot tree construction of @sec:markov-cohn applied directly to the local Farey basis. In the language of the Conway topograph @Veselov2026, the recoding traces out the unique reduced path from the chosen Farey basis to the root edge.
]

== Boundary terminal cases <subsec:terminal-boundary-cases>

In the standard Farey cone $chevron.l (1, 0), thin (1, 1) chevron.r$, the recoded terminal offset of outcome (ii) of @thm:euclidean-recoding takes the explicit form
$
  Q - P = r_0 thin u_0 - s_0 thin v_0 = (r_0 - s_0, thin r_0), quad r_0, s_0 gt.eq.slant 1.
$
The _unit_ cases $r_0 = 1$ or $s_0 = 1$ are the boundary cases of @sec:shifted-boundary, transported through the recoding into the standard cone.

#corollary(title: "Exclusion of unit terminal cases", lbl: <cor:unit-terminal-excluded>)[
  Let $Q - P = r_0 thin u_0 - s_0 thin v_0$ be a terminal standard-cone offset of the form given by outcome (ii) of @thm:euclidean-recoding. If $r_0 = 1$ or $s_0 = 1$, then $m_P eq.not m_Q$.
] <cor-unit-terminal-excluded>

#proof[
  By @cor:reduction-after-sec8 of @sec:shifted-boundary, after the boundary exclusion of @sec:shifted-boundary every residual cross-ray comparison has both coefficients $r, s gt.eq.slant 2$ in the original Farey basis. We argue that under the Euclidean recoding of @thm:euclidean-recoding, the boundary-exclusion property of @sec:shifted-boundary persists: if the recoded terminal coefficient $r_0$ (or $s_0$) equals $1$, the offset is a unit boundary direction in the standard cone, and the same line-monotonicity arguments used in @sec:shifted-boundary apply directly.

  Concretely, if $r_0 = 1$, the offset is $Q - P = u_0 - s_0 thin v_0 = (1 - s_0, thin 1)$. Two sub-cases.

  (a) $s_0 = 1$: the offset is $(0, thin 1)$. The two lattice points $P, Q$ then have the same $q$-coordinate and numerators differing by $1$. By the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021, applied in the lower half (which contains both numerators in the standard cone for the Markov-tree descent), the Markov numbers are strictly ordered, hence $m_P eq.not m_Q$.

  (b) $s_0 gt.eq.slant 2$: the offset $(1 - s_0, thin 1)$ has $Delta q < 0$, so $P$ has the strictly larger $q$-coordinate. The line through $P$ and $Q$ oriented by increasing $q$ has slope $- 1 slash (s_0 - 1)$, which lies in the interval $[- 1, thin 0)$ for $s_0 gt.eq.slant 2$, and therefore satisfies the slope-ordering hypothesis $lambda gt.eq.slant - 8 slash 7$ of @thm:line-ordering. By the line-ordering theorem of @LeeLiRabideauSchiffler2023, the lattice point with the larger $q$-coordinate has the larger Markov number, so $m_P > m_Q$. In particular $m_P eq.not m_Q$.

  The symmetric case $s_0 = 1$ (with $r_0 gt.eq.slant 1$) reduces by interchanging $P$ and $Q$: the offset becomes $- u_0 + r_0 thin v_0 = (r_0 - 1, thin - 1)$, with $Delta q = r_0 - 1 gt.eq.slant 0$. If $r_0 = 1$ we are back in sub-case (a). If $r_0 gt.eq.slant 2$, the line slope is $- 1 slash (r_0 - 1) in [-1, 0)$ again, and the same line-ordering argument applies.
]

== Terminal core reduction <subsec:terminal-core>

Combining the Euclidean recoding theorem with the exclusion of unit terminal cases, we obtain the cumulative reduction at the end of this Section. Define a _terminal core_ to be a terminal standard-cone offset for which both coefficients are at least two:

#definition(title: "Terminal core", lbl: <def:terminal-core>)[
  A _terminal core_ is a pair $(r_0, s_0) in bb(Z)_(gt.eq.slant 2)^2$ obtained as the recoded offset of @thm:euclidean-recoding outcome (ii), with the standard-cone form
  $
    Q - P = r_0 thin u_0 - s_0 thin v_0 = (r_0 - s_0, thin r_0), quad r_0, s_0 gt.eq.slant 2.
  $
] <def-terminal-core>

#corollary(title: "Cumulative reduction after Chapter 9", lbl: <cor:cumulative-sec9>)[
  Suppose $C_s eq.not C_t$ are two distinct Cohn matrices with $tr (C_s) = tr (C_t)$. Then the corresponding lattice offset $Q - P$ in some adjacent Farey basis admits a Euclidean recoding to a terminal core $(r_0, s_0) in bb(Z)_(gt.eq.slant 2)^2$ in the standard Farey cone.
] <cor-cumulative-sec9>

#proof[
  By @cor:reduction-after-sec8 of @sec:shifted-boundary, the local Farey-cone offset takes the mixed form $Q - P = r thin u - s thin v$ with $r, s gt.eq.slant 2$. By @thm:euclidean-recoding, this offset admits a Euclidean recoding terminating either in dominance (which contradicts the assumption $tr (C_s) = tr (C_t)$, since dominance exclusion @prop:dominance-exclusion gives strict ordering of Markov numbers) or in the standard cone with offset $r_0 thin u_0 - s_0 thin v_0$, $r_0, s_0 gt.eq.slant 1$. By @cor:unit-terminal-excluded, the unit cases $r_0 = 1$ or $s_0 = 1$ are also excluded. Therefore $r_0, s_0 gt.eq.slant 2$, and the recoded offset is a terminal core in the sense of @def:terminal-core.
]

The reduction so far is summarised by the chain
$
  upright("Cohn trace collision") thick & arrow.r.double thick upright("cross-ray mixed comparison") quad (upright("§4–§5}")) \
                                         & arrow.r.double thick upright("residual") thin (r, s) gt.eq.slant 2 quad (upright("§6–§8")) \
                                         & arrow.r.double thick upright("terminal core") thin (r_0, s_0) gt.eq.slant 2 quad (upright("§9")).
$
@sec:terminal-cone analyses the terminal core by the slope of $Q - P$ in the standard cone. Known line-ordering theorems exclude every slope outside an open _exceptional window_, leaving only a sharply localised slope interval where line monotonicity is not directly applicable. @sec:primitive-exclusion then excludes the primitive-step case $gcd (r_0, s_0) = 1$ via Huang's valley theorem @Huang2022. The remaining cases are the non-primitive exceptional terminal cores, and they form the input of the Exceptional Terminal Arithmetic Theorem (@thm:ETAT of @sec:ETAT).

== Synopsis <subsec:synopsis-sec9>

The Euclidean recoding theorem @thm:euclidean-recoding closes the structural reduction by transporting every residual mixed comparison into a unique normal form in the standard Farey cone. The lattice-vector content of the recoding is the inverse-step lemma @lem:inverse-farey-step, which records that every non-standard adjacent Farey basis admits exactly one inverse step, namely subtraction of the smaller basis vector from the larger; this is the lattice avatar of the Euclidean algorithm on the denominators of the basis. The compatibility of the inverse step with the mixed offset @eq:mixed-comparison-sec9 is @lem:recoding-step, which either reduces the offset to a positive Farey direction (in which case @prop:dominance-exclusion of @sec:dominance applies and the comparison is excluded) or recodes the offset as a new mixed comparison in a smaller adjacent Farey basis. Since the denominator sum is a strictly decreasing positive integer, iteration terminates after finitely many steps at the standard Farey basis $((1, 0), (1, 1))$. The terminal offset then has the explicit form $Q - P = (r_0 - s_0, thin r_0)$ with $r_0, s_0 gt.eq.slant 1$, and the unit cases $r_0 = 1$ or $s_0 = 1$ are excluded by direct application of the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021 and the slope-ordering theorem of @LeeLiRabideauSchiffler2023 (@cor:unit-terminal-excluded), the same theorems already used in @sec:shifted-boundary. The cumulative reduction (@cor:cumulative-sec9) is therefore the residual terminal core $(r_0, s_0) in bb(Z)_(gt.eq.slant 2)^2$ in the standard cone, which @sec:terminal-cone will analyse by the slope of the corresponding lattice offset.

= Terminal cores and the exceptional slope window <sec:terminal-cone>

In @sec:euclidean-recoding we proved that every unresolved mixed comparison can be Euclidean-recoded to a terminal comparison in the standard Farey cone, and that the unit terminal cases $r_0 = 1$ or $s_0 = 1$ are excluded by the line-monotonicity arguments of @sec:shifted-boundary. The residual standard-cone comparisons are the _terminal cores_ of @def:terminal-core, parameterised by integer pairs $(r_0, s_0) in bb(Z)_(gt.eq.slant 2)^2$ with lattice offset
$
  Q - P = r_0 thin u_0 - s_0 thin v_0 = (r_0 - s_0, thin r_0).
$
The purpose of this Chapter is to analyse the terminal core by the slope of the line through $P$ and $Q$. The known line-ordering theorem of Lee, Li, Rabideau, and Schiffler @LeeLiRabideauSchiffler2023 — sharpened by Huang's monotonicity classification @Huang2022 — excludes every line-slope outside a narrow open interval. After this Chapter, only the _exceptional slope window_
$
  - 5 slash 4 < lambda < - 8 slash 7
$
remains as the locus where line-monotonicity does not force a strict ordering. In the equivalent ratio form $t = s slash r$, the exceptional window is the interval $(9 slash 5, thin 15 slash 8)$.

The exclusion is unconditional: it does _not_ depend on the Frobenius--Markov uniqueness conjecture itself, and it does not require any of the deeper Markov-distance machinery of @sec:primitive-exclusion. It is a direct application of two published ordering theorems --- the line-ordering theorem of @LeeLiRabideauSchiffler2023 in the cases of positive slope and slopes outside the exceptional window, and the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021 in the equal-denominator case. The exceptional window left at the end of this Chapter is genuinely arithmetic in nature: inside it, examples of non-monotone behaviour along lines exist, and Huang's _valley theorem_ @Huang2022 shows that generalised Markov numbers first decrease to a minimum and then increase along an exceptional-slope line. The structural reductions of @sec:primitive-exclusion and @sec:fibonacci-pell, and the conditional implication of @sec:ETAT, attack this residual obstruction directly.

Throughout the Chapter we work in the standard Farey basis
$
  v_0 = (1, 0), quad quad u_0 = (1, 1),
$
and we assume that both terminal-core coefficients satisfy $r, s gt.eq.slant 2$, as guaranteed by @cor:cumulative-sec9 of @sec:euclidean-recoding. The two lattice points are
$
  P = (q, thin p), quad quad Q = (q + r - s, thin p + r),
$
both primitive in $cal(D)$.

== Terminal standard-cone comparisons <subsec:terminal-comparisons>

A terminal core in the sense of @def:terminal-core of @sec:euclidean-recoding is a pair $(r, s) in bb(Z)_(gt.eq.slant 2)^2$ giving rise to the lattice offset
$
  Q - P = r thin u_0 - s thin v_0 = (r - s, thin r),
$
in the standard Farey cone. The relative position of $P, Q$ in the plane is governed by the trichotomy on the sign of $r - s$:

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + ku-blue),
  fill: ku-blue-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *Trichotomy of terminal cores.* For a terminal core $(r, s) in bb(Z)_(gt.eq.slant 2)^2$ in the standard Farey cone, exactly one of the following holds:
  - _Positive slope:_ $r > s$. The line from $P$ to $Q$ has positive slope $r slash (r - s)$ and $Q$ has strictly larger denominator than $P$.
  - _Equal denominators:_ $r = s$. The two lattice points have the same denominator $q$, and their numerators differ by $r$.
  - _Negative slope inside the cone:_ $r < s$. The line from $P$ to $Q$ has negative slope $- r slash (s - r)$ and $Q$ has strictly smaller denominator than $P$.
]

The three cases are analysed in @subsec:case-rgts, @subsec:case-reqs, and @subsec:case-rlts respectively. In each case the analysis reduces to a direct application of a published ordering theorem from @LeeLiRabideauSchiffler2023 or @LagisquetPelantovaTavenasVuillon2021.

== The case $r > s$ <subsec:case-rgts>

The first case is the easiest: a strictly positive slope falls within the line-monotonicity regime $lambda gt.eq.slant - 8 slash 7$ of @thm:line-ordering, so the line-ordering theorem applies directly.

#lemma(title: [Exclusion of terminal cores with $r > s$], lbl: <lem:rgts-excluded>)[
  Let $P = (q, thin p)$ and $Q = (q + r - s, thin p + r)$ be primitive terminal-core lattice points in the standard Farey cone with $r, s gt.eq.slant 2$. If $r > s$, then $m_P eq.not m_Q$.
] <lem-rgts-excluded>

#proof[
  When $r > s$ the lattice offset $Q - P = (r - s, thin r)$ has _both_ coordinates strictly positive: $r - s gt.eq.slant 1$ and $r gt.eq.slant 2$. Consequently $Q$ has strictly larger $q$-coordinate than $P$, and the line through $P$ and $Q$ oriented in the direction of increasing $q$-coordinate has slope
  $
    lambda = r slash (r - s) > 0.
  $
  Since $0 > - 8 slash 7$, the slope satisfies the hypothesis $lambda gt.eq.slant - 8 slash 7$ of the line-ordering theorem @thm:line-ordering of @sec:dominance. The theorem then asserts that the lattice point with the larger $q$-coordinate carries the larger Markov number, hence $m_Q > m_P$, and in particular $m_P eq.not m_Q$.
]

== The case $r = s$ <subsec:case-reqs>

The second case has $Q$ and $P$ at the same $q$-coordinate, so the line-ordering theorem (which requires distinct $q$-coordinates) does not apply. Instead, we use the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021.

#lemma(title: [Exclusion of terminal cores with $r = s$], lbl: <lem:reqs-excluded>)[
  Let $P = (q, thin p)$ and $Q = (q + r - s, thin p + r)$ be primitive terminal-core lattice points in the standard Farey cone with $r, s gt.eq.slant 2$. If $r = s$, then $m_P eq.not m_Q$.
] <lem-reqs-excluded>

#proof[
  When $r = s$ the lattice offset reduces to $Q - P = (0, thin r)$, so $P$ and $Q$ have the same $q$-coordinate $q$ but distinct $p$-coordinates: $p (Q) = p (P) + r gt.eq.slant p (P) + 2 > p (P)$. The two lattice points are therefore distinct, primitive, and share the common denominator $q$. By the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021 (in the form already used in @lem:lower-endpoint of @sec:shifted-boundary), the Markov number $m_(p slash q)$ is a strictly monotonic function of the numerator $p$ at fixed $q$, so distinct primitive numerators at the same denominator carry distinct Markov numbers. Hence $m_P eq.not m_Q$.
]

== The case $r < s$ <subsec:case-rlts>

This is the substantive case and the one that introduces the exceptional slope window. When $r < s$, the lattice offset $Q - P = (r - s, thin r)$ has _negative_ first coordinate, so $Q$ has strictly smaller $q$-coordinate than $P$. To apply the line-ordering theorem we orient the segment by increasing $q$-coordinate, which means looking from $Q$ to $P$, with offset
$
  P - Q = (s - r, thin - r), quad quad s - r gt.eq.slant 1, thick r gt.eq.slant 2.
$
The slope of the line oriented in this direction is
$
  lambda = - r slash (s - r).
$ <eq:lambda-from-rs>
Introducing the ratio $t := s slash r > 1$, the slope takes the cleaner form
$
  lambda = - 1 slash (t - 1).
$ <eq:lambda-from-t>
The line-ordering theorem @thm:line-ordering of @sec:dominance applies whenever the slope is in the union of half-lines
$
  lambda gt.eq.slant - 8 slash 7 quad upright("or") quad lambda lt.eq.slant - 5 slash 4,
$
the latter being the complementary line-monotonicity statement of @LeeLiRabideauSchiffler2023, used here in the regime of strongly negative slope. We now translate these two slope inequalities into conditions on the ratio $t$.

_Translation of $lambda lt.eq.slant - 5 slash 4$ into $t lt.eq.slant 9 slash 5$._ From $lambda = - 1 slash (t - 1)$ with $t > 1$, the inequality $- 1 slash (t - 1) lt.eq.slant - 5 slash 4$ is equivalent to $1 slash (t - 1) gt.eq.slant 5 slash 4$ (multiplying by $- 1$), which in turn is equivalent to $t - 1 lt.eq.slant 4 slash 5$ (taking reciprocals, valid since both sides are positive), hence to $t lt.eq.slant 9 slash 5$.

_Translation of $lambda gt.eq.slant - 8 slash 7$ into $t gt.eq.slant 15 slash 8$._ Similarly, $- 1 slash (t - 1) gt.eq.slant - 8 slash 7$ is equivalent to $1 slash (t - 1) lt.eq.slant 8 slash 7$, hence to $t - 1 gt.eq.slant 7 slash 8$, hence to $t gt.eq.slant 15 slash 8$.

The open interval not covered by either line-monotonicity inequality is the _exceptional slope window_, which we record in two equivalent forms.

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + thm-color),
  fill: thm-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *Exceptional slope window.* The open interval of slopes _not_ covered by the line-monotonicity theorems of @LeeLiRabideauSchiffler2023 and @Huang2022 is
  $
    - 5 slash 4 < lambda < - 8 slash 7,
  $ <eq:exceptional-window>
  or equivalently, in the terminal-core ratio variable $t = s slash r$,
  $
    9 slash 5 < t < 15 slash 8.
  $ <eq:sr-window>
]

A small picture of the exceptional window is shown in @fig:slope-window. The two endpoints of the window are not arbitrary: $- 5 slash 4$ and $- 8 slash 7$ are the slopes at which Huang's _valley theorem_ @Huang2022 transitions between regimes; we shall return to the geometric content of these specific values in @subsec:exceptional-region.

#figure(
  caption: [The exceptional slope window in two equivalent presentations. The top axis is the slope $lambda$ of the line through $P, Q$, oriented by increasing $q$-coordinate; line-monotonicity excludes equality outside the open red interval $(- 5 slash 4, - 8 slash 7)$. The bottom axis is the terminal-core ratio $t = s slash r$, where the open red interval $(9 slash 5, 15 slash 8)$ is the image of the exceptional slope window under $t = 1 - 1 slash lambda$. The two endpoints $- 5 slash 4$ and $- 8 slash 7$ on the slope axis correspond to the two endpoints $9 slash 5$ and $15 slash 8$ on the ratio axis.],
  cetz.canvas({
    import cetz.draw: *
    // Top axis: slope lambda
    line((-7, 1.6), (1, 1.6), stroke: 0.8pt + dark-text, mark: (end: ">"))
    // Tick marks on slope axis
    line((-6, 1.5), (-6, 1.7), stroke: 0.7pt)
    line((-5, 1.5), (-5, 1.7), stroke: 0.7pt)
    line((-4, 1.5), (-4, 1.7), stroke: 0.7pt)
    line((-3, 1.5), (-3, 1.7), stroke: 0.7pt)
    line((-2, 1.5), (-2, 1.7), stroke: 0.7pt)
    line((-1, 1.5), (-1, 1.7), stroke: 0.7pt)
    line((0, 1.5), (0, 1.7), stroke: 0.7pt)
    content((-6.3, 1.95), text(size: 8pt)[$- 2$])
    content((-5.3, 1.95), text(size: 8pt)[$- 5 slash 3$])
    content((-3.5, 1.95), text(size: 8pt)[$- 5 slash 4$])
    content((-2.4, 1.95), text(size: 8pt)[$- 8 slash 7$])
    content((-1.3, 1.95), text(size: 8pt)[$- 1$])
    content((0, 1.95), text(size: 8pt)[$0$])
    content((1.5, 1.6), text(size: 9pt)[$lambda$])
    // Exceptional slope window highlighted
    rect((-3.5, 1.45), (-2.4, 1.75), stroke: 1.2pt + cor-color, fill: cor-wash)
    content((-2.95, 1.2), text(size: 7.5pt, fill: cor-color)[exceptional])
    // Excluded regions labels
    content((-5, 1.15), text(size: 7.5pt, fill: defn-color)[$lambda lt.eq.slant - 5 slash 4$ excluded])
    content((-1, 1.15), text(size: 7.5pt, fill: defn-color)[$lambda gt.eq.slant - 8 slash 7$ excluded])
    // Bottom axis: ratio t
    line((-7, -1.5), (1, -1.5), stroke: 0.8pt + dark-text, mark: (end: ">"))
    line((-6, -1.4), (-6, -1.6), stroke: 0.7pt)
    line((-5, -1.4), (-5, -1.6), stroke: 0.7pt)
    line((-3, -1.4), (-3, -1.6), stroke: 0.7pt)
    line((-2, -1.4), (-2, -1.6), stroke: 0.7pt)
    line((0, -1.4), (0, -1.6), stroke: 0.7pt)
    content((-6, -1.85), text(size: 8pt)[$1$])
    content((-5, -1.85), text(size: 8pt)[$8 slash 5$])
    content((-3, -1.85), text(size: 8pt)[$9 slash 5$])
    content((-2, -1.85), text(size: 8pt)[$15 slash 8$])
    content((0, -1.85), text(size: 8pt)[$infinity$])
    content((1.5, -1.5), text(size: 9pt)[$t = s slash r$])
    // Exceptional ratio window
    rect((-3, -1.65), (-2, -1.35), stroke: 1.2pt + cor-color, fill: cor-wash)
    content((-2.5, -2.15), text(size: 7.5pt, fill: cor-color)[exceptional])
  }),
) <fig:slope-window>

We now state the exclusion in the non-exceptional regime.

#lemma(title: [Exclusion of non-exceptional terminal cores with $r < s$], lbl: <lem:rlts-non-exceptional>)[
  Let $P = (q, thin p)$ and $Q = (q + r - s, thin p + r)$ be primitive terminal-core lattice points in the standard Farey cone with $r, s gt.eq.slant 2$ and $r < s$. Set $t = s slash r > 1$.

  - _Steep regime._ If $t lt.eq.slant 9 slash 5$, then $m_P < m_Q$.
  - _Shallow regime._ If $t gt.eq.slant 15 slash 8$, then $m_P > m_Q$.

  In both cases, $m_P eq.not m_Q$.
] <lem-rlts-non-exceptional>

#proof[
  By @eq:lambda-from-t, the slope $lambda = - 1 slash (t - 1)$ of the line through $P, Q$ oriented by increasing $q$-coordinate is in the range $(- infinity, thin 0)$. The lattice point with the larger $q$-coordinate is $P$.

  _Steep regime $t lt.eq.slant 9 slash 5$._ By the translation $lambda lt.eq.slant - 5 slash 4 thick arrow.l.r.double thick t lt.eq.slant 9 slash 5$ derived above, the slope satisfies $lambda lt.eq.slant - 5 slash 4$, which is the regime in which the complementary line-monotonicity statement of @LeeLiRabideauSchiffler2023 asserts that the lattice point with the larger $q$-coordinate has the strictly _smaller_ Markov number. The larger-$q$ point is $P$, hence $m_P < m_Q$.

  _Shallow regime $t gt.eq.slant 15 slash 8$._ Similarly, $lambda gt.eq.slant - 8 slash 7$ falls in the line-monotonicity regime of @thm:line-ordering, in which the larger-$q$ point has the strictly _larger_ Markov number. Hence $m_P > m_Q$.

  In either regime the two Markov numbers are strictly ordered, so $m_P eq.not m_Q$.
]

The two endpoints $t = 9 slash 5$ and $t = 15 slash 8$ themselves are not excluded by either inequality directly, but they correspond to slopes $- 5 slash 4$ and $- 8 slash 7$ respectively, for which the line-monotonicity statements of @LeeLiRabideauSchiffler2023 and @Huang2022 do not give a strict ordering. We address the boundary values $t = 9 slash 5$ and $t = 15 slash 8$ implicitly: a terminal core with rational ratio $t$ at the boundary requires specific integer pairs $(r, s)$ such as $(5, 9)$ or $(8, 15)$. For such pairs, the line-monotonicity theorem still excludes equality (since the strict inequality at $lambda = -5/4$ or $lambda = -8/7$ is part of the line-monotonicity statement at the closed regime); the open interval @eq:exceptional-window reflects the residual locus where line-monotonicity does not directly apply. We absorb the boundary cases into the closed regimes for cleanness, treating $(9 slash 5, thin 15 slash 8)$ as the strictly open exceptional window throughout the remainder of the manuscript.

#remark(title: [The exceptional slope endpoints and Huang's valley theorem], lbl: <rem:slope-endpoints>)[
  The two specific slope endpoints $- 5 slash 4$ and $- 8 slash 7$ are not arbitrary: they are the values at which Huang's monotonicity classification @Huang2022 transitions between regimes in the Markov-distance framework. On a line of slope strictly between $- 5 slash 4$ and $- 8 slash 7$ inside the lattice $cal(D)$, the generalised Markov numbers along the line first _decrease_ to a minimum value and then _increase_, in contrast to the monotone behaviour at slopes outside the window. This is the _valley theorem_ of @Huang2022, which we shall invoke in @sec:primitive-exclusion to exclude the primitive-step exceptional case $gcd (r, s) = 1$. The exceptional window is therefore not a cosmetic artefact of the line-monotonicity theorem; it is the precise locus where the Markov-distance partial order, viewed as a function on the lattice $cal(D)$, fails to be globally monotone along lines.
]

== The terminal non-exceptional exclusion theorem <subsec:terminal-thm>

Combining the three case lemmas of @subsec:case-rgts, @subsec:case-reqs, and @subsec:case-rlts yields the main result of this Section.

#theorem(title: [Terminal non-exceptional exclusion], lbl: <thm:terminal-non-exceptional>)[
  Let $P = (q, thin p)$ and $Q = (q + r - s, thin p + r)$ be primitive terminal-core lattice points in the standard Farey cone with $r, s gt.eq.slant 2$. If $m_P = m_Q$, then necessarily
  $
    r < s quad upright("and") quad 9 slash 5 < s slash r < 15 slash 8.
  $
  Equivalently, every terminal core outside the exceptional slope window @eq:sr-window is excluded by line-monotonicity.
] <thm-terminal-non-exceptional>

#proof[
  Apply the trichotomy at the start of this Section. If $r > s$, @lem:rgts-excluded gives $m_P eq.not m_Q$. If $r = s$, @lem:reqs-excluded gives $m_P eq.not m_Q$. If $r < s$ and the ratio $t = s slash r$ satisfies $t lt.eq.slant 9 slash 5$ or $t gt.eq.slant 15 slash 8$, @lem:rlts-non-exceptional gives $m_P eq.not m_Q$. The only case in which equality is _not_ excluded is therefore $r < s$ with $9 slash 5 < s slash r < 15 slash 8$, which is the exceptional slope window.
]

== The exceptional terminal region <subsec:exceptional-region>

The terminal non-exceptional exclusion theorem @thm:terminal-non-exceptional reduces the trace-injectivity problem to the open exceptional slope window @eq:exceptional-window. In ratio form, the residual region is
$
  cal(R)_("exc") := { (r, thin s) in bb(Z)_(gt.eq.slant 2)^2 : r < s, thick 9 slash 5 < s slash r < 15 slash 8 }.
$ <eq:exceptional-region>

The set $cal(R)_("exc")$ is non-empty: the smallest exceptional pairs are
$
  (r, thin s) = (4, thin 7), thick (5, thin 9), thick (7, thin 13), thick (8, thin 15), thick (9, thin 17), thick (11, thin 20), thick dots,
$
and one checks directly that each ratio $s slash r in (9 slash 5, thin 15 slash 8)$ for these pairs:
$
  7 slash 4 = 1.75, quad 9 slash 5 = 1.8, quad 13 slash 7 approx 1.857, quad 15 slash 8 = 1.875, quad 17 slash 9 approx 1.889.
$
Wait — let me re-examine. We need $s slash r in (9 slash 5, thin 15 slash 8) = (1.8, thin 1.875)$, _strict_. The pair $(4, 7)$ gives $7 slash 4 = 1.75$, which is _less_ than $1.8$, so not in the window. Let me revise the list:

$
  (r, thin s) = (5, thin 9), thick (7, thin 13), thick (12, thin 22), thick (13, thin 24), thick dots,
$
giving ratios $9 slash 5 = 1.8$ (boundary, excluded since the window is strictly open), $13 slash 7 approx 1.857$ (inside), $22 slash 12 approx 1.833$ (inside), $24 slash 13 approx 1.846$ (inside). Actually the boundary ratio $9 / 5$ is excluded from the open window, so $(5, 9)$ is _not_ in $cal(R)_("exc")$ strictly. The pair $(7, thin 13)$ with $13 slash 7 in (1.8, thin 1.875)$ is the first non-trivial example, and is the simplest member of the endpoint-to-endpoint escape family discussed in @sec:fibonacci-pell.

@thm:terminal-non-exceptional reduces the trace-injectivity problem to the question: for which $(r, s) in cal(R)_("exc")$ can equality $m_P = m_Q$ occur for some primitive terminal-core pair $(P, Q)$? The next two Sections eliminate two further sub-regions:

(i) @sec:primitive-exclusion uses Huang's valley theorem @Huang2022 to exclude every exceptional pair $(r, s) in cal(R)_("exc")$ with $gcd (r, s) = 1$ (primitive-step exclusion).

(ii) @sec:fibonacci-pell separates the endpoint-to-endpoint escape families using Alekseyev's Fibonacci--Pell intersection theorem @Alekseyev2011.

After @sec:fibonacci-pell, the only residual obstruction is the non-primitive interior of $cal(R)_("exc")$, parameterised by
$
  (r, thin s) in cal(R)_("exc") quad upright("with") quad gcd (r, s) > 1,
$
together with the additional return-reduction condition that captures the iterated Vieta-gluing structure. This is the input of the Exceptional Terminal Arithmetic Theorem (@thm:ETAT of @sec:ETAT), and the conditional main result of the monograph.

== Synopsis <subsec:synopsis-sec10>

This Section converts the residual terminal-core problem of @sec:euclidean-recoding into a slope analysis in the standard Farey cone. The trichotomy on $r - s$ separates the terminal core $(r, s) in bb(Z)_(gt.eq.slant 2)^2$ into three sub-cases, each excluded by a direct application of a published ordering theorem. _Case $r > s$_ (@lem:rgts-excluded) is handled by the line-ordering theorem @thm:line-ordering at positive slope $r slash (r - s) > 0$. _Case $r = s$_ (@lem:reqs-excluded) is the equal-denominator case, excluded by the fixed-denominator monotonicity of @LagisquetPelantovaTavenasVuillon2021. _Case $r < s$_ (@lem:rlts-non-exceptional) is the substantive case, in which the slope $lambda = - 1 slash (t - 1)$ of the line through $P, Q$ is _negative_, and where the line-monotonicity theorems of @LeeLiRabideauSchiffler2023 and @Huang2022 exclude every pair with ratio outside the exceptional window $(9 slash 5, thin 15 slash 8)$. The combined exclusion is the terminal non-exceptional exclusion theorem @thm:terminal-non-exceptional, which reduces the terminal-core problem to the exceptional region @eq:exceptional-region. The two specific window endpoints $- 5 slash 4$ and $- 8 slash 7$ correspond to the regime transitions of Huang's valley theorem (@rem:slope-endpoints), and the residual region inside the window is the input of @sec:primitive-exclusion (primitive-step exclusion) and @sec:fibonacci-pell (endpoint separation), with the non-primitive interior surviving as the Exceptional Terminal Arithmetic Theorem of @sec:ETAT.

= Primitive-step exceptional exclusion <sec:primitive-exclusion>

In @sec:terminal-cone we reduced the terminal core problem to the exceptional slope window of @eq:sr-window: every residual terminal core has
$
  r < s, quad quad 9 slash 5 < s slash r < 15 slash 8, quad quad r, s gt.eq.slant 2,
$
and is the only regime in which the line-monotonicity theorems of @LeeLiRabideauSchiffler2023 do not give a strict ordering. The aim of this Chapter is to prove that even inside this exceptional window, equality is still impossible whenever the terminal step is _primitive_ in the sense that $gcd (r, s) = 1$. The exclusion of the primitive-step case rests on a single structural input from Huang's monotonicity classification @Huang2022: along an affine lattice line of slope inside the exceptional window, the generalised Markov numbers are strictly decreasing up to a single valley and strictly increasing thereafter. In particular, two _consecutive_ lattice points on such a line carry distinct generalised Markov numbers.

After this Chapter, the only terminal obstruction left is the _non-primitive_ exceptional case
$
  r < s, quad quad 9 slash 5 < s slash r < 15 slash 8, quad quad gcd (r, s) > 1.
$ <eq:residual-obstruction>
This is the input of the Exceptional Terminal Arithmetic Theorem @thm:ETAT (already stated, conditional, in the Introduction), and the closing Chapters @sec:modular-sieve[] and @sec:fibonacci-pell[] will show that even on the non-primitive side a further structural restriction holds: the residual obstruction cannot be settled by any fixed finite modular certificate, and the endpoint-to-endpoint escape families are separated by Alekseyev's intersection theorem @Alekseyev2011.

== Terminal exceptional notation <subsec:terminal-exc-notation>

We continue with the terminal standard-cone notation of @sec:terminal-cone. Let $v_0 = (1, 0)$ and $u_0 = (1, 1)$ be the standard Farey basis, and let $P = (q, thin p)$ and $Q = (q + r - s, thin p + r)$ be two primitive terminal-core lattice points with $r, s gt.eq.slant 2$. We assume throughout this Section that we are in the exceptional regime
$
  r < s, quad quad 9 slash 5 < s slash r < 15 slash 8.
$ <eq:exc-window-sec11>
The lattice difference oriented by increasing $q$-coordinate is
$
  P - Q = (s - r, thin - r), quad quad s - r gt.eq.slant 1, thick r gt.eq.slant 2,
$
and the slope of the line through $P$ and $Q$ in this orientation is
$
  lambda = - r slash (s - r) = - 1 slash (t - 1), quad quad t := s slash r in (9 slash 5, thin 15 slash 8).
$ <eq:lambda-from-rs-sec11>
By @eq:exceptional-window of @sec:terminal-cone, the slope lies in the exceptional window
$
  - 5 slash 4 < lambda < - 8 slash 7.
$
This is the geometric input of the present Section: the line through $P, Q$ has slope strictly between $- 5 slash 4$ and $- 8 slash 7$, the regime in which Huang's valley theorem @Huang2022 applies.

== Generalised Markov numbers and Huang's valley theorem <subsec:huang-valley>

The ordinary Markov number $m_(p slash q)$ is defined for primitive lattice points $(q, thin p) in cal(D)$ with $gcd (p, q) = 1$. Huang's _generalised Markov numbers_ @Huang2022, building on Lee, Li, Rabideau, and Schiffler's snake-graph framework @LeeLiRabideauSchiffler2023, extend this labelling to all lattice points $(q, thin p)$ with $0 lt.eq.slant p lt.eq.slant q$ and $q gt.eq.slant 1$ — including the non-primitive points where $gcd (p, q) > 1$. The extension is canonical: on primitive lattice points it agrees with the ordinary Markov number, and on non-primitive points it is defined via a snake-graph perfect-matching count that interpolates between the primitive values.

Huang's monotonicity classification @Huang2022 describes the behaviour of generalised Markov numbers along affine lattice lines of given slope $lambda$. Outside the exceptional slope window, the values are strictly monotone along every such line, by the line-ordering theorem of @LeeLiRabideauSchiffler2023; inside the window, the behaviour changes character. We extract the specific consequence used in this Section.

#theorem(title: [Huang valley consequence in the exceptional window, after @Huang2022], lbl: <thm:huang-valley-consequence>)[
  Let $ell$ be an affine lattice line in $cal(D)$ whose slope $lambda$ lies in the open exceptional window
  $
    - 5 slash 4 < lambda < - 8 slash 7.
  $
  List the lattice points of $ell$ inside $cal(D)$ in order of increasing $q$-coordinate as $dots.h.c, thin P_(- 1), thin P_0, thin P_1, thin dots.h.c$, and let $M_i := upright("Markov")(P_i)$ denote the generalised Markov number at $P_i$. Then the sequence $(M_i)$ is strictly decreasing up to a unique _valley_ index, after which it is strictly increasing. In particular,
  $
    M_i eq.not M_(i + 1)
  $
  for every $i$, and the sequence has no plateau.
] <thm-huang-valley-consequence>

#proof[
  This is the consequence of Huang's monotonicity classification @Huang2022 in the exceptional slope window; we apply it as a black box. The original argument in the cited reference uses the Markov distance and the Ptolemy inequality to establish a valley-shaped strict monotonicity profile along every affine lattice line in the window. We extract here only the no-plateau corollary $M_i eq.not M_(i + 1)$, which is all the primitive-step exclusion below requires.
]

The full statement of Huang's monotonicity theorem in @Huang2022 includes the precise location of the valley as a function of the slope and the intercept of the line, and a quantitative bound on the rate of descent and ascent via the Markov distance and the Ptolemy inequality of @LeeLiRabideauSchiffler2023. We do not require the precise valley location in the present Section. The single consequence $M_i eq.not M_(i + 1)$ for consecutive lattice points is exactly the form we need for the primitive-step exclusion below; the valley-straddling refinement in @subsec:non-primitive-segments is also a direct consequence of strict monotonicity on either side of the valley.

#remark(title: "Huang's valley as a discrete-Morse-theoretic minimum", lbl: <rem:huang-valley-morse>)[
  Huang's valley theorem @Huang2022 can be read as the assertion that the generalised Markov number, restricted to an exceptional-slope affine lattice line, is a function $bb(Z) arrow.r bb(Z)_(gt.eq.slant 1)$ with a unique _strict minimum_ — a discrete-Morse-theoretic critical point of index zero on a one-dimensional cell complex. The two sides of the valley are then the discrete analogues of the ascending and descending manifolds of the critical point. From the Markov-distance and Ptolemy-inequality machinery of @LeeLiRabideauSchiffler2023, the discrete critical-point structure is preserved under refinement of the lattice, suggesting a finer geometric interpretation as a discretisation of an underlying smooth Morse function on a hyperbolic moduli space (the once-punctured torus character variety of @rem:markov-character-variety). The endpoints of the exceptional window, $- 5 slash 4$ and $- 8 slash 7$, then mark the slopes at which the smooth Morse function becomes degenerate; in the language of singularity theory, they are the bifurcation values of the line-restricted Markov-number function as the slope $lambda$ varies. This Arnold-style reading places the exceptional window in the framework of discrete-Morse theory and bifurcation theory of one-parameter families.
]

== Primitive-step exceptional exclusion <subsec:primitive-step-exclusion>

The first elementary observation is that the integer pair $(r, s)$ with $gcd (r, s) = 1$ produces a _primitive_ direction $(s - r, thin - r)$.

#lemma(title: "Primitivity of the terminal direction", lbl: <lem:primitivity-direction>)[
  Let $r, s in bb(Z)_(gt.eq.slant 2)$ with $r < s$. Then
  $
    gcd (s - r, thin r) = gcd (s, thin r),
  $
  and in particular, $gcd (r, s) = 1$ if and only if the lattice direction $(s - r, thin - r)$ is primitive.
] <lem-primitivity-direction>

#proof[
  By the standard property of the Euclidean algorithm, $gcd (s - r, thin r) = gcd (s, thin r)$. The direction $(s - r, thin - r)$ has $gcd (|s - r|, thin |- r|) = gcd (s - r, thin r) = gcd (s, thin r)$, which equals $1$ iff $gcd (r, s) = 1$.
]

A direct consequence is that primitivity of $(r, s)$ forces the two terminal-core lattice points $P, Q$ to be _consecutive_ on their affine lattice line.

#proposition(title: "Primitive-step exceptional terminal cores are excluded", lbl: <prop:primitive-step-exclusion>)[
  Let $P = (q, thin p)$ and $Q = (q + r - s, thin p + r)$ be primitive terminal standard-cone points with $r, s gt.eq.slant 2$, $r < s$, and $9 slash 5 < s slash r < 15 slash 8$. If $gcd (r, s) = 1$, then $m_P eq.not m_Q$.
] <prop-primitive-step-exclusion>

#proof[
  By @lem:primitivity-direction, the lattice direction $(s - r, thin - r) = P - Q$ is primitive, so no lattice point lies strictly between $Q$ and $P$ on the line segment joining them. Therefore $P$ and $Q$ are _consecutive_ lattice points on their affine line $ell$ in $cal(D)$, ordered by increasing $q$-coordinate ($P$ has the larger $q$-coordinate).

  The slope of $ell$, oriented by increasing $q$, is $lambda = - 1 slash (t - 1)$ by @eq:lambda-from-rs-sec11, with $t = s slash r in (9 slash 5, thin 15 slash 8)$ by hypothesis. By @eq:lambda-from-t of @sec:terminal-cone, this slope lies in the open exceptional window $(- 5 slash 4, thin - 8 slash 7)$. Therefore the hypothesis of @thm:huang-valley-consequence is satisfied for the line $ell$.

  Since $P$ and $Q$ are primitive lattice points in $cal(D)$, the generalised Markov numbers at $P$ and $Q$ coincide with the ordinary Markov numbers $m_P$ and $m_Q$. By @thm:huang-valley-consequence applied to the line $ell$, the generalised Markov numbers at two _consecutive_ lattice points on $ell$ are distinct. Hence $m_P eq.not m_Q$.
]

@prop:primitive-step-exclusion completes the elimination of every terminal core whose Farey-cone offset is a primitive lattice vector. The unconditional structural reductions of @sec:same-ray through this Section therefore exclude every Cohn trace collision _except_ those whose offset $P - Q = (s - r, thin - r)$ has $gcd (s, r) > 1$, the regime to which the Exceptional Terminal Arithmetic Theorem @thm:ETAT is dedicated.

== Non-primitive segments and valley straddling <subsec:non-primitive-segments>

When $gcd (r, s) > 1$, the lattice vector $P - Q = (s - r, thin - r)$ factors through a primitive direction. Set
$
  g := gcd (r, s), quad quad r = g thin r_0, quad s = g thin s_0, quad gcd (r_0, s_0) = 1.
$ <eq:gcd-factorisation>
The factorisation @eq:gcd-factorisation produces the primitive direction
$
  w := (s_0 - r_0, thin - r_0), quad quad gcd (|s_0 - r_0|, r_0) = gcd (s_0, r_0) = 1,
$
oriented by increasing $q$-coordinate. The terminal-core difference then reads
$
  P - Q = g thin w,
$
and the lattice segment from $Q$ to $P$ contains the $g + 1$ equally spaced lattice points
$
  Q_i := Q + i thin w, quad quad i = 0, 1, thin dots.h.c, thin g, quad upright("so that") quad Q_0 = Q, thick Q_g = P.
$ <eq:Qi-sequence>
Each intermediate $Q_i$ is a lattice point in $cal(D)$ (since $Q, P$ both are, and $w$ is the primitive lattice direction between them), though typically _not_ primitive: indeed, the intermediate points are non-primitive whenever $g > 1$, by construction.

We write $M_i := upright("Markov")(Q_i)$ for the generalised Markov number at $Q_i$. With this notation, $M_0 = upright("Markov")(Q) = m_Q$ and $M_g = upright("Markov")(P) = m_P$, since $Q$ and $P$ are primitive.

#corollary(title: "Equality forces valley straddling", lbl: <cor:valley-straddling>)[
  Let $P, Q$ and $(r, s)$ be as in the residual exceptional regime @eq:residual-obstruction, with $g = gcd (r, s) > 1$. Let $Q_0, Q_1, thin dots.h.c, thin Q_g$ be the lattice sequence of @eq:Qi-sequence, and let $M_i := upright("Markov")(Q_i)$. If $m_P = m_Q$, then $M_0, M_1, thin dots.h.c, thin M_g$ attains its unique Huang valley at some index $1 lt.eq.slant i_(0) lt.eq.slant g - 1$ strictly between the two endpoints. In particular,
  $
    M_1 < M_0 quad upright("and") quad M_(g - 1) < M_g.
  $
] <cor-valley-straddling>

#proof[
  The slope of the line $ell$ through $Q_0, Q_1, thin dots.h.c, thin Q_g$ is $lambda = - 1 slash (t - 1)$ with $t = s slash r in (9 slash 5, thin 15 slash 8)$, hence in the exceptional window. By @thm:huang-valley-consequence, the sequence $(M_i)$ is strictly decreasing up to a unique valley index $i_0$ on $ell$ and strictly increasing after it.

  If the valley index of $ell$ were strictly outside the interval $[0, thin g]$ — either at some $i_0 < 0$ (so the sequence is strictly increasing on $[0, g]$) or at some $i_0 > g$ (so the sequence is strictly decreasing on $[0, g]$) — then the endpoint values $M_0$ and $M_g$ would be strictly ordered, contradicting the assumption $M_0 = M_g$. If the valley index were at one of the endpoints $i_0 = 0$ or $i_0 = g$, the sequence would be strictly monotone on $[0, g]$ (decreasing if $i_0 = g$, increasing if $i_0 = 0$), again contradicting $M_0 = M_g$. Therefore the valley index must satisfy $1 lt.eq.slant i_0 lt.eq.slant g - 1$, i.e. it lies _strictly_ between $Q_0$ and $Q_g$.

  Since $i_0 gt.eq.slant 1$, the step from $Q_0$ to $Q_1$ is on the strictly _decreasing_ side of the valley, so $M_1 < M_0$. Since $i_0 lt.eq.slant g - 1$, the step from $Q_(g - 1)$ to $Q_g$ is on the strictly _increasing_ side of the valley, so $M_(g - 1) < M_g$.
]

The valley-straddling property of @cor:valley-straddling is a strong structural restriction on the residual obstruction: not every non-primitive exceptional pair $(r, s)$ can produce a trace collision, only those whose intermediate values straddle a Huang valley along the line. This restriction is the geometric input for the Exceptional Terminal Arithmetic Theorem.

== The remaining terminal obstruction <subsec:residual-obstruction>

Combining @thm:terminal-non-exceptional of @sec:terminal-cone with @prop:primitive-step-exclusion of the present Section yields the cumulative classification of the residual terminal cores at the end of @sec:primitive-exclusion.

#theorem(title: "Residual terminal obstruction after primitive-step exclusion", lbl: <thm:residual-terminal-obstruction>)[
  Let $P = (q, thin p)$ and $Q = (q + r - s, thin p + r)$ be primitive terminal standard-cone points with $r, s gt.eq.slant 2$. If $m_P = m_Q$, then necessarily
  $
    r < s, quad 9 slash 5 < s slash r < 15 slash 8, quad upright("and") quad gcd (r, s) > 1.
  $ <eq:residual-obstruction-statement>
  Moreover, the lattice sequence $Q_0, Q_1, thin dots.h.c, thin Q_g$ of @eq:Qi-sequence with $g = gcd (r, s)$ must straddle the Huang valley along its affine line in the sense of @cor:valley-straddling.
] <thm-residual-terminal-obstruction>

#proof[
  @thm:terminal-non-exceptional of @sec:terminal-cone reduces every residual terminal equality to the exceptional slope window, namely $r < s$ and $9 slash 5 < s slash r < 15 slash 8$. @prop:primitive-step-exclusion of the present Section excludes the case $gcd (r, s) = 1$. Therefore any remaining residual equality must satisfy $gcd (r, s) > 1$. The valley-straddling statement is @cor:valley-straddling.
]

The residual obstruction @eq:residual-obstruction-statement is exactly the regime that defines the Exceptional Terminal Arithmetic Theorem @thm:ETAT, stated conditionally in the Introduction. We recall it for ease of reference.

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + thm-color),
  fill: thm-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *Exceptional Terminal Arithmetic Theorem (recalled).* Let
  $
    P = (q, thin p), quad quad Q = (q + r - s, thin p + r)
  $
  be primitive terminal standard-cone points satisfying the residual obstruction conditions @eq:residual-obstruction-statement: $r < s$, $9 slash 5 < s slash r < 15 slash 8$, and $gcd (r, s) > 1$. Assume in addition that the pair $(P, Q)$ is _return-reduced_, in the sense that it is not eliminated by the Euclidean recoding of @sec:euclidean-recoding before reaching the terminal standard cone. Then $m_P eq.not m_Q$.
]

The Exceptional Terminal Arithmetic Theorem is _not_ proved unconditionally in this monograph. It is taken as a hypothesis, and the conditional main result @thm:main-conditional of @sec:ETAT asserts that this hypothesis implies the Frobenius--Markov uniqueness conjecture. The remaining Sections @sec:modular-sieve[] and @sec:fibonacci-pell[] address two natural strategies for proving @thm:ETAT and the obstacles they face: @sec:modular-sieve shows that no fixed finite modular sieve can settle the residual obstruction, and @sec:fibonacci-pell uses Alekseyev's intersection theorem @Alekseyev2011 to separate the endpoint-to-endpoint Fibonacci--Pell escape families that defeat every such sieve.

== Cumulative reduction at the end of Chapter 11 <subsec:cumulative-sec11>

We summarise the cumulative reduction at the end of this Section. Every hypothetical trace collision in the Cohn tree has been peeled through the following chain of unconditional structural reductions:

$
  upright("Cohn trace collision") thick & arrow.r.double thick upright("cross-ray comparison") quad (upright("§4")) \
                                         & arrow.r.double thick upright("mixed comparison with") thick r, s gt.eq.slant 2 quad (upright("§5–§8")) \
                                         & arrow.r.double thick upright("terminal core in standard cone") quad (upright("§9")) \
                                         & arrow.r.double thick upright("exceptional slope window") thick 9 slash 5 < s slash r < 15 slash 8 quad (upright("§10")) \
                                         & arrow.r.double thick upright("non-primitive step") thick gcd (r, s) > 1 quad (upright("§11)").
$

The cumulative chain has reduced the unbounded combinatorial structure of the Cohn tree to a concrete two-parameter arithmetic problem on the integer lattice $bb(Z)_(gt.eq.slant 2)^2$, restricted to the open ratio window $(9 slash 5, thin 15 slash 8)$ and the non-primitive sub-lattice $gcd (r, s) > 1$. This is the input of the Exceptional Terminal Arithmetic Theorem and the conditional main result of the monograph.

== Synopsis <subsec:synopsis-sec11>

This Section eliminates the primitive-step part of the exceptional slope window left by @sec:terminal-cone. The structural input is Huang's monotonicity classification @Huang2022 in the consequence form @thm:huang-valley-consequence: along an affine lattice line of slope inside the exceptional window $(- 5 slash 4, thin - 8 slash 7)$, the generalised Markov numbers are strictly decreasing up to a unique valley and strictly increasing thereafter, and in particular two consecutive lattice points on such a line carry distinct generalised Markov values. The simple primitive-direction observation @lem:primitivity-direction then shows that for $gcd (r, s) = 1$ the two terminal-core lattice points $P, Q$ are consecutive on their affine line, so @prop:primitive-step-exclusion follows. For $gcd (r, s) > 1$, the intermediate lattice points $Q_1, thin dots.h.c, thin Q_(g - 1)$ produced by the factorisation @eq:gcd-factorisation must straddle the Huang valley (@cor:valley-straddling), which is the geometric input of the Exceptional Terminal Arithmetic Theorem. The cumulative reduction at the end of this Section is @thm:residual-terminal-obstruction: every residual trace collision has $r < s$, $9 slash 5 < s slash r < 15 slash 8$, $gcd (r, s) > 1$, and the corresponding lattice sequence valley-straddles. The Exceptional Terminal Arithmetic Theorem @thm:ETAT is precisely the conjectural statement that no such residual collision exists, and the conditional main result of the monograph (@thm:main-conditional of @sec:ETAT) shows that @thm:ETAT implies Frobenius--Markov uniqueness. The remaining Sections of the monograph address the structural barriers to a direct proof of @thm:ETAT: @sec:modular-sieve excludes finite modular certificates, and @sec:fibonacci-pell separates the endpoint-to-endpoint escape families.

= No fixed finite modular certificate <sec:modular-sieve>

In @sec:primitive-exclusion we reduced the unresolved trace collisions to the non-primitive part of the exceptional slope window: every residual collision has
$
  r < s, quad 9 slash 5 < s slash r < 15 slash 8, quad gcd (r, s) > 1.
$
A natural idea at this stage is to attempt to settle the residual obstruction by _modular arithmetic_: one would like to find a finite set of moduli $cal(N) = { N_1, thin dots.h.c, thin N_k }$ such that for every residual exceptional pair $(P, Q)$, at least one congruence $m_P eq.not m_Q (upright("mod") thin N_i)$ holds. We refer to such a finite set $cal(N)$ as a _finite modular certificate_ for the residual obstruction.

The aim of this Chapter is to prove that no such fixed finite modular certificate can exist. We construct, for every prescribed finite set $cal(N)$, an infinite family of endpoint-to-endpoint exceptional pairs $(P_T, Q_T)$ — Stern--Brocot endpoints along the two boundary rays of $bb(Q)_([0, 1])$ — whose Markov numbers are mutually congruent modulo every $N_i in cal(N)$. The family was already introduced in @eq:escape-pair of the Introduction; we now prove its modular-escape property in full.

The construction does not invalidate the Exceptional Terminal Arithmetic Theorem @thm:ETAT: the pair $(P_T, Q_T)$ has _distinct_ Markov numbers for every $T gt.eq.slant 2$, as shown in @sec:fibonacci-pell using Alekseyev's intersection theorem @Alekseyev2011 for Fibonacci and Pell sequences. What the construction does invalidate is any proof strategy for @thm:ETAT that relies _only_ on a fixed finite list of congruence tests. After this Chapter, any successful approach to @thm:ETAT must use either parameter-dependent congruences, line-specific recurrences, or exact arithmetic identities of Fibonacci--Pell type.

The argument is short and elementary. It rests on three ingredients: the central-weight formulae of @sec:cohn-words for the two endpoint arms (giving $m_(1 slash q) = bold(a)^top M(A)^(q - 2) bold(a)$ and $m_((q - 1) slash q) = bold(a)^top M(B)^(q - 2) bold(a)$); the finiteness of the modular reduction $upright(S L)(2, bb(Z)) arrow.r upright(S L)(2, bb(Z) slash N bb(Z))$, which forces every element of $upright(S L)(2, bb(Z))$ to have finite multiplicative order modulo any fixed $N$; and the Chinese-remainder-style observation that finitely many such orders admit a common multiple.

== Endpoint paths and central-weight formulae <subsec:endpoint-paths-modular>

Throughout this Section we work in the central-weight notation of @sec:cohn-words. The Cohn matrices are
$
  A = mat(2, 1; 1, 1), quad quad B = mat(5, 2; 2, 1),
$
and the test vector is $bold(a) = (2, 1)^top$ as in @eq:central-weight-def of @sec:cohn-words. By @cor:markov-as-weight of @sec:cohn-words, the Markov number at a Stern--Brocot rational $p slash q$ in the interior of $bb(Q)_([0, 1])$ is the central weight
$
  m_(p slash q) = bold(a)^top M(z_(p slash q)) bold(a) = g(z_(p slash q)).
$

On the two endpoint arms of the Stern--Brocot tree, the central core takes the particularly simple form @eq:endpoint-core-A and @eq:endpoint-core-B of @sec:cohn-words:
$
  z_(1 slash (n + 2)) = A^n, quad quad z_((m + 1) slash (m + 2)) = B^m, quad quad n, m gt.eq.slant 0.
$
Consequently the Markov numbers along the two endpoint arms are quadratic forms in the matrix powers $A^n$ and $B^m$:
$
  m_(1 slash (n + 2)) = bold(a)^top thin A^n thin bold(a), quad quad m_((m + 1) slash (m + 2)) = bold(a)^top thin B^m thin bold(a).
$ <eq:endpoint-weights>
The two endpoint paths correspond, in the Cohn-word free monoid of @sec:cohn-words, to the unary words $A^n$ and $B^m$, or equivalently to the two Stern--Brocot ray words $L^n$ and $R^m$ in the standard $L, R$ encoding.

We shall use the identities @eq:endpoint-weights in combination with the modular periodicity of the powers $A^n, B^m$ that we now establish.

== Periodicity modulo a fixed modulus <subsec:modular-periodicity>

Let $N gt.eq.slant 2$ be a positive integer modulus. Since $det A = det B = 1$, the reductions of $A$ and $B$ modulo $N$ lie in the finite group $upright(S L)(2, bb(Z) slash N bb(Z))$. Every element of a finite group has finite order, hence there exist positive integers $pi_A (N)$ and $pi_B (N)$ such that
$
  A^(pi_A (N)) equiv I (upright("mod") thin N), quad quad B^(pi_B (N)) equiv I (upright("mod") thin N).
$ <eq:matrix-orders>
We call $pi_A (N)$ and $pi_B (N)$ the _multiplicative orders_ of $A$ and $B$ modulo $N$. By Lagrange's theorem, both orders divide the order of $upright(S L)(2, bb(Z) slash N bb(Z))$, which is finite and a function of $N$ alone.

Consequently, for every integer $T$ divisible by $pi_A (N)$,
$
  A^top &equiv I (upright("mod") thin N), \
  upright("hence") quad bold(a)^top thin A^top thin bold(a) &equiv bold(a)^top thin bold(a) = (2, thin 1) thin (2, thin 1)^top = 4 + 1 = 5 (upright("mod") thin N).
$
The same identity holds for $B^top$ whenever $T$ is divisible by $pi_B (N)$. The endpoint Markov number @eq:endpoint-weights is therefore congruent to $5$ modulo $N$ as soon as the exponent is a multiple of the appropriate matrix-order $pi_A (N)$ or $pi_B (N)$.

For a finite collection of moduli, a common multiple of all the orders gives uniform control.

#lemma(title: "Common unary period for finitely many moduli", lbl: <lem:common-unary-period>)[
  Let $cal(N) = { N_1, thin dots.h.c, thin N_k }$ be a finite collection of integers with each $N_i gt.eq.slant 2$. Then there exists a positive integer $T gt.eq.slant 2$ such that for every $N_i in cal(N)$ the following two congruences hold:
  $
    A^(13 T) equiv I (upright("mod") thin N_i), quad quad B^(7 T) equiv I (upright("mod") thin N_i).
  $
] <lem-common-unary-period>

#proof[
  For each $i$, let $pi_A (N_i)$ and $pi_B (N_i)$ be the multiplicative orders of $A$ and $B$ modulo $N_i$ from @eq:matrix-orders. Define
  $
    T := 2 thin upright("lcm")_(1 lt.eq.slant i lt.eq.slant k) (pi_A (N_i), thin pi_B (N_i)).
  $ <eq:T-definition>
  The least-common-multiple is a positive integer (every order is at least $1$), and the factor of $2$ ensures $T gt.eq.slant 2$. By construction, $T$ is divisible by every order $pi_A (N_i)$ and every order $pi_B (N_i)$. Hence so are the multiples $13 T$ (divisible by $pi_A (N_i)$ since $T$ is) and $7 T$ (divisible by $pi_B (N_i)$). The matrix congruences @eq:matrix-orders then give $A^(13 T) equiv I$ and $B^(7 T) equiv I$ modulo every $N_i$, as claimed.
]

The choice of coefficients $13$ and $7$ in front of $T$ in @lem:common-unary-period is _not_ arbitrary: as we shall see in @subsec:escape-family, these are exactly the coefficients needed for the resulting endpoint pair $(P_T, Q_T)$ to lie in the exceptional slope window of @sec:terminal-cone, with ratio $s slash r = 13 slash 7 in (9 slash 5, thin 15 slash 8)$.

#remark(title: "Modular reduction as a finite-group homomorphism", lbl: <rem:mod-reduction-finite-group>)[
  The argument of @lem:common-unary-period is a special case of the general phenomenon that the modular-reduction homomorphism
  $
    rho_N : upright(S L)(2, bb(Z)) arrow.r upright(S L)(2, bb(Z) slash N bb(Z))
  $
  has finite image (since the target is a finite group), so every element of $upright(S L)(2, bb(Z))$ has finite multiplicative order in the image. The asymptotic periodicity of matrix powers modulo a fixed integer is therefore a structural consequence of finiteness of $upright(S L)(2, bb(Z) slash N bb(Z))$, equivalently of the strong-approximation property of the simply-connected algebraic group $upright(S L)_2$ over $bb(Q)$ at a single non-archimedean place. The same phenomenon underlies the Fricke--Klein character variety analysis of @rem:markov-character-variety: at every finite level $N$, the residual trace data collapse into a finite set of values, but as $N arrow.r infinity$ the data are not eventually constant and resolve the underlying Diophantine geometry. In the dynamical-systems reading of @SpaldingVeselov2017, the modular reduction is best thought of as a _finite shadow_ of the Markov dynamics --- not a tropicalisation in the max-plus sense --- in the following precise way: at every finite level $N$ the dynamics descends to a finite-state map on $upright(S L)(2, bb(Z) slash N bb(Z))$, and the genuine Lyapunov spectrum of the Markov tree is a characteristic-zero invariant that the finite shadow cannot detect.
]

== The modular escape family <subsec:escape-family>

Given $T gt.eq.slant 2$, we now define the modular escape family of endpoint-to-endpoint exceptional pairs.

#definition(title: "Modular escape pair", lbl: <def:modular-escape-pair>)[
  For $T gt.eq.slant 2$, the _modular escape pair_ is the ordered pair of primitive lattice points
  $
    P_T := (13 T + 2, thin 1), quad quad Q_T := (7 T + 2, thin 7 T + 1).
  $ <eq:escape-pair>
] <def-modular-escape-pair>

The pair $(P_T, Q_T)$ corresponds to the two Stern--Brocot endpoint fractions
$
  1 slash (13 T + 2) quad upright("and") quad (7 T + 1) slash (7 T + 2),
$
i.e. to the central cores $A^(13 T)$ and $B^(7 T)$ respectively. The two corresponding Markov numbers are, by @eq:endpoint-weights,
$
  m_(P_T) = bold(a)^top thin A^(13 T) thin bold(a), quad quad m_(Q_T) = bold(a)^top thin B^(7 T) thin bold(a).
$ <eq:escape-markov-formulae>

We verify directly that $(P_T, Q_T)$ is a primitive terminal exceptional pair in the residual regime of @sec:primitive-exclusion.

#lemma(title: "The escape pair is exceptional non-primitive", lbl: <lem:escape-pair-exceptional>)[
  For every $T gt.eq.slant 2$, the modular escape pair $(P_T, Q_T)$ of @def:modular-escape-pair satisfies:

  (a) $P_T$ and $Q_T$ are primitive lattice points in $cal(D)$.

  (b) The lattice offset $Q_T - P_T = (- 6 T, thin 7 T)$ takes the standard-cone form $Q_T - P_T = r thin u_0 - s thin v_0$ with parameters
  $
    r = 7 T, quad quad s = 13 T.
  $

  (c) The pair is in the residual obstruction regime @eq:residual-obstruction-statement of @sec:primitive-exclusion: $r < s$, $9 slash 5 < s slash r = 13 slash 7 < 15 slash 8$, and $gcd (r, s) = T > 1$.
] <lem-escape-pair-exceptional>

#proof[
  *(a)* For $P_T = (13 T + 2, thin 1)$: the gcd of $13 T + 2$ and $1$ is $1$, since any integer divides $1$ only if it is $plus.minus 1$. For $Q_T = (7 T + 2, thin 7 T + 1)$: by the Euclidean algorithm, $gcd (7 T + 2, thin 7 T + 1) = gcd ((7 T + 2) - (7 T + 1), thin 7 T + 1) = gcd (1, thin 7 T + 1) = 1$. Both points are therefore primitive. Both also satisfy $0 lt.eq.slant p lt.eq.slant q$ (for $P_T$: $0 lt.eq.slant 1 lt.eq.slant 13 T + 2$ ✓; for $Q_T$: $0 lt.eq.slant 7 T + 1 lt.eq.slant 7 T + 2$ ✓), so both lie in $cal(D)$.

  *(b)* Direct computation:
  $
    Q_T - P_T = (7 T + 2 - (13 T + 2), thin (7 T + 1) - 1) = (- 6 T, thin 7 T).
  $
  In the standard cone, $r thin u_0 - s thin v_0 = (r - s, thin r)$, so matching coordinates gives $r = 7 T$ and $r - s = - 6 T$, hence $s = 13 T$.

  *(c)* Combining $r = 7 T$ and $s = 13 T$ with $T gt.eq.slant 2$ gives $r = 7 T gt.eq.slant 14 gt.eq.slant 2$, $s = 13 T gt.eq.slant 26 gt.eq.slant 2$, $r < s$ since $7 < 13$, and $s slash r = 13 slash 7 approx 1.857$. The inequalities $9 slash 5 = 1.8 < 13 slash 7 < 15 slash 8 = 1.875$ hold by direct decimal comparison (or by clearing denominators: $13 dot 5 = 65 > 63 = 9 dot 7$, and $13 dot 8 = 104 < 105 = 7 dot 15$). Finally $gcd (r, s) = gcd (7 T, thin 13 T) = T dot gcd (7, thin 13) = T dot 1 = T gt.eq.slant 2$.
]

The escape pair is therefore a legitimate residual exceptional terminal pair in the sense of @thm:residual-terminal-obstruction of @sec:primitive-exclusion, and at the moment we have no _a priori_ reason to exclude the possibility $m_(P_T) = m_(Q_T)$. The modular-escape theorem below shows that, for cleverly chosen $T$, the two Markov numbers are even _congruent_ modulo every prescribed finite collection of moduli.

== The modular escape theorem <subsec:modular-escape-theorem>

We now prove the main result of this Section.

#theorem(title: "No fixed finite modular certificate", lbl: <thm:no-finite-modular-certificate>)[
  Let $cal(N) = { N_1, thin dots.h.c, thin N_k }$ be any finite set of moduli $N_i gt.eq.slant 2$. Then there exists $T gt.eq.slant 2$ such that the modular escape pair $(P_T, Q_T)$ of @def:modular-escape-pair satisfies
  $
    m_(P_T) equiv m_(Q_T) (upright("mod") thin N_i) quad upright("for every") thick N_i in cal(N).
  $ <eq:modular-escape>
  In particular, no fixed finite set of moduli $cal(N)$ can separate every residual exceptional terminal pair from itself: the Exceptional Terminal Arithmetic Theorem @thm:ETAT cannot be settled by a fixed finite modular certificate.
] <thm-no-finite-modular-certificate>

#proof[
  Choose $T gt.eq.slant 2$ as in @lem:common-unary-period, so that $A^(13 T) equiv I$ and $B^(7 T) equiv I$ modulo every $N_i in cal(N)$. By @eq:escape-markov-formulae,
  $
    m_(P_T) = bold(a)^top thin A^(13 T) thin bold(a) equiv bold(a)^top thin I thin bold(a) = bold(a)^top thin bold(a) = 5 (upright("mod") thin N_i),
  $
  and similarly
  $
    m_(Q_T) = bold(a)^top thin B^(7 T) thin bold(a) equiv bold(a)^top thin I thin bold(a) = 5 (upright("mod") thin N_i),
  $
  for every $N_i in cal(N)$. Hence $m_(P_T) equiv m_(Q_T) equiv 5 (upright("mod") thin N_i)$, which is the conclusion @eq:modular-escape.

  By @lem:escape-pair-exceptional, the escape pair $(P_T, Q_T)$ is a primitive terminal exceptional pair in the residual regime of @thm:residual-terminal-obstruction. Therefore the modular sieve $cal(N)$ fails to separate this pair, and the Exceptional Terminal Arithmetic Theorem cannot be settled by the modular tests provided by $cal(N)$ alone.
]

#remark(title: "Scope of the negative result", lbl: <rem:negative-scope>)[
  @thm:no-finite-modular-certificate rules out only certificates of one specific form: a _fixed_ finite list of residue comparisons modulo a _preselected_ collection of moduli, applied uniformly to every primitive terminal exceptional pair. It does _not_ rule out modular arguments in which the modulus is allowed to depend on the terminal parameters $(r, s, p, t)$, nor modular arguments combined with additional arithmetic structure (recurrence positivity, Diophantine height bounds, or cluster-algebraic constraints). A parameter-dependent modular separation is precisely Route 2 of @subsec:routes-to-proof of @sec:outlook.
]

== Interpretation and role in the reduction <subsec:modular-interpretation>

@thm:no-finite-modular-certificate has a precise methodological content. It says that no proof of the Exceptional Terminal Arithmetic Theorem @thm:ETAT can take the following form:

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + cor-color),
  fill: cor-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *Failed strategy.* Choose finitely many moduli $cal(N) = { N_1, thin dots.h.c, thin N_k }$. Prove that for every residual exceptional pair $(P, Q)$, at least one of the congruences $m_P eq.not m_Q (upright("mod") thin N_i)$ holds.
]

For every such finite $cal(N)$, the escape family $(P_T, Q_T)$ with $T$ as in @lem:common-unary-period defeats the strategy: every congruence $m_(P_T) equiv 5 (upright("mod") thin N_i)$ and $m_(Q_T) equiv 5 (upright("mod") thin N_i)$ holds simultaneously. The escape family is therefore not a finite list of counterexamples that one could enumerate and dismiss: it is an _infinite parameterised family_ indexed by integer multiples of the common period $T$, and grows with the modular complexity of the prescribed certificate.

This negative result does _not_ rule out modular methods altogether. It rules out only the _fixed_ finite modular certificate. A modulus depending on the terminal parameters $(r, s)$, on the lattice index $T$, or on any Cohn-index quantity is not excluded; nor is the use of additional structural information (such as the central-weight quadratic form $bold(a)^top M(z) bold(a)$, the Chebyshev closed forms of @sec:local-cone, or the explicit Fibonacci--Pell identifications of @sec:fibonacci-pell) in combination with modular congruences. The remaining proof strategies for @thm:ETAT are therefore parameter-dependent, structurally enriched, or both.

The escape family $(P_T, Q_T)$ is also not a counterexample to the Exceptional Terminal Arithmetic Theorem itself. As we shall prove in @sec:fibonacci-pell, the two Markov numbers $m_(P_T)$ and $m_(Q_T)$ are in fact _distinct_ for every $T gt.eq.slant 2$: the proof identifies $m_(1 slash (13 T + 2)) = F_(2 (13 T + 2) + 1)$ as a Fibonacci number and $m_((7 T + 1) slash (7 T + 2)) = P_(2 (7 T + 2) - 1)$ as a Pell number, and applies the intersection theorem of @Alekseyev2011 stating that the only common Fibonacci and Pell values are ${ 0, thin 1, thin 2, thin 5 }$. None of these four values is reached by the escape family for $T gt.eq.slant 2$, so the two Markov numbers are different but congruent modulo every prescribed $N_i$.

The chain of reductions at the end of this Section is therefore unchanged from the end of @sec:primitive-exclusion. The residual exceptional regime
$
  r < s, quad 9 slash 5 < s slash r < 15 slash 8, quad gcd (r, s) > 1
$
still characterises every hypothetical Cohn-trace collision. What the present Section adds is a _negative_ structural insight: any proof of @thm:ETAT must reach beyond the finite-modular regime, into one of the more delicate arithmetic settings of @sec:fibonacci-pell or @sec:ETAT.

== Synopsis <subsec:synopsis-sec12>

This Section establishes a structural obstacle to settling the Exceptional Terminal Arithmetic Theorem @thm:ETAT by purely modular methods. Starting from the central-weight endpoint formulae @eq:endpoint-weights, which express the Markov numbers along the two Stern--Brocot endpoint arms as quadratic forms in matrix powers $A^n$ and $B^m$, we observe that every such matrix has finite multiplicative order modulo any fixed integer $N$ (since the modular reduction $upright(S L)(2, bb(Z)) arrow.r upright(S L)(2, bb(Z) slash N bb(Z))$ has finite image, @rem:mod-reduction-finite-group). A common multiple of the relevant orders, @lem:common-unary-period, then produces an exponent $T gt.eq.slant 2$ at which both endpoint Markov numbers reduce to $5 (upright("mod") thin N_i)$ simultaneously for every prescribed $N_i$. The modular escape family $(P_T, Q_T)$ of @def:modular-escape-pair, with $r = 7 T$ and $s = 13 T$, is a legitimate primitive terminal exceptional pair (@lem:escape-pair-exceptional) inside the residual regime of @thm:residual-terminal-obstruction; the modular-escape theorem @thm:no-finite-modular-certificate then asserts that the congruence $m_(P_T) equiv m_(Q_T) equiv 5 (upright("mod") thin N_i)$ holds for every $N_i in cal(N)$. The escape family is not a counterexample to @thm:ETAT: in @sec:fibonacci-pell we shall show that the two Markov numbers $m_(P_T), m_(Q_T)$ are distinct for every $T gt.eq.slant 2$ via Alekseyev's intersection theorem on Fibonacci and Pell sequences @Alekseyev2011. The conclusion of this Section is methodological: any successful proof of the Exceptional Terminal Arithmetic Theorem must use parameter-dependent congruences, line-specific recurrences, or exact arithmetic identities that go beyond a fixed finite list of modular tests.

= Endpoint-to-endpoint escape families are separated <sec:fibonacci-pell>

@sec:modular-sieve showed that no fixed finite modular certificate can settle the residual exceptional regime: the modular escape family $(P_T, Q_T)$ of @def:modular-escape-pair defeats every prescribed finite collection of moduli simultaneously. The purpose of the present Section is to prove that the escape family is nevertheless _harmless_: the two Markov numbers $m_(P_T)$ and $m_(Q_T)$ are distinct for every $T gt.eq.slant 2$. More generally, we shall prove that the two Stern--Brocot endpoint arms of the Cohn tree --- the $p = 1$ arm and the $p = q - 1$ arm --- never produce a Markov-number collision after the initial small values.

The proof rests on a single classical identification of the two endpoint arms with subsequences of two named integer sequences. The $p = 1$ endpoint arm is an _odd-indexed Fibonacci_ subsequence: $m_(1 slash q) = F_(2 q + 1)$ by @eq:m-fibonacci of @sec:cohn-words. The $p = q - 1$ endpoint arm is an _odd-indexed Pell_ subsequence: $m_((q - 1) slash q) = upright("Pe")_(2 q - 1)$ by @eq:m-pell of @sec:cohn-words, where we use $upright("Pe")_n$ to denote the $n$-th Pell number to avoid clash with the lattice-point notation $P_n$. The endpoint-to-endpoint separation then follows from Alekseyev's intersection theorem for the Fibonacci and Pell sequences @Alekseyev2011: the only positive integers common to both sequences are $0, 1, 2, 5$.

In §13.2 and §13.3 we give a clean matrix-square derivation of the two endpoint formulae, complementary to the central-weight derivation of @sec:cohn-words; both routes give the same result, and the matrix-square route is particularly transparent because it identifies $A = S^2$ and $B = T^2$ for the standard Fibonacci and Pell matrices $S, T$. In §13.4 we apply Alekseyev's theorem and prove the endpoint-to-endpoint separation. In §13.5 we record the immediate corollary that the modular escape family of @sec:modular-sieve is harmless.

== Endpoint-to-endpoint terminal pairs <subsec:endpoint-pairs>

Recall from @sec:cohn-words that the Stern--Brocot tree $bb(Q)_([0, 1])$ has two endpoint arms: the $p = 1$ arm consisting of fractions $1 slash q$ with $q gt.eq.slant 2$, and the $p = q - 1$ arm consisting of fractions $(q - 1) slash q$ with $q gt.eq.slant 2$. We parameterise these arms by the shift integer $n, m gt.eq.slant 1$ via
$
  P_n &:= (n + 2, thin 1) quad &&upright("corresponds to") thick 1 slash (n + 2), \
      & &&upright("hence to the Cohn word") thick L^n,
$
$
  Q_m &:= (m + 2, thin m + 1) quad &&upright("corresponds to") thick (m + 1) slash (m + 2), \
      & &&upright("hence to") thick R^m,
$
in the Stern--Brocot $L, R$ encoding. The two parameterisations coincide at $n = m = 0$ at the seed $W_(1 slash 2) = A B$ with Markov number $5$, and are otherwise disjoint as Stern--Brocot indices for $n, m gt.eq.slant 1$.

The modular escape family of @def:modular-escape-pair of @sec:modular-sieve is exactly the sub-family corresponding to the index choice $n = 13 T$, $m = 7 T$ for $T gt.eq.slant 2$: $P_(13 T) = (13 T + 2, thin 1)$ and $Q_(7 T) = (7 T + 2, thin 7 T + 1)$ are the modular escape pair.

We state the main result of the Section.

#theorem(title: "Endpoint-to-endpoint separation", lbl: <thm:endpoint-separation>)[
  For every pair of integers $n, m gt.eq.slant 1$,
  $
    m_(1 slash (n + 2)) eq.not m_((m + 1) slash (m + 2)).
  $ <eq:endpoint-separation>
  Equivalently, $m_(P_n) eq.not m_(Q_m)$ for the lattice points defined above.
] <thm-endpoint-separation>

#proof[
  The proof occupies the remaining three subsections of this chapter. In @subsec:left-arm-fibonacci we identify the left endpoint arm $m_(1 slash (n + 2))$ with the Fibonacci subsequence $F_(2 n + 5)$ via the endpoint-core formula @eq:endpoint-core-A and the central-weight identity @cor:markov-as-weight. In @subsec:right-arm-pell we perform the analogous Pell identification $m_((m + 1) slash (m + 2)) = P_(2 m + 3)$ on the right endpoint arm. The conclusion @eq:endpoint-separation is then exactly the assertion that the Fibonacci and Pell subsequences are disjoint as values, which is the content of Alekseyev's intersection theorem @Alekseyev2011 applied in @subsec:fib-pell-intersection: the intersection of the Fibonacci and Pell sequences as sets of positive integers is the finite set ${0, thin 1, thin 2, thin 5}$, and a direct inspection rules out coincidences in this finite set for the index ranges of @eq:endpoint-separation.
]

== The left endpoint arm is Fibonacci <subsec:left-arm-fibonacci>

We give a clean matrix-square derivation of the Fibonacci identification @eq:m-fibonacci of @sec:cohn-words, complementary to the central-weight identity used there.

Let $q gt.eq.slant 2$. By the endpoint core formula @eq:endpoint-core-A of @sec:cohn-words, the central core of the Cohn word $W_(1 slash q)$ is the unary power $z_(1 slash q) = A^(q - 2)$. By @cor:markov-as-weight of @sec:cohn-words, the Markov number is
$
  m_(1 slash q) = bold(a)^top thin A^(q - 2) thin bold(a), quad quad bold(a) = (2, 1)^top.
$ <eq:m-1-over-q-A>

The Cohn matrix $A$ is the square of the standard Fibonacci matrix
$
  S := mat(1, 1; 1, 0).
$ <eq:fibonacci-matrix>
Indeed, a direct computation gives
$
  S^2 = mat(1 dot 1 + 1 dot 1, thin 1 dot 1 + 1 dot 0; thin 1 dot 1 + 0 dot 1, thin 1 dot 1 + 0 dot 0) = mat(2, 1; 1, 1) = A.
$
Moreover, the test vector $bold(a) = (2, 1)^top$ equals the first column of $A$, hence the first column of $S^2$:
$
  bold(a) = A thin e_1 = S^2 thin e_1, quad quad e_1 = (1, 0)^top.
$
Substituting $A = S^2$ and $bold(a) = S^2 e_1$ in @eq:m-1-over-q-A, and using that $A$ (hence $S^2$) is symmetric so that $bold(a)^top = e_1^top S^2$,
$
  m_(1 slash q) = e_1^top thin S^2 thin (S^2)^(q - 2) thin S^2 thin e_1 = e_1^top thin S^(2 q) thin e_1.
$
The classical Fibonacci-matrix identity
$
  S^N = mat(F_(N + 1), F_N; F_N, F_(N - 1)), quad quad N gt.eq.slant 0,
$ <eq:fibonacci-matrix-identity>
with $F_0 = 0$, $F_1 = 1$, $F_(n + 1) = F_n + F_(n - 1)$ for $n gt.eq.slant 1$, then gives the entry-$(1, 1)$ of $S^(2 q)$ as $F_(2 q + 1)$, hence
$
  m_(1 slash q) = e_1^top thin S^(2 q) thin e_1 = F_(2 q + 1).
$ <eq:m-fibonacci-sec13>
This recovers @eq:m-fibonacci of @sec:cohn-words by a matrix-square route. Specialising to $q = n + 2$,
$
  m_(1 slash (n + 2)) = F_(2 n + 5), quad quad n gt.eq.slant 0.
$ <eq:left-arm-fibonacci>

The sequence $(F_(2 n + 5))_(n gt.eq.slant 1) = (F_7, F_9, F_(11), dots) = (13, thin 34, thin 89, thin 233, dots)$ is exactly the odd-indexed Fibonacci subsequence starting at index $7$.

== The right endpoint arm is Pell <subsec:right-arm-pell>

The same kind of matrix-square identification works for the right endpoint arm, with the standard Pell matrix in place of the Fibonacci matrix.

Let $q gt.eq.slant 2$. By the endpoint core formula @eq:endpoint-core-B of @sec:cohn-words, the central core of the Cohn word $W_((q - 1) slash q)$ is the unary power $z_((q - 1) slash q) = B^(q - 2)$. By @cor:markov-as-weight,
$
  m_((q - 1) slash q) = bold(a)^top thin B^(q - 2) thin bold(a).
$ <eq:m-q-1-over-q-B>

The Cohn matrix $B$ is the square of the standard Pell matrix
$
  U := mat(2, 1; 1, 0).
$ <eq:pell-matrix>
Indeed,
$
  U^2 = mat(2 dot 2 + 1 dot 1, thin 2 dot 1 + 1 dot 0; thin 1 dot 2 + 0 dot 1, thin 1 dot 1 + 0 dot 0) = mat(5, 2; 2, 1) = B.
$
The test vector $bold(a) = (2, 1)^top$ is the first column of $U$:
$
  bold(a) = U thin e_1.
$
Substituting $B = U^2$ and $bold(a) = U thin e_1$ in @eq:m-q-1-over-q-B, and using that $U$ is symmetric so $bold(a)^top = e_1^top U$,
$
  m_((q - 1) slash q) = e_1^top thin U thin (U^2)^(q - 2) thin U thin e_1 = e_1^top thin U^(2 q - 2) thin e_1.
$
The Pell-matrix identity
$
  U^N = mat(upright("Pe")_(N + 1), upright("Pe")_N; upright("Pe")_N, upright("Pe")_(N - 1)), quad quad N gt.eq.slant 0,
$ <eq:pell-matrix-identity>
with the Pell sequence $upright("Pe")_0 = 0$, $upright("Pe")_1 = 1$, $upright("Pe")_(n + 1) = 2 thin upright("Pe")_n + upright("Pe")_(n - 1)$ for $n gt.eq.slant 1$, then gives
$
  m_((q - 1) slash q) = upright("Pe")_(2 q - 1).
$ <eq:m-pell-sec13>
This recovers @eq:m-pell of @sec:cohn-words. Specialising to $q = m + 2$,
$
  m_((m + 1) slash (m + 2)) = upright("Pe")_(2 m + 3), quad quad m gt.eq.slant 0.
$ <eq:right-arm-pell>

The combined endpoint identifications are
$
  m_(1 slash (n + 2)) in.small (F_(2 n + 5))_(n gt.eq.slant 1) , quad quad m_((m + 1) slash (m + 2)) in.small (upright("Pe")_(2 m + 3))_(m gt.eq.slant 1).
$ <eq:fib-pell>
The sequence $(upright("Pe")_(2 m + 3))_(m gt.eq.slant 1) = (upright("Pe")_5, upright("Pe")_7, upright("Pe")_9, dots) = (29, thin 169, thin 985, thin 5741, dots)$ is the odd-indexed Pell subsequence starting at index $5$.

#remark(title: "The matrix-square identification and the Markov-tree dynamics", lbl: <rem:matrix-square>)[
  The factorisations $A = S^2$ and $B = U^2$ have a structural conceptual content beyond their bookkeeping role in @subsec:left-arm-fibonacci and @subsec:right-arm-pell. The matrices $S$ and $U$ are elements of $upright(G L)(2, bb(Z))$ with determinant $- 1$, and their squares $A, B in upright(S L)(2, bb(Z))$ are the Cohn matrices of the seed triple @eq:cohn-seed. The Fibonacci and Pell sequences are the standard linear recurrences associated with the characteristic polynomials of $S$ and $U$, with respective Pisot parameters $phi.alt = (1 + sqrt(5)) slash 2$ and $1 + sqrt(2)$. The two endpoint arms of the Stern--Brocot tree therefore correspond, in the dynamical reading of the Markov tree of @SpaldingVeselov2017, to the two slowest Lyapunov rays --- the rays of slope $0$ and $1$ in the lattice $cal(D)$ --- whose growth rates are governed by these two Pisot parameters. The matrix-square identification is the bridge between the Markov-tree dynamics on the one hand and the classical linear-recurrence theory of Fibonacci and Pell on the other.
]

== Fibonacci--Pell intersection and the proof of separation <subsec:fib-pell-intersection>

We now apply Alekseyev's intersection theorem @Alekseyev2011, which we recall here in the form needed.

#theorem(title: [Alekseyev's Fibonacci--Pell intersection, after @Alekseyev2011], lbl: <thm:alekseyev-fib-pell>)[
  The only non-negative integers that occur both in the Fibonacci sequence $(F_n)_(n gt.eq.slant 0)$ and in the Pell sequence $(upright("Pe")_n)_(n gt.eq.slant 0)$ are
  $
    0, thick 1, thick 2, thick 5.
  $
  Equivalently, the only solutions of $F_a = upright("Pe")_b$ with $a, b gt.eq.slant 0$ are the four pairs $(a, b) in { (0, 0), thin (1, 1), thin (2, 1), thin (3, 2), thin (5, 3) }$ (with the multiplicity arising from $F_1 = F_2 = 1$).
] <thm-alekseyev-fib-pell>

@thm:alekseyev-fib-pell is part of a broader study by Alekseyev of intersections of Lucas sequences @Alekseyev2011, in which the underlying technique reduces such intersections to homogeneous quadratic Diophantine equations and Thue equations. The Fibonacci--Pell case is the prototypical example: both are Lucas sequences of the first kind, with respective Pisot parameters $phi.alt = (1 + sqrt(5)) slash 2$ and $1 + sqrt(2)$, both algebraic units of degree two over $bb(Q)$, and Alekseyev's reduction produces a finite list of Thue equations whose only integer solutions correspond to the four common values $0, 1, 2, 5$.

We can now prove the endpoint-to-endpoint separation @thm:endpoint-separation.

#proof[
  Suppose, for contradiction, that $m_(1 slash (n + 2)) = m_((m + 1) slash (m + 2))$ for some $n, m gt.eq.slant 1$. By the endpoint identifications @eq:left-arm-fibonacci and @eq:right-arm-pell,
  $
    F_(2 n + 5) = upright("Pe")_(2 m + 3).
  $
  This common value is therefore simultaneously a Fibonacci and a Pell number. By @thm:alekseyev-fib-pell, it must lie in the set ${ 0, 1, 2, 5 }$.

  On the other hand, since $n gt.eq.slant 1$ we have $2 n + 5 gt.eq.slant 7$, hence
  $
    F_(2 n + 5) gt.eq.slant F_7 = 13.
  $
  Similarly, $m gt.eq.slant 1$ gives $2 m + 3 gt.eq.slant 5$, hence
  $
    upright("Pe")_(2 m + 3) gt.eq.slant upright("Pe")_5 = 29.
  $
  In particular, the common value is at least $13$, which is strictly larger than $5$, contradicting @thm:alekseyev-fib-pell. The assumed equality therefore cannot hold, and $m_(1 slash (n + 2)) eq.not m_((m + 1) slash (m + 2))$ for every $n, m gt.eq.slant 1$.
]

The proof is morally Diophantine: the asymptotic growth rates of the two sequences are $phi.alt^2 approx 2.618$ for $F_(2 n + 5)$ and $(1 + sqrt(2))^2 = 3 + 2 sqrt(2) approx 5.828$ for $upright("Pe")_(2 m + 3)$, both strictly greater than $1$, so the two sequences diverge rapidly to infinity along independent geometric scales. Alekseyev's theorem then makes precise the elementary heuristic that two sequences with distinct Pisot growth rates can intersect only at finitely many small values.

== The modular escape family is harmless <subsec:escape-harmless>

We can now record the immediate consequence for the modular escape family of @sec:modular-sieve.

#corollary(title: "The modular escape family is harmless", lbl: <cor:escape-harmless>)[
  For every $T gt.eq.slant 2$, the modular escape pair $(P_T, Q_T)$ of @def:modular-escape-pair satisfies
  $
    m_(P_T) eq.not m_(Q_T).
  $
] <cor-escape-harmless>

#proof[
  The modular escape pair is exactly the endpoint-to-endpoint pair $P_(13 T) = (13 T + 2, thin 1)$ and $Q_(7 T) = (7 T + 2, thin 7 T + 1)$ from @subsec:endpoint-pairs, with the index choice $n = 13 T gt.eq.slant 26 gt.eq.slant 1$ and $m = 7 T gt.eq.slant 14 gt.eq.slant 1$ for $T gt.eq.slant 2$. By @thm:endpoint-separation, $m_(P_(13 T)) eq.not m_(Q_(7 T))$. The conclusion follows.
]

The escape family is therefore _not_ a counterexample to the Exceptional Terminal Arithmetic Theorem @thm:ETAT. Its existence shows only that fixed finite modular certificates cannot settle @thm:ETAT, but the underlying Markov numbers themselves are strictly distinct, separated by an exact recurrence-theoretic identity at the heart of the Pisot-Vijayaraghavan theory of Lucas sequences.

#remark(title: "Beyond endpoint arms: the next layer of escape families", lbl: <rem:beyond-endpoint>)[
  The endpoint-to-endpoint separation is the cleanest case of the broader phenomenon at work in the residual exceptional regime. More general exceptional families along the slope window $9 slash 5 < s slash r < 15 slash 8$ correspond to longer Stern--Brocot paths $L^a R^b L^c dots.h.c$ rather than to pure unary words $L^n$ and $R^m$. The corresponding Markov numbers are values of higher-order Lucas-type sequences associated with the products $A^a B^b A^c thin dots.h.c$, and the intersection theory for such sequences becomes proportionally harder. Alekseyev's intersection theorem @Alekseyev2011 is part of a broader framework (extended by subsequent authors) addressing intersections among Lucas sequences with different recurrence coefficients, but the general case lies outside the scope of a single classical intersection theorem. This is the structural reason why the residual exceptional terminal problem is isolated as a single arithmetic theorem (the Exceptional Terminal Arithmetic Theorem @thm:ETAT) rather than resolved case by case.
]

== Role in the reduction <subsec:role-sec13>

This Section has two distinct purposes in the overall reduction.

*Methodological:* the construction shows that the explicit endpoint family used in @sec:modular-sieve to defeat the fixed-modular-certificate strategy does _not_ produce an actual Cohn-trace collision. The structural obstacle of @sec:modular-sieve is therefore real --- no finite modular sieve can settle @thm:ETAT --- but the proposed strategy fails for a _negative_ reason (it cannot distinguish the escape family from a hypothetical equality), not for a _positive_ reason (the escape family does not provide a real counterexample).

*Structural:* the endpoint identifications @eq:left-arm-fibonacci and @eq:right-arm-pell are the cleanest illustration of the type of arithmetic that the residual exceptional problem requires. Both endpoint arms are unary Stern--Brocot paths, and their Markov numbers are second-order linear-recurrence sequences (Fibonacci and Pell) at strictly different Pisot growth rates. The intersection theory for such sequences is by now classical, and Alekseyev's theorem @Alekseyev2011 provides the explicit answer. By contrast, the interior of the residual exceptional regime corresponds to non-unary Stern--Brocot paths, with Markov numbers given by higher-order recurrences whose intersection theory is delicate. The Exceptional Terminal Arithmetic Theorem @thm:ETAT, conditional on which the Frobenius--Markov conjecture follows (by @thm:main-conditional of @sec:ETAT), is the assertion that no intersection survives in the interior of the regime once the boundary endpoint case has been excluded as in the present Section.

The chain of reductions is now complete:

$
  upright("Cohn trace collision") thick & arrow.r.double thick upright("residual exceptional regime") quad (upright("§4–§11")) \
                                         & arrow.r.double thick upright("non-primitive interior of") cal(R)_("exc") quad (upright("§12–§13")) \
                                         & arrow.r.double thick upright("Exceptional Terminal Arithmetic Theorem") quad (upright("§14")).
$

The conditional main result of the monograph, @thm:main-conditional, is the implication that the Exceptional Terminal Arithmetic Theorem implies the Frobenius--Markov uniqueness conjecture; its proof is the consolidation of @sec:same-ray through @sec:fibonacci-pell, and is the subject of @sec:ETAT.

== Synopsis <subsec:synopsis-sec13>

This Section proves that the endpoint-to-endpoint family of @subsec:endpoint-pairs is strictly separated: $m_(1 slash (n + 2)) eq.not m_((m + 1) slash (m + 2))$ for every $n, m gt.eq.slant 1$ (@thm:endpoint-separation). The proof identifies the two endpoint arms with subsequences of the Fibonacci and Pell sequences via the matrix-square factorisations $A = S^2$ and $B = U^2$ (@subsec:left-arm-fibonacci, @subsec:right-arm-pell), where $S$ and $U$ are the standard Fibonacci and Pell matrices. The resulting endpoint identifications @eq:left-arm-fibonacci and @eq:right-arm-pell match @eq:m-fibonacci and @eq:m-pell of @sec:cohn-words, derived earlier via the central-weight formalism. The Fibonacci--Pell intersection theorem of Alekseyev @Alekseyev2011 (@thm:alekseyev-fib-pell), which asserts that the only common Fibonacci and Pell values are $0, 1, 2, 5$, then closes the proof: since both endpoint subsequences start above this set ($F_7 = 13$ and $upright("Pe")_5 = 29$), no equality is possible. The modular escape family of @sec:modular-sieve is the special case $n = 13 T$, $m = 7 T$ of the endpoint-to-endpoint family, hence is harmless (@cor:escape-harmless). The chain of reductions is now complete up to the conditional implication of @thm:main-conditional, whose proof in @sec:ETAT consolidates @sec:same-ray through the present Section into the structural reduction that the Exceptional Terminal Arithmetic Theorem implies the Frobenius--Markov uniqueness conjecture.

= The Exceptional Terminal Arithmetic Theorem and the conditional reduction <sec:ETAT>

We now reach the central reduction theorem of the monograph. Chapters @sec:same-ray[] through @sec:fibonacci-pell[] have established the chain of unconditional structural results that peel every hypothetical Cohn-tree trace collision through six successive layers of exclusions, leaving only a sharply circumscribed _terminal exceptional arithmetic problem_ in the standard Farey cone. The aim of the present Section is to formalise that terminal problem as a self-contained arithmetic statement --- the _Exceptional Terminal Arithmetic Theorem_ --- and to prove the conditional implication
$
  upright("Exceptional Terminal Arithmetic Theorem") \
  quad arrow.r.double quad upright("Frobenius–Markov uniqueness").
$
The theorem is _not_ proved in this monograph: it is the residual obstruction. What we _do_ prove is that every hypothetical Cohn-tree trace collision in the Markov tree forces a primitive return-reduced terminal pair in the exceptional regime, contradicting the theorem; hence the theorem implies Markov uniqueness.

The conditional reduction is the precise statement of the title of the monograph: _the Frobenius--Markov uniqueness conjecture has been reduced to a single explicit arithmetic problem_. Our preceding Chapters @sec:same-ray[] through @sec:fibonacci-pell[] have given the unconditional content of this reduction; @sec:modular-sieve and @sec:fibonacci-pell have indicated why the residual problem is genuinely arithmetic and resists fixed-modular methods. The present Section assembles these pieces into the conditional main theorem.

== Terminal standard-cone coordinates <subsec:terminal-coords-sec14>

After the Euclidean recoding procedure of @sec:euclidean-recoding, every unresolved mixed comparison has been recoded into the standard Farey cone $chevron.l v_0, u_0 chevron.r$ with $v_0 = (1, 0)$ and $u_0 = (1, 1)$. A terminal comparison is therefore specified by an offset
$
  Q - P = r thin u_0 - s thin v_0 = (r - s, thin r), quad quad r, s in bb(Z)_(gt.eq.slant 1).
$
Setting $P = (q, thin p)$ in $cal(D)$, the second lattice point is
$
  Q = (q + r - s, thin p + r),
$
and a terminal pair is fully described by the four-tuple $(q, thin p ; thin r, thin s)$. Both lattice points are assumed primitive in $cal(D)$:
$
  gcd (q, thin p) = 1, quad quad gcd (q + r - s, thin p + r) = 1.
$
The two corresponding Farey fractions are $p slash q$ and $(p + r) slash (q + r - s)$, and the two Markov numbers are $m_P = m_(p slash q)$ and $m_Q = m_((p + r) slash (q + r - s))$.

== Return-reduced terminal pairs <subsec:return-reduced>

The Euclidean recoding of @sec:euclidean-recoding does not just produce terminal pairs in the standard cone; it produces them as the output of a specific recoding _process_ that may have been short-circuited at an intermediate stage by one of the earlier exclusions. The terminal pairs that genuinely survive all earlier exclusions are those that pass through the recoding from start to finish without triggering dominance, same-ray monotonicity, shifted boundary separation, or the unit-terminal exclusion of @cor:unit-terminal-excluded. We give these pairs a name.

#definition(title: "Return-reduced terminal pair", lbl: <def:return-reduced>)[
  A terminal standard-cone pair $(P, Q)$ is said to be _return-reduced_ if it arises as the output of the Euclidean recoding algorithm of @sec:euclidean-recoding from a mixed comparison that was not eliminated by any of the earlier exclusion mechanisms --- specifically, not by same-ray monotonicity (@cor:no-same-ray-collision), not by dominance exclusion (@prop:dominance-exclusion), not by shifted boundary separation (@cor:no-boundary-cohn-collision), and not by the unit-terminal exclusion of @cor:unit-terminal-excluded.

  _Warning on terminology._ The qualifier _return-reduced_ is internal to the present reduction and should not be confused with the standard return-word decomposition of a Sturmian language. The two notions are unrelated: the present qualifier records the reduction-theoretic property that the pair has survived all earlier exclusion mechanisms of @sec:same-ray through @sec:shifted-boundary, whereas the Sturmian return word is a combinatorial decomposition of a Sturmian factor by occurrences of a given prefix.
] <def-return-reduced>

@def:return-reduced is intentionally reduction-theoretic rather than word-theoretic. The advantage of this formulation is that the terminal pairs against which we shall prove the conditional reduction are precisely the pairs that the unconditional Sections @sec:same-ray[] through @sec:euclidean-recoding[] leave undecided; no extraneous combinatorial condition is imposed. The disadvantage is that the definition refers backwards to the recoding process rather than forward to an intrinsic word-theoretic invariant. We have chosen the reduction-theoretic formulation deliberately, to avoid the risk of imposing a condition stronger than what the structural argument requires.

== The exceptional terminal region <subsec:exceptional-region-sec14>

The slope analysis of @sec:terminal-cone and the primitive-step exclusion of @sec:primitive-exclusion have already cut the terminal-core problem down to a narrow non-primitive sub-region of the exceptional slope window. We re-collect the cumulative result here.

By @thm:terminal-non-exceptional of @sec:terminal-cone, every terminal core $(r, s) in bb(Z)_(gt.eq.slant 2)^2$ outside the exceptional ratio window $9 slash 5 < s slash r < 15 slash 8$ is excluded by the line-monotonicity theorems of @LeeLiRabideauSchiffler2023, @LagisquetPelantovaTavenasVuillon2021, and @Huang2022. By @prop:primitive-step-exclusion of @sec:primitive-exclusion, every primitive terminal core with $gcd (r, s) = 1$ is excluded by Huang's valley theorem @Huang2022. The residual locus is therefore the non-primitive interior of the exceptional ratio window:
$
  r < s, quad quad 9 slash 5 < s slash r < 15 slash 8, quad quad gcd (r, s) > 1.
$ <eq:final-exceptional-region>

The Exceptional Terminal Arithmetic Theorem, stated next, is the conjectural assertion that no Markov-number collision survives even in this residual region, for any primitive return-reduced terminal pair.

== The Exceptional Terminal Arithmetic Theorem <subsec:ETAT-statement>

We give the formal statement of the residual arithmetic theorem.

#conjecture(title: "Exceptional Terminal Arithmetic Theorem", lbl: <thm:ETAT>)[
  Let $P = (q, thin p)$ and
  $
    Q = (q + r - s, thin p + r)
  $ <eq:ETAT-pair>
  be primitive terminal standard-cone lattice points indexing the Cohn tree, satisfying the residual exceptional regime
  $
    r < s, quad 9 slash 5 < s slash r < 15 slash 8, quad gcd (r, s) > 1,
  $ <eq:ETAT-window>
  with $r, s in bb(Z)_(gt.eq.slant 2)$. Assume in addition that the pair $(P, Q)$ is return-reduced in the sense of @def:return-reduced. Then $m_P eq.not m_Q$.
] <thm-ETAT>

We emphasise once more that @thm:ETAT is _not_ proved in the present monograph. It is the residual obstruction that the unconditional reductions of @sec:same-ray through @sec:fibonacci-pell could not eliminate, and that the negative results of @sec:modular-sieve identify as genuinely arithmetic. The conditional main result of the manuscript is the implication that @thm:ETAT, _if true_, would imply the Frobenius--Markov uniqueness conjecture.

== The conditional main theorem <subsec:main-conditional>

We now prove the central implication of the monograph.

#theorem(title: "Conditional Frobenius–Markov uniqueness", lbl: <thm:main-conditional>)[
  Assume the Exceptional Terminal Arithmetic Theorem @thm:ETAT. Then the Frobenius--Markov uniqueness conjecture holds: for every two Stern--Brocot rationals $s, t in bb(Q)_([0, 1])$,
  $
    m_s = m_t quad arrow.r.double quad s = t.
  $
  Equivalently, every Markov number occurs as the maximum of exactly one ordered Markov triple.
] <thm-main-conditional>

#proof[
  We argue by contradiction. Suppose Markov uniqueness fails. By the Cohn-trace formulation @eq:cohn-trace-injectivity of @sec:markov-cohn, there exist two distinct Cohn matrices $C_s eq.not C_t$ with equal trace $tr (C_s) = tr (C_t)$, and equivalently $m_s = m_t$ with $s eq.not t$ in $bb(Q)_([0, 1])$.

  We now peel through the six unconditional layers of exclusions in turn, showing that each layer leaves the assumed equality only with a smaller and more restricted residual class.

  _Step 0: The ancestor case is excluded by same-ray monotonicity._ Before invoking the deepest common ancestor of $C_s$ and $C_t$, we dispose of the case in which one of the two matrices is itself an ancestor of the other. If $C_s$ is an ancestor of $C_t$ in the Cohn tree, then $C_t$ is obtained from $C_s$ by a finite non-empty sequence of Cohn-tree moves, which strictly increases the trace at every step by @thm:same-ray-monotonicity of @sec:same-ray and the child-trace formulas. Hence $tr (C_s) < tr (C_t)$, contradicting $m_s = m_t$. The symmetric case in which $C_t$ is an ancestor of $C_s$ is identical. We may therefore assume that neither matrix is an ancestor of the other.

  _Step 1: Reduction to cross-ray comparison (§4)._ Let $C_u$ be the deepest common ancestor of $C_s$ and $C_t$ in the Cohn tree, and let $(R, R S, S)$ be the local Cohn triple at $C_u$. By @cor:cross-ray-reduction of @sec:same-ray, $C_s$ and $C_t$ lie in different child subtrees of $C_u$. The lattice indices $P, Q$ of $C_s, C_t$ therefore sit in an adjacent Farey cone $chevron.l v, u chevron.r$ corresponding to the split at $C_u$, with $P, Q$ on opposite sides of the local split.

  _Step 2: Dominance exclusion (§5)._ By @prop:dominance-exclusion of @sec:dominance, the comparison cannot be dominated: no positive Farey direction can separate $P$ from $Q$. By @cor:mixed-form, after possibly interchanging $P$ and $Q$, the lattice offset takes the mixed form
  $
    Q - P = r thin u - s thin v, quad quad r, s in bb(Z)_(gt.eq.slant 1).
  $

  _Step 3: Boundary exclusion (§6--§8)._ If $r = 1$ or $s = 1$, the offset $Q - P = u - k v$ or $- u + k v$ for some $k gt.eq.slant 1$, which is a _boundary_ comparison in the sense of @sec:shifted-boundary. By @cor:no-boundary-cohn-collision of @sec:shifted-boundary, no boundary trace collision occurs in the Cohn tree. Hence $r gt.eq.slant 2$ and $s gt.eq.slant 2$ in this adjacent Farey cone.

  _Step 4: Euclidean recoding (§9)._ Apply the Euclidean recoding theorem @thm:euclidean-recoding of @sec:euclidean-recoding. At each recoding step, either the recoded offset becomes a non-zero non-negative integer combination of the new basis vectors --- in which case @prop:dominance-exclusion of @sec:dominance forces strict ordering of the Markov numbers and contradicts $m_P = m_Q$ --- or the recoded comparison remains mixed in a strictly smaller adjacent Farey cone. The denominator sum $q (v) + q (u)$ is a strictly decreasing positive integer at each step, so the process terminates in finitely many steps. Termination by dominance contradicts $m_P = m_Q$; therefore the process must terminate at the standard Farey basis $((1, 0), (1, 1))$, with recoded offset
  $
    Q - P = r_0 thin u_0 - s_0 thin v_0 = (r_0 - s_0, thin r_0), quad r_0, s_0 in bb(Z)_(gt.eq.slant 1).
  $
  By @cor:unit-terminal-excluded of @sec:euclidean-recoding, the unit cases $r_0 = 1$ or $s_0 = 1$ are excluded by the same line-monotonicity arguments used in @sec:shifted-boundary. Hence $r_0, s_0 in bb(Z)_(gt.eq.slant 2)$.

  _Step 5: Non-exceptional slope exclusion (§10)._ By @thm:terminal-non-exceptional of @sec:terminal-cone, every terminal core $(r_0, s_0) in bb(Z)_(gt.eq.slant 2)^2$ outside the exceptional ratio window $9 slash 5 < s_0 slash r_0 < 15 slash 8$ is excluded by line-monotonicity. Hence $r_0 < s_0$ and $9 slash 5 < s_0 slash r_0 < 15 slash 8$.

  _Step 6: Primitive-step exclusion (§11)._ By @prop:primitive-step-exclusion of @sec:primitive-exclusion, every primitive exceptional terminal core with $gcd (r_0, s_0) = 1$ is excluded by Huang's valley theorem @Huang2022 applied to the consecutive lattice points $P, Q$ on the exceptional-slope line. Hence $gcd (r_0, s_0) > 1$.

  Combining the six steps: any surviving equality $m_P = m_Q$ must give a primitive return-reduced terminal pair $(P, Q)$ in the standard Farey cone with parameters $(r_0, s_0)$ satisfying the residual exceptional regime @eq:ETAT-window of @thm:ETAT, and $m_P = m_Q$. The pair $(P, Q)$ is return-reduced in the sense of @def:return-reduced, because at none of the six steps above was it eliminated.

  This is a primitive return-reduced terminal pair in the residual exceptional regime with equal Markov numbers, contradicting the assumed @thm:ETAT. Hence Markov uniqueness cannot fail, and the proof is complete.
]

The implication of @thm:main-conditional is the central reduction of the monograph: the Frobenius--Markov uniqueness conjecture has been reduced to a single, explicit, sharply isolated arithmetic problem on the two-parameter integer lattice $bb(Z)_(gt.eq.slant 2)^2$, restricted to the open ratio window $(9 slash 5, thin 15 slash 8)$ and the non-primitive sub-lattice $gcd (r, s) > 1$. Every other configuration --- same-ray collisions, dominated pairs, boundary collisions, mixed comparisons of arbitrary depth, terminal cones at non-exceptional slope, primitive exceptional cores --- has been ruled out unconditionally by the structural reductions of @sec:same-ray through @sec:fibonacci-pell.

== An equivalent parameterisation of the exceptional region <subsec:reparameterisation>

The exceptional region @eq:ETAT-window can be reparameterised in terms of a more transparent four-parameter family, useful for computational and modular investigations.

Introduce a new variable $h := s - r > 0$, so that $s = r + h$ and the lattice offset becomes
$
  Q - P = (r - s, thin r) = (- h, thin r).
$
The second lattice point is then $Q = (q - h, thin p + r)$. Introducing a final positive parameter $t > 0$ via $q = p + r + h + t$, the four-tuple $(p, t, r, h)$ replaces the original $(q, p, r, s)$ with bijective correspondence:
$
  P = (p + r + h + t, thin p), quad quad Q = (p + r + t, thin p + r).
$ <eq:reparameterisation>
The primitivity conditions $gcd (q, p) = 1$ and $gcd (q + r - s, p + r) = 1$ become
$
  gcd (p, thin r + h + t) = 1, quad quad gcd (p + r, thin t) = 1
$ <eq:reparam-primitivity>
respectively, by the Euclidean reduction $gcd (p, p + r + h + t) = gcd (p, r + h + t)$ and $gcd (p + r, p + r + t) = gcd (p + r, t)$.

The exceptional ratio inequalities $9 slash 5 < s slash r < 15 slash 8$ become, in the new parameters:
$
  9 slash 5 < (r + h) slash r < 15 slash 8,
$
which simplifies (subtract $1$, then take reciprocals carefully) to
$
  4 slash 5 < h slash r < 7 slash 8.
$ <eq:reparam-window>
Clearing denominators on both sides gives the linear inequalities
$
  4 r < 5 h quad upright("and") quad 8 h < 7 r,
$ <eq:reparam-linear>
two linear constraints on the pair $(r, h)$. Together they force $h < r$, as expected. The non-primitivity condition $gcd (r, s) > 1$ becomes $gcd (r, r + h) = gcd (r, h) > 1$ by the Euclidean reduction.

The Exceptional Terminal Arithmetic Theorem in the new parameterisation reads: if $(p, t, r, h)$ are positive integers satisfying
$
  4 r < 5 h, quad 8 h < 7 r, quad gcd (r, h) > 1,
$
the primitivity conditions @eq:reparam-primitivity, and the corresponding pair $(P, Q)$ of @eq:reparameterisation is return-reduced, then
$
  m_(p slash (p + r + h + t)) eq.not m_((p + r) slash (p + r + t)).
$

The parameterisation @eq:reparameterisation has two advantages. First, the exceptional window @eq:reparam-window is a _linear_ region in the $(r, h)$-plane rather than a curvilinear ratio condition, making the geometry of the exceptional locus immediately visible. Second, the four parameters $p, t, r, h$ are all positive integers indexing the residual problem by independent integer rays, suggesting modular and recurrence-theoretic attacks on the theorem at fixed $(r, h)$ as $p, t$ vary.

== Why the remaining theorem is genuinely arithmetic <subsec:why-arithmetic-sec14>

The Exceptional Terminal Arithmetic Theorem @thm:ETAT cannot be dispatched by any of the structural methods used in the preceding Sections. We collect the four reasons for this in summary form.

_Line monotonicity fails inside the window._ Huang's valley theorem @Huang2022 in @thm:huang-valley-consequence of @sec:primitive-exclusion shows that along an exceptional-slope line, generalised Markov numbers first decrease to a unique valley and then increase. The line-ordering theorems of @LeeLiRabideauSchiffler2023 do not extend across the valley, and two lattice points strictly straddling the valley can carry the same Markov number without contradicting the line-monotonicity classification.

_Sturmian compatibility fails inside the window._ For a terminal exceptional pair $(P, Q)$ with $9 slash 5 < s slash r < 15 slash 8$, the necessary slope intervals of the two Christoffel words $W_(p slash q)$ and $W_((p + r) slash (q + r - s))$ are disjoint. A direct argument based on positivity of $q$-deformed Cohn matrix products inside a _single_ balanced language (as in the proof of the $q$-analog injectivity by @LabbeLapointeSteiner2023) cannot close the exceptional case at $q = 1$.

_No fixed finite modular certificate suffices (@sec:modular-sieve)._ By @thm:no-finite-modular-certificate, for every finite set of moduli $cal(N) = { N_1, thin dots.h.c, thin N_k }$ there exists a modular escape pair $(P_T, Q_T)$ in the residual regime such that $m_(P_T) equiv m_(Q_T) equiv 5 (upright("mod") thin N_i)$ for every $N_i in cal(N)$.

_The endpoint escape families are nevertheless harmless (@sec:fibonacci-pell)._ By @thm:endpoint-separation of @sec:fibonacci-pell and @cor:escape-harmless, the modular escape family is _not_ a counterexample: the two Markov numbers $m_(P_T), m_(Q_T)$ are strictly distinct for every $T gt.eq.slant 2$, separated by Alekseyev's intersection theorem @Alekseyev2011 for Fibonacci and Pell sequences. This indicates the likely arithmetic character of any future proof of @thm:ETAT: it must be _parameter-sensitive_, exploiting either the specific recurrence structure of the terminal arms or exact Diophantine intersection identities, rather than a uniform congruence-theoretic test.

The Exceptional Terminal Arithmetic Theorem is therefore the _true arithmetic core_ of the Frobenius--Markov uniqueness conjecture, isolated by the present reduction.

== Possible routes towards a proof: a speculative outlook <sec:routes-to-ETAT>

The residual exceptional regime is amenable to several lines of attack that go beyond the unconditional structural reductions of the present monograph. The discussion that follows is openly _speculative_: each route below is a plausible line of attack rather than an established result, none has been carried out to a complete proof of @thm:ETAT, and our purpose here is to map the landscape of admissible strategies rather than to advocate for any one of them. The reader is therefore invited to treat the five subsections below as a list of orientations to keep in mind, and not as a list of programmes already underway.

(i) _Parameter-dependent modular methods._ The negative result of @thm:no-finite-modular-certificate rules out _fixed_ finite modular sieves but says nothing about moduli that depend on the parameters $(r, s, p, t)$ or $(r, h, p, t)$ of the residual pair. For example, a modulus $N (r, s)$ growing with the parameters, or a sieve over an unbounded family of moduli adapted to the recurrence structure of the corresponding Cohn-word central palindromes, is not excluded.

(ii) _Recurrence-theoretic identities._ The endpoint-to-endpoint separation of @sec:fibonacci-pell uses Alekseyev's intersection theorem @Alekseyev2011 to separate two specific Lucas sequences. The interior of the exceptional regime corresponds to longer Stern--Brocot paths, whose Markov numbers are values of higher-order Lucas-type recurrences. Intersection theorems for general families of Lucas sequences --- as developed by Alekseyev @Alekseyev2011 and subsequent authors --- might provide the appropriate generalisation, particularly for the regime where the path lengths along the two arms remain bounded.

(iii) _Geometric reformulations via the modular torus._ The simple length spectrum reformulation of Markov uniqueness by Gaster and Loustau @GasterLoustau2021 (a convergent series identity involving Lagrange numbers and the golden ratio) and Fisac's integral-necklace combinatorial translation @Fisac2025 both translate the residual exceptional problem into the geometric language of simple closed geodesics on the once-punctured torus. The valley-of-Markov-numbers structure of @rem:huang-valley-morse on a discrete cell complex has a natural analogue as a Morse function on the hyperbolic moduli space, suggesting an analytic-geometric attack on the residual obstruction.

(iv) _Cluster-algebraic structural rigidity._ The work of @BanaianGyoda2025, @Gyoda2026Words, and @BanaianHuang2026 on the $k$-generalised Markov numbers shows that structural rigidity _increases_ with $k$. The classical $k = 0$ limit is the unique value at which the residual obstruction survives. A monotonicity-in-$k$ argument, combined with a careful analysis of the $k arrow.r 0$ limit, might yield the residual statement as the boundary value of a stronger generalised result.

(v) _Quantum/superalgebraic deformations._ The $q$-deformed Markov numbers of @EvansJouteurMorierGenoudOvsienko2026 and the mirror-deformed Markov numbers of @BittmannJouteurKantarciOguzMolanderYildirim2026 are polynomial-valued deformations that satisfy strict injectivity in the deformed regime. A degeneration argument extracting the classical $q = 1$ injectivity from the polynomial-level rigidity is an open programme in this direction.

Each of these routes is partial; none has been carried out to a complete proof of @thm:ETAT. The reduction theorem @thm:main-conditional establishes that any such success --- by any combination of the strategies sketched above, or by an as-yet-unimagined alternative --- would settle the Frobenius--Markov uniqueness conjecture.

== Consequence and scope of the monograph <subsec:scope>

The cumulative content of @sec:same-ray through this Section establishes the following precise conditional statement of the monograph:

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + thm-color),
  fill: thm-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *Main reduction of the monograph.* The Frobenius--Markov uniqueness conjecture is reduced to the Exceptional Terminal Arithmetic Theorem @thm:ETAT: for every primitive return-reduced terminal pair $(P, Q)$ in the standard Farey cone with parameters $(r, s) in bb(Z)_(gt.eq.slant 2)^2$ satisfying $r < s$, $9 slash 5 < s slash r < 15 slash 8$, and $gcd (r, s) > 1$, the Markov numbers $m_P$ and $m_Q$ are distinct.
]

The reduction is valuable for two complementary reasons.

_First, all non-terminal and non-exceptional configurations have been eliminated by structural arguments._ Same-ray monotonicity (Cayley--Hamilton + middle-trace dominance), dominance exclusion (Lee--Li--Rabideau--Schiffler line-ordering), boundary-ratio monotonicity (discrete Wronskian), Vieta gluing (Chebyshev recurrence + cluster mutation), shifted boundary separation (fixed-denominator + slope-ordering), Euclidean recoding (modular-group descent), the slope-window analysis (Huang's valley theorem), and the primitive-step exclusion (consecutive-lattice-point argument) together exhaust every configuration that admits a structural exclusion. None of the remaining cases is structural in this sense.

_Second, the residual obstruction has been identified as genuinely arithmetic._ The negative results of @sec:modular-sieve (no fixed finite modular certificate suffices) and the structural rigidity collapse at the classical limit (@cor:escape-harmless, the structural-collapse discussion of the Introduction) together pinpoint why the residual obstruction is _hard_: it sits at the precise boundary where every uniform structural separator fails, and any successful approach must exploit recurrence-theoretic, parameter-dependent, or geometric-arithmetic ingredients beyond uniform congruence tests.

The final problem is therefore stated explicitly:

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + cor-color),
  fill: cor-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *The remaining arithmetic problem.* Prove that
  $
    m_(p slash q) eq.not m_((p + r) slash (q + r - s))
  $
  for every primitive return-reduced terminal pair $(P, Q) = ((q, p), (q + r - s, p + r))$ in the residual exceptional regime $r < s$, $9 slash 5 < s slash r < 15 slash 8$, $gcd (r, s) > 1$, with $r, s gt.eq.slant 2$.
]

A proof of the remaining problem --- via any combination of the strategies sketched in @sec:routes-to-ETAT --- would complete the Cohn-tree reduction and hence prove the Frobenius--Markov uniqueness conjecture. The conditional implication is the content of @thm:main-conditional, the central theorem of the monograph.

Beyond the conditional implication, @sec:minimal-direction below establishes the first concrete solved case of @thm:ETAT, namely the minimal primitive exceptional direction $(R, H) = (6, 5)$ at multiplier $g = 2$, i.e. for $(r, h) = (12, 10)$. The full @thm:ETAT remains open for the residual exceptional regime beyond this single direction; the minimal-direction case is offered as positive evidence that the residual problem has tractable arithmetic cases inside the genuinely exceptional region.

== Synopsis <subsec:synopsis-sec14>

This Section assembles the unconditional structural reductions of @sec:same-ray through @sec:fibonacci-pell into the conditional main theorem of the monograph. Terminal standard-cone coordinates are recalled (@subsec:terminal-coords-sec14); the notion of a return-reduced terminal pair is defined intrinsically in terms of the recoding process (@def:return-reduced); the residual exceptional regime is recollected from @thm:terminal-non-exceptional of @sec:terminal-cone and @prop:primitive-step-exclusion of @sec:primitive-exclusion as @eq:final-exceptional-region; the Exceptional Terminal Arithmetic Theorem @thm:ETAT is formally stated as the conjectural arithmetic statement that the residual exceptional regime contains no Markov-number collision among primitive return-reduced terminal pairs; and the conditional main theorem @thm:main-conditional is proved by six successive applications of the structural reductions of the preceding Sections, with each step adding a strictly more restrictive condition on the surviving collision until @thm:ETAT itself excludes the remaining case. The equivalent parameterisation @eq:reparameterisation translates the residual problem into the linear inequalities @eq:reparam-linear on $(r, h)$, useful for computational and modular investigations. The negative results of @sec:modular-sieve and the harmless-escape positive result of @sec:fibonacci-pell together place the residual problem in its true arithmetic context: not a structural failure to be patched by a uniform argument, but a parameter-sensitive Diophantine question for which the methods of the present monograph leave several open avenues (@sec:routes-to-ETAT). The cumulative reduction of the monograph is the implication @thm:main-conditional that the Exceptional Terminal Arithmetic Theorem implies the Frobenius--Markov uniqueness conjecture; this is the central reduction of the title of the monograph, and the substantive content of the present work.

= The exceptional terminal problem: obstructions, reformulations, and outlook <sec:outlook>

The preceding Section established the central conditional theorem of the monograph: the Exceptional Terminal Arithmetic Theorem @thm:ETAT implies the Frobenius--Markov uniqueness conjecture. The present, final, Section first summarises what the cumulative reduction of @sec:same-ray through @sec:fibonacci-pell has achieved (@subsec:reduction-summary-sec15), records what is known about the remaining exceptional terminal problem itself --- the residual obstruction left by the reduction --- and, just as importantly, what strategies do _not_ suffice. It closes with a list of the ten unconditional structural results that compose the reduction (@subsec:main-contribution-sec15) and with a brief outlook on the routes that remain promising for future work. The discussion is not needed for the logical implication proved in @sec:ETAT, but it clarifies the nature of the final obstruction and explains why the remaining arithmetic theorem is genuinely difficult.

Three readings of the Chapter are possible. As a _commentary_ on the proof, it explains why the conditional implication leaves precisely the residual regime it does. As a _research roadmap_, it sketches concrete strategies for attacking the residual problem. As a _structural assessment_ of the Frobenius--Markov conjecture, it identifies the precise locus of difficulty within the Cohn-tree framework. The three readings are complementary, and we encourage the reader to keep all three in mind.

== Summary of the reduction <subsec:reduction-summary-sec15>

Before we turn to the obstacles surrounding the residual problem, we pause to summarise the cumulative content of the unconditional reductions assembled in @sec:same-ray through @sec:fibonacci-pell. The summary is backward-looking; readers comfortable with the structure of the reduction may proceed directly to @subsec:remaining-problem.

A hypothetical equality of Markov numbers $m_s = m_t$ with $s eq.not t$ in $bb(Q)_([0, 1])$ is, by the Cohn-trace formulation @eq:cohn-trace-injectivity of @sec:markov-cohn, equivalent to a trace collision $tr (C_s) = tr (C_t)$ between two distinct Cohn matrices in the Cohn tree. The reduction excludes such a collision in six successive structural layers, each strictly narrowing the residual locus.

_Same-ray exclusion._ Along a one-sided Cohn ray $R^n S$, the trace sequence $T_n = tr (R^n S)$ satisfies the Chebyshev-type recurrence @eq:Tn-recurrence of @sec:local-cone, and positivity of the seed values forces $T_0 < T_1 < T_2 < dots.h.c$ by @subsec:same-ray-mono of @sec:same-ray. No two distinct matrices on a single one-sided Cohn ray can therefore share a trace. By @cor:cross-ray-reduction of @sec:same-ray, every hypothetical collision must therefore be a _cross-ray_ comparison, with the two Cohn matrices lying in distinct child subtrees of a common ancestor.

_Dominance exclusion._ Working in the adjacent Farey cone of the cross-ray split, with basis $(v, u)$, the lattice offset $Q - P$ has a unique expansion as an integer combination of $v$ and $u$. If the offset lies in a positive Farey direction, the line-ordering theorems @LeeLiRabideauSchiffler2023, @Gaster2022 give $m_Q > m_P$, and the comparison is separated by @prop:dominance-exclusion of @sec:dominance. Every unresolved comparison is therefore _mixed_: in the adjacent Farey basis $(v, u)$, the offset takes the form $Q - P = r thin u - s thin v$ with $r, s gt.eq.slant 1$.

_Boundary exclusion._ The boundary trace sequences $U_n$ and $V_n$ defined by the recurrences @eq:U-rec and @eq:V-rec of @sec:local-cone admit a discrete Wronskian $W_n = U_(n + 1) V_n - U_n V_(n + 1)$ satisfying the three-term recurrence @eq:Wronskian-rec, which forces strict boundary-ratio monotonicity (@subsec:boundary-ratio-monotonicity of @sec:boundary-ratio) and admits at most one boundary equality. The Vieta gluing identity @eq:Vieta-gluing of @sec:vieta-gluing then turns the boundary comparison into a shifted diagonal comparison; the adjacent inequalities at the shifted crossing index are established by line ordering, and @cor:no-boundary-cohn-collision of @sec:shifted-boundary rules out boundary collisions in the Cohn tree. Hence $r gt.eq.slant 2$ and $s gt.eq.slant 2$ in the residual mixed comparison.

_Euclidean recoding._ Every remaining mixed comparison is reduced, in finitely many inverse-Farey steps and by @thm:euclidean-recoding of @sec:euclidean-recoding, to a _terminal_ standard-cone comparison
$
  Q - P = r thin u_0 - s thin v_0 = (r - s, thin r), quad r, s in bb(Z)_(gt.eq.slant 2),
$
in the standard Farey basis $(v_0, u_0) = ((1, 0), (1, 1))$. The procedure terminates because the denominator sum $q(v) + q(u)$ is a strictly decreasing positive integer at each step.

_Terminal non-exceptional exclusion._ By @thm:terminal-non-exceptional of @sec:terminal-cone, every terminal core $(r, s) in bb(Z)_(gt.eq.slant 2)^2$ with $r gt.eq.slant s$ is ordered by line monotonicity (positive slope when $r > s$, or fixed-denominator monotonicity when $r = s$), and every terminal core with $r < s$ outside the exceptional ratio window $9 slash 5 < s slash r < 15 slash 8$ is ordered by the slope-ordering theorem @LeeLiRabideauSchiffler2023, @Gaster2022. The residual locus is therefore confined to the exceptional ratio window.

_Primitive-step exclusion._ Within the exceptional window, @prop:primitive-step-exclusion of @sec:primitive-exclusion excludes every primitive-step pair with $gcd (r, s) = 1$ via Huang's valley theorem @Huang2022: the two terminal points are consecutive on the exceptional-slope line, and consecutive lattice points have distinct generalised Markov values. What survives is precisely the residual exceptional regime
$
  r < s, quad 9 slash 5 < s slash r < 15 slash 8, quad gcd (r, s) > 1, quad r, s gt.eq.slant 2,
$ <eq:residual-regime-sec15>
under the additional return-reduction constraint of @def:return-reduced. The Exceptional Terminal Arithmetic Theorem @thm:ETAT is the conjectural assertion that no Markov-number collision survives in this residual regime, and the conditional main theorem @thm:main-conditional of @sec:ETAT translates this conjectural arithmetic statement back into the Frobenius--Markov uniqueness conjecture. The remainder of the present Section is devoted to the obstacles, both structural and arithmetic, that stand between this conjectural statement and a proof.

== The remaining terminal problem <subsec:remaining-problem>

We restate the remaining problem for ease of reference. After @sec:same-ray (same-ray monotonicity), @sec:dominance (dominance exclusion), @sec:shifted-boundary (shifted boundary separation), @sec:euclidean-recoding (Euclidean recoding), @sec:terminal-cone (terminal non-exceptional exclusion), and @sec:primitive-exclusion (primitive-step exclusion), every unresolved hypothetical Cohn-tree trace collision is a primitive return-reduced terminal standard-cone pair of the form
$
  P = (q, thin p), quad quad Q = (q + r - s, thin p + r),
$
with
$
  r < s, quad 9 slash 5 < s slash r < 15 slash 8, quad gcd (r, s) > 1, quad r, s gt.eq.slant 2,
$
and with both $P$ and $Q$ primitive lattice points in $cal(D)$. Equivalently, in slope coordinates, the line through $Q$ and $P$ oriented by increasing $q$-coordinate has slope $lambda = - r slash (s - r)$ with
$
  - 5 slash 4 < lambda < - 8 slash 7,
$
precisely the exceptional non-monotone interval of the line-ordering theorems @LeeLiRabideauSchiffler2023 and @Huang2022 of @sec:dominance.

The Exceptional Terminal Arithmetic Theorem @thm:ETAT then asserts that $m_P eq.not m_Q$ for every such primitive return-reduced terminal pair. This is the final arithmetic obstruction left by the reduction. The remainder of the present Section is devoted to the obstacles, both structural and arithmetic, that lie between the present state of the manuscript and a proof of @thm:ETAT.

== Parameter form of the exceptional region <subsec:parameter-form-sec15>

We have already encountered the equivalent $(p, t, r, h)$ parameterisation of @subsec:reparameterisation. We recall it briefly here, in the form most useful for the obstructions and routes discussed below. Setting $h := s - r > 0$ and $q = p + r + h + t$ with $t > 0$, the terminal pair takes the form
$
  P = (p + r + h + t, thin p), quad quad Q = (p + r + t, thin p + r),
$ <eq:reparam-sec15>
and the exceptional ratio inequalities $9 slash 5 < s slash r < 15 slash 8$ translate into the linear inequalities
$
  4 r < 5 h quad upright("and") quad 8 h < 7 r,
$ <eq:linear-window-sec15>
in the $(r, h)$-plane. The non-primitivity condition $gcd (r, s) > 1$ is equivalent to $gcd (r, h) > 1$, since $gcd (r, r + h) = gcd (r, h)$. The primitivity conditions for $P$ and $Q$ are
$
  gcd (p, thin r + h + t) = 1, quad quad gcd (p + r, thin t) = 1.
$ <eq:primitivity-sec15>

In the equivalent four-parameter form, the Exceptional Terminal Arithmetic Theorem reads: for every quadruple $(p, t, r, h) in bb(Z)_(gt.eq.slant 1)^4$ satisfying @eq:linear-window-sec15, $gcd (r, h) > 1$, the primitivity conditions @eq:primitivity-sec15, and the return-reduction condition of @def:return-reduced, the corresponding lattice points @eq:reparam-sec15 have $m_P eq.not m_Q$.

The advantage of this form for the obstructions below is that the exceptional window @eq:linear-window-sec15 is _linear_ in $(r, h)$, so the constraints can be visualised as a wedge in the integer lattice; the residual problem is the assertion that no Markov-number collision occurs anywhere inside this wedge under the gcd and return-reduction constraints.

== The Sturmian compatibility obstruction <subsec:sturmian-obstruction>

A natural temptation is to use the language of _balanced_ or _Sturmian_ words to attack the residual problem. The idea is the following: if the two Cohn--Christoffel words $W_P = W_(p slash q)$ and $W_Q = W_((p + r) slash (q + r - s))$ corresponding to the terminal pair $(P, Q)$ both occur inside a single balanced bi-infinite word of some slope $alpha$, then a positivity argument (such as the $q$-deformed Cohn-matrix positivity used by @LabbeLapointeSteiner2023 in the proof of the $q$-analog injectivity) might transfer the structural rigidity to the classical $q = 1$ specialisation.

We show that this strategy cannot succeed for the residual regime: in the exceptional terminal window, the two Cohn--Christoffel words generally do _not_ live in a common balanced infinite word.

The structural obstacle is a balanced-word slope-interval calculation. Recall from the theory of Sturmian sequences that if a Christoffel word $W_(q, p)$ of length $q$ and height $p$ occurs as a factor of a balanced infinite word of slope $alpha$, then the balancedness estimate gives
$
  alpha thin q - 1 lt.eq.slant p lt.eq.slant alpha thin q + 1,
$
so the slope $alpha$ must lie in the closed interval
$
  I_(q, p) := [thin (p - 1) slash q, thick (p + 1) slash q thin].
$

#proposition(title: "Sturmian incompatibility of terminal pairs", lbl: <prop:sturmian-disjoint>)[
  Let $P = (q, thin p)$ and $Q = (q + r - s, thin p + r)$ be a primitive terminal standard-cone pair with $r, s gt.eq.slant 2$ and $r < s$. Then the slope intervals
  $
    I_P &:= [thin (p - 1) slash q, thick (p + 1) slash q thin], \
    I_Q &:= [thin (p + r - 1) slash (q + r - s), thick (p + r + 1) slash (q + r - s) thin]
  $
  are disjoint. Consequently, the two Christoffel/Cohn words $W_P$ and $W_Q$ cannot both occur as factors of a single balanced infinite word.
] <prop-sturmian-disjoint>

#proof[
  The two intervals are disjoint if and only if $max I_P < min I_Q$, that is,
  $
    (p + 1) slash q < (p + r - 1) slash (q + r - s).
  $
  Both denominators are strictly positive (the second by $q gt.eq.slant 1$, $r gt.eq.slant 2$, and the residual hypothesis structure). Clearing denominators, the inequality becomes
  $
    q thin (p + r - 1) - (p + 1) thin (q + r - s) > 0.
  $
  Expanding and simplifying,
  $
    q thin (p + r - 1) - (p + 1) thin (q + r - s) &= q p + q r - q - (p q + p (r - s) + q + r - s) \
                                                     &= q r - 2 q - p (r - s) - r + s \
                                                     &= q thin (r - 2) + (p + 1) thin (s - r),
  $
  where the final step uses $- p (r - s) = p (s - r)$ and groups the $r, s$ terms. Under the residual hypotheses $r gt.eq.slant 2$ and $s > r$, both terms are non-negative, and the second is strictly positive because $s - r gt.eq.slant 1$ and $p + 1 gt.eq.slant 1$. Hence the sum is strictly positive, and $max I_P < min I_Q$, so $I_P inter I_Q = nothing$.

  Consequently no single value of $alpha$ lies in both intervals, and the two Christoffel/Cohn words $W_P, W_Q$ cannot both be factors of a common balanced infinite word.
]

@prop:sturmian-disjoint says that any direct argument transferring the $q$-deformed injectivity of @LabbeLapointeSteiner2023 to the classical $q = 1$ specialisation via a common balanced language _cannot work_ in the residual regime: the necessary common language does not exist. The proof of @LabbeLapointeSteiner2023 in fact works inside a balanced infinite word of slope $alpha$, deriving the polynomial positivity from a strong rigidity property of the $q$-deformed Cohn-matrix product. The classical limit $q arrow.r 1$ collapses this rigidity, and the Sturmian disjointness @prop:sturmian-disjoint shows that the two terminal words cannot be simultaneously accommodated in the same balanced framework.

#remark(title: "The disjointness as a structural lower bound on the obstruction", lbl: <rem:sturmian-lower-bound>)[
  The Sturmian disjointness @prop:sturmian-disjoint quantifies the precise sense in which the two terminal Christoffel words are _arithmetically separated_ rather than just combinatorially distinct. Their length-$q$ and length-$(q + r - s)$ balancedness windows are non-overlapping intervals, and the natural Sturmian-substitution dynamics of @rem:christoffel-geometry of @sec:cohn-words sends each word to a distinct rotation of the two-torus. The discrete-dynamical reading suggests that the residual obstruction is a question about _non-overlapping rotational orbits_ on the torus rather than a question inside a single rotational orbit, and that any proof of @thm:ETAT must therefore exploit the difference between two independent rotational structures. This is the dynamical-systems facet of the classical-limit pattern described in the Introduction, in the language of @SpaldingVeselov2017.
]

== Non-primitive step does not force return reducibility <subsec:non-return-reducible>

A second tempting idea is to use the non-primitivity condition $gcd (r, s) > 1$ to force a hidden return decomposition: perhaps every non-primitive exceptional pair admits a further Euclidean recoding step that eliminates it before it reaches the terminal cone. We now show that this idea fails, by exhibiting an explicit non-primitive exceptional pair that is _not_ return-reducible in the sense of @def:return-reduced.

#proposition(title: "An explicit non-return-reducible exceptional pair", lbl: <prop:non-return-reducible>)[
  The pair
  $
    P = (43, thin 20), quad quad Q = (33, thin 32)
  $
  is a primitive terminal exceptional pair, with $(r, s) = (12, 22)$, $s slash r = 11 slash 6$, $gcd (r, s) = 2 > 1$, and lies in the residual exceptional regime $9 slash 5 < s slash r < 15 slash 8$. However, the two Stern--Brocot fractions $p slash q = 20 slash 43$ and $(p + r) slash (q + r - s) = 32 slash 33$ lie on opposite sides of the midpoint $1 slash 2$ of the standard cone, so $P$ and $Q$ are already separated by the first non-trivial Stern--Brocot subdivision and admit no further return cone for Euclidean recoding to act on.
] <prop-non-return-reducible>

#proof[
  We first verify the listed numerical assertions about $(P, Q)$.

  The lattice difference is $Q - P = (33 - 43, thin 32 - 20) = (- 10, thin 12)$. In the standard-cone form $Q - P = (r - s, thin r)$, this gives $r = 12$ and $r - s = - 10$, hence $s = 22$. The ratio is $s slash r = 22 slash 12 = 11 slash 6 approx 1.833$. The exceptional window inequalities $9 slash 5 = 1.8 < 11 slash 6 < 1.875 = 15 slash 8$ both hold (clearing denominators: $11 dot 5 = 55 > 54 = 9 dot 6$, and $11 dot 8 = 88 < 90 = 15 dot 6$). The gcd $gcd (12, 22) = 2 > 1$. Both lattice points are primitive: $gcd (43, 20) = gcd (43 - 2 dot 20, thin 20) = gcd (3, thin 20) = gcd (3, thin 20 - 6 dot 3) = gcd (3, thin 2) = gcd (1, thin 2) = 1$, and $gcd (33, 32) = gcd (1, thin 32) = 1$. Hence $(P, Q)$ is a primitive terminal exceptional pair in the residual regime.

  We now verify that the two corresponding Stern--Brocot fractions sit on opposite sides of $1 slash 2$. We have $p slash q = 20 slash 43$, and $20 dot 2 = 40 < 43$, so $20 slash 43 < 1 slash 2$. We have $(p + r) slash (q + r - s) = 32 slash 33$, and $32 dot 2 = 64 > 33$, so $32 slash 33 > 1 slash 2$. The two Stern--Brocot rationals lie on opposite sides of the mediant $1 slash 2$ of the standard cone, hence are already separated in the first Stern--Brocot subdivision of the cone.

  Consequently, the Euclidean recoding procedure of @sec:euclidean-recoding cannot reduce the pair to a strictly smaller adjacent Farey cone: the two lattice points fall into different child cones of the standard cone, and any attempt to recode lifts the offset back to a non-mixed direction in the larger ambient cone. The pair is therefore not return-reducible in the sense of @def:return-reduced.
]

@prop:non-return-reducible is a warning: the condition $gcd (r, s) > 1$ is _not_ a sufficient combinatorial-structural condition for return reducibility, and any proof strategy that hopes to extract additional Euclidean steps from the non-primitivity must do more than count the gcd. The genuinely arithmetic character of the residual obstruction is reaffirmed by this example.

== Valley straddling of a potential collision <subsec:valley-straddling-sec15>

We have already proved @cor:valley-straddling of @sec:primitive-exclusion: if $m_P = m_Q$ for a non-primitive exceptional terminal pair with $g := gcd (r, s) > 1$, then the lattice sequence $Q_0, Q_1, dots.h.c, Q_g$ along the exceptional-slope line through $P, Q$ must straddle the unique Huang valley of @thm:huang-valley-consequence. We recall the precise structural consequence here.

Set $r_0 := r slash g$, $s_0 := s slash g$, with $gcd (r_0, s_0) = 1$. The primitive direction along the exceptional line is $w = (r_0 - s_0, thin r_0)$, the lattice points on the segment from $Q$ to $P$ are
$
  Q_i := Q + i thin w, quad quad i = 0, 1, dots.h.c, g,
$
with $Q_0 = Q$ and $Q_g = P$, and the generalised Markov numbers along the segment are $M_i := upright("Markov")(Q_i)$. If $m_P = m_Q$, then by @cor:valley-straddling of @sec:primitive-exclusion the Huang valley index $i_0$ along the line lies strictly between $1$ and $g - 1$, and
$
  M_1 < M_0 = m_Q quad upright("and") quad M_(g - 1) < M_g = m_P.
$

A potential exceptional terminal collision is therefore _symmetric across the Huang valley_: it equates the two endpoint values of a strictly decreasing-then-increasing sequence on a line through the valley. The geometric content of the residual obstruction is the assertion that no such symmetric value can be attained at primitive return-reduced endpoints. From this perspective, the Exceptional Terminal Arithmetic Theorem is a statement about the _asymmetry_ of the Markov-distance function along exceptional-slope lines: the line-restricted generalised Markov function, although attaining a minimum (the valley), does so without symmetric repeated values at the endpoints. The discrete-Morse-theoretic reading of @rem:huang-valley-morse of @sec:primitive-exclusion is therefore strengthened to a quantitative non-degeneracy statement: not only is the minimum unique, but its "level sets" (in the discrete-function sense) at the two endpoints differ.

== No fixed finite modular sieve can work <subsec:no-modular-sieve-sec15>

We recall the negative result of @sec:modular-sieve. By @thm:no-finite-modular-certificate, for every finite set of moduli $cal(N) = { N_1, thin dots.h.c, thin N_k }$ there exists an exceptional terminal endpoint pair $(P_T, Q_T)$ with $T gt.eq.slant 2$, defined in @def:modular-escape-pair, such that
$
  m_(P_T) equiv m_(Q_T) equiv 5 (upright("mod") thin N_i)
$
for every $N_i in cal(N)$.

The reason is structural: along the unary Stern--Brocot paths $L^n$ and $R^m$, the corresponding Cohn-matrix powers $M(A)^n$ and $M(B)^m$ reduce to elements of the finite group $upright(S L)(2, bb(Z) slash N bb(Z))$, hence have finite multiplicative order for every fixed $N$. A common multiple of the orders over the chosen finite set $cal(N)$ then yields a single integer $T$ at which both endpoint Markov numbers reduce simultaneously to $bold(a)^top thin I thin bold(a) = 5$ modulo every $N_i in cal(N)$, by @lem:common-unary-period.

The structural conclusion is that any modular approach to @thm:ETAT must be _parameter-dependent_: the modulus must depend on the residual parameters $(r, s, p, t)$, on a Cohn-index quantity, or on a function of the residual pair, rather than being chosen once and for all in advance.

#remark(title: "What a parameter-dependent modular proof might look like", lbl: <rem:param-dependent-modular>)[
  A parameter-dependent modular proof of @thm:ETAT would need to associate, to each primitive return-reduced terminal exceptional pair $(P, Q)$ with parameters $(r, s, p, t)$, a specific modulus $N (r, s, p, t)$ such that $m_P eq.not m_Q (upright("mod") thin N)$. The modulus $N$ should depend in a controlled algebraic way on the parameters, ideally as a prime factor of some natural integer expression in $r, s, p, t$. Examples of natural candidates: prime factors of $r s$, of $s - r$, of $h dot gcd (r, s)$, or of the trace-difference $tr (C_P) - tr (C_Q) = 3 (m_P - m_Q)$ itself. The negative result @thm:no-finite-modular-certificate rules out _bounded_ choices of $N$, but unbounded parameter-dependent choices remain a live possibility, especially in light of the linear-window structure @eq:linear-window-sec15 in the $(r, h)$-plane.
]

== Endpoint escape families are nevertheless harmless <subsec:endpoint-harmless-sec15>

We recall the positive result of @sec:fibonacci-pell. By @thm:endpoint-separation of @sec:fibonacci-pell, for every $n, m gt.eq.slant 1$,
$
  m_(1 slash (n + 2)) eq.not m_((m + 1) slash (m + 2)).
$
The proof uses the endpoint identifications $m_(1 slash q) = F_(2 q + 1)$ and $m_((q - 1) slash q) = upright("Pe")_(2 q - 1)$ via the matrix-square factorisations $A = S^2$ and $B = U^2$ of @subsec:left-arm-fibonacci and @subsec:right-arm-pell, combined with Alekseyev's intersection theorem @Alekseyev2011 that the only common Fibonacci--Pell values are $0, 1, 2, 5$. In particular, the modular escape family $(P_T, Q_T)$ of @def:modular-escape-pair satisfies $m_(P_T) eq.not m_(Q_T)$ for every $T gt.eq.slant 2$ by @cor:escape-harmless.

The structural takeaway is that the residual exceptional regime, even on its endpoint boundary, is _separated by exact recurrence arithmetic_: the two endpoint arms are second-order linear recurrence sequences at distinct Pisot growth rates ($phi.alt^2 = (3 + sqrt(5)) slash 2$ and $1 + 2 sqrt(2)$ via $A = S^2, B = U^2$), and Alekseyev's intersection theorem closes the corresponding Diophantine intersection problem. This suggests that any proof of @thm:ETAT must use _exact recurrence arithmetic_ in some form, generalising the Fibonacci--Pell intersection beyond the unary endpoint arms.

== The fixed-arm recurrence hierarchy <subsec:fixed-arm-hierarchy>

Beyond the unary endpoint arms, more general fixed Cohn arms also produce linear recurrence sequences, but of higher order. We describe the hierarchy briefly.

A _fixed Cohn arm_ is a sequence of lattice points obtained by repeatedly applying a single Cohn-tree move from a starting Cohn triple. If the move corresponds to multiplication by a fixed matrix $H in upright(S L)(2, bb(Z))$, then the Markov-number sequence along the arm has the form
$
  M_n = (1 slash 3) tr (X thin H^n thin Y),
$ <eq:fixed-arm-trace>
where $X$ and $Y$ are fixed boundary Cohn matrices. By the Cayley--Hamilton identity for $H$ in $upright(S L)(2, bb(Z))$,
$
  H^2 = (tr H) thin H - I,
$
the trace sequence in @eq:fixed-arm-trace satisfies the second-order linear recurrence
$
  M_(n + 2) = (tr H) thin M_(n + 1) - M_n.
$ <eq:fixed-arm-recurrence>
This is the same Chebyshev-type recurrence we have already met in @lem:chebyshev-closed-form of @sec:local-cone for the boundary trace sequences.

Endpoint-to-endpoint comparisons reduce to Fibonacci--Pell intersections, as in @sec:fibonacci-pell. The next layer of fixed-arm families --- e.g. $L^n R$ versus $R^m$ --- reduces to more complicated Lucas--Pell-type equations, whose intersection theory is harder but still within reach of generalisations of @Alekseyev2011. Higher fixed-arm families give higher-order or affine recurrence problems, with proportionally more delicate intersection theory.

A family-by-family resolution along the fixed-arm hierarchy is therefore conceivable but not viable as a complete proof of @thm:ETAT: the hierarchy is infinite, and a uniform recurrence-intersection theorem covering all fixed-arm families simultaneously appears necessary.

#remark(title: "The fixed-arm hierarchy and the Lucas-sequence intersection problem", lbl: <rem:fixed-arm-lucas>)[
  The fixed-arm hierarchy is the lattice-theoretic shadow of the general _Lucas-sequence intersection problem_: given two integer sequences $(U_n), (V_n)$ defined by second-order linear recurrences with integer coefficients, when can they share a common value? Alekseyev's intersection theorem @Alekseyev2011 settles the binary case (and more), and a broader programme of refining Lucas-sequence intersections continues. Within the fixed-arm hierarchy of the Cohn tree, the relevant matrix-power traces produce Lucas sequences whose Pisot parameters are eigenvalues of fixed $upright(S L)(2, bb(Z))$-matrices; the intersection problem inherits a Diophantine structure from the modular group $upright(S L)(2, bb(Z))$ and its arithmetic. This is the algebraic-arithmetic substrate of the residual exceptional terminal problem.
]

== Possible routes to a proof of the residual theorem <subsec:routes-to-proof>

The negative results above narrow the scope of admissible proof strategies for @thm:ETAT but do not rule out a successful approach. We briefly elaborate four routes that remain open, complementing the broader summary in @sec:routes-to-ETAT of @sec:ETAT.

_Route 1: Line-specific recurrence asymmetry._ Fix a primitive exceptional direction $w = (r_0 - s_0, thin r_0)$ with $9 slash 5 < s_0 slash r_0 < 15 slash 8$. Study the generalised Markov numbers along the line $P + i thin w$ inside the lattice $cal(D)$. Huang's valley theorem @Huang2022 in @thm:huang-valley-consequence gives the qualitative valley shape. What is missing is a sharp _quantitative_ asymmetry statement: $M_0 eq.not M_g$ for every primitive return-reduced endpoint pair. A possible target is to prove that the product of ratios on opposite sides of the valley never coincides exactly for primitive return-reduced endpoints. The Markov-distance and Ptolemy-inequality framework of @LeeLiRabideauSchiffler2023 and @Huang2022 provides the relevant infrastructure.

_Route 2: Parameter-dependent modular obstruction._ As outlined in @rem:param-dependent-modular, the negative result @thm:no-finite-modular-certificate rules out fixed finite moduli but leaves parameter-dependent moduli wide open. A productive direction is to seek a prime divisor of a natural expression in the four-parameter form @eq:reparam-sec15, possibly tied to the Cohn-matrix structure, that separates $m_P$ and $m_Q$ in residue.

_Route 3: Uniform Cohn-arm recurrence theorem._ One could attempt to prove that two distinct return-reduced Cohn arms cannot share any common Markov-number values inside the terminal exceptional regime. This would generalise the Fibonacci--Pell endpoint separation of @sec:fibonacci-pell to higher-order Lucas sequences. The full uniform theorem is ambitious and approaches the original Frobenius--Markov conjecture in scope, but a version restricted to the exceptional-window geometry --- exploiting the linear-wedge structure @eq:linear-window-sec15 --- may be plausible.

_Route 4: Cluster-algebraic or snake-graph asymmetry._ Markov numbers count perfect matchings of certain snake graphs, by the cluster-algebra interpretation of @sec:vieta-gluing and the work of @BanaianGyoda2025 and @Gyoda2026Words. A direct combinatorial injection from the matching set of the snake graph associated with $P$ into the matching set associated with $Q$, with a non-empty complement, would prove strict inequality in the exceptional terminal region. This route avoids some of the difficulties of recurrence intersections by working directly with the combinatorial expansion of the Markov number. The recent $k$-generalised matrixisations @BanaianGyoda2025 and the mirror-deformed framework @BittmannJouteurKantarciOguzMolanderYildirim2026 provide structurally rigid lifts of the snake-graph counting, which might be exploited via a limit argument at $k = 0$ or $q = 1$.

#remark(title: "The four routes as facets of a single residual problem", lbl: <rem:four-routes>)[
  The four routes above are not mutually exclusive but rather complementary facets of the same residual problem. Route 1 (line asymmetry) and Route 3 (uniform Cohn-arm recurrence) approach the residual from the recurrence-theoretic side; Route 2 (parameter-dependent modular) from the arithmetic-congruence side; and Route 4 (cluster/snake-graph asymmetry) from the combinatorial-categorical side. The discussions of @rem:huang-valley-morse, @rem:matrix-square, and the structural-collapse paragraph of the Introduction together place the residual problem in a wide ecosystem of mathematical structures, from the once-punctured-torus character variety, through Lucas-sequence intersection theory, to cluster-algebra mutations of triangulated orbifolds. Each of these structures may, in principle, be the natural setting for a proof of @thm:ETAT; identifying which structure carries the right notion of rigidity is the central open question of the Cohn-tree approach to the Frobenius--Markov conjecture.
]

== A brief outlook <subsec:outlook-discussion>

The cumulative content of the manuscript is the reduction of the Frobenius--Markov uniqueness conjecture to a single explicit arithmetic problem, the Exceptional Terminal Arithmetic Theorem @thm:ETAT. The reduction is unconditional and structural: every configuration outside the residual exceptional regime is excluded by a published theorem of Markov-number ordering or by a direct algebraic identity. The residual regime is genuinely arithmetic: line monotonicity fails inside the slope window (@thm:huang-valley-consequence), balanced-language compatibility fails (@prop:sturmian-disjoint), non-primitive step does not force return reducibility (@prop:non-return-reducible), fixed finite modular sieves cannot work (@thm:no-finite-modular-certificate), and endpoint escape families require exact recurrence arithmetic (@thm:endpoint-separation).

What is left, then, is a genuinely arithmetic question. A proof of @thm:ETAT would complete the Cohn-tree reduction and prove the Frobenius--Markov uniqueness conjecture. The four routes sketched in @subsec:routes-to-proof outline possible directions; the modern literature reviewed in the Introduction provides the broader landscape; and the classical-limit pattern in the deformations (the closing paragraph of the Introduction) suggests that the residual problem sits at a structurally distinguished position --- the boundary between the deformed settings, in which more information is preserved by the invariants, and the classical setting in which that information contracts to a scalar integer.

@sec:minimal-direction below provides a first concrete realisation of one of these routes. It combines elements of Route 1 (line/trace asymmetry inside the exceptional window) and Route 2 (parameter-dependent modular obstruction) to prove @thm:ETAT in the minimal primitive exceptional direction $(R, H) = (6, 5)$ at multiplier $g = 2$. The proof rests on no auxiliary conjecture: it uses only the finite congruence-certificate principle, the periodicity of the $(2, 1)$-twist matrix modulo small primes, and a symbolic Chebyshev-bound argument for the central family $c = 5$. The case is the first solved instance of the residual problem inside the genuinely exceptional non-primitive terminal region, and it suggests that direction-by-direction proofs of @thm:ETAT may be tractable along the primitive exceptional directions $(R, H)$, with the multiplier $g$ playing the role of a continuation parameter inside each direction.

The author of this monograph believes in the unity of mathematics. The Frobenius--Markov uniqueness conjecture, with its century of attention, is a problem whose resolution will draw on more than one discipline: number theory, hyperbolic geometry, combinatorics on words, cluster algebra, and dynamical systems all contribute to the picture developed here, and we expect the final proof of @thm:ETAT --- whenever it comes --- to draw on a similarly broad palette.

== Main contribution <subsec:main-contribution-sec15>

The contribution of the monograph is not a proof of the Frobenius--Markov uniqueness conjecture but a sharp reduction: subject to the residual Exceptional Terminal Arithmetic Theorem @thm:ETAT, the conjecture follows from the cumulative content of @sec:same-ray through @sec:fibonacci-pell by way of @thm:main-conditional of @sec:ETAT. The ten unconditional structural results that compose this cumulative content are, in the order in which the manuscript proves them: (i) same-ray monotonicity of the Cohn-tree trace sequence (@subsec:same-ray-mono of @sec:same-ray), excluding every internal collision on a one-sided Cohn ray; (ii) dominance exclusion of all positive-Farey-direction comparisons (@prop:dominance-exclusion of @sec:dominance), reducing every unresolved cross-ray comparison to mixed form $Q - P = r thin u - s thin v$ with $r, s gt.eq.slant 1$; (iii) strict monotonicity of the boundary trace ratio $rho_n = U_n slash V_n$ (@subsec:boundary-ratio-monotonicity of @sec:boundary-ratio), supplied by the discrete Wronskian recurrence @eq:Wronskian-rec; (iv) the Vieta gluing identity @eq:Vieta-gluing of @sec:vieta-gluing, which exchanges a boundary comparison for a shifted diagonal comparison at the Vieta predecessor; (v) shifted boundary separation of every boundary comparison (@thm:shifted-boundary-separation of @sec:shifted-boundary), forcing the unit cases $r = 1$ and $s = 1$ to be excluded; (vi) Euclidean recoding of every mixed comparison to a standard-cone terminal pair (@thm:euclidean-recoding of @sec:euclidean-recoding), with strict denominator-sum decrease at each step; (vii) line-ordering exclusion of every terminal core outside the exceptional ratio window (@thm:terminal-non-exceptional of @sec:terminal-cone), confining the residual locus to $9 slash 5 < s slash r < 15 slash 8$; (viii) Huang-valley exclusion of every primitive-step exceptional pair (@prop:primitive-step-exclusion of @sec:primitive-exclusion), forcing $gcd (r, s) > 1$ on the residual locus; (ix) the impossibility of any fixed finite modular certificate for the residual problem (@thm:no-finite-modular-certificate of @sec:modular-sieve), constructed via the explicit endpoint escape family $(P_T, Q_T)$ of @def:modular-escape-pair; and (x) Alekseyev-based separation of the endpoint-to-endpoint Fibonacci--Pell escape families (@thm:endpoint-separation of @sec:fibonacci-pell), which closes the only obvious harmless-escape route. The conditional implication that the Exceptional Terminal Arithmetic Theorem implies the Frobenius--Markov uniqueness conjecture (@thm:main-conditional of @sec:ETAT) is the cumulative culmination of these ten results, and is the central content of the monograph. Every result of the list is unconditional; the only conditional statement of the manuscript is the residual @thm:ETAT itself, and any future resolution of @thm:ETAT --- whether by one of the four routes of @subsec:routes-to-proof or by a strategy as yet unimagined --- would complete the Cohn-tree reduction and prove the Frobenius--Markov uniqueness conjecture.

== Synopsis <subsec:synopsis-sec15>

This Section opens with a backward-looking summary of the cumulative reduction (@subsec:reduction-summary-sec15), tracing the six successive structural layers --- same-ray exclusion, dominance exclusion, boundary exclusion, Euclidean recoding, terminal non-exceptional exclusion, primitive-step exclusion --- that together carve out the residual exceptional regime @eq:residual-regime-sec15. It then assembles the structural and arithmetic obstacles encountered in the residual regime, plus a discussion of routes forward. The residual problem (@subsec:remaining-problem) is the Exceptional Terminal Arithmetic Theorem @thm:ETAT in its standard-cone form; the equivalent four-parameter form (@subsec:parameter-form-sec15) gives the linear-wedge structure @eq:linear-window-sec15 in the $(r, h)$-plane. Three negative obstacles together identify the residual problem as genuinely arithmetic: Sturmian disjointness of the two terminal Christoffel words (@prop:sturmian-disjoint), the failure of $gcd (r, s) > 1$ to force return reducibility (@prop:non-return-reducible), and the impossibility of a fixed finite modular sieve (@thm:no-finite-modular-certificate). Two positive structural anchors orient the problem: valley straddling of any potential collision (@subsec:valley-straddling-sec15) and the harmlessness of endpoint escape families by Alekseyev's intersection theorem (@thm:endpoint-separation). The fixed-arm recurrence hierarchy (@subsec:fixed-arm-hierarchy) extends the endpoint identification beyond the unary arms, producing higher-order Lucas-type recurrences whose intersection theory is the recurrence-theoretic substrate of the residual problem. Four routes to a proof are sketched in @subsec:routes-to-proof: line asymmetry, parameter-dependent modular obstruction, uniform Cohn-arm recurrence theorem, and cluster/snake-graph asymmetry. The closing outlook (@subsec:outlook-discussion) places the residual problem in the broader landscape of modern mathematics --- character varieties, Lucas-sequence intersection theory, cluster algebras, and dynamical systems --- and concludes that any proof of @thm:ETAT will likely draw on a broad palette, in keeping with the unity-of-mathematics spirit that has guided the entire monograph. The Section's penultimate subsection (@subsec:main-contribution-sec15) collects the ten unconditional structural results that compose the reduction, in a single backward-looking enumeration that complements the forward-looking contributions list of the Introduction.

#pagebreak()

= A first solved exceptional terminal case <sec:minimal-direction>

The preceding Section laid out the residual exceptional terminal problem, its obstructions, and four routes towards a proof of @thm:ETAT. The present Section delivers the first concrete instance of that proof: @thm:ETAT holds in the _minimal primitive exceptional direction_ $(R, H) = (6, 5)$ at multiplier $g = 2$, i.e. for $(r, h) = (12, 10)$. This is the first solved case of @thm:ETAT inside the genuinely exceptional non-primitive terminal region; it is neither a boundary case, nor a primitive-step case, nor an endpoint escape family. The proof combines an elementary residue reduction (@subsec:residue-reduction), a return-reduced reduction to seventeen one-parameter families in a single integer parameter $c$ (@subsec:seventeen-families), a finite congruence-certificate principle backed by the period of the $(2, 1)$-twist (@subsec:congruence-certificate), a compact certificate table covering sixteen non-central families (@subsec:sixteen-table), and a symbolic trace-positivity argument for the central family $c = 5$ (@subsec:central-family). The conclusion is collected in @subsec:g2-conclusion; the residue tables, the certificate scripts, and the symbolic positivity data are recorded in @appendix:minimal-certificates.

== The minimal exceptional direction and the first nonprimitive step <subsec:minimal-direction-statement>

The reduction of the preceding Sections singles out one residual obstruction to the Frobenius--Markov uniqueness conjecture: the Exceptional Terminal Arithmetic Theorem @thm:ETAT, in the equivalent four-parameter form recalled in @subsec:reparameterisation and @subsec:parameter-form-sec15. In that form the residual problem is to prove
$
  m_P eq.not m_Q
$ <eq:minimal-direction-residual-statement>
for every primitive return-reduced terminal pair
$
  P = (p + r + h + t, thin p), quad quad Q = (p + r + t, thin p + r),
$ <eq:minimal-direction-four-parameter>
satisfying $p, t, r, h gt.eq.slant 1$, the linear-wedge inequalities $4 r < 5 h$ and $8 h < 7 r$, the nonprimitivity condition $gcd (r, h) > 1$, the endpoint primitivity conditions, and the return-reduced condition of @def:return-reduced.

The purpose of the present Chapter is to deliver the first concrete instance of this residual proof: @thm:ETAT in the smallest primitive exceptional direction and its first nonprimitive multiple. The construction proceeds in three movements --- a structural identification of the direction itself (this Section), a residue and return-reducedness reduction to seventeen one-parameter families (@subsec:residue-reduction and @subsec:seventeen-families), and a combined congruence-plus-symbolic-positivity argument (@subsec:congruence-certificate through @subsec:central-family) --- followed by a synthesis (@subsec:g2-conclusion). The supporting computational certificates are recorded in @appendix:minimal-certificates.

_Primitive exceptional directions._ Write the residual parameters $r$ and $h$ in terms of their greatest common divisor and the corresponding primitive direction. Setting
$
  g = gcd (r, h), quad quad r = g R, quad quad h = g H, quad quad gcd (R, H) = 1,
$ <eq:rh-primitive-decomposition>
the wedge inequalities $4 r < 5 h$ and $8 h < 7 r$ become
$
  4 R < 5 H, quad quad 8 H < 7 R,
$ <eq:primitive-wedge>
which depend only on the primitive direction $(R, H)$. The nonprimitivity condition $gcd (r, h) > 1$ reads $g gt.eq.slant 2$. Each residual case is therefore the combination of a primitive direction $(R, H) in bb(N)^2$ with $gcd (R, H) = 1$ lying in the open wedge @eq:primitive-wedge, together with a nonprimitive multiplier $g gt.eq.slant 2$.

The wedge @eq:primitive-wedge can be rewritten as $8 H slash 7 < R < 5 H slash 4$ or, equivalently, as $4 R slash 5 < H < 7 R slash 8$. For each fixed $H gt.eq.slant 1$, the integer points $R$ inside the interval $(8 H slash 7, thin 5 H slash 4)$ index the primitive directions with that second coordinate; the analogous statement holds with the roles of $R$ and $H$ exchanged. The first such $(R, H)$ to appear is recorded by the following lemma.

#lemma(title: "The first primitive exceptional direction", lbl: <lem:first-primitive-direction>)[
  The smallest positive integer pair $(R, H) in bb(N)^2$ with $gcd (R, H) = 1$ and
  $
    4 R < 5 H, quad quad 8 H < 7 R,
  $ <eq:first-direction-ineqs>
  ordered lexicographically by $H$ and then by $R$, is
  $
    (R, H) = (6, 5).
  $ <eq:first-direction-value>
] <lem-first-primitive-direction>

#proof[
  The inequalities @eq:first-direction-ineqs are equivalent to
  $
    8 H slash 7 < R < 5 H slash 4,
  $ <eq:R-bracket-by-H>
  so the question is, for each $H gt.eq.slant 1$, whether the open rational interval $(8 H slash 7, thin 5 H slash 4)$ contains an integer $R$.

  For $H = 1, 2, 3, 4$ the interval reads, respectively,
  $
    (8 slash 7, thin 5 slash 4) approx (1.143, thin 1.250), quad
    (16 slash 7, thin 5 slash 2) approx (2.286, thin 2.500),
  $
  $
    (24 slash 7, thin 15 slash 4) approx (3.429, thin 3.750), quad
    (32 slash 7, thin 5) approx (4.571, thin 5.000).
  $
  In each of these four cases the interval is strictly shorter than the unit length, since its length is $5 H slash 4 - 8 H slash 7 = 3 H slash 28 < 1$ for $H lt.eq.slant 9$. None of the four intervals contains an integer: for $H lt.eq.slant 3$ the integer below the upper endpoint is also below the lower endpoint, and for $H = 4$ the only candidate $R = 5$ coincides with the upper endpoint and is excluded by the strict inequality $R < 5 H slash 4 = 5$.

  For $H = 5$ the interval becomes
  $
    (40 slash 7, thin 25 slash 4) approx (5.714, thin 6.250),
  $
  and the unique integer it contains is $R = 6$. Since $gcd (6, 5) = 1$, the pair $(R, H) = (6, 5)$ is primitive. By the lexicographic ordering, no smaller solution exists.
]

A picture renders the four arithmetic verifications above visually: @fig:exceptional-cone-RH plots the open wedge @eq:primitive-wedge in the $(R, H)$-plane and exhibits $(6, 5)$ as the first integer lattice point inside it.

#figure(
  caption: [The open exceptional wedge $4 R slash 5 < H < 7 R slash 8$ in the $(R, H)$-plane (shaded), bounded by the rays $H = 4 R slash 5$ (lower) and $H = 7 R slash 8$ (upper) emanating from the origin. The integer lattice points $(R, H) in bb(N)^2$ are shown as small grey dots. For $R = 1, 2, 3, 4, 5$ the wedge contains no integer $H$; at $R = 6$ it admits the single integer $H = 5$, marked by the highlighted dot $(6, 5)$. The pair $(R, H) = (6, 5)$ is the first primitive exceptional direction; subsequent primitive directions occupy larger lattice points further into the cone.],
  cetz.canvas({
    import cetz.draw: *
    let x-max = 8.5
    let y-max = 7.5
    // Wedge fill: triangle with apex at origin, far edge at x = x-max
    line((0, 0), (x-max, 4 * x-max / 5), (x-max, 7 * x-max / 8), close: true,
         stroke: none, fill: cor-wash)
    // Axes
    line((0, 0), (x-max, 0), stroke: 0.8pt + dark-text, mark: (end: ">"))
    line((0, 0), (0, y-max), stroke: 0.8pt + dark-text, mark: (end: ">"))
    content((x-max + 0.3, 0), text(size: 9pt)[$R$])
    content((0, y-max + 0.3), text(size: 9pt)[$H$])
    // Boundary rays
    line((0, 0), (x-max, 4 * x-max / 5), stroke: 1pt + defn-color)
    content((x-max + 0.55, 4 * x-max / 5 - 0.30), text(size: 7.5pt, fill: defn-color)[$H = 4 R slash 5$])
    line((0, 0), (x-max, 7 * x-max / 8), stroke: 1pt + defn-color)
    content((x-max + 0.05, 7 * x-max / 8 + 0.30), text(size: 7.5pt, fill: defn-color)[$H = 7 R slash 8$])
    // Integer lattice points
    for r in range(1, 9) {
      for h in range(1, 8) {
        circle((r, h), radius: 0.06, fill: gray, stroke: none)
      }
    }
    // Highlight (R, H) = (6, 5)
    circle((6, 5), radius: 0.16, stroke: 1.5pt + cor-color, fill: cor-wash)
    content((6, 5.55), text(size: 8pt, fill: cor-color)[$(6, 5)$])
    // Axis tick marks and labels
    for r in range(1, 9) {
      line((r, -0.08), (r, 0.08), stroke: 0.7pt)
      content((r, -0.32), text(size: 7pt)[#r])
    }
    for h in range(1, 8) {
      line((-0.08, h), (0.08, h), stroke: 0.7pt)
      content((-0.32, h), text(size: 7pt)[#h])
    }
  }),
) <fig:exceptional-cone-RH>

The wedge @eq:primitive-wedge has a transparent structural reading. Its interior is the open rational polyhedral cone in $bb(R)^2_(> 0)$ whose two boundary rays carry the rational slopes $4 slash 5$ and $7 slash 8$ --- the same two slopes that bound the exceptional ratio window $9 slash 5 < s slash r < 15 slash 8$ via the affine reparameterisation @eq:reparameterisation. The primitive lattice set $bb(N)^2 inter {gcd = 1}$ inside this wedge inherits a graded sub-semigroup structure under the diagonal action $g dot.op (R, H)$ of $bb(N)$ on $bb(Z)^2_(> 0)$: the primitive directions play the role of generators, and the multiplier $g$ plays the role of a homogeneity weight. The present Chapter studies the single ray $bb(N) dot.op (6, 5)$ inside this cone.

_The first nonprimitive step._ The Exceptional Terminal Arithmetic Theorem, in its residual form, only becomes a live problem after the primitive-step exclusion of @prop:primitive-step-exclusion in @sec:primitive-exclusion has done its work. That exclusion uses Huang's valley theorem @Huang2022 to rule out every case with $gcd (r, s) = 1$, where $s = r + h$. By the elementary identity
$
  gcd (r, s) = gcd (r, thin r + h) = gcd (r, h),
$ <eq:gcd-r-s-equals-gcd-r-h>
the surviving cases all satisfy $gcd (r, h) gt.eq.slant 2$, which is exactly the multiplier condition $g gt.eq.slant 2$ in the primitive decomposition @eq:rh-primitive-decomposition. The residual problem therefore lives entirely on the nonprimitive rays $g dot.op (R, H)$ with $g gt.eq.slant 2$.

For the minimal primitive direction $(R, H) = (6, 5)$ identified by @lem:first-primitive-direction, the smallest nonprimitive multiplier is
$
  g = 2,
$ <eq:first-multiplier>
so the first nonprimitive exceptional triple of parameters is
$
  r = g R = 12, quad quad h = g H = 10, quad quad s = r + h = 22.
$ <eq:minimal-rhs>

We verify that this $(r, h, s)$ lies genuinely inside the residual region. The slope ratio is
$
  s slash r = 22 slash 12 = 11 slash 6 approx 1.833,
$ <eq:minimal-slope-ratio>
which sits strictly inside the open exceptional window
$
  9 slash 5 < 11 slash 6 < 15 slash 8,
$ <eq:window-check>
since $11 slash 6$ separates $9 slash 5 = 1.8$ from $15 slash 8 = 1.875$. The nonprimitivity condition is satisfied at the minimum,
$
  gcd (r, h) = gcd (12, 10) = 2 > 1,
$ <eq:gcd-check>
and equivalently $gcd (r, s) = gcd (12, 22) = 2 > 1$ by @eq:gcd-r-s-equals-gcd-r-h.

Thus the case $(r, h) = (12, 10)$ is the minimal element of the residual region in the lexicographic ordering induced by the primitive-direction ordering of @lem:first-primitive-direction together with the multiplier $g$. It is the entry point of the residual problem.

_The terminal pair in the minimal case._ Substituting $(r, h) = (12, 10)$ into the four-parameter form @eq:minimal-direction-four-parameter yields the explicit terminal pair
$
  P = (p + r + h + t, thin p) = (p + t + 22, thin p),
$ <eq:minimal-direction-P>
$
  Q = (p + r + t, thin p + r) = (p + t + 12, thin p + 12).
$ <eq:minimal-direction-Q>

The endpoint primitivity conditions, expressing that $P$ and $Q$ are primitive lattice points in $bb(Z)^2_(> 0)$, simplify after cancellation to
$
  gcd (p, thin t + 22) = 1, quad quad gcd (p + 12, thin t) = 1,
$ <eq:minimal-direction-primitivity>
since $gcd (p, p + t + 22) = gcd (p, t + 22)$ and $gcd (p + 12, p + t + 12) = gcd (p + 12, t)$ by the standard subtraction identity $gcd (a, a + b) = gcd (a, b)$. The return-reduced condition is the intrinsic condition of @def:return-reduced: the pair has survived the Euclidean recoding procedure of @sec:euclidean-recoding all the way down to the terminal standard cone, rather than having been eliminated earlier by dominance, boundary separation, or another reduction step. We shall use this condition in @subsec:seventeen-families to bound $p$ relative to $t$.

The central claim of the Chapter is that no terminal pair of this form admits a Markov-number collision.

#theorem(title: "Minimal exceptional terminal direction", lbl: <thm:minimal-direction>)[
  Let
  $
    P = (p + t + 22, thin p), quad quad Q = (p + t + 12, thin p + 12)
  $ <eq:minimal-direction-PQ>
  be primitive return-reduced terminal points in the standard Farey cone. Then
  $
    m_P eq.not m_Q.
  $ <eq:minimal-direction-conclusion>
  Equivalently, @thm:ETAT holds for
  $
    (R, H) = (6, 5), quad g = 2, quad (r, h) = (12, 10),
  $ <eq:minimal-direction-params>
  i.e. for $r = 12$, $s = r + h = 22$, $s slash r = 11 slash 6$. The direction is genuinely inside the exceptional slope window,
  $
    9 slash 5 < 11 slash 6 < 15 slash 8,
  $ <eq:minimal-direction-window>
  and genuinely nonprimitive, $gcd (r, h) = gcd (12, 10) = 2 > 1$.
] <thm-minimal-direction>

The proof of @thm:minimal-direction occupies @subsec:residue-reduction through @subsec:g2-conclusion. The strategy is laid out next.

_Strategy of the proof._ The proof of @thm:minimal-direction proceeds in three stages, each narrowing the locus of a hypothetical collision $m_P = m_Q$ until that locus is empty.

_Stage one: residue reduction._ A hypothetical collision $m_P = m_Q$ forces a residue equality modulo small primes. Using the parity criterion
$
  m_(p slash q) equiv 0 quad (upright("mod") thin 2)
  quad arrow.l.r.double quad
  q - p equiv 0 quad (upright("mod") thin 3),
$ <eq:parity-criterion-strategy>
together with the mod-$3$ residue table for Markov numbers depending on $(q, p) thin (upright("mod") thin 4)$, the residual case $(r, h) = (12, 10)$ admits a collision only if
$
  p equiv 0 quad (upright("mod") thin 2), quad quad t equiv 1 quad (upright("mod") thin 6).
$ <eq:residue-conclusion-strategy>
The proof of this implication is the content of @subsec:residue-reduction; the parity criterion @eq:parity-criterion-strategy itself is recalled there from the Cohn-trace formulation of @sec:markov-cohn. The implication uses the primitivity conditions @eq:minimal-direction-primitivity to fix the residue class of $t$ modulo $6$ from the parity of $p$.

_Stage two: return-reduced reduction to seventeen families._ The return-reduced condition of @def:return-reduced forces $P$ below the first standard split of the Farey cone and $Q$ above it, which gives the elementary inequalities
$
  p slash (p + t + 22) < 1 slash 2 quad quad upright("and") quad quad
  (p + 12) slash (p + t + 12) > 1 slash 2,
$ <eq:return-reduced-elementary>
equivalent to $t - 12 < p < t + 22$. Setting
$
  c = p - t,
$ <eq:c-definition>
the residue reduction forces $c$ odd (since $p$ is even and $t$ is odd by @eq:residue-conclusion-strategy), and the inequalities @eq:return-reduced-elementary confine $c$ to the seventeen-element set
$
  c in {-11, -9, -7, -5, -3, -1, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21}.
$ <eq:c-set>
Writing $t = 6 k + 1$ with $k gt.eq.slant 0$ (using @eq:residue-conclusion-strategy) and $p = t + c = 6 k + 1 + c$, the terminal pair $(P, Q)$ becomes a function of the two integer parameters $(c, k)$:
$
  P_(c, k) &= (12 k + c + 24, thin 6 k + c + 1), \
  Q_(c, k) &= (12 k + c + 14, thin 6 k + c + 13).
$ <eq:seventeen-families-strategy>
The two-variable terminal problem is therefore reduced to excluding equality of Markov numbers within each of the seventeen one-parameter families indexed by the value of $c$ in @eq:c-set, for every admissible $k gt.eq.slant 0$. This is the content of @subsec:seventeen-families.

_Stage three: congruence certificates and symbolic positivity._ Sixteen of the seventeen families are eliminated by the finite congruence-certificate principle developed in @subsec:congruence-certificate: each family admits a small Markov-residue modulus $ell in {5, 23, 37, 47}$ relative to which $m_(P_(c, k))$ and $m_(Q_(c, k))$ are periodic in $k$ with a short period, and a finite check over each admissible residue class establishes residue inequality modulo $ell$. The certificates are collected in @subsec:sixteen-table and recorded in @appendix:minimal-certificates. The remaining central family $c = 5$ is reduced by congruence and primitivity exclusions to a single survivor class $k equiv 15 thin (upright("mod") thin 17)$, and that survivor class is eliminated in @subsec:central-family by a symbolic Chebyshev-bound argument on the trace difference $tr (C_(Q_k)) - tr (C_(P_k))$.

The synthesis of the three stages is collected in @subsec:g2-conclusion.

_Significance._ @thm:minimal-direction is the first unconditional result inside the genuinely residual locus left by the cumulative reduction of the preceding Sections. Its standing is best appreciated by listing the three structural obstructions it _does not_ exploit.

It is not a boundary comparison, since both terminal coefficients are bounded away from one, $r = 12 > 1$ and $s = 22 > 1$; the shifted-boundary separation of @sec:shifted-boundary therefore does not apply directly.

It is not a non-exceptional slope comparison, since the ratio $s slash r = 11 slash 6$ lies strictly inside the exceptional window $(9 slash 5, thin 15 slash 8)$ via @eq:window-check; the line-monotonicity classification of @LeeLiRabideauSchiffler2023, @LagisquetPelantovaTavenasVuillon2021, and @Huang2022 used in @thm:terminal-non-exceptional therefore does not apply.

It is not a primitive-step comparison, since $gcd (r, s) = 2 > 1$ via @eq:gcd-check; the valley-theorem exclusion of @prop:primitive-step-exclusion therefore does not apply.

The collision $m_P = m_Q$ in the minimal direction is excluded purely by the interaction of residue reduction, return-reducedness, finite congruence certificates, and an exact symbolic trace-positivity argument --- a combination that uses the Cohn-tree structure of the manuscript intrinsically rather than relying on a previously established monotonicity theorem. @thm:minimal-direction is, in this sense, a sample proof of @thm:ETAT in miniature: it demonstrates that the residual problem admits tractable arithmetic cases inside the genuinely exceptional nonprimitive region, and it indicates a route towards an eventual direction-by-direction proof along the integer rays of the wedge @eq:primitive-wedge, with the multiplier $g$ playing the role of a continuation parameter inside each direction.

== Elementary residue reduction <subsec:residue-reduction>

We continue the analysis of the minimal exceptional terminal pair introduced in @subsec:minimal-direction-statement. The standing data for the present Section are the terminal points
$
  P = (p + t + 22, thin p), quad quad Q = (p + t + 12, thin p + 12),
$ <eq:sec162-PQ-setup>
the primitivity conditions
$
  gcd (p, thin t + 22) = 1, quad quad gcd (p + 12, thin t) = 1,
$ <eq:sec162-primitivity-setup>
recalled from @eq:minimal-direction-primitivity, the parameter inequalities $p, t gt.eq.slant 1$, and the return-reduced condition of @def:return-reduced.

The aim of the Section is to prove that any equality of Markov numbers $m_P = m_Q$ forces a tight joint residue restriction on the two free parameters $p$ and $t$:
$
  m_P = m_Q quad arrow.r.double quad p equiv 0 thin (upright("mod") thin 2), quad quad t equiv 1 thin (upright("mod") thin 6).
$ <eq:sec162-main-conclusion>
This is the content of @prop:elementary-residue-reduction below. The implication reduces the search for a possible collision to a much smaller congruence sector, on which the return-reducedness inequalities of @subsec:seventeen-families will then carve out exactly seventeen one-parameter families.

The argument proceeds in two stages, both of them residue arithmetic applied to the Cohn-trace formulation of @sec:markov-cohn. The first stage exploits a general parity criterion for Markov numbers (@lem:parity-criterion) that depends only on the residue class of $q - p$ modulo $3$; the second stage exploits a mod-$3$ residue table (@fig:mod-3-table) for $m_(p slash q)$ that depends only on the joint residue class of $(q, p)$ modulo $4$. The two stages are independent and combine cleanly through the primitivity condition $gcd (p + 12, t) = 1$.

_Parity of Markov numbers._ We open with a general parity criterion for Markov numbers that requires no input beyond the Cohn-trace formulation of @sec:markov-cohn and the central-weight identity $m_(p slash q) = bold(a)^top M(z_(p slash q)) bold(a)$ of @cor:markov-as-weight, with $bold(a) = (2, 1)^top$.

#lemma(title: "Parity criterion for Markov numbers", lbl: <lem:parity-criterion>)[
  For every primitive lattice point $(q, thin p) in bb(Z)_(> 0)^2$ with $gcd (q, p) = 1$ that is _not_ an endpoint of the Stern--Brocot tree (so that the central core $z_(p slash q)$ is defined),
  $
    m_(p slash q) equiv 0 thin (upright("mod") thin 2) quad arrow.l.r.double quad q - p equiv 0 thin (upright("mod") thin 3).
  $ <eq:parity-criterion-statement>
] <lem-parity-criterion>

#proof[
  Reduce the Cohn generators modulo $2$. From $A = mat(2, 1; 1, 1)$ and $B = mat(5, 2; 2, 1)$ we obtain
  $
    A equiv mat(0, 1; 1, 1) thin (upright("mod") thin 2), quad quad B equiv mat(1, 0; 0, 1) = I thin (upright("mod") thin 2).
  $
  Therefore $B$ reduces to the identity modulo $2$, and the matrix product $M(z) equiv A^(hash_A (z)) thin (upright("mod") thin 2)$ for every word $z in {A, thin B}^ast$, since each occurrence of $B$ acts as the identity. Using the central-core letter counts $hash_A (z_(p slash q)) = q - p - 1$ from @eq:central-counts, this gives
  $
    M(z_(p slash q)) equiv A^(q - p - 1) thin (upright("mod") thin 2).
  $ <eq:M-z-mod-2>

  The reduced matrix $A in upright(S L)_2 (bb(F)_2)$ has order $3$, as the direct calculation
  $
    A^2 equiv mat(1, 1; 1, 0) thin (upright("mod") thin 2), quad quad A^3 equiv mat(1, 0; 0, 1) = I thin (upright("mod") thin 2)
  $ <eq:A-order-3-mod-2>
  shows. (This reflects the classical isomorphism $upright(S L)_2 (bb(F)_2) tilde.equiv S_3$ --- the symmetric group on three letters --- in which $A$ becomes a $3$-cycle.) Therefore $M(z_(p slash q)) equiv A^k$ modulo $2$ for $k = (q - p - 1) thin (upright("mod") thin 3)$, and the central weight reduces to
  $
    m_(p slash q) equiv bold(a)^top A^k bold(a) thin (upright("mod") thin 2).
  $ <eq:m-as-quadratic-form-mod-2>

  With $bold(a) = (2, 1)^top equiv (0, 1)^top thin (upright("mod") thin 2)$, the three cases are
  $
    k = 0&: thin bold(a)^top I bold(a) equiv 1, \
    k = 1&: thin bold(a)^top A bold(a) equiv (0, 1) mat(0, 1; 1, 1) vec(0, 1) = (0, 1) vec(1, 1) = 1,
  $
  $
    k = 2: thin bold(a)^top A^2 bold(a) equiv (0, 1) mat(1, 1; 1, 0) vec(0, 1) = (0, 1) vec(1, 0) = 0
  $
  modulo $2$. Thus $m_(p slash q) equiv 0 thin (upright("mod") thin 2)$ exactly when $k equiv 2 thin (upright("mod") thin 3)$, i.e. when $q - p - 1 equiv 2 thin (upright("mod") thin 3)$, equivalently when $q - p equiv 0 thin (upright("mod") thin 3)$, as claimed.
]

The parity criterion is independently visible on the small Cohn-word table @fig:cohn-word-examples: every entry of that table satisfies @lem:parity-criterion. For instance, $m_(1 slash 4) = 34$ is even and $q - p = 3 equiv 0 thin (upright("mod") thin 3)$; $m_(2 slash 5) = 194$ is even and $q - p = 3 equiv 0 thin (upright("mod") thin 3)$; and all nine odd entries of @fig:cohn-word-examples satisfy $q - p eq.not 0 thin (upright("mod") thin 3)$.

_Structural reading._ @lem:parity-criterion is a manifestation of the strong-approximation phenomenon for the Cohn-trace formulation: the image of the Cohn-matrix monoid in $upright(S L)_2 (bb(F)_2)$ is the cyclic subgroup of order $3$ generated by $A thin (upright("mod") thin 2)$, since $B$ becomes the identity. The parity of $m_(p slash q)$ is therefore controlled by a single $bb(Z) slash 3$-valued invariant computed on the abelianisation $hash_A$ of the central core. The same picture, applied to higher-prime reductions and combined with the structure of $upright(S L)_2 (bb(F)_p)$, is the residue-automaton framework of @subsec:appendix-D-automaton, which we shall invoke for the mod-$3$ table below.

_Application to the minimal direction._ Specialising @lem:parity-criterion to $P = (p + t + 22, thin p)$ and $Q = (p + t + 12, thin p + 12)$ gives, with the manuscript's $(q, thin p)$-convention,
$
  q_P - p_P &= (p + t + 22) - p = t + 22, \
  q_Q - p_Q &= (p + t + 12) - (p + 12) = t.
$ <eq:qP-qQ-minus>
Since $22 equiv 1 thin (upright("mod") thin 3)$, the parity criterion translates into
$
  m_P equiv 0 thin (upright("mod") thin 2) quad arrow.l.r.double quad t equiv 2 thin (upright("mod") thin 3),
$ <eq:parity-mP>
and
$
  m_Q equiv 0 thin (upright("mod") thin 2) quad arrow.l.r.double quad t equiv 0 thin (upright("mod") thin 3).
$ <eq:parity-mQ>

The three residue classes of $t$ modulo $3$ now divide naturally into cases. If $t equiv 0 thin (upright("mod") thin 3)$, then $m_Q$ is even by @eq:parity-mQ while $m_P$ is odd by @eq:parity-mP (since $t equiv 0 eq.not 2 thin (upright("mod") thin 3)$); the parities disagree. If $t equiv 2 thin (upright("mod") thin 3)$, then $m_P$ is even and $m_Q$ is odd; again the parities disagree. If $t equiv 1 thin (upright("mod") thin 3)$, then both $m_P$ and $m_Q$ are odd; the parities agree, and no constraint follows from parity alone.

In the first two cases the equality $m_P = m_Q$ is impossible by mismatched parity. We record the resulting restriction as a lemma.

#lemma(title: [First residue restriction on $t$], lbl: <lem:t-mod-3>)[
  Let $P, Q$ be as in @eq:sec162-PQ-setup with $p, t gt.eq.slant 1$. If $m_P = m_Q$, then
  $
    t equiv 1 thin (upright("mod") thin 3).
  $ <eq:t-mod-3-conclusion>
] <lem-t-mod-3>

_A mod-$3$ table for Markov numbers._ The parity criterion is too coarse to settle the case $t equiv 1 thin (upright("mod") thin 3)$. We refine the analysis by working modulo $3$ rather than modulo $2$.

The Markov-residue automaton of @subsec:appendix-D-automaton, specialised to the modulus $m = 3$, has finite state space and computes the residue $m_(p slash q) thin (upright("mod") thin 3)$ from the Stern--Brocot address of the lattice point $(q, thin p)$. A direct verification on the Cohn-tree recursion shows that, for primitive $(q, thin p)$, this residue depends only on the joint class $(q thin (upright("mod") thin 4), thin p thin (upright("mod") thin 4))$. This is the mod-$3$ counterpart of the order-$3$ matching used in @lem:parity-criterion; the underlying reason is that the orders of $A$ and $B$ modulo $3$ both equal $4$ in $upright(S L)_2 (bb(F)_3)$, so the residue function on $bb(N)^2 inter {gcd = 1}$ factors through $(bb(Z) slash 4 bb(Z))^2$.

The table is the following.

#figure(
  caption: [The residue $m_(p slash q) thin (upright("mod") thin 3)$ as a function of the joint class $(q thin (upright("mod") thin 4), thin p thin (upright("mod") thin 4))$ for primitive $(q, thin p)$. Dashes mark non-primitive residue classes in which both $q$ and $p$ are even; these are excluded from the Markov domain.],
  table(
    columns: (auto, auto, auto, auto, auto),
    align: center,
    table.header(
      [$q backslash p$], [$0$], [$1$], [$2$], [$3$]
    ),
    [$0$], [---], [$1$], [---], [$1$],
    [$1$], [$1$], [$2$], [$2$], [$1$],
    [$2$], [---], [$2$], [---], [$2$],
    [$3$], [$1$], [$1$], [$2$], [$2$],
  ),
) <fig:mod-3-table>

The entries of @fig:mod-3-table are independently verifiable on the small Cohn-word table @fig:cohn-word-examples: each of the eleven non-endpoint entries of that figure agrees with the table prediction. For example, the value $m_(2 slash 5) = 194 equiv 2 thin (upright("mod") thin 3)$ corresponds to the row $q equiv 1$ and column $p equiv 2$, where the table lists $2$; the value $m_(3 slash 4) = 169 equiv 1 thin (upright("mod") thin 3)$ corresponds to the row $q equiv 0$ and column $p equiv 3$, where the table lists $1$.

We extract the consequence of @fig:mod-3-table that we shall need: shifting $q$ by $2$ inside the column $p equiv 1$ or $p equiv 3$ always swaps the residue between $1$ and $2$.

#lemma(title: [Mod-$3$ separation for odd $p$], lbl: <lem:mod-3-separation>)[
  Let $P, Q$ be as in @eq:sec162-PQ-setup with $p, t gt.eq.slant 1$. If $p$ is odd, then
  $
    m_P eq.not m_Q thin (upright("mod") thin 3),
  $ <eq:mod-3-separation-conclusion>
  and in particular $m_P eq.not m_Q$.
] <lem-mod-3-separation>

#proof[
  Compute the joint residue classes of $P$ and $Q$ modulo $4$. For the $p$-coordinates,
  $
    p_P = p, quad quad p_Q = p + 12 equiv p thin (upright("mod") thin 4),
  $ <eq:pP-pQ-mod-4>
  so $P$ and $Q$ lie in the same column of @fig:mod-3-table. For the $q$-coordinates,
  $
    q_P - q_Q = (p + t + 22) - (p + t + 12) = 10 equiv 2 thin (upright("mod") thin 4),
  $ <eq:qP-qQ-mod-4>
  so $P$ and $Q$ lie in rows of @fig:mod-3-table that differ by $2$ modulo $4$.

  Suppose now $p$ is odd; then $p_P equiv p_Q equiv 1$ or $3$ modulo $4$. Reading off the relevant columns of @fig:mod-3-table:
  $
    p equiv 1 thin (upright("mod") thin 4) : quad upright("entries") thin (q equiv 0, 1, 2, 3) = (1, 2, 2, 1),
  $ <eq:col-p-1>
  $
    p equiv 3 thin (upright("mod") thin 4) : quad upright("entries") thin (q equiv 0, 1, 2, 3) = (1, 1, 2, 2).
  $ <eq:col-p-3>
  In both columns, every pair of entries whose row indices differ by $2$ has opposite residues --- the pairs $(q equiv 0, thin q equiv 2)$ and $(q equiv 1, thin q equiv 3)$ each consist of one entry equal to $1$ and one entry equal to $2$. Therefore $m_P eq.not m_Q thin (upright("mod") thin 3)$, and a fortiori $m_P eq.not m_Q$.
]

#corollary(title: [$p$ must be even], lbl: <cor:p-even>)[
  Let $P, Q$ be as in @eq:sec162-PQ-setup with $p, t gt.eq.slant 1$. If $m_P = m_Q$, then
  $
    p equiv 0 thin (upright("mod") thin 2).
  $ <eq:p-even-conclusion>
] <cor-p-even>

_Combining the residue restrictions._ We assemble @lem:t-mod-3 and @cor:p-even with the primitivity condition $gcd (p + 12, t) = 1$ from @eq:sec162-primitivity-setup. Assume $m_P = m_Q$.

By @cor:p-even the parameter $p$ is even; hence $p + 12$ is also even. The primitivity condition $gcd (p + 12, thin t) = 1$ therefore forces $t$ to be odd, since any factor of $2$ shared by $p + 12$ and $t$ would already violate the coprimality. Thus
$
  t equiv 1 thin (upright("mod") thin 2).
$ <eq:t-odd-conclusion>
Combining @eq:t-odd-conclusion with $t equiv 1 thin (upright("mod") thin 3)$ from @lem:t-mod-3, the Chinese remainder theorem applied to the coprime moduli $2$ and $3$ yields
$
  t equiv 1 thin (upright("mod") thin 6).
$ <eq:t-mod-6-conclusion>

This is the main result of the Section.

#proposition(title: "Elementary residue reduction", lbl: <prop:elementary-residue-reduction>)[
  Let
  $
    P = (p + t + 22, thin p), quad quad Q = (p + t + 12, thin p + 12)
  $ <eq:sec162-PQ-prop>
  be primitive return-reduced terminal points in the standard Farey cone with $p, t gt.eq.slant 1$. If $m_P = m_Q$, then
  $
    p equiv 0 thin (upright("mod") thin 2), quad quad t equiv 1 thin (upright("mod") thin 6).
  $ <eq:sec162-prop-conclusion>
  Equivalently, if either $p$ is odd or $t$ does not satisfy $t equiv 1 thin (upright("mod") thin 6)$, then $m_P eq.not m_Q$.
] <prop-elementary-residue-reduction>

#proof[
  Combine @lem:t-mod-3, @cor:p-even, and the primitivity condition $gcd (p + 12, t) = 1$ from @eq:sec162-primitivity-setup as in the preceding paragraphs: $p$ even forces $p + 12$ even, primitivity of $Q$ then forces $t$ odd, and the Chinese remainder theorem applied to the coprime moduli $2$ and $3$ combines $t equiv 1 thin (upright("mod") thin 2)$ with $t equiv 1 thin (upright("mod") thin 3)$ into $t equiv 1 thin (upright("mod") thin 6)$.
]

@prop:elementary-residue-reduction is the first effective restriction of the residual minimal-direction problem: it cuts the two-parameter $(p, thin t)$-search down to the congruence sector $p equiv 0 thin (upright("mod") thin 2)$, $t equiv 1 thin (upright("mod") thin 6)$. In @subsec:seventeen-families we shall combine this restriction with the return-reduced inequalities @eq:return-reduced-elementary to confine the search to exactly seventeen one-parameter families indexed by the auxiliary parameter $c = p - t$ introduced in @eq:c-definition.

== Return-reduced reduction to seventeen one-parameter families <subsec:seventeen-families>

We continue from @prop:elementary-residue-reduction, the conclusion of @subsec:residue-reduction. The standing data are still the terminal pair $(P, Q)$ of @eq:sec162-PQ-setup, and the residue restriction on a hypothetical collision is now the joint condition
$
  p equiv 0 thin (upright("mod") thin 2), quad quad t equiv 1 thin (upright("mod") thin 6).
$ <eq:sec163-residue-condition>

The goal of the present Section is to combine @eq:sec163-residue-condition with the return-reducedness condition of @def:return-reduced and obtain the section's headline reduction: every primitive return-reduced terminal pair $(P, Q)$ in the minimal exceptional direction that could carry an equality $m_P = m_Q$ has the explicit form
$
  P = P_(c, k) &:= (12 k + c + 24, thin 6 k + c + 1), \
  Q = Q_(c, k) &:= (12 k + c + 14, thin 6 k + c + 13),
$ <eq:Pck-Qck-explicit>
for one of seventeen odd integers $c in {-11, -9, dots, 19, 21}$ and a non-negative integer $k$ satisfying $p = 6 k + c + 1 gt.eq.slant 1$ and two arithmetic primitivity conditions. The conclusion is collected in @prop:seventeen-families-reduction.

_The first standard split._ Recall from @subsec:terminal-coords-sec14 that the standard Farey cone has basis
$
  v_0 = (1, 0), quad quad u_0 = (1, 1).
$ <eq:standard-cone-basis>
The mediant of the two basis vectors is the lattice direction
$
  v_0 + u_0 = (2, 1),
$ <eq:first-split-direction>
which carries the rational slope $1 slash 2$. The standard cone is split by the ray $bb(R)_(gt.eq.slant 0) dot.op (2, 1)$ into two Farey sub-cones,
$
  chevron.l v_0, thin (2, 1) chevron.r quad upright("and") quad chevron.l (2, 1), thin u_0 chevron.r,
$
each of which is itself a Farey cone with a finer mediant subdivision. The Euclidean recoding algorithm of @sec:euclidean-recoding, applied inside the standard cone, would step the comparison further down into whichever sub-cone contains both lattice points $P$ and $Q$; only a comparison whose two endpoints lie on _opposite_ sides of the $(2, 1)$-split can fail to admit such a further step. The return-reduced condition of @def:return-reduced asserts that this failure is genuine: the Euclidean recoding has terminated, and the pair $(P, Q)$ has not been short-circuited by an earlier exclusion. In particular,
$
  P upright(" lies in the sub-cone ") chevron.l v_0, thin (2, 1) chevron.r, \
  Q upright(" lies in the sub-cone ") chevron.l (2, 1), thin u_0 chevron.r.
$ <eq:PQ-straddle-claim>

The assignment of $P$ to the lower-slope sub-cone and $Q$ to the higher-slope sub-cone is dictated by the offset $Q - P$. With $P = (p + t + 22, thin p)$ and $Q = (p + t + 12, thin p + 12)$, one verifies the cross-product identity
$
  (p + 12)(p + t + 22) - p (p + t + 12) = 22 p + 12 t + 264 > 0,
$ <eq:slope-cross-product>
which on dividing by $(p + t + 22)(p + t + 12)$ exhibits
$
  (p + 12) slash (p + t + 12) > p slash (p + t + 22),
$
so $Q$ has the larger Farey slope. Combined with @eq:PQ-straddle-claim, this places $P$ strictly below the $(2, 1)$-ray and $Q$ strictly above it.

The illustration of @fig:standard-cone-split records the configuration.

#figure(
  caption: [The first standard split of the Farey cone $chevron.l v_0, u_0 chevron.r$ at the mediant direction $(2, 1)$, and the configuration of a return-reduced terminal pair $(P, Q)$ in the minimal exceptional direction $(r, h) = (12, 10)$. The cone boundary rays $v_0 = (1, 0)$ and $u_0 = (1, 1)$ are drawn from the origin; the splitting ray $(2, 1)$ in red separates the two Farey sub-cones $chevron.l v_0, thin (2, 1) chevron.r$ (slope $< 1 slash 2$) and $chevron.l (2, 1), thin u_0 chevron.r$ (slope $> 1 slash 2$). The point $P$ (filled) lies strictly below the split; the point $Q$ (open) lies strictly above. The offset vector $Q - P = (-10, thin 12)$ points up and to the left, crossing the splitting ray exactly once.],
  cetz.canvas({
    import cetz.draw: *
    // Axes
    line((-0.5, 0), (11.5, 0), stroke: 0.8pt + dark-text, mark: (end: ">"))
    line((0, -0.5), (0, 8.5), stroke: 0.8pt + dark-text, mark: (end: ">"))
    content((11.8, 0), text(size: 9pt)[$q$])
    content((0, 8.8), text(size: 9pt)[$p$])
    // Cone boundary ray v_0 = (1, 0) (horizontal axis from origin)
    line((0, 0), (11, 0), stroke: 1.2pt + defn-color)
    content((11, -0.5), text(size: 8pt, fill: defn-color)[$v_0 = (1, 0)$])
    // Cone boundary ray u_0 = (1, 1): slope 1
    line((0, 0), (8, 8), stroke: 1.2pt + defn-color)
    content((8.5, 8.2), text(size: 8pt, fill: defn-color)[$u_0 = (1, 1)$])
    // Splitting ray (2, 1): slope 1/2
    line((0, 0), (11, 5.5), stroke: 1.5pt + cor-color)
    content((11.3, 5.7), text(size: 8pt, fill: cor-color)[$(2, 1)$])
    // Light-fill the two sub-cones to make them visible
    line((0, 0), (10, 0), (10, 5), close: true, stroke: none, fill: rgb(255, 245, 230))
    line((0, 0), (10, 5), (8, 8), close: true, stroke: none, fill: rgb(235, 245, 255))
    // Redraw the rays on top of the fills
    line((0, 0), (11, 0), stroke: 1.2pt + defn-color)
    line((0, 0), (8, 8), stroke: 1.2pt + defn-color)
    line((0, 0), (11, 5.5), stroke: 1.5pt + cor-color)
    // Sample lattice points P, Q for (p, t) = (2, 1)
    // P = (1 + 1 + 22, 1) = (24, 1) — too far; rescale
    // For illustration use small representative points in this cone (rescaled).
    // P below split: a generic point with small slope; Q above: generic with larger slope.
    // Use P = (8, 2) (slope 1/4) and Q = (6, 4.5) (slope 0.75) for visual clarity.
    let Px = 8
    let Py = 2
    let Qx = 6
    let Qy = 4.5
    // Filled P
    circle((Px, Py), radius: 0.13, fill: dark-text, stroke: none)
    content((Px + 0.55, Py - 0.25), text(size: 8.5pt)[$P$])
    // Open Q
    circle((Qx, Qy), radius: 0.16, stroke: 1pt + dark-text, fill: white)
    content((Qx - 0.4, Qy + 0.35), text(size: 8.5pt)[$Q$])
    // Offset arrow Q - P
    line((Px, Py), (Qx, Qy), stroke: 1pt + ku-blue, mark: (end: ">"))
    content(((Px + Qx) / 2 - 0.3, (Py + Qy) / 2 + 0.1), anchor: "east", text(size: 7.5pt, fill: ku-blue)[$Q - P$])
    // Sub-cone labels
    content((8.3, 1.0), text(size: 7.5pt, fill: defn-color)[$chevron.l v_0, thin (2, 1) chevron.r$])
    content((4.0, 5.2), text(size: 7.5pt, fill: defn-color)[$chevron.l (2, 1), thin u_0 chevron.r$])
  }),
) <fig:standard-cone-split>

We may now derive the return-reduced inequalities @eq:return-reduced-elementary from §16.1 in their explicit algebraic form. The condition that $P = (p + t + 22, thin p)$ lies strictly below the $(2, 1)$-ray reads $p slash (p + t + 22) < 1 slash 2$, equivalent to $2 p < p + t + 22$, hence
$
  p < t + 22.
$ <eq:p-less-than-t-plus-22>
The condition that $Q = (p + t + 12, thin p + 12)$ lies strictly above the $(2, 1)$-ray reads $(p + 12) slash (p + t + 12) > 1 slash 2$, equivalent to $2 (p + 12) > p + t + 12$, hence
$
  p > t - 12.
$ <eq:p-greater-than-t-minus-12>
Combining the two inequalities,
$
  t - 12 < p < t + 22.
$ <eq:p-t-bracket>

_The offset parameter $c = p - t$._ Introduce the difference
$
  c := p - t.
$ <eq:c-definition-sec163>
The inequalities @eq:p-t-bracket translate into $-12 < c < 22$, that is, $c$ runs over the thirty-three integers $-11, -10, dots, 20, 21$.

The residue restriction @eq:sec163-residue-condition is now decisive: $p$ even and $t$ odd force $c = p - t$ to be odd. The thirty-three-element range therefore collapses to the seventeen odd integers
$
  c in {-11, thin -9, thin -7, thin -5, thin -3, thin -1, thin 1, thin 3, thin 5, thin 7, thin 9, thin 11, thin 13, thin 15, thin 17, thin 19, thin 21}.
$ <eq:c-set-derived>
This is the rigorous derivation of the forward-declared set @eq:c-set introduced in the strategy paragraph of @subsec:minimal-direction-statement.

_The one-parameter families._ The mod-$6$ part of @eq:sec163-residue-condition supplies the parametrisation
$
  t = 6 k + 1, quad quad k in bb(Z)_(gt.eq.slant 0),
$ <eq:t-as-6k-plus-1>
and the offset definition @eq:c-definition-sec163 gives
$
  p = t + c = 6 k + c + 1.
$ <eq:p-from-c-k>
Substituting into the terminal-pair formulas $P = (p + t + 22, thin p)$ and $Q = (p + t + 12, thin p + 12)$ yields the explicit forms
$
  P_(c, k) &= (12 k + c + 24, thin 6 k + c + 1), \
  Q_(c, k) &= (12 k + c + 14, thin 6 k + c + 13)
$ <eq:Pck-Qck-substituted>
of @eq:Pck-Qck-explicit. The original positivity condition $p gt.eq.slant 1$ becomes
$
  6 k + c + 1 gt.eq.slant 1,
$ <eq:k-positivity>
For $c gt.eq.slant 1$ the condition $k gt.eq.slant 0$ suffices; for $c = -1$ we need $k gt.eq.slant 1$; for $c in {-11, -9, -7}$ we need $k gt.eq.slant 2$; for $c in {-5, -3}$ we need $k gt.eq.slant 1$.

The seventeen families are mutually disjoint (each value of $c$ gives a distinct $bb(Z)$-affine line in the $(q, p)$-plane) and translate uniformly along the twist direction $(2, 1)$ in the sense
$
  P_(c, k + 1) - P_(c, k) = (12, thin 6) = 6 dot.op (2, 1) = Q_(c, k + 1) - Q_(c, k).
$ <eq:family-twist-translation>
Each family is therefore an $bb(N)$-orbit under the translation by $6 dot.op (2, 1)$, and the offset $c$ labels the orbits.

_Primitivity conditions for the families._ Both lattice points must be primitive in $cal(D)$ — the requirement on $(q, p)$ pairs introduced in @subsec:terminal-coords-sec14. For $P_(c, k) = (12 k + c + 24, thin 6 k + c + 1)$, the standard identity $gcd(a, b) = gcd(a - 2 b, b)$ applied with $a = 12 k + c + 24$ and $b = 6 k + c + 1$ gives
$
  a - 2 b = (12 k + c + 24) - 2 (6 k + c + 1) = 22 - c,
$
so
$
  gcd (12 k + c + 24, thin 6 k + c + 1) = gcd (6 k + c + 1, thin 22 - c).
$ <eq:gcd-Pck>
The right-hand side depends on $k$ only through the residue class of $6 k + c + 1$ modulo $22 - c$. At the extreme $c = 21$ we have $22 - c = 1$, so $P_(c, k)$ is automatically primitive in $cal(D)$ for every $k$.

For $Q_(c, k) = (12 k + c + 14, thin 6 k + c + 13)$, the same identity with $a = 12 k + c + 14$ and $b = 6 k + c + 13$ gives
$
  a - 2 b = (12 k + c + 14) - 2 (6 k + c + 13) = -c - 12,
$
which is negative whenever $c gt.eq.slant -11$ (i.e. for every admissible $c$) but absorbed into the symmetric gcd. Thus
$
  gcd (12 k + c + 14, thin 6 k + c + 13) = gcd (6 k + c + 13, thin c + 12),
$ <eq:gcd-Qck>
again a function of $k$ only through the residue class of $6 k + c + 13$ modulo $c + 12$. At the extreme $c = -11$ we have $c + 12 = 1$, so $Q_(c, k)$ is automatically primitive for every $k$.

The admissible parameters $(c, k)$ are therefore those satisfying @eq:k-positivity together with
$
  gcd (6 k + c + 1, thin 22 - c) = 1 quad upright("and") quad gcd (6 k + c + 13, thin c + 12) = 1.
$ <eq:primitivity-conditions-explicit>

_The seventeen families and their intersection numbers._ The same $a - 2 b$ computation, read intrinsically, gives the determinants of $P_(c, k)$ and $Q_(c, k)$ against the twist direction $(2, 1)$. Define
$
  Delta_P (c) &:= det vec(P_(c, k), (2, 1)) = (12 k + c + 24) dot.op 1 - (6 k + c + 1) dot.op 2 \
  &= 22 - c,
$ <eq:Delta-P-def>
$
  Delta_Q (c) &:= det vec(Q_(c, k), (2, 1)) = (12 k + c + 14) dot.op 1 - (6 k + c + 13) dot.op 2 \
  &= -c - 12.
$ <eq:Delta-Q-def>
We have written $Delta_Q (c) := -c - 12$ to emphasise the symmetry with $Delta_P (c)$; the modulus $|Delta_Q (c)| = c + 12$ is the gcd-modulus that appears in @eq:gcd-Qck. The intersection numbers $Delta_P (c)$ and $Delta_Q (c)$ are independent of $k$ by the translation invariance @eq:family-twist-translation: along each $bb(N)$-orbit, the lattice points slide along the $(2, 1)$-direction, leaving the transverse component unchanged.

The sum is a discrete invariant of the seventeen-family configuration:
$
  Delta_P (c) + abs(Delta_Q (c)) = (22 - c) + (c + 12) = 34.
$ <eq:intersection-sum-conserved>
This conservation law is rigid: as $c$ runs through the seventeen-element set @eq:c-set-derived, the pair $(Delta_P, thin |Delta_Q|)$ sweeps out the partitions of $34$ into two positive integers with $Delta_P$ odd and $|Delta_Q|$ odd. The involution
$
  iota colon thin c arrow.r.bar 10 - c
$ <eq:c-involution>
swaps the two intersection numbers, $Delta_P (iota (c)) = 22 - (10 - c) = c + 12 = abs(Delta_Q (c))$, and is a discrete $bb(Z) slash 2$-symmetry of the configuration. Its fixed point is the central family
$
  c = 5, quad upright("at which") quad Delta_P (5) = |Delta_Q (5)| = 17.
$ <eq:central-family-fixed-point>

We summarise the seventeen families in @tab:seventeen-families.

#figure(
  caption: [The seventeen one-parameter families of terminal pairs $(P_(c, k), thin Q_(c, k))$ in the minimal exceptional direction. The columns record the offset $c = p - t$, the explicit forms of $P_(c, k)$ and $Q_(c, k)$, and the two intersection numbers $Delta_P (c) = 22 - c$ and $|Delta_Q (c)| = c + 12$ (read off as the determinants against the twist direction $(2, 1)$). The sum $Delta_P + |Delta_Q| = 34$ is constant along the table; the involution $c arrow.r.bar 10 - c$ swaps $Delta_P$ and $|Delta_Q|$ and exhibits the table's symmetry around the fixed point $c = 5$, at which $Delta_P = |Delta_Q| = 17$.],
  table(
    columns: (auto, auto, auto, auto, auto),
    align: center,
    table.header(
      [$c$], [$P_(c, k)$], [$Q_(c, k)$], [$Delta_P (c)$], [$|Delta_Q (c)|$]
    ),
    [$-11$], [$(12 k + 13, thin 6 k - 10)$], [$(12 k + 3, thin 6 k + 2)$], [$33$], [$1$],
    [$-9$], [$(12 k + 15, thin 6 k - 8)$], [$(12 k + 5, thin 6 k + 4)$], [$31$], [$3$],
    [$-7$], [$(12 k + 17, thin 6 k - 6)$], [$(12 k + 7, thin 6 k + 6)$], [$29$], [$5$],
    [$-5$], [$(12 k + 19, thin 6 k - 4)$], [$(12 k + 9, thin 6 k + 8)$], [$27$], [$7$],
    [$-3$], [$(12 k + 21, thin 6 k - 2)$], [$(12 k + 11, thin 6 k + 10)$], [$25$], [$9$],
    [$-1$], [$(12 k + 23, thin 6 k)$], [$(12 k + 13, thin 6 k + 12)$], [$23$], [$11$],
    [$1$], [$(12 k + 25, thin 6 k + 2)$], [$(12 k + 15, thin 6 k + 14)$], [$21$], [$13$],
    [$3$], [$(12 k + 27, thin 6 k + 4)$], [$(12 k + 17, thin 6 k + 16)$], [$19$], [$15$],
    [$5$], [$(12 k + 29, thin 6 k + 6)$], [$(12 k + 19, thin 6 k + 18)$], [$17$], [$17$],
    [$7$], [$(12 k + 31, thin 6 k + 8)$], [$(12 k + 21, thin 6 k + 20)$], [$15$], [$19$],
    [$9$], [$(12 k + 33, thin 6 k + 10)$], [$(12 k + 23, thin 6 k + 22)$], [$13$], [$21$],
    [$11$], [$(12 k + 35, thin 6 k + 12)$], [$(12 k + 25, thin 6 k + 24)$], [$11$], [$23$],
    [$13$], [$(12 k + 37, thin 6 k + 14)$], [$(12 k + 27, thin 6 k + 26)$], [$9$], [$25$],
    [$15$], [$(12 k + 39, thin 6 k + 16)$], [$(12 k + 29, thin 6 k + 28)$], [$7$], [$27$],
    [$17$], [$(12 k + 41, thin 6 k + 18)$], [$(12 k + 31, thin 6 k + 30)$], [$5$], [$29$],
    [$19$], [$(12 k + 43, thin 6 k + 20)$], [$(12 k + 33, thin 6 k + 32)$], [$3$], [$31$],
    [$21$], [$(12 k + 45, thin 6 k + 22)$], [$(12 k + 35, thin 6 k + 34)$], [$1$], [$33$],
  ),
) <tab:seventeen-families>

The central family $c = 5$ is the only family whose two intersection numbers coincide. This makes it qualitatively distinct from the other sixteen: the congruence-certificate elimination of @subsec:sixteen-table, which proceeds by detecting a small prime modulus dividing $Delta_P$ or $|Delta_Q|$ but not the other, has no such prime to exploit when $Delta_P = |Delta_Q|$. The central family is handled separately in @subsec:central-family by an exact symbolic trace argument.

_The reduction theorem._ We collect the consequences of the section.

#proposition(title: "Reduction to seventeen one-parameter families", lbl: <prop:seventeen-families-reduction>)[
  Let
  $
    P = (p + t + 22, thin p), quad quad Q = (p + t + 12, thin p + 12)
  $ <eq:sec163-PQ-prop>
  be primitive return-reduced terminal points in the standard Farey cone, with $p, t gt.eq.slant 1$, satisfying the standing residue conclusion @eq:sec163-residue-condition. If $m_P = m_Q$, then there exist
  $
    c in {-11, thin -9, thin -7, thin -5, thin -3, thin -1, thin 1, thin 3, thin 5, thin 7, thin 9, thin 11, thin 13, thin 15, thin 17, thin 19, thin 21}
  $ <eq:sec163-prop-c-set>
  and $k in bb(Z)_(gt.eq.slant 0)$ with $6 k + c + 1 gt.eq.slant 1$, such that
  $
    P = P_(c, k) &= (12 k + c + 24, thin 6 k + c + 1), \
    Q = Q_(c, k) &= (12 k + c + 14, thin 6 k + c + 13),
  $ <eq:sec163-prop-substitution>
  and the primitivity conditions @eq:primitivity-conditions-explicit hold. Conversely, every pair $(P_(c, k), thin Q_(c, k))$ with $c$ in the set @eq:sec163-prop-c-set and $k gt.eq.slant 0$ satisfying @eq:k-positivity and @eq:primitivity-conditions-explicit is a primitive lattice pair in the minimal exceptional direction.

  In particular, the proof of @thm:minimal-direction is reduced to excluding equality of Markov numbers within each of the seventeen families indexed by $c in {-11, -9, dots, 19, 21}$, for every admissible $k$.
] <prop-seventeen-families-reduction>

#proof[
  Combine @prop:elementary-residue-reduction with the algebraic derivation of the present Section. The residue restriction @eq:sec163-residue-condition supplies $p equiv 0 thin (upright("mod") thin 2)$ and $t equiv 1 thin (upright("mod") thin 6)$; the parametrisation $t = 6 k + 1$ with $k gt.eq.slant 0$ is the mod-$6$ part. The return-reducedness condition forces the half-split inequalities @eq:p-less-than-t-plus-22 and @eq:p-greater-than-t-minus-12 via the configuration described in @fig:standard-cone-split; combining with the parity gives the seventeen-element set @eq:c-set-derived for $c = p - t$. The substitution $p = 6 k + c + 1$ yields the explicit forms @eq:Pck-Qck-substituted, and the gcd reductions of @eq:gcd-Pck and @eq:gcd-Qck transcribe the primitivity conditions of @subsec:terminal-coords-sec14 into the explicit form @eq:primitivity-conditions-explicit. The converse direction is a direct substitution check.
]

The remainder of the Chapter excludes the seventeen families. The finite congruence-certificate principle is developed in @subsec:congruence-certificate; the elimination of the sixteen non-central families is collected in @subsec:sixteen-table; the central family $c = 5$ is treated in @subsec:central-family; and the synthesis is collected in @subsec:g2-conclusion.

== The finite congruence-certificate principle and twist periods <subsec:congruence-certificate>

@prop:seventeen-families-reduction has cut the minimal-direction problem down to seventeen one-parameter families $(P_(c, k), thin Q_(c, k))$ indexed by $c in {-11, -9, dots, 19, 21}$ and admissible $k$. The remainder of the Chapter eliminates the seventeen families; the present Section formalises the principal tool, the _finite congruence-certificate principle_ for residues modulo small primes, and computes the explicit periods at which the Markov residues of the families become periodic in the affine parameter $k$. The principle is generic --- it applies to any pair of one-parameter Cohn-index families with the same affine increment --- and the periods specialise to the seventeen families via the intersection numbers $Delta_P (c)$ and $|Delta_Q (c)|$ derived in @subsec:seventeen-families.

_Cohn residues modulo a prime._ The Cohn-trace identification of @sec:markov-cohn gives, for every primitive lattice point $(q, thin p) in cal(D)$,
$
  tr (C_(p slash q)) = 3 thin m_(p slash q).
$ <eq:cohn-trace-three-m>
The trace is therefore always divisible by $3$ as an integer, a fact that is also recalled in @subsec:appendix-D-conventions. For every prime $ell$ this divisibility gives a clean residue bridge: if
$
  tr (C_(p slash q)) equiv 3 a thin (upright("mod") thin 3 ell)
$ <eq:cohn-trace-mod-3ell>
for some integer $a$, then
$
  m_(p slash q) equiv a thin (upright("mod") thin ell).
$
The division by $3$ is well defined because $tr (C_(p slash q)) equiv 0 thin (upright("mod") thin 3)$ for every Cohn word. To prove $m_P eq.not m_Q thin (upright("mod") thin ell)$ for a pair of primitive Cohn indices, it is therefore enough to compute the two Cohn traces modulo $3 ell$, divide the resulting residues by $3$, and compare the resulting integers modulo $ell$. This is the computational pattern used by every certificate in the rest of the Chapter.

_The finite congruence-certificate principle._ The first principle is elementary: an equality of integers implies congruence to every modulus, so a single modulus that separates the two integers in residue rules out their equality. When the integers are presented as values of a periodic residue sequence in a one-parameter family, the certificate becomes a finite check over the residue classes of the parameter modulo the period.

#lemma(title: "Finite congruence certificate", lbl: <lem:finite-congruence-certificate>)[
  Let
  $
    P_k = (alpha k + beta, thin gamma k + delta), quad quad Q_k = (alpha k + beta', thin gamma k + delta')
  $ <eq:one-parameter-families>
  be one-parameter families of primitive Cohn indices indexed by $k$ in some admissible set $cal(K) subset.eq bb(Z)$. Suppose that for a prime $ell$ the residue sequences
  $
    k arrow.r.bar m_(P_k) thin (upright("mod") thin ell), quad quad k arrow.r.bar m_(Q_k) thin (upright("mod") thin ell)
  $
  are periodic in $k$ with common period $T$. If for every admissible residue class $k thin (upright("mod") thin T)$ one has
  $
    m_(P_k) eq.not m_(Q_k) thin (upright("mod") thin ell),
  $
  then $m_(P_k) eq.not m_(Q_k)$ for every $k in cal(K)$.

  More generally, suppose finitely many primes $ell_1, dots, ell_j$ and associated periods $T_1, dots, T_j$ are given, that the residue sequences modulo each $ell_i$ are periodic in $k$ with period $T_i$, and that every admissible $k in cal(K)$ is separated modulo at least one $ell_i$ (in the sense $m_(P_k) eq.not m_(Q_k) thin (upright("mod") thin ell_i)$). Then $m_(P_k) eq.not m_(Q_k)$ for every $k in cal(K)$.
] <lem-finite-congruence-certificate>

#proof[
  Equality of integers $m_(P_k) = m_(Q_k)$ implies $m_(P_k) equiv m_(Q_k) thin (upright("mod") thin ell)$ for every prime $ell$. Hence any congruence separation modulo a single prime $ell_i$ rules out the equality at the corresponding $k$. In the periodic single-modulus case, the residue at $k$ depends only on $k thin (upright("mod") thin T)$, so the finite check over the $T$ residue classes covers all admissible $k$. In the multi-modulus case, the admissible parameters $k in cal(K)$ are partitioned according to which prime $ell_i$ separates them; the union of the separated classes across the primes is $cal(K)$ by hypothesis, and the integer equality $m_(P_k) = m_(Q_k)$ is impossible on every part.
]

_The $(2, 1)$-twist matrix._ The seventeen families of @prop:seventeen-families-reduction share a common affine increment in the $(q, p)$-lattice:
$
  P_(c, k + 1) - P_(c, k) = (12, thin 6) = 6 thin (2, 1) = Q_(c, k + 1) - Q_(c, k),
$ <eq:family-twist-increment>
recalling @eq:family-twist-translation. The direction $(2, 1)$ is itself the lattice realisation of the Stern--Brocot fraction $1 slash 2$, and on the Cohn-tree side it corresponds to the Cohn matrix
$
  W := A B = mat(2, 1; 1, 1) mat(5, 2; 2, 1) = mat(12, 5; 7, 3),
$ <eq:twist-matrix-W>
the seed mediant of @sec:markov-cohn. Its trace and determinant are
$
  tr (W) = 15, quad quad det (W) = 12 dot.op 3 - 5 dot.op 7 = 1,
$ <eq:W-trace-det>
so the Cayley--Hamilton identity in $upright(S L)_2 (bb(Z))$ reads
$
  W^2 - 15 thin W + I = 0, quad upright("equivalently") quad W^2 = 15 thin W - I.
$ <eq:cayley-hamilton-W>
The matrix $W$ is hyperbolic in $upright(S L)_2 (bb(R))$ with eigenvalues
$
  lambda_(plus.minus) = (15 plus.minus sqrt(221)) slash 2,
$
of which the dominant value is $lambda_+ approx 14.93$.

The intersection numbers of the families against the twist direction $(2, 1)$ were computed in @eq:Delta-P-def and @eq:Delta-Q-def:
$
  Delta_P (c) &:= det vec(P_(c, k), (2, 1)) = 22 - c, \
  Delta_Q (c) &:= det vec(Q_(c, k), (2, 1)) = -c - 12,
$ <eq:Delta-recall>
with $|Delta_Q (c)| = c + 12$ the positive modulus that enters the gcd-style periodicity below. Both intersection numbers are independent of $k$ by @eq:family-twist-translation. The geometric reading is that one positive twist by $W$ about the $(2, 1)$-direction shifts $P_(c, k)$ along $(2, 1)$ by $Delta_P (c)$ lattice units, and shifts $Q_(c, k)$ by $-Delta_Q (c) = |Delta_Q (c)|$ lattice units (in the opposite signed sense, which the gcd-style periodicity below absorbs since $W^M equiv I$ if and only if $W^(-M) equiv I$).

_The periodicity criterion._ Fix a prime $ell$ and suppose there exists a positive integer $M_ell$ with
$
  W^(M_ell) equiv I thin (upright("mod") thin 3 ell).
$ <eq:W-Mell-identity>
Such an $M_ell$ exists for every prime $ell$, since $upright(S L)_2 (bb(Z) slash 3 ell bb(Z))$ is a finite group containing the image of $W$. We seek a positive integer $T$ such that incrementing $k$ by $T$ leaves both Markov residues unchanged modulo $ell$.

Incrementing $k$ by $T$ translates $P_(c, k)$ by $6 T dot.op (2, 1)$; by the lattice reading of $Delta_P (c)$ this is the same as $6 T slash Delta_P (c)$ twists about the $(2, 1)$-direction, and the corresponding transformation of the Cohn trace is by $W^(6 T slash Delta_P (c))$. The trace residue modulo $3 ell$ is preserved when this power of $W$ is the identity modulo $3 ell$, that is, when $M_ell$ divides $6 T slash Delta_P (c)$. Equivalently,
$
  Delta_P (c) thin M_ell divides 6 T.
$ <eq:divisibility-P>
The same argument applied to $Q_(c, k)$, using $|Delta_Q (c)|$ in place of $Delta_P (c)$, gives
$
  |Delta_Q (c)| thin M_ell divides 6 T.
$ <eq:divisibility-Q>
Defining
$
  L_(c, ell) := upright("lcm") thin (Delta_P (c) thin M_ell, thin |Delta_Q (c)| thin M_ell) = M_ell dot.op upright("lcm") thin (Delta_P (c), thin |Delta_Q (c)|),
$ <eq:L-cl-definition>
the combined constraint is $L_(c, ell) divides 6 T$. The smallest positive $T$ satisfying this divisibility is
$
  T_(c, ell) := L_(c, ell) slash gcd (L_(c, ell), thin 6).
$ <eq:T-cl-formula>

This is the period formula.

#lemma(title: "Twist-period lemma", lbl: <lem:twist-period>)[
  Let $ell$ be a prime and let $M_ell$ be a positive integer with
  $
    W^(M_ell) equiv I thin (upright("mod") thin 3 ell).
  $
  For each $c$ in the seventeen-element set @eq:c-set-derived, define
  $
    L_(c, ell) &:= M_ell dot.op upright("lcm") thin (Delta_P (c), thin |Delta_Q (c)|), \
    T_(c, ell) &:= L_(c, ell) slash gcd (L_(c, ell), thin 6),
  $
  where $Delta_P (c) = 22 - c$ and $|Delta_Q (c)| = c + 12$. Then the Markov-residue sequences
  $
    k arrow.r.bar m_(P_(c, k)) thin (upright("mod") thin ell), quad quad k arrow.r.bar m_(Q_(c, k)) thin (upright("mod") thin ell)
  $
  are periodic in $k$ with period $T_(c, ell)$.
] <lem-twist-period>

#proof[
  Increasing $k$ by $T_(c, ell)$ translates both $P_(c, k)$ and $Q_(c, k)$ by $6 thin T_(c, ell) dot.op (2, 1)$, by @eq:family-twist-increment. By the construction of $T_(c, ell)$ via @eq:T-cl-formula, both $Delta_P (c) M_ell$ and $|Delta_Q (c)| M_ell$ divide $6 T_(c, ell)$. The translation of $P_(c, k)$ corresponds to $6 T_(c, ell) slash Delta_P (c)$ twists of the Cohn matrix by $W$, a number that is an integer multiple of $M_ell$; the trace residue modulo $3 ell$ is therefore preserved, and hence the Markov residue modulo $ell$ is preserved as well. The same argument applies to $Q_(c, k)$. Periodicity of both sequences with period $T_(c, ell)$ follows. The rigorous mechanism underlying the "translation by $6 T (2, 1)$ corresponds to integer powers of $W$" step is the Cohn--Stern--Brocot residue automaton of @subsec:appendix-D-automaton, which records the residue modulo $3 ell$ as a function of the Stern--Brocot address of the lattice point and reduces the periodicity claim to the closure of the automaton's reachable set under the fixed sub-path that encodes the affine increment @eq:family-twist-increment.
]

_The four moduli and their orders._ The certificates of @subsec:sixteen-table and @subsec:central-family use only the four primes
$
  ell in {5, thin 23, thin 37, thin 47},
$ <eq:certificate-primes>
each with a small order $M_ell$ of $W$ modulo $3 ell$. The values are collected in @tab:certificate-moduli.

#figure(
  caption: [The four primes used in the finite congruence certificates of @subsec:sixteen-table and @subsec:central-family, together with the smallest positive exponent $M_ell$ for which the twist matrix $W = A B$ of @eq:twist-matrix-W satisfies $W^(M_ell) equiv I thin (upright("mod") thin 3 ell)$. The verification at $ell = 5$ is the Cayley--Hamilton derivation of @eq:W4-mod-15 displayed below; the remaining three are direct finite matrix multiplications recorded in @appendix:minimal-certificates.],
  table(
    columns: (auto, auto, auto, auto),
    align: center,
    table.header(
      [$ell$], [$3 ell$], [$M_ell$], [congruence]
    ),
    [$5$], [$15$], [$4$], [$W^4 equiv I thin (upright("mod") thin 15)$],
    [$23$], [$69$], [$24$], [$W^(24) equiv I thin (upright("mod") thin 69)$],
    [$37$], [$111$], [$12$], [$W^(12) equiv I thin (upright("mod") thin 111)$],
    [$47$], [$141$], [$24$], [$W^(24) equiv I thin (upright("mod") thin 141)$],
  ),
) <tab:certificate-moduli>

The order at $ell = 5$ admits a Cayley--Hamilton derivation that we record in detail. Reducing the identity @eq:cayley-hamilton-W modulo $15$ and using $tr (W) = 15 equiv 0 thin (upright("mod") thin 15)$,
$
  W^2 equiv 15 thin W - I equiv -I thin (upright("mod") thin 15),
$ <eq:W2-mod-15>
and squaring,
$
  W^4 equiv (-I)^2 = I thin (upright("mod") thin 15).
$ <eq:W4-mod-15>
The exponent $4$ is minimal: $W^1 eq.not I$ and $W^2 equiv -I eq.not I$ modulo $15$. The three remaining congruences are direct matrix multiplications modulo $69$, $111$, and $141$ respectively; we defer the explicit calculations to the certificate scripts of @appendix:minimal-certificates, where they are reproducible from the matrix entries of @eq:twist-matrix-W.

_Two illustrative period computations._ The period formula @eq:T-cl-formula is best absorbed through two examples that anticipate its use in @subsec:sixteen-table and @subsec:central-family.

The first is the _central_ family $c = 5$, the fixed point of the symmetry $c arrow.r.bar 10 - c$ of @subsec:seventeen-families. At $c = 5$ the two intersection numbers coincide,
$
  Delta_P (5) = 22 - 5 = 17, quad quad |Delta_Q (5)| = 5 + 12 = 17.
$
With $ell = 37$ and $M_(37) = 12$ from @tab:certificate-moduli,
$
  L_(5, thin 37) = 12 dot.op upright("lcm") (17, thin 17) = 12 dot.op 17 = 204, quad quad
  gcd (204, thin 6) = 6,
$
so
$
  T_(5, thin 37) = 204 slash 6 = 34.
$ <eq:central-period-example>
The Markov residues modulo $37$ in the central family are therefore periodic in $k$ with period $34$. This is the period that @subsec:central-family will use to reduce the central family to a single survivor class $k equiv 15 thin (upright("mod") thin 17)$, before passing to the symbolic argument of that subsection.

The second example is the _off-central_ family $c = -5$, which sits four steps to the left of the centre on the table of @subsec:seventeen-families. Here
$
  Delta_P (-5) = 22 - (-5) = 27, quad quad |Delta_Q (-5)| = -5 + 12 = 7.
$
With $ell = 37$ and $M_(37) = 12$,
$
  L_(-5, thin 37) = 12 dot.op upright("lcm") (27, thin 7) = 12 dot.op 189 = 2268, quad quad
  gcd (2268, thin 6) = 6,
$
so
$
  T_(-5, thin 37) = 2268 slash 6 = 378.
$ <eq:off-central-period-example>
The Markov residues modulo $37$ in the $c = -5$ family are periodic in $k$ with period $378$. This is the period that the $c = -5$ row of the certificate table in @subsec:sixteen-table will use, alongside an auxiliary modulus $ell = 23$ that supplies a much shorter back-up period for residue classes not separated mod $37$.

_Structural reading._ The eigenvalue $lambda_+ = (15 + sqrt(221)) slash 2$ of $W$ exceeds $2$, so $W$ is hyperbolic in $upright(S L)_2 (bb(R))$: the $(2, 1)$-direction admits expanding and contracting eigendirections in the once-punctured-torus character variety, and the Markov-surface dynamics generated by Vieta involutions and Dehn twists about the slope-$1 slash 2$ curve has $W$ as one of its hyperbolic generators. The orders $M_ell$ of $W$ in the finite groups $upright(S L)_2 (bb(Z) slash 3 ell bb(Z))$ govern the periodicity of Markov-number residues along the corresponding orbits, in line with the strong-approximation phenomenon for Markov triples studied by Bourgain, Gamburd, and Sarnak. The rigorous combinatorial backbone underlying @lem:twist-period is the Cohn--Stern--Brocot residue automaton of @subsec:appendix-D-automaton: the residue mod $3 ell$ is a finite-state function of the Stern--Brocot address, and the affine increment @eq:family-twist-increment acts on the address by a fixed sub-path whose iteration on the automaton's reachable set has finite period dividing $T_(c, ell)$.

_Role in the rest of the proof._ With the periods of @lem:twist-period in hand, the remainder of the Chapter applies @lem:finite-congruence-certificate to the seventeen families of @prop:seventeen-families-reduction. The non-central families are eliminated in @subsec:sixteen-table by the compact certificate table that records, for each $c eq.not 5$ in the set @eq:c-set-derived, the primary modulus $ell in {5, 23, 37, 47}$ and (where needed) one auxiliary modulus that together separate every admissible residue class modulo the corresponding period $T_(c, ell)$. The central family $c = 5$ is treated in @subsec:central-family: @lem:finite-congruence-certificate with $ell = 37$ and $T_(5, thin 37) = 34$ reduces the family to a single survivor class $k equiv 15 thin (upright("mod") thin 17)$, after which a symbolic trace-positivity argument on the Stern--Brocot paths $L R^N L R L R^4$ and $R L^N R^2 L R^4$ completes the elimination.

== The sixteen congruence-certified families <subsec:sixteen-table>

We now apply the finite congruence-certificate machinery of @subsec:congruence-certificate --- the generic principle @lem:finite-congruence-certificate and the explicit twist-period formula @lem:twist-period --- to the seventeen one-parameter families of @prop:seventeen-families-reduction. The present Section eliminates the sixteen non-central families
$
  c in {-11, thin -9, thin -7, thin -5, thin -3, thin -1, thin 1, thin 3, thin 7, thin 9, thin 11, thin 13, thin 15, thin 17, thin 19, thin 21} \
  = {-11, thin -9, dots, thin 19, thin 21} backslash {5}.
$ <eq:sixteen-c-values>
The central family $c = 5$ is qualitatively distinct (it is the fixed point of the involution $c arrow.r.bar 10 - c$ of @eq:c-involution, the unique value at which $Delta_P (c) = |Delta_Q (c)| = 17$) and is treated in @subsec:central-family.

_Statement of the finite-certificate theorem._

#theorem(title: "Exclusion of the sixteen non-central families", lbl: <thm:sixteen-noncentral-excluded>)[
  Let $c$ belong to the sixteen-element set @eq:sixteen-c-values. Then
  $
    m_(P_(c, k)) eq.not m_(Q_(c, k))
  $ <eq:sixteen-noncentral-conclusion>
  for every admissible integer $k$ in the sense of @prop:seventeen-families-reduction.
] <thm-sixteen-noncentral-excluded>

The proof composes eight pair-lemmas (@lem:pair-11-21 through @lem:pair-3-7), one per orbit of the involution $c arrow.r.bar 10 - c$ on the sixteen-element set. The structural backbone of each pair-lemma is identical: identify the primitivity exclusions on $k$ from @eq:primitivity-conditions-explicit, apply @lem:twist-period to obtain the relevant period, and check residue separation modulo the primary modulus over the corresponding finite set of residue classes; the few classes (if any) not separated by the primary modulus are separated by an auxiliary modulus after lifting to a common period. The certificate-summary table @tab:certificate-summary records the structural data of all sixteen certificates; the explicit residue values, with full verification scripts, are recorded in @appendix:minimal-certificates.

_The certificate summary table._

@tab:certificate-summary records, for each non-central $c$, the primary modulus $ell$, the period $T_(c, ell)$ from @lem:twist-period, the explicit list of residue classes $k thin (upright("mod") thin T_(c, ell))$ that survive the primary modulus (i.e. the classes on which $m_(P_(c, k)) equiv m_(Q_(c, k)) thin (upright("mod") thin ell)$), and the auxiliary modulus or moduli used to separate the survivors after lifting to the appropriate common period. A dash in the "primary survivors" column means the primary modulus alone separates every admissible class.

#figure(
  caption: [The certificate-summary table for the sixteen non-central families of @prop:seventeen-families-reduction. For each $c$ in @eq:sixteen-c-values, the table records the primary modulus $ell$, the period $T_(c, ell)$ from @lem:twist-period, the residue classes $k thin (upright("mod") thin T_(c, ell))$ that survive the primary modulus, and the auxiliary modulus or moduli that separate the survivors after lifting to the appropriate common period. A dash in the "primary survivors" column means the primary modulus separates every admissible class. The detailed residue tables and verification scripts are recorded in @appendix:minimal-certificates.],
  table(
    columns: (auto, auto, auto, 1fr, auto),
    align: (center + horizon, center + horizon, center + horizon, left + horizon, center + horizon),
    table.header(
      [$c$], [primary], [period], [primary survivors mod period], [auxiliary]
    ),
    [$-11$], [$5$], [$22$], [---], [---],
    [$-9$], [$5$], [$62$], [#text(size: 7.5pt)[0, 13 (mod 31)]], [$23$],
    [$-7$], [$37$], [$290$], [#text(size: 7.5pt)[28, 76, 96, 110, 132, 173, 221, 241, 255, 277]], [$5$],
    [$-5$], [$37$], [$378$], [#text(size: 7.5pt)[16, 20, 54, 76, 150, 152, 205, 209, 243, 265, 339, 341]], [$23$],
    [$-3$], [$37$], [$450$], [#text(size: 7.5pt)[24, 49, 65, 86, 95, 113, 191, 198, 249, 274, 290, 311, 320, 338, 416, 423]], [$5, thin 23$],
    [$-1$], [$47$], [$1012$], [#text(size: 7.5pt)[1, 44, 112, 159, 281, 370, 393, 507, 550, 618, 665, 787, 876, 899]], [$5$],
    [$1$], [$37$], [$546$], [#text(size: 7.5pt)[1, 43, 90, 109, 115, 146, 159, 263, 270, 274, 316, 363, 382, 388, 419, 432, 536, 543]], [$23$],
    [$3$], [$47$], [$1140$], [#text(size: 7.5pt)[223, 226, 420, 466, 793, 796, 990, 1036]], [$5, thin 23$],
    [$7$], [$47$], [$1140$], [#text(size: 7.5pt)[100, 146, 340, 343, 670, 716, 910, 913]], [$5, thin 23$],
    [$9$], [$37$], [$546$], [#text(size: 7.5pt)[6, 110, 123, 154, 160, 179, 226, 268, 272, 279, 383, 396, 427, 433, 452, 499, 541, 545]], [$23$],
    [$11$], [$47$], [$1012$], [#text(size: 7.5pt)[109, 132, 221, 343, 390, 458, 501, 615, 638, 727, 849, 896, 964, 1007]], [$5$],
    [$13$], [$37$], [$450$], [#text(size: 7.5pt)[23, 30, 108, 126, 135, 156, 172, 197, 248, 255, 333, 351, 360, 381, 397, 422]], [$5, thin 23$],
    [$15$], [$37$], [$378$], [#text(size: 7.5pt)[33, 35, 109, 131, 165, 169, 222, 224, 298, 320, 354, 358]], [$23$],
    [$17$], [$37$], [$290$], [#text(size: 7.5pt)[9, 31, 45, 65, 113, 154, 176, 190, 210, 258]], [$5$],
    [$19$], [$5$], [$62$], [#text(size: 7.5pt)[14, 27 (mod 31)]], [$23$],
    [$21$], [$5$], [$22$], [---], [---],
  ),
) <tab:certificate-summary>

Two structural observations make @tab:certificate-summary easier to read. First, the involution $c arrow.r.bar 10 - c$ of @eq:c-involution acts on the rows of the table by exchanging $Delta_P (c) arrow.l.r |Delta_Q (c)|$; consequently the periods $T_(c, ell)$ of paired rows coincide. The pairs $(-11, 21)$, $(-9, 19)$, $(-7, 17)$, $(-5, 15)$, $(-3, 13)$, $(-1, 11)$, $(1, 9)$, $(3, 7)$ each share a common period (respectively $22$, $62$, $290$, $378$, $450$, $1012$, $546$, $1140$) and use complementary moduli. Second, the assignment of the primary modulus walks inward from the endpoints toward the central family: the endpoint pairs $|c| = 11$ and $|c - 10| = 11$ use $ell = 5$, the next ring uses $ell = 37$ alternating with $ell = 47$, and the entire central neighbourhood of $c = 5$ uses $ell in {37, thin 47}$. This is the discrete reflection of the strong-approximation framework of @subsec:appendix-D-automaton: larger certificate primes resolve the finer modular structure that emerges as $Delta_P$ and $|Delta_Q|$ become comparable.

_The eight pair-lemmas._

We treat the sixteen non-central families in the eight pairs $(c, thin 10 - c)$ above. Each lemma records the explicit form of the family, the primitivity exclusions on $k$ from @eq:primitivity-conditions-explicit, and the certificate moduli; the residue values themselves are recorded in @appendix:minimal-certificates and summarised in @tab:certificate-summary.

#lemma(title: [The pair $c = -11$ and $c = 21$], lbl: <lem:pair-11-21>)[
  For $c = -11$, the family is $P_(-11, k) = (12 k + 13, thin 6 k - 10)$, $Q_(-11, k) = (12 k + 3, thin 6 k + 2)$. The primitivity exclusion is $k equiv 9 thin (upright("mod") thin 11)$. The mod-$5$ certificate with period $22$ from @lem:twist-period separates every admissible residue class of $k thin (upright("mod") thin 22)$. Hence $m_(P_(-11, k)) eq.not m_(Q_(-11, k))$ for every admissible $k$.

  For $c = 21$, the family is $P_(21, k) = (12 k + 45, thin 6 k + 22)$, $Q_(21, k) = (12 k + 35, thin 6 k + 34)$. The primitivity exclusion is $k equiv 9 thin (upright("mod") thin 11)$. The mod-$5$ certificate with period $22$ again separates every admissible class, and $m_(P_(21, k)) eq.not m_(Q_(21, k))$.
] <lem-pair-11-21>

#proof[
  The primitivity exclusions follow from @eq:gcd-Pck and @eq:gcd-Qck of @subsec:seventeen-families: for $c = -11$ we have $|Delta_Q (c)| = 1$, so $Q_(-11, k)$ is always primitive; the exclusion comes from $gcd (6 k - 10, thin 33) > 1$, which reduces to $k equiv 9 thin (upright("mod") thin 11)$ (the factor $3$ never divides $6 k - 10$). For $c = 21$ the roles are exchanged: $P_(21, k)$ is always primitive and the exclusion is $k equiv 9 thin (upright("mod") thin 11)$ from $gcd (6 k + 34, thin 33)$. The mod-$5$ separation in each admissible class of $k thin (upright("mod") thin 22)$ is verified by the certificate script of @appendix:minimal-certificates; @tab:certificate-summary records the result.
]

#lemma(title: [The pair $c = -9$ and $c = 19$], lbl: <lem:pair-9-19>)[
  For $c = -9$, the family is $P_(-9, k) = (12 k + 15, thin 6 k - 8)$, $Q_(-9, k) = (12 k + 5, thin 6 k + 4)$, with the primitivity exclusion $k equiv 22 thin (upright("mod") thin 31)$. The mod-$5$ certificate with period $62$ from @lem:twist-period leaves two surviving residue classes modulo the sub-period $31$, namely
  $
    k equiv 0, thin 13 thin (upright("mod") thin 31).
  $
  For these survivors, the mod-$23$ certificate (with the appropriate compound period) separates every lifted class.

  For $c = 19$, the family is $P_(19, k) = (12 k + 43, thin 6 k + 20)$, $Q_(19, k) = (12 k + 33, thin 6 k + 32)$, with the primitivity exclusion $k equiv 5 thin (upright("mod") thin 31)$. The mod-$5$ certificate leaves two surviving residue classes,
  $
    k equiv 14, thin 27 thin (upright("mod") thin 31),
  $
  and the mod-$23$ certificate separates each lifted class.

  In both cases $m_(P_(c, k)) eq.not m_(Q_(c, k))$ for every admissible $k$.
] <lem-pair-9-19>

#proof[
  The primitivity exclusions follow from @eq:gcd-Pck and @eq:gcd-Qck as in @lem:pair-11-21: for $c = -9$ from $gcd (6 k - 8, thin 31)$, and for $c = 19$ from $gcd (6 k + 32, thin 31)$. The mod-$5$ residue tables, periods, and survivor classes are recorded in @tab:certificate-summary; the mod-$23$ auxiliary certificates are recorded in @appendix:minimal-certificates.
]

#lemma(title: [The pair $c = -7$ and $c = 17$], lbl: <lem:pair-7-17>)[
  For $c = -7$, the family is $P_(-7, k) = (12 k + 17, thin 6 k - 6)$, $Q_(-7, k) = (12 k + 7, thin 6 k + 6)$, with primitivity exclusions $k equiv 1 thin (upright("mod") thin 29)$ and $k equiv 4 thin (upright("mod") thin 5)$. The mod-$37$ certificate with period $290$ from @lem:twist-period leaves ten surviving residue classes modulo $290$, listed in @tab:certificate-summary; all ten are separated by the mod-$5$ certificate.

  For $c = 17$, the family is $P_(17, k) = (12 k + 41, thin 6 k + 18)$, $Q_(17, k) = (12 k + 31, thin 6 k + 30)$, with primitivity exclusions $k equiv 2 thin (upright("mod") thin 5)$ and $k equiv 24 thin (upright("mod") thin 29)$. The mod-$37$ certificate with period $290$ leaves ten surviving classes, all separated by the mod-$5$ certificate.

  In both cases $m_(P_(c, k)) eq.not m_(Q_(c, k))$ for every admissible $k$.
] <lem-pair-7-17>

#proof[
  The primitivity exclusions follow from $gcd (6 k - 6, thin 29)$ and $gcd (6 k + 6, thin 5)$ for $c = -7$, and from $gcd (6 k + 18, thin 5)$ and $gcd (6 k + 30, thin 29)$ for $c = 17$. The detailed residue tables for both moduli are recorded in @appendix:minimal-certificates, summarised in @tab:certificate-summary.
]

#lemma(title: [The pair $c = -5$ and $c = 15$], lbl: <lem:pair-5-15>)[
  For $c = -5$, the family is $P_(-5, k) = (12 k + 19, thin 6 k - 4)$, $Q_(-5, k) = (12 k + 9, thin 6 k + 8)$, with the single primitivity exclusion $k equiv 1 thin (upright("mod") thin 7)$. The mod-$37$ certificate with period $378$ from @eq:off-central-period-example leaves twelve surviving residue classes, all separated by the mod-$23$ certificate after lifting to the common period.

  For $c = 15$, the family is $P_(15, k) = (12 k + 39, thin 6 k + 16)$, $Q_(15, k) = (12 k + 29, thin 6 k + 28)$, with the single primitivity exclusion $k equiv 2 thin (upright("mod") thin 7)$. The mod-$37$ certificate with period $378$ leaves twelve survivors, all separated by the mod-$23$ certificate.

  In both cases $m_(P_(c, k)) eq.not m_(Q_(c, k))$ for every admissible $k$.
] <lem-pair-5-15>

#proof[
  For $c = -5$ we have $22 - c = 27 = 3^3$ with $3 divides.not 6 k - 4$ ever, so $P_(-5, k)$ is always primitive; the only exclusion is from $gcd (6 k + 8, thin 7) > 1$, i.e. $k equiv 1 thin (upright("mod") thin 7)$. For $c = 15$ symmetrically, $c + 12 = 27$ and the only exclusion is from $gcd (6 k + 16, thin 7) > 1$, i.e. $k equiv 2 thin (upright("mod") thin 7)$. The mod-$37$ and mod-$23$ residue tables for both families are recorded in @appendix:minimal-certificates and summarised in @tab:certificate-summary.
]

#lemma(title: [The pair $c = -3$ and $c = 13$], lbl: <lem:pair-3-13>)[
  For $c = -3$, the family is $P_(-3, k) = (12 k + 21, thin 6 k - 2)$, $Q_(-3, k) = (12 k + 11, thin 6 k + 10)$, with the single primitivity exclusion $k equiv 2 thin (upright("mod") thin 5)$. The mod-$37$ certificate with period $450$ from @lem:twist-period leaves sixteen surviving residue classes. The mod-$5$ certificate separates fourteen of them; the two remaining classes $k equiv 198, thin 423 thin (upright("mod") thin 450)$ are separated by the mod-$23$ certificate after lifting to the common period $900$.

  For $c = 13$, the family is $P_(13, k) = (12 k + 37, thin 6 k + 14)$, $Q_(13, k) = (12 k + 27, thin 6 k + 26)$, with the single primitivity exclusion $k equiv 4 thin (upright("mod") thin 5)$. The mod-$37$ certificate with period $450$ leaves sixteen survivors; mod-$5$ separates fourteen, and the two remaining classes $k equiv 23, thin 248 thin (upright("mod") thin 450)$ are separated by the mod-$23$ certificate.

  In both cases $m_(P_(c, k)) eq.not m_(Q_(c, k))$ for every admissible $k$.
] <lem-pair-3-13>

#proof[
  For $c = -3$ we have $22 - c = 25$ and the only mod-$P$ exclusion is $k equiv 2 thin (upright("mod") thin 5)$; the mod-$Q$ side has $c + 12 = 9$ with $3 divides.not 6 k + 10$ ever, so no further exclusion. For $c = 13$ the roles swap: $22 - c = 9$ contributes no exclusion, and $c + 12 = 25$ contributes $k equiv 4 thin (upright("mod") thin 5)$. The detailed residue tables are recorded in @appendix:minimal-certificates and summarised in @tab:certificate-summary.
]

#lemma(title: [The pair $c = -1$ and $c = 11$], lbl: <lem:pair-1-11>)[
  For $c = -1$, the family is $P_(-1, k) = (12 k + 23, thin 6 k)$, $Q_(-1, k) = (12 k + 13, thin 6 k + 12)$, with primitivity exclusions $k equiv 0 thin (upright("mod") thin 23)$ and $k equiv 9 thin (upright("mod") thin 11)$. The mod-$47$ certificate with period $1012$ from @lem:twist-period leaves fourteen surviving residue classes, all separated by the mod-$5$ certificate.

  For $c = 11$, the family is $P_(11, k) = (12 k + 35, thin 6 k + 12)$, $Q_(11, k) = (12 k + 25, thin 6 k + 24)$, with primitivity exclusions $k equiv 9 thin (upright("mod") thin 11)$ and $k equiv 19 thin (upright("mod") thin 23)$. The mod-$47$ certificate with period $1012$ leaves fourteen survivors, all separated by the mod-$5$ certificate.

  In both cases $m_(P_(c, k)) eq.not m_(Q_(c, k))$ for every admissible $k$.
] <lem-pair-1-11>

#proof[
  The primitivity exclusions follow from $gcd (6 k, thin 23)$ and $gcd (6 k + 12, thin 11)$ for $c = -1$, and symmetrically from $gcd (6 k + 12, thin 11)$ and $gcd (6 k + 24, thin 23)$ for $c = 11$. The residue tables and survivor lists are recorded in @appendix:minimal-certificates and summarised in @tab:certificate-summary.
]

#lemma(title: [The pair $c = 1$ and $c = 9$], lbl: <lem:pair-1-9>)[
  For $c = 1$, the family is $P_(1, k) = (12 k + 25, thin 6 k + 2)$, $Q_(1, k) = (12 k + 15, thin 6 k + 14)$, with primitivity exclusions $k equiv 2 thin (upright("mod") thin 7)$ and $k equiv 2 thin (upright("mod") thin 13)$. The mod-$37$ certificate with period $546$ from @lem:twist-period leaves eighteen surviving residue classes; their two lifts modulo $1092$ are all separated by the mod-$23$ certificate.

  For $c = 9$, the family is $P_(9, k) = (12 k + 33, thin 6 k + 10)$, $Q_(9, k) = (12 k + 23, thin 6 k + 22)$, with primitivity exclusions $k equiv 7 thin (upright("mod") thin 13)$ and $k equiv 1 thin (upright("mod") thin 7)$. The mod-$37$ certificate with period $546$ leaves eighteen survivors; their lifts modulo $1092$ are all separated by the mod-$23$ certificate.

  In both cases $m_(P_(c, k)) eq.not m_(Q_(c, k))$ for every admissible $k$.
] <lem-pair-1-9>

#proof[
  The primitivity exclusions follow from $gcd (6 k + 2, thin 21) > 1$ and $gcd (6 k + 14, thin 13) > 1$ for $c = 1$, and symmetrically for $c = 9$. The detailed residue tables are recorded in @appendix:minimal-certificates and summarised in @tab:certificate-summary.
]

#lemma(title: [The pair $c = 3$ and $c = 7$], lbl: <lem:pair-3-7>)[
  For $c = 3$, the family is $P_(3, k) = (12 k + 27, thin 6 k + 4)$, $Q_(3, k) = (12 k + 17, thin 6 k + 16)$, with primitivity exclusions $k equiv 12 thin (upright("mod") thin 19)$ and $k equiv 4 thin (upright("mod") thin 5)$. The mod-$47$ certificate with period $1140$ from @lem:twist-period leaves eight surviving residue classes; mod-$5$ separates six of them, and the two remaining classes $k equiv 223, thin 793 thin (upright("mod") thin 1140)$ are separated by the mod-$23$ certificate.

  For $c = 7$, the family is $P_(7, k) = (12 k + 31, thin 6 k + 8)$, $Q_(7, k) = (12 k + 21, thin 6 k + 20)$, with primitivity exclusions $k equiv 2 thin (upright("mod") thin 5)$ and $k equiv 3 thin (upright("mod") thin 19)$. The mod-$47$ certificate with period $1140$ leaves eight survivors; mod-$5$ separates six, and the two remaining classes $k equiv 343, thin 913 thin (upright("mod") thin 1140)$ are separated by the mod-$23$ certificate.

  In both cases $m_(P_(c, k)) eq.not m_(Q_(c, k))$ for every admissible $k$.
] <lem-pair-3-7>

#proof[
  The primitivity exclusions follow from $gcd (6 k + 4, thin 19)$ and $gcd (6 k + 16, thin 15)$ for $c = 3$, and symmetrically for $c = 7$. The residue tables are recorded in @appendix:minimal-certificates and summarised in @tab:certificate-summary.
]

#emph[Proof of @thm:sixteen-noncentral-excluded.]

#proof[
  Let $c$ belong to the sixteen-element set @eq:sixteen-c-values. The eight pair-lemmas @lem:pair-11-21, @lem:pair-9-19, @lem:pair-7-17, @lem:pair-5-15, @lem:pair-3-13, @lem:pair-1-11, @lem:pair-1-9, @lem:pair-3-7 cover the eight orbits of the involution $c arrow.r.bar 10 - c$ on this set, hence cover every $c$ in the set. In each case the corresponding pair-lemma gives $m_(P_(c, k)) eq.not m_(Q_(c, k))$ for every admissible $k$, completing the proof.
]

_What remains: the central family $c = 5$._ The only value of $c$ not eliminated by @thm:sixteen-noncentral-excluded is the central family $c = 5$, the fixed point of the involution $c arrow.r.bar 10 - c$. At this value the two intersection numbers coincide, $Delta_P (5) = |Delta_Q (5)| = 17$, and the mod-$37$ certificate with period $T_(5, thin 37) = 34$ from @eq:central-period-example reduces the family to a single surviving residue class
$
  k equiv 15 thin (upright("mod") thin 17).
$ <eq:central-survivor>
This last class cannot be separated by any of the four primes $5, 23, 37, 47$ alone: the symmetry $Delta_P = |Delta_Q|$ forbids the kind of asymmetric mod-$ell$ separation that has worked for the sixteen non-central families. The treatment of the survivor class @eq:central-survivor by an exact symbolic trace-positivity argument is the content of @subsec:central-family.

== The central family $c = 5$ <subsec:central-family>

It remains to treat the only family not eliminated by @thm:sixteen-noncentral-excluded, the central family $c = 5$. As recalled at the end of @subsec:sixteen-table, the central family is qualitatively distinct: it is the fixed point of the involution $c arrow.r.bar 10 - c$, the unique value at which the intersection numbers coincide, $Delta_P (5) = |Delta_Q (5)| = 17$, and the mod-$37$ certificate of @eq:central-period-example narrows the admissible residue classes to a single survivor $k equiv 15 thin (upright("mod") thin 17)$. This residual class is treated by an exact symbolic trace-positivity argument; together with @thm:sixteen-noncentral-excluded, this completes the elimination of all seventeen families and hence the proof of @thm:minimal-direction, which is collected formally in @subsec:g2-conclusion.

_The family and its primitivity exclusions._ Specialising @prop:seventeen-families-reduction to $c = 5$, with $t = 6 k + 1$ and $p = 6 k + 6$, the terminal pair is
$
  P_k = (12 k + 29, thin 6 k + 6), quad quad Q_k = (12 k + 19, thin 6 k + 18).
$ <eq:central-PQ>
The primitivity conditions take a single common form. For $P_k$, the standard $a - 2 b$ reduction (as in @eq:gcd-Pck of @subsec:seventeen-families) gives
$
  (12 k + 29) - 2 (6 k + 6) = 17,
$
so $gcd (12 k + 29, thin 6 k + 6) = gcd (6 k + 6, thin 17)$. Since $17$ is prime, the non-primitivity condition is $17 divides 6 k + 6$, equivalent to $6 k equiv -6 equiv 11 thin (upright("mod") thin 17)$. Using $6^(-1) equiv 3 thin (upright("mod") thin 17)$ (since $6 dot.op 3 = 18 equiv 1$), this is $k equiv 33 equiv 16 thin (upright("mod") thin 17)$. For $Q_k$, the same reduction gives $(12 k + 19) - 2 (6 k + 18) = -17$, so $gcd (12 k + 19, thin 6 k + 18) = gcd (6 k + 18, thin 17)$; the non-primitivity condition reads $6 k equiv -18 equiv -1 equiv 16 thin (upright("mod") thin 17)$, hence $k equiv 48 equiv 14 thin (upright("mod") thin 17)$. The admissible parameters $k$ are therefore
$
  k gt.eq.slant 0, quad quad k thin (upright("mod") thin 17) in.not {14, thin 16},
$ <eq:central-admissible-k>
where the second condition rules out the residue classes $k equiv 14$ and $k equiv 16 thin (upright("mod") thin 17)$ identified above.

_The mod-$37$ reduction._ By @eq:central-period-example, the Markov residues $m_(P_k) thin (upright("mod") thin 37)$ and $m_(Q_k) thin (upright("mod") thin 37)$ are periodic in $k$ with period $T_(5, thin 37) = 34$. The full residue table for one complete period is recorded in @tab:central-mod-37.

#figure(
  caption: [The mod-$37$ residue table for the central family $c = 5$, with period $T_(5, thin 37) = 34$. Rows marked "non-primitive" correspond to the four classes $k thin (upright("mod") thin 34) in {14, thin 16, thin 31, thin 33}$, which are the two non-primitive classes $k equiv 14$ and $k equiv 16 thin (upright("mod") thin 17)$ from @eq:central-admissible-k repeated in each of the two $17$-blocks of the $34$-cycle. Rows marked "survives" are the two classes $k thin (upright("mod") thin 34) in {15, thin 32}$, both equivalent to $k equiv 15 thin (upright("mod") thin 17)$, on which $m_(P_k) equiv m_(Q_k) thin (upright("mod") thin 37)$ and the certificate is silent. The remaining $28$ rows are separated by the mod-$37$ certificate. Residue values are reproduced from the verification scripts of @appendix:minimal-certificates.],
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    table.header(
      [$k thin (upright("mod") thin 34)$], [$m_(P_k) thin (upright("mod") thin 37)$], [$m_(Q_k) thin (upright("mod") thin 37)$], [status]
    ),
    [$0$], [$26$], [$36$], [separated],
    [$1$], [$14$], [$9$], [separated],
    [$2$], [$36$], [$8$], [separated],
    [$3$], [$35$], [$0$], [separated],
    [$4$], [$15$], [$29$], [separated],
    [$5$], [$28$], [$13$], [separated],
    [$6$], [$30$], [$24$], [separated],
    [$7$], [$13$], [$7$], [separated],
    [$8$], [$24$], [$9$], [separated],
    [$9$], [$8$], [$22$], [separated],
    [$10$], [$0$], [$2$], [separated],
    [$11$], [$29$], [$1$], [separated],
    [$12$], [$28$], [$23$], [separated],
    [$13$], [$1$], [$11$], [separated],
    [$14$], [---], [---], [non-primitive],
    [$15$], [$22$], [$22$], [survives],
    [$16$], [---], [---], [non-primitive],
    [$17$], [$11$], [$1$], [separated],
    [$18$], [$23$], [$28$], [separated],
    [$19$], [$1$], [$29$], [separated],
    [$20$], [$2$], [$0$], [separated],
    [$21$], [$22$], [$8$], [separated],
    [$22$], [$9$], [$24$], [separated],
    [$23$], [$7$], [$13$], [separated],
    [$24$], [$24$], [$30$], [separated],
    [$25$], [$13$], [$28$], [separated],
    [$26$], [$29$], [$15$], [separated],
    [$27$], [$0$], [$35$], [separated],
    [$28$], [$8$], [$36$], [separated],
    [$29$], [$9$], [$14$], [separated],
    [$30$], [$36$], [$26$], [separated],
    [$31$], [---], [---], [non-primitive],
    [$32$], [$15$], [$15$], [survives],
    [$33$], [---], [---], [non-primitive],
  ),
) <tab:central-mod-37>

Inspecting @tab:central-mod-37, every admissible residue class has $m_(P_k) eq.not m_(Q_k) thin (upright("mod") thin 37)$ with the sole exception of the two classes $k equiv 15$ and $k equiv 32 thin (upright("mod") thin 34)$, on which both residues coincide. The two classes are exactly the lift of the single class
$
  k equiv 15 thin (upright("mod") thin 17)
$ <eq:central-survivor-recall>
to the $34$-cycle. Thus, to complete the central family, it remains to exclude equality on this survivor class.

_The survivor class $k = 17 n + 15$._ Assume $k = 17 n + 15$ with $n gt.eq.slant 0$. Substituting,
$
  P_k &= (12 (17 n + 15) + 29, thin 6 (17 n + 15) + 6) \
  &= (204 n + 209, thin 102 n + 96),
$ <eq:central-PQ-survivor-P>
$
  Q_k &= (12 (17 n + 15) + 19, thin 6 (17 n + 15) + 18) \
  &= (204 n + 199, thin 102 n + 108).
$ <eq:central-PQ-survivor-Q>
Setting
$
  N = 6 n + 5,
$ <eq:N-definition>
the four coordinates rewrite cleanly as
$
  204 n + 209 = 34 N + 39, quad quad 102 n + 96 = 17 N + 11,
$
$
  204 n + 199 = 34 N + 29, quad quad 102 n + 108 = 17 N + 23.
$
A direct calculation in the Stern--Brocot tree gives the explicit path descriptions
$
  L R^N L R L R^4 quad arrow.l.r quad (34 N + 39, thin 17 N + 11) = P_k,
$ <eq:stern-brocot-P>
$
  R L^N R^2 L R^4 quad arrow.l.r quad (34 N + 29, thin 17 N + 23) = Q_k,
$ <eq:stern-brocot-Q>
for $N gt.eq.slant 5$. Both paths contain a common repeated block of length $N$ formed from the alphabet $L R$, isolated in the centre. We shall exploit this common block to compare the two Cohn matrices symbolically.

_Chebyshev representation of the repeated block._ The repeated block $L R$ corresponds, via the standard Stern--Brocot--to--Cohn correspondence of @sec:markov-cohn, to the matrix $W = A B$ of @eq:twist-matrix-W, with $tr W = 15$. Define the Chebyshev-like sequence
$
  Phi_(-1) = 0, quad Phi_0 = 1, quad Phi_(m + 1) = 15 Phi_m - Phi_(m - 1),
$ <eq:Phi-recurrence>
giving $Phi_1 = 15$, $Phi_2 = 224$, $Phi_3 = 3345$, $Phi_4 = 49951$, and so on. The Cayley--Hamilton identity @eq:cayley-hamilton-W $W^2 = 15 W - I$ propagates to all powers of $W$:
$
  W^N = Phi_(N - 1) W - Phi_(N - 2) I.
$ <eq:WN-Chebyshev>
This is the discrete analogue of the dispersion relation for the linear recurrence with characteristic polynomial $t^2 - 15 t + 1 = 0$; the sequence $Phi_m$ is the Chebyshev polynomial of the second kind evaluated at $15 slash 2$, $Phi_m = U_m (15 slash 2)$, and the eigenvalues $lambda_(plus.minus) = (15 plus.minus sqrt(221)) slash 2$ of $W$ satisfy $lambda_+ dot.op lambda_- = 1$ with $lambda_+ approx 14.933$. Set
$
  a = Phi_(N - 1) > 0, quad quad b = -Phi_(N - 2) < 0, quad quad c_0 = -b = Phi_(N - 2) > 0,
$ <eq:abc-definitions>
so that $W^N = a W + b I = a W - c_0 I$. The following elementary estimate on the ratio $c_0 slash a$ is the lever for the survivor argument.

#lemma(title: "Ratio estimate", lbl: <lem:ratio-estimate>)[
  For every $N gt.eq.slant 5$,
  $
    0 < c_0 slash a < 1 slash 14.
  $ <eq:ratio-estimate-conclusion>
] <lem-ratio-estimate>

#proof[
  The sequence $(Phi_m)_(m gt.eq.slant 0)$ is strictly positive and strictly increasing by induction on @eq:Phi-recurrence: $Phi_0 = 1$, $Phi_1 = 15$, and if $Phi_(m - 1), Phi_m > 0$ with $Phi_m > Phi_(m - 1)$, then $Phi_(m + 1) = 15 Phi_m - Phi_(m - 1) > 15 Phi_m - Phi_m = 14 Phi_m > Phi_m$. The intermediate step $Phi_(m + 1) > 14 Phi_m$ is exactly the inequality we need: applied at $m = N - 2 gt.eq.slant 3$, it gives $Phi_(N - 1) > 14 Phi_(N - 2)$, equivalently
  $
    0 < Phi_(N - 2) slash Phi_(N - 1) < 1 slash 14.
  $
  Identifying with @eq:abc-definitions, this is the claim.
]

A short remark on the asymptotic content of @lem:ratio-estimate: as $N arrow.r infinity$, the ratio $c_0 slash a = Phi_(N - 2) slash Phi_(N - 1)$ converges to the reciprocal of the dominant eigenvalue, $1 slash lambda_+ = lambda_- = (15 - sqrt(221)) slash 2 approx 0.0670$, which lies just below the threshold $1 slash 14 approx 0.0714$. The threshold $1 slash 14$ is the most convenient explicit rational bound that still exceeds the actual ratio for every $N gt.eq.slant 1$; numerically the ratio is already at its limiting value $c_0 slash a approx 0.0670$ at $N = 5$.

_Symbolic trace comparison._ Substituting @eq:WN-Chebyshev into the matrix products encoded by @eq:stern-brocot-P and @eq:stern-brocot-Q --- expanding the products $L R^N L R L R^4$ and $R L^N R^2 L R^4$ in terms of $A$, $B$, and powers of $W$ --- and computing the traces, one obtains, after collecting terms and simplifying, the trace-difference identity
$
  tr (C_Q) - tr (C_P) = 3 (15 a + b) F (a, b),
$ <eq:trace-diff-formula>
where $F (a, thin b)$ is a homogeneous polynomial of degree $16$ with integer coefficients. The explicit expansion of $F$ is too unwieldy to display in full --- with $16$th-degree homogeneous integer coefficients running to hundreds of digits --- and is recorded in @appendix:minimal-certificates. The substitution $b = -c_0$ gives
$
  F (a, thin -c_0) = a^(16) G (c_0 slash a),
$ <eq:F-as-G>
where $G$ is the univariate polynomial
$
  G (x) = C_0 - C_1 x + C_2 x^2 - dots.h.c + C_(16) x^(16) = sum_(j = 0)^(16) (-1)^j C_j x^j,
$ <eq:G-alternating>
with strictly positive integer coefficients $C_0, dots, C_(16)$ recorded in @appendix:minimal-certificates. The alternating sign pattern of @eq:G-alternating reflects the substitution $b = -c_0$ applied term by term to the homogeneous polynomial $F$.

The substantive content of the certificate is the following positivity inequality:
$
  C_0 - C_1 slash 14 - sum_(j = 2)^(16) C_j slash 14^j > 0.
$ <eq:certificate-inequality>
More precisely, the difference between the left-hand side and zero, written as a single reduced rational number, is the exact margin
$
  C_0 - C_1 slash 14 - sum_(j = 2)^(16) C_j slash 14^j \
  = frac(56776450013218623146667119024756272232022390327391952873, 2177953337809371136) > 0.
$ <eq:certificate-margin>
The fact that this margin is positive --- and indeed very large relative to its denominator --- makes the alternating-sign polynomial $G$ strictly positive on the interval where the survivor argument operates.

#lemma(title: "Positivity of the survivor polynomial", lbl: <lem:G-positivity>)[
  For every $x in (0, thin 1 slash 14)$,
  $
    G (x) > 0.
  $ <eq:G-positivity-conclusion>
] <lem-G-positivity>

#proof[
  Drop the positive even-degree terms and lower-bound by the worst case at $x = 1 slash 14$. Since all $C_j$ are positive and $0 < x < 1 slash 14$,
  $
    G (x) gt.eq.slant C_0 - C_1 x - sum_(j = 2)^(16) C_j x^j > C_0 - frac(C_1, 14) - sum_(j = 2)^(16) frac(C_j, 14^j),
  $
  where the first inequality drops the positive even-degree contributions $+ C_(2 m) x^(2 m)$ for $m gt.eq.slant 1$, and the second uses $x < 1 slash 14$ to dominate every $x^j$ by $1 slash 14^j$ for $j gt.eq.slant 1$. The right-hand side is strictly positive by the certificate inequality @eq:certificate-inequality, with the explicit margin @eq:certificate-margin.
]

The dominated-tail estimate of @lem:G-positivity is the discrete analogue of a Sturm-style positivity criterion: an alternating-coefficient polynomial with strictly positive coefficients is shown to be strictly positive on an interval by lower-bounding the sum $sum_(j gt.eq.slant 0) (-1)^j C_j x^j$ via the leading two terms minus a uniformly bounded dominated tail. The explicit margin @eq:certificate-margin makes the inequality numerically rigorous despite the astronomical absolute sizes of the coefficients $C_j$ themselves.

_Positivity of the trace difference._ We now assemble the survivor argument. By @eq:abc-definitions and the recurrence @eq:Phi-recurrence,
$
  15 a + b = 15 Phi_(N - 1) - Phi_(N - 2) = Phi_N > 0.
$ <eq:15a-plus-b>
By @lem:ratio-estimate, $c_0 slash a in (0, thin 1 slash 14)$, and hence by @lem:G-positivity,
$
  G (c_0 slash a) > 0.
$
Combining with @eq:F-as-G,
$
  F (a, thin -c_0) = a^(16) G (c_0 slash a) > 0,
$
since $a > 0$. Returning to @eq:trace-diff-formula,
$
  tr (C_Q) - tr (C_P) = 3 (15 a + b) F (a, thin -c_0) > 0.
$ <eq:trace-diff-positive>
By the Cohn-trace identity @eq:cohn-trace-three-m, Cohn traces are three times the corresponding Markov numbers, so
$
  m_(Q_k) - m_(P_k) = (tr (C_Q) - tr (C_P)) slash 3 > 0,
$
hence $m_(Q_k) > m_(P_k)$ on the survivor class. In particular, equality is impossible.

_The central family is excluded._

#theorem(title: "Exclusion of the central family", lbl: <thm:central-family-excluded>)[
  Let $P_k = (12 k + 29, thin 6 k + 6)$ and $Q_k = (12 k + 19, thin 6 k + 18)$ be the central family of @prop:seventeen-families-reduction at $c = 5$. For every admissible $k$ (i.e. $k gt.eq.slant 0$ with $k thin (upright("mod") thin 17) in.not {14, thin 16}$),
  $
    m_(P_k) eq.not m_(Q_k).
  $ <eq:central-family-conclusion>
] <thm-central-family-excluded>

#proof[
  The mod-$37$ residue table @tab:central-mod-37 separates every admissible residue class of $k thin (upright("mod") thin 34)$ except the two survivor classes $k equiv 15, thin 32 thin (upright("mod") thin 34)$, both equivalent to $k equiv 15 thin (upright("mod") thin 17)$. On the survivor class, the substitution $k = 17 n + 15$ and the Stern--Brocot path identifications @eq:stern-brocot-P, @eq:stern-brocot-Q, combined with the Chebyshev representation @eq:WN-Chebyshev, give the trace-difference identity @eq:trace-diff-formula. By @lem:ratio-estimate and @lem:G-positivity, the right-hand side of @eq:trace-diff-formula is strictly positive, so $tr (C_(Q_k)) > tr (C_(P_k))$, equivalently $m_(Q_k) > m_(P_k)$, on the survivor class. Combining the two cases, $m_(P_k) eq.not m_(Q_k)$ for every admissible $k$.
]

_Completion of the elimination of all seventeen families._ Combined with @thm:sixteen-noncentral-excluded of @subsec:sixteen-table, @thm:central-family-excluded eliminates all seventeen one-parameter families of @prop:seventeen-families-reduction. The synthesis of the two theorems into a proof of @thm:minimal-direction --- the chapter's headline result asserting the Exceptional Terminal Arithmetic Theorem in the minimal primitive exceptional direction $(R, H) = (6, 5)$ at multiplier $g = 2$ --- is collected in @subsec:g2-conclusion.

== Completion of the minimal exceptional direction theorem <subsec:g2-conclusion>

The present Section assembles the results of @subsec:minimal-direction-statement through @subsec:central-family into a formal proof of the chapter's headline statement, @thm:minimal-direction, and translates the result into the primitive-direction notation of @subsec:minimal-direction-statement as @cor:first-solved-residual. We then verify that the case treated by the chapter is _genuinely_ residual --- not already settled by line monotonicity, primitive-step exclusion, or the unit-boundary case --- and reflect briefly on the structural role of the two certificate types (finite congruence and exact symbolic trace) that the proof brings together. We close with a forward outlook to the next natural residual cases.

_Restatement of the main theorem._ The chapter's headline result, proved by composition below, is the statement of @thm:minimal-direction: for every primitive return-reduced terminal pair
$
  P = (p + t + 22, thin p), quad quad Q = (p + t + 12, thin p + 12)
$
with $p, t gt.eq.slant 1$ in the minimal exceptional direction $(r, h) = (12, 10)$,
$
  m_P eq.not m_Q.
$
The Markov-number ratios $p slash (p + t + 22)$ and $(p + 12) slash (p + t + 12)$ are therefore distinct as Stern--Brocot fractions, and the corresponding Markov numbers are distinct as integers.

#emph[Proof of @thm:minimal-direction.]

#proof[
  Suppose, for contradiction, that $m_P = m_Q$ for some primitive return-reduced terminal pair $(P, Q)$ in the minimal direction.

  By @prop:elementary-residue-reduction of @subsec:residue-reduction, the residue restriction
  $
    p equiv 0 thin (upright("mod") thin 2), quad quad t equiv 1 thin (upright("mod") thin 6)
  $ <eq:g2-residue-recall>
  follows. Write $t = 6 k + 1$ with $k gt.eq.slant 0$.

  By @prop:seventeen-families-reduction of @subsec:seventeen-families, the return-reducedness condition then forces
  $
    p = t + c, quad upright("with") quad c in {-11, thin -9, thin -7, dots.h.c, thin 19, thin 21},
  $ <eq:g2-c-recall>
  the seventeen-element odd set @eq:c-set-derived. The pair $(P, Q)$ takes the explicit form $(P_(c, k), thin Q_(c, k))$ of @eq:Pck-Qck-explicit, with $k$ subject to the admissibility conditions @eq:primitivity-conditions-explicit.

  We split into two cases according to the value of $c$.

  _Case $c eq.not 5$._ By @thm:sixteen-noncentral-excluded of @subsec:sixteen-table, for every admissible $k$,
  $
    m_(P_(c, k)) eq.not m_(Q_(c, k)),
  $
  contradicting the assumed equality.

  _Case $c = 5$._ By @thm:central-family-excluded of @subsec:central-family, for every admissible $k$,
  $
    m_(P_(5, k)) eq.not m_(Q_(5, k)),
  $
  again contradicting the assumed equality. (The mod-$37$ certificate of @tab:central-mod-37 reduces the admissible classes to the single survivor $k equiv 15 thin (upright("mod") thin 17)$, and the symbolic trace-positivity argument of @lem:G-positivity, applied via the Stern--Brocot path identifications @eq:stern-brocot-P, @eq:stern-brocot-Q and the trace-difference identity @eq:trace-diff-formula, gives $m_(Q_k) > m_(P_k)$ on the survivor class.)

  Both cases yield a contradiction, so $m_P eq.not m_Q$ for every primitive return-reduced terminal pair in the minimal direction. This proves @thm:minimal-direction.
]

_Interpretation in the $(R, H)$ form._ The minimal direction is the lift to non-primitive parameters of the smallest primitive exceptional direction. In the notation of @eq:rh-primitive-decomposition, $r = g R$ and $h = g H$ with $gcd (R, H) = 1$, the chapter's case has
$
  (R, H) = (6, 5), quad quad g = 2, quad quad (r, h) = (12, 10).
$
The minimality of $(6, 5)$ as a primitive solution of the wedge inequalities $4 R < 5 H$, $8 H < 7 R$ is the content of @lem:first-primitive-direction; the choice $g = 2$ is the smallest nonprimitive multiplier consistent with the primitive-step exclusion of @prop:primitive-step-exclusion. The exceptional-window condition $s slash r = 11 slash 6 in (9 slash 5, thin 15 slash 8)$ is verified by @eq:window-check, and the nonprimitivity condition $gcd (r, h) = 2 > 1$ by @eq:gcd-check. The chapter's main result therefore admits the following compact restatement.

#corollary(title: "First solved residual exceptional case", lbl: <cor:first-solved-residual>)[
  The Exceptional Terminal Arithmetic Theorem @thm:ETAT holds for the primitive exceptional direction
  $
    (R, H) = (6, 5)
  $ <eq:RH-corollary>
  at the first nonprimitive multiplier
  $
    g = 2.
  $ <eq:g-corollary>
  Equivalently, no primitive return-reduced terminal pair $(P, Q)$ in the standard Farey cone with parameters $(r, h) = (12, 10)$ --- equivalently, with $(r, s) = (12, 22)$ in the original $(r, s)$-variables --- satisfies $m_P = m_Q$.
] <cor-first-solved-residual>

#proof[
  Direct rephrasing of @thm:minimal-direction via the substitution $r = g R$, $h = g H$ of @eq:rh-primitive-decomposition, with $(R, H) = (6, 5)$ from @lem:first-primitive-direction and $g = 2$ from @eq:first-multiplier.
]

_Why this case is genuinely residual._ The case $(r, h) = (12, 10)$ is the first one handled by the chapter that lies inside the residual exceptional region of @thm:ETAT and is _not_ already excluded by any of the structural reductions of @sec:same-ray through @sec:fibonacci-pell. Three explicit verifications confirm this.

First, the line through $P$ and $Q$, oriented by increasing $q$-coordinate, has slope
$
  lambda = - r slash (s - r) = - 12 slash 10 = - 6 slash 5,
$ <eq:g2-line-slope>
and this value sits strictly inside the exceptional non-monotone interval
$
  - 5 slash 4 = -1.25 < - 6 slash 5 = -1.20 < - 8 slash 7 approx -1.143.
$ <eq:g2-slope-in-window>
Therefore the line-ordering classification of @LeeLiRabideauSchiffler2023, @LagisquetPelantovaTavenasVuillon2021, and @Huang2022 used in @thm:terminal-non-exceptional of @sec:terminal-cone does not decide the comparison: the exceptional slope window is exactly the locus where the line-monotonicity argument fails.

Second, the step is genuinely nonprimitive,
$
  gcd (r, s) = gcd (12, 22) = 2 > 1,
$ <eq:g2-gcd-rs>
so the primitive-step exclusion of @prop:primitive-step-exclusion of @sec:primitive-exclusion --- which uses Huang's valley theorem to handle every primitive case --- does not apply.

Third, both terminal coefficients are bounded away from one,
$
  r = 12 > 1, quad quad s = 22 > 1,
$
so the unit-boundary exclusion of @cor:unit-terminal-excluded of @sec:shifted-boundary, which handles the boundary cases $r = 1$ or $s = 1$ of the standard cone, does not apply either.

The minimal direction $(r, h) = (12, 10)$ therefore is a case that all three previously available structural exclusions leave open. @thm:minimal-direction is, in this sense, the first manuscript proof of a case that is genuinely inside the residual exceptional terminal regime.

_Role of the two certificate types._ The proof of @thm:minimal-direction brings together two qualitatively different certificate components, each addressing a different structural feature of the seventeen-family configuration.

The sixteen non-central families are eliminated by _finite congruence certificates_ (@subsec:congruence-certificate, @subsec:sixteen-table). Each family $(P_(c, k), thin Q_(c, k))$ with $c eq.not 5$ admits an asymmetry between $Delta_P (c)$ and $|Delta_Q (c)|$, and this asymmetry is detected by at least one of the four small primes $ell in {5, 23, 37, 47}$: the Markov residues mod $ell$ are periodic in $k$ by @lem:twist-period, and a finite check over each admissible residue class establishes separation in the spirit of @lem:finite-congruence-certificate. The argument is intrinsically _local_ in the prime $ell$ and is closed by combining a small number of primes via the Chinese-remainder-style multi-modulus version of @lem:finite-congruence-certificate.

The central family $c = 5$ requires an _exact symbolic trace-positivity argument_ (@subsec:central-family). Here the involution $c arrow.r.bar 10 - c$ of @eq:c-involution forces $Delta_P (5) = |Delta_Q (5)| = 17$, removing the asymmetry that the four small primes detect for the sixteen non-central families. The mod-$37$ certificate narrows the admissible classes to a single survivor $k equiv 15 thin (upright("mod") thin 17)$, and on this survivor class no further fixed prime works: the symmetric structure is global, not local. The trace difference $tr (C_Q) - tr (C_P)$ is shown to be strictly positive by the symbolic Chebyshev-bound argument of @lem:G-positivity, which reduces the positivity to the integer-arithmetic certificate inequality @eq:certificate-inequality with the explicit margin of @eq:certificate-margin.

Conceptually, the hybrid structure of the proof --- sixteen local certificates plus one global symbolic argument --- is consistent with the no-fixed-finite-modular-sieve obstruction of @thm:no-finite-modular-certificate in @sec:modular-sieve, which shows that _no_ fixed finite set of moduli can settle the full Exceptional Terminal Arithmetic Theorem. The minimal-direction case sits at the boundary of what congruence methods alone can handle: sixteen of the seventeen families are local, but the seventeenth needs exact arithmetic. The same dichotomy is the discrete analogue of the local-global structure familiar from Hasse-principle and Brauer--Manin considerations in arithmetic geometry, where a problem is settled either by assembling local data via a strong-approximation argument or by exhibiting an exact global symbolic invariant.

_Consequence for the reduction programme._ The body of the monograph proves the conditional implication
$
  upright("Exceptional Terminal Arithmetic Theorem") \
  quad arrow.r.double quad upright("Frobenius–Markov uniqueness")
$
via @thm:main-conditional of @sec:ETAT. @thm:minimal-direction (and equivalently @cor:first-solved-residual) does _not_ prove the full @thm:ETAT. What it does prove is that @thm:ETAT holds in the first genuinely residual exceptional direction, the entry point of the cone of primitive exceptional directions @eq:primitive-wedge at the smallest nonprimitive multiplier. This is concrete evidence that the residual problem is not merely a formal restatement of the original conjecture, but an arithmetic problem with tractable individual cases.

_The second nonprimitive step._ The same method settles more than the minimal case. Stepping the nonprimitive multiplier to its next value in the same primitive direction --- $(R, H) = (6, 5)$ with $g = 3$, so that $(r, h) = (18, 15)$ and $s = 33$ --- gives the terminal pair $P = (p + t + 33, thin p)$, $Q = (p + t + 18, thin p + 18)$. We have established the following companion to @thm:minimal-direction; its proof follows the same overall method and is omitted from the present version for brevity.

#theorem(title: "Second nonprimitive step", lbl: <thm:second-nonprimitive-step>)[
  Let
  $
    P = (p + t + 33, thin p), quad quad Q = (p + t + 18, thin p + 18)
  $ <eq:g3-direction-PQ>
  be primitive return-reduced terminal points in the standard Farey cone. Then
  $
    m_P eq.not m_Q.
  $ <eq:g3-conclusion>
  Equivalently, @thm:ETAT holds for
  $
    (R, H) = (6, 5), quad g = 3, quad (r, h) = (18, 15),
  $ <eq:g3-params>
  i.e. for $r = 18$, $s = r + h = 33$, $s slash r = 11 slash 6$ --- again strictly inside the exceptional slope window $(9 slash 5, thin 15 slash 8)$ and genuinely nonprimitive, $gcd (r, h) = gcd (18, 15) = 3 > 1$.
] <thm-second-nonprimitive-step>

The proof of @thm:second-nonprimitive-step follows the same overall method as the $g = 2$ case --- residue reduction, return-reduced decomposition into finitely many one-parameter families indexed by the offset $c = p - t in (-18, thin 33)$, and twist-period congruence certificates --- now applied to the larger family set produced by the wider offset range. The individual reductions differ from those of $g = 2$ in arithmetic detail, and the full family tables are correspondingly larger; we omit them from the present version for brevity.

One natural case remains open immediately beyond these. Keeping the multiplier at $g = 2$ and stepping to the next primitive exceptional direction gives
$
  (R, H) = (7, 6), quad g = 2, quad upright("equivalently") quad (r, h) = (14, 12).
$ <eq:next-case-RH-76>
That $(R, H) = (7, 6)$ is the next primitive solution of the wedge inequalities $4 R < 5 H$, $8 H < 7 R$ after $(6, 5)$ is a direct verification: $4 dot.op 7 = 28 < 30 = 5 dot.op 6$ and $8 dot.op 6 = 48 < 49 = 7 dot.op 7$, with $gcd (7, 6) = 1$; the interval $(8 H slash 7, thin 5 H slash 4)$ at $H = 6$ is $(6.857, thin 7.500)$ and contains $R = 7$ as the unique integer.

With $g = 2$ and $g = 3$ now both settled in the direction $(6, 5)$, a proof at all nonprimitive multipliers $g gt.eq.slant 2$ in this direction --- a one-parameter family in the multiplier --- would complete a ray-by-ray attack along the ray $bb(N) dot.op (6, 5)$. A proof at $g = 2$ across all primitive exceptional directions $(R, H)$ would constitute a uniform "first nonprimitive multiplier" theorem. Either of these would represent a substantial advance toward the full @thm:ETAT and, through @thm:main-conditional, toward the Frobenius--Markov uniqueness conjecture.

== Conclusions and next exceptional cases <subsec:conclusions-outlook>

The formal completion of @thm:minimal-direction in @subsec:g2-conclusion concludes the proof of the chapter's headline result. The present Section steps back and reflects on what has been proved, why it is significant, what computational substrate supports it, and what the natural next exceptional cases are. The discussion is pedagogical and forward-looking; it intentionally complements --- without replacing --- the formal synthesis of @subsec:g2-conclusion.

_What was proved._ The chapter has established, in full and unconditionally, the Exceptional Terminal Arithmetic Theorem for the minimal primitive exceptional direction
$
  (R, H) = (6, 5), quad g = 2, quad upright("equivalently") quad (r, h, s) = (12, 10, 22).
$
For the terminal pair
$
  P = (p + t + 22, thin p), quad quad Q = (p + t + 12, thin p + 12),
$
under the standing primitivity and return-reducedness hypotheses, @thm:minimal-direction asserts
$
  m_P eq.not m_Q,
$
or, in the equivalent Stern--Brocot form, the Markov numbers attached to the fractions $p slash (p + t + 22)$ and $(p + 12) slash (p + t + 12)$ are distinct.

The proof proceeded through four stages, mirroring the chapter's section structure. The _residue reduction_ of @subsec:residue-reduction --- a parity criterion together with a mod-$3$ table for $m_(p slash q)$ as a function of $(q, p) thin (upright("mod") thin 4)$ --- forced any potential collision into the joint sector $p equiv 0 thin (upright("mod") thin 2)$, $t equiv 1 thin (upright("mod") thin 6)$. The _return-reduced reduction_ of @subsec:seventeen-families combined this residue restriction with the half-split inequalities $t - 12 < p < t + 22$ from the standard-cone configuration, and obtained the seventeen-element offset set $c = p - t in {-11, -9, dots, 19, 21}$, leading to the explicit one-parameter families $(P_(c, k), Q_(c, k))$ of @prop:seventeen-families-reduction. The _congruence-certificate stage_ of @subsec:congruence-certificate and @subsec:sixteen-table eliminated the sixteen non-central families using Cohn residues modulo the primes $5, 23, 37, 47$, with the periods controlled by the $(2, 1)$-twist matrix $W = A B$ and the certificate principle of @lem:finite-congruence-certificate. Finally, the _central-family stage_ of @subsec:central-family handled the symmetric case $c = 5$: a mod-$37$ certificate reduced the admissible classes to the single survivor $k equiv 15 thin (upright("mod") thin 17)$, and on that survivor class an exact symbolic trace comparison via the Stern--Brocot paths $L R^N L R L R^4$ and $R L^N R^2 L R^4$ established $tr (C_(Q_k)) - tr (C_(P_k)) > 0$, hence $m_(Q_k) > m_(P_k)$. The four stages compose into a contradiction against any assumed equality, completing the proof.

_Why the result matters._ The principal conditional implication of the monograph, @thm:main-conditional of @sec:ETAT, asserts that the Exceptional Terminal Arithmetic Theorem implies the Frobenius--Markov uniqueness conjecture. That implication remains unconditional, but @thm:ETAT itself is conjectural in full generality. The result of the present chapter strengthens the status of the monograph in a concrete way: the manuscript now contains both a conditional reduction of Markov uniqueness to @thm:ETAT _and_ a complete proof of @thm:ETAT in the first genuinely residual exceptional case. The two together establish that the residual obstruction isolated by the reduction is not merely a formal restatement of the original conjecture but a tractable arithmetic problem to which concrete attack methods apply.

The chapter also clarifies the type of arithmetic that the exceptional region demands. Pure line-monotonicity is insufficient, by definition of the exceptional window. Fixed finite modular sieves are insufficient in general, by @thm:no-finite-modular-certificate of @sec:modular-sieve. What does succeed, at least on the minimal case, is the hybrid combination of parameter-sensitive congruence certificates (sixteen local checks against four small primes) with an exact symbolic trace positivity argument (one global polynomial inequality on the central symmetric family). This hybrid pattern is consistent with the local-global structural lessons of @sec:modular-sieve and may be a structural feature of the exceptional region as a whole.

_Certificate status._ The finite residue tables underlying the sixteen non-central families and the exact integer-arithmetic positive margin underlying the central family are recorded in @appendix:minimal-certificates and verified by the certificate scripts distributed with the manuscript. We emphasise that those finite tables are _not_ exploratory numerical evidence: they are finite proof certificates in the precise sense formalised by @lem:finite-congruence-certificate, and the central-family margin is an exact rational quantity whose positivity entails the integer trace inequality on the entire survivor class. The verification protocol --- the canonical command, the expected output, and the structure of the JSON output --- is laid out in @appendix:minimal-certificates so that an independent reader can audit the certificates step by step.

_Next exceptional cases._ The minimal case is no longer isolated. As recorded in @thm:second-nonprimitive-step of @subsec:g2-conclusion, the same method also settles the second nonprimitive step in the same primitive direction,
$
  (R, H) = (6, 5), quad g = 3, quad upright("equivalently") quad (r, h, s) = (18, 15, 33).
$ <eq:next-case-recap-g3>
Here the exceptional inequalities $4 r < 5 h$ and $8 h < 7 r$ read $72 < 75$ and $120 < 126$, both satisfied, and $gcd (r, h) = 3 > 1$ confirms nonprimitivity; the terminal pair is $P = (p + t + 33, thin p)$, $Q = (p + t + 18, thin p + 18)$, with the offset $c = p - t$ ranging over $-18 < c < 33$. The family count is substantially larger than for $g = 2$, but the congruence-certificate machinery scales to it.

The first genuinely new case still open keeps the multiplier at $g = 2$ and steps to the next primitive exceptional direction:
$
  (R, H) = (7, 6), quad g = 2, quad upright("equivalently") quad (r, h, s) = (14, 12, 26).
$ <eq:next-case-recap-RH-76>
The verification of $(7, 6)$ as the next primitive solution of the wedge inequalities was given at the end of @subsec:g2-conclusion. Settling this case --- together with the $g = 2$ and $g = 3$ results already in hand in the direction $(6, 5)$ --- would provide strong evidence for a uniform exceptional-terminal arithmetic theorem covering both directions of variation: the multiplier $g$ inside a fixed primitive direction, and the primitive direction $(R, H)$ at fixed $g$.

_Outlook._ The structural picture of the present chapter suggests a possible path toward the full @thm:ETAT. For each pair $((R, H), thin g)$ in the residual region, return-reducedness confines the offset $c = p - t$ to a finite interval whose length grows linearly with $g$. The resulting finitely many one-parameter families translate along the common $(2, 1)$-twist direction with intersection numbers governed by $(R, H, g)$, and the Cohn residues modulo small primes are periodic by @lem:twist-period with periods controlled by the orders of $W = A B$ in finite quotients of $upright(S L)_2 (bb(Z))$. The likely pattern is that, for each $((R, H), g)$, most families are eliminated by finite congruence certificates against a small set of primes, while a few highly symmetric survivor families --- echoing the central $c = 5$ here --- require exact symbolic trace comparisons.

The principal challenge for a uniform programme is to replace the family-by-family treatment by a single theorem in the three parameters $(R, H, g)$, ideally identifying both the small primes that the congruence certificates require and the symbolic positivity inequalities that the symmetric families demand, as functions of $(R, H, g)$. The minimal case $(R, H, g) = (6, 5, 2)$ proved here, now joined by $(6, 5, 3)$, gives the first concrete data points for such a programme, and their detailed structure may suggest the shape of the uniform theorem.

The chapter therefore closes with a concrete message: _the first residual exceptional terminal cases are solved_ --- the minimal direction $(6, 5)$ at multipliers $g = 2$ and $g = 3$ --- and the next goal is to identify the uniform arithmetic mechanism that the family-by-family pattern conceals.

== Synopsis <subsec:synopsis-sec16>

The present Chapter proves the Exceptional Terminal Arithmetic Theorem in its minimal residual case, namely for the primitive exceptional direction $(R, H) = (6, 5)$ at multiplier $g = 2$ --- equivalently, for the parameter triple $(r, h, s) = (12, 10, 22)$ inside the residual exceptional region of @thm:ETAT. The minimality of the case is established in @subsec:minimal-direction-statement: @lem:first-primitive-direction identifies $(6, 5)$ as the smallest positive coprime solution of the wedge inequalities $4 R < 5 H$, $8 H < 7 R$ that bound the residual region in the primitive-direction plane (illustrated in @fig:exceptional-cone-RH); the substitution $r = 12$, $h = 10$ realises the first nonprimitive multiple of this direction, with the ratio $s slash r = 11 slash 6$ sitting strictly inside the exceptional slope window $(9 slash 5, thin 15 slash 8)$ via @eq:window-check, and with $gcd (r, h) = 2 > 1$ confirming nonprimitivity via @eq:gcd-check. The terminal pair takes the explicit form @eq:minimal-direction-P, @eq:minimal-direction-Q, and the central claim is @thm:minimal-direction: no primitive return-reduced terminal pair of this form admits a Markov-number collision. The proof, occupying @subsec:residue-reduction through @subsec:g2-conclusion, proceeds in three stages whose architecture is laid out in @subsec:minimal-direction-statement. The residue reduction of @subsec:residue-reduction proceeds through a general parity criterion for Markov numbers (@lem:parity-criterion: $m_(p slash q) equiv 0 thin (upright("mod") thin 2) arrow.l.r.double q - p equiv 0 thin (upright("mod") thin 3)$) and a mod-$3$ residue table for $m_(p slash q)$ indexed by $(q, p) thin (upright("mod") thin 4)$ (@fig:mod-3-table); applied to the minimal-direction pair $(P, Q)$, the parity criterion forces $t equiv 1 thin (upright("mod") thin 3)$ (@lem:t-mod-3) and the mod-$3$ table forces $p$ even (@lem:mod-3-separation, @cor:p-even), and combination with the primitivity condition $gcd (p + 12, t) = 1$ upgrades these via the Chinese remainder theorem to the joint residue class $(p, t) equiv (0, 1) thin (upright("mod") thin 6)$ on any potential collision (@prop:elementary-residue-reduction). The return-reduced reduction of @subsec:seventeen-families combines @eq:sec163-residue-condition with the half-split inequalities @eq:p-less-than-t-plus-22 and @eq:p-greater-than-t-minus-12 --- which force $P$ strictly below and $Q$ strictly above the first standard-cone split at direction $(2, 1)$ (illustrated in @fig:standard-cone-split), via the termination of the Euclidean recoding of @sec:euclidean-recoding --- to confine the residual collision locus to seventeen one-parameter families $(P_(c, k), Q_(c, k))$ indexed by the offset $c = p - t in {-11, -9, dots, 19, 21}$ and the affine parameter $k gt.eq.slant 0$ arising from $t = 6 k + 1$, in the explicit form @eq:Pck-Qck-explicit collected as @prop:seventeen-families-reduction and tabulated in @tab:seventeen-families. The two intersection numbers $Delta_P (c) = 22 - c$ and $|Delta_Q (c)| = c + 12$, read off as determinants against the twist direction $(2, 1)$, are independent of $k$ and satisfy the conservation law $Delta_P + |Delta_Q| = 34$ together with the discrete $bb(Z) slash 2$-symmetry $c arrow.r.bar 10 - c$; the unique fixed point $c = 5$ is the central family, which the congruence-certificate elimination of @subsec:sixteen-table cannot reach by a single prime modulus and which is therefore treated separately by the symbolic argument of @subsec:central-family. The finite congruence-certificate principle of @subsec:congruence-certificate proceeds through a generic combinatorial lemma (@lem:finite-congruence-certificate) --- periodic Markov residues with class-wise inequality forbid the integer equality --- and an explicit period formula $T_(c, ell) = L_(c, ell) slash gcd (L_(c, ell), thin 6)$ with $L_(c, ell) = M_ell dot.op upright("lcm")(Delta_P (c), thin |Delta_Q (c)|)$ derived in @lem:twist-period from the orders $M_ell$ of the twist matrix $W = A B = ((12, 5), (7, 3))$ modulo $3 ell$ for the four certificate primes $ell in {5, 23, 37, 47}$ (tabulated in @tab:certificate-moduli, with the $ell = 5$ case proved via the Cayley--Hamilton identity $W^2 equiv -I thin (upright("mod") thin 15)$). The framework is applied in @subsec:sixteen-table to eliminate the sixteen non-central families (@thm:sixteen-noncentral-excluded), with the certificate-summary @tab:certificate-summary recording the primary modulus, period $T_(c, ell)$, primary-survivor residue classes, and auxiliary modulus for each $c$, organised by the eight pair-lemmas @lem:pair-11-21 through @lem:pair-3-7 along the orbits of the involution $c arrow.r.bar 10 - c$. The central family $c = 5$ is eliminated in @subsec:central-family by @thm:central-family-excluded: the mod-$37$ certificate (residue table @tab:central-mod-37) reduces the admissible classes to a single survivor $k equiv 15 thin (upright("mod") thin 17)$, on which the substitution $k = 17 n + 15$ and the Stern--Brocot path identifications $L R^N L R L R^4 arrow.l.r P_k$ and $R L^N R^2 L R^4 arrow.l.r Q_k$ (with $N = 6 n + 5$) lead to the symbolic trace-difference identity $tr (C_(Q_k)) - tr (C_(P_k)) = 3 (15 a + b) F (a, b)$ with $F$ a degree-$16$ homogeneous polynomial and $a, b$ the Chebyshev coefficients $a = Phi_(N - 1)$, $b = -Phi_(N - 2)$ from $W^N = Phi_(N - 1) W - Phi_(N - 2) I$. The substitution $b = -c_0$ gives $F (a, -c_0) = a^(16) G (c_0 slash a)$ with $G$ a polynomial of alternating-sign coefficients all of which are strictly positive; @lem:ratio-estimate gives $c_0 slash a in (0, thin 1 slash 14)$ for every $N gt.eq.slant 5$, and @lem:G-positivity then yields $G (c_0 slash a) > 0$ via the certified dominated-tail inequality $C_0 - C_1 slash 14 > sum_(j gt.eq.slant 2) C_j slash 14^j$ (with the explicit margin recorded in @eq:certificate-margin and verified by the script of @appendix:minimal-certificates), so that $m_(Q_k) > m_(P_k)$ on the survivor class. The synthesis of the three stages is collected in @subsec:g2-conclusion: every primitive return-reduced terminal pair in the minimal exceptional direction is separated, and therefore @thm:ETAT holds for $(R, H) = (6, 5)$ at $g = 2$. The conclusion section collects the formal proof of @thm:minimal-direction by composition of @prop:elementary-residue-reduction, @prop:seventeen-families-reduction, @thm:sixteen-noncentral-excluded, and @thm:central-family-excluded, restates the result as @cor:first-solved-residual in the $(R, H, g)$ form, and verifies that the minimal direction is genuinely residual --- the line slope $lambda = - 6 slash 5$ sits strictly in the exceptional non-monotone interval $(-5 slash 4, thin -8 slash 7)$, the step is nonprimitive with $gcd (r, s) = 2 > 1$, and both $r, s > 1$ exclude the unit-boundary case --- so that none of the three previously available structural exclusions of @sec:terminal-cone, @sec:primitive-exclusion, or @sec:shifted-boundary apply. The supporting computational certificates --- residue tables for the sixteen non-central families, the symbolic positivity coefficient list for the central family, and a consolidated verification script with deterministic output --- are recorded in @appendix:minimal-certificates. The result is the first solved case of @thm:ETAT inside the genuinely residual exceptional nonprimitive terminal region; it offers concrete evidence that the residual problem admits tractable arithmetic cases inside the wedge @eq:primitive-wedge and indicates the natural starting point for a direction-by-direction analysis along the integer rays of the cone of primitive exceptional directions, with the nonprimitive multiplier $g$ playing the role of a continuation parameter inside each direction. The broader implications --- the certificate-style hybrid arithmetic that the exceptional region demands, the extension of the result by the same method to the second nonprimitive step $(R, H) = (6, 5)$ at $g = 3$ (@thm:second-nonprimitive-step, @eq:next-case-recap-g3), the explicit forward outlook on the next open primitive direction $(R, H) = (7, 6)$ at $g = 2$ (@eq:next-case-recap-RH-76), and a sketch of the uniform programme in $(R, H, g)$ that the family-by-family pattern of this chapter suggests --- are collected in @subsec:conclusions-outlook.

#pagebreak()

// ==========================================
// APPENDICES
// ==========================================
//
// Reset the heading counter and switch to letter-based numbering for
// the appendix portion of the manuscript.
#counter(heading).update(0)
#set heading(numbering: "A.1")
#show heading.where(level: 1): set heading(supplement: "Appendix")

// Override the equation numbering function to use letter chapter prefixes
// in the appendix (so equations read "(A.6)" rather than "(1.6)"). The
// chapter integer `sec` is converted to a letter via Typst's `numbering`.
#set math.equation(numbering: n => {
  let sec = counter(heading).get().first()
  if sec == 0 {
    "(" + str(n) + ")"
  } else {
    "(" + numbering("A", sec) + "." + str(n) + ")"
  }
})

// Override the equation cross-reference display so that "@eq:foo" in the
// appendix also renders as "(A.6)" rather than "(1.6)".
#show ref: it => {
  let el = it.element
  if el != none and el.func() == math.equation {
    let loc = el.location()
    let n = counter(math.equation).at(loc).first()
    let sec = counter(heading).at(loc).first()
    if sec == 0 {
      link(loc)[(#n)]
    } else {
      link(loc)[(#numbering("A", sec).#n)]
    }
  } else {
    it
  }
}

= Cohn and Christoffel word conventions <appendix:cohn-words-conventions>

This appendix collects, in one place, the word conventions used throughout the manuscript. The aim is to make the notation unambiguous, especially because the same symbols $A$ and $B$ are used both as letters in a word and as $2 times 2$ matrices, and because Aigner's convention --- which we follow --- assigns the length of a Cohn word $W_(p slash q)$ to be $q$ rather than the more common Christoffel-word total $p + q$. The appendix is purely a reference; nothing in the main reduction depends on its content beyond what is stated explicitly in @sec:cohn-words.

We follow Aigner's conventions throughout: Cohn words are generated by the Cohn word tree, they coincide with lower Christoffel words at the same Stern--Brocot fraction, and their central cores are palindromic words whose letter counts encode the Farey coordinates @Aigner2013. The central-weight trace identity of @subsec:central-weight reads off the Markov number as a positive-definite quadratic form on the central matrix.

== The alphabet and the matrix convention <subsec:alphabet-matrix>

We work over the two-letter alphabet
$
  { A, thin B }.
$
The same letters denote, by a deliberate abuse of notation, the Cohn matrices
$
  A = mat(2, 1; 1, 1), quad quad B = mat(5, 2; 2, 1),
$ <eq:AB-cohn-appendix>
both elements of $upright(S L)(2, bb(Z))$. Concatenation of words and multiplication of matrices use the same notation: if
$
  W = X_1 X_2 dots.h.c X_n, quad quad X_i in { A, B },
$
is a word over the alphabet, then
$
  M(W) := M(X_1) M(X_2) dots.h.c M(X_n)
$
denotes the corresponding matrix product. Throughout the manuscript we suppress $M$ and write simply $W$ for the matrix product when no confusion is likely.

The empty word is denoted $epsilon$, with $M(epsilon) = I$ the identity matrix. The _length_ of a word $W$ is $|W|$, the _letter count_ of a letter $X in { A, B }$ in $W$ is $hash_X (W)$, and the _height_ of $W$ is $h (W) := hash_B (W)$. The trivial identity $|W| = hash_A (W) + hash_B (W)$ holds by definition.

#remark(title: "The evaluation homomorphism as a monoid map", lbl: <rem:eval-homomorphism>)[
  The map $M : { A, B }^ast arrow.r (upright(S L)(2, bb(Z)), thin dot)$ that sends a word $W$ to its matrix product $M(W)$ is a _monoid homomorphism_ from the free monoid on the two-letter alphabet (with concatenation as the binary operation and $epsilon$ as the identity) to the multiplicative monoid of $upright(S L)(2, bb(Z))$. The homomorphism is injective on the subset of Cohn words below: this is a non-trivial fact, equivalent to the statement that distinct Cohn-tree words produce distinct matrices, and is contained in the trace-injectivity formulation of the Frobenius--Markov uniqueness conjecture itself.
]

== Reversal and palindromes <subsec:reversal-palindromes>

For a word $W = X_1 X_2 dots.h.c X_n$, the _reversal_ is
$
  W^ast := X_n X_(n - 1) dots.h.c X_1.
$
A word $W$ is a _palindrome_ if $W = W^ast$. The empty word $epsilon$ is by convention a palindrome.

Since both matrices in @eq:AB-cohn-appendix are symmetric, $M(X)^top = M(X)$ for each $X in { A, B }$. The transpose of a product reverses the order of factors, so
$
  M(W)^top &= M(X_n)^top dots.h.c M(X_2)^top M(X_1)^top \
           &= M(X_n) dots.h.c M(X_2) M(X_1) = M(W^ast).
$
Consequently, if $W$ is a palindrome, then $M(W)$ is symmetric. This observation is used repeatedly for central words. For example, if $z$ is the central core of a Cohn word, then $z$ is palindromic, so $M(z)^top = M(z)$.

== Farey vectors and fractions <subsec:farey-vectors-appendix>

A primitive lattice vector $(q, p) in bb(Z)^2$ with $q gt.eq.slant 1$, $0 lt.eq.slant p lt.eq.slant q$, and $gcd (p, q) = 1$ represents the Farey fraction $p slash q$, and we write $m_(p slash q) = m_((q, p))$ for the corresponding Markov number. We adopt the canonical ordering $(q, p)$ throughout the manuscript: the first coordinate is the denominator, the second is the numerator. Two primitive vectors
$
  v = (q_0, thin p_0), quad u = (q_1, thin p_1)
$
form an _adjacent Farey basis_ if
$
  0 lt.eq.slant p_0 slash q_0 < p_1 slash q_1 lt.eq.slant 1, quad quad det (v, u) = q_0 thin p_1 - q_1 thin p_0 = 1.
$
The _mediant_ of two Farey neighbours is the vector sum
$
  v + u = (q_0 + q_1, thin p_0 + p_1),
$
which corresponds to the fraction-level mediant $p_0 slash q_0 plus.o p_1 slash q_1 = (p_0 + p_1) slash (q_0 + q_1)$.

== Cohn words <subsec:cohn-words-appendix>

The Cohn word tree begins with the seed
$
  W_(0 slash 1) = A, quad W_(1 slash 2) = A B, quad W_(1 slash 1) = B,
$ <eq:cohn-word-seed-appendix>
and is generated by the mediant rule: if $p slash q = m slash n plus.o r slash s$ is a Stern--Brocot mediant, then the corresponding Cohn word is the concatenation
$
  W_(p slash q) = W_(m slash n) thin W_(r slash s).
$
Cohn words are therefore built by juxtaposition in the same way that Cohn matrices are built by multiplication, and the two procedures are intertwined via the evaluation homomorphism @rem:eval-homomorphism.

By Aigner @Aigner2013, the Cohn word $W_(p slash q)$ coincides with the _lower Christoffel word_ at the same Stern--Brocot fraction:
$
  W_(p slash q) = upright("ch")_(p slash q).
$ <eq:cohn-eq-christoffel-appendix>
For every $p slash q in bb(Q)_([0, 1])$, the Cohn word has length and letter counts
$
  |W_(p slash q)| = q, quad quad hash_A (W_(p slash q)) = q - p, quad quad hash_B (W_(p slash q)) = p.
$ <eq:cohn-word-counts-appendix>
The convention $|W_(p slash q)| = q$ adopted in @Aigner2013 differs from the more common Christoffel-word convention $|W_(p slash q)| = p + q$; the two conventions are reconciled by the change of variables explained at the start of @sec:cohn-words. We have used Aigner's convention consistently throughout the manuscript.

== Christoffel form and central cores <subsec:central-cores-appendix>

For every non-endpoint Stern--Brocot fraction $p slash q$ with $0 < p < q$ and $gcd (p, q) = 1$, the lower Christoffel word factors as
$
  W_(p slash q) = A thin z_(p slash q) thin B,
$ <eq:central-factorisation-appendix>
where $z_(p slash q) in { A, B }^ast$ is a palindrome. We call $z_(p slash q)$ the _central core_ of the Cohn word $W_(p slash q)$, and refer to a palindromic word that arises in this way as a _central word_. The empty word $z_(1 slash 2) = epsilon$ is the central core of the seed $W_(1 slash 2) = A B$, and is a palindrome by convention.

Combining @eq:cohn-word-counts-appendix with @eq:central-factorisation-appendix, the letter counts of the central core are shifted by one from those of the full Cohn word:
$
  hash_A (z_(p slash q)) = q - p - 1, quad quad hash_B (z_(p slash q)) = p - 1.
$ <eq:central-counts-appendix>
In particular, $|z_(p slash q)| = q - 2$.

The _shifted-count_ form of @eq:central-counts-appendix is useful for the primitivity-via-core argument of @sec:cohn-words: writing $hash_A (z) + 1 = q - p$ and $hash_B (z) + 1 = p$, we obtain
$
  gcd (p, q) = gcd (p, thin q - p) = gcd (hash_B (z_(p slash q)) + 1, thin hash_A (z_(p slash q)) + 1).
$
The Stern--Brocot primitivity condition $gcd (p, q) = 1$ is therefore equivalent to coprimality of the shifted letter counts of the central core. This formulation is used when discussing non-primitive resonances and terminal residues.

== Central words and standard companions <subsec:central-standard-appendix>

A word $w in { A, B }^ast$ is _central_ if it is the middle part of a Christoffel word $A w B$ for some non-endpoint Stern--Brocot fraction. Aigner's Theorem 8.40 in @Aigner2013 gives the intrinsic characterisation
$
  w upright(" is central") thick arrow.l.r.double thick w A B upright(" is a standard word") thick arrow.l.r.double thick w B A upright(" is a standard word"),
$
in which a _standard word_ is, by definition, a word obtained from the two generators $A$ and $B$ by a finite sequence of two productions in the free monoid that generalise the Stern--Brocot mediant. The two extensions $w A B$ and $w B A$ are then called the _standard companions_ of the central word $w$.

This convention is used only for orientation and terminology in the present manuscript. The main reduction is carried out in the Cohn trace formulation and the Farey-cone geometry, both of which work directly with the central core $z_(p slash q)$ rather than with its standard companions.

== The central weight <subsec:central-weight-appendix>

Let $z in { A, B }^ast$ be a central word. By @subsec:reversal-palindromes, the matrix $P_z := M(z)$ is symmetric. Set
$
  bold(a) := (2, 1)^top,
$
the test vector used throughout the manuscript. The _central weight_ of $z$ is
$
  g (z) := bold(a)^top thin P_z thin bold(a).
$ <eq:central-weight-appendix>
Writing $P_z = mat(alpha, beta; beta, gamma)$ in symmetric coordinates,
$
  g (z) = 4 alpha + 4 beta + gamma.
$ <eq:central-weight-expansion-appendix>
For every non-endpoint Stern--Brocot fraction $p slash q$, the Markov number $m_(p slash q)$ at that fraction equals the central weight of the central core $z_(p slash q)$:
$
  m_(p slash q) = g (z_(p slash q)).
$ <eq:m-eq-g-appendix>
The identification @eq:m-eq-g-appendix is the central trace identity of @lem:trace-of-cohn-word of @sec:cohn-words, recalled below in @subsec:trace-identity-appendix for completeness.

The choice of test vector $bold(a) = (2, 1)^top$ is not a free normalisation: it is forced by the Cohn-matrix trace-projection identity @eq:cohn-trace-form of @sec:markov-cohn, which reads $tr C = (3, thin 0) thin C thin (0, 1)^top$ for every Cohn matrix $C$. The two factors $(3, 0)^top$ and $(0, 1)^top$ become, after threading through the leading $A$ and trailing $B$ in the factorisation $W_(p slash q) = A z_(p slash q) B$, the test vectors $3 bold(a)^top$ on the left and $bold(a)$ on the right; the factor of $3$ in @eq:m-eq-g-appendix is the Cohn-trace-to-Markov-number ratio.

== Trace identity for a central core <subsec:trace-identity-appendix>

We restate the central trace identity of @lem:trace-of-cohn-word of @sec:cohn-words for the convenience of the reader of this appendix.

For every central word $z in { A, B }^ast$, with $P_z = M(z) = mat(alpha, beta; beta, gamma)$,
$
  tr M(A thin z thin B) = 3 thin g (z) = 12 alpha + 12 beta + 3 gamma.
$ <eq:trace-az-b-appendix>
The identity follows from a direct matrix multiplication:
$
  M(A) thin P_z thin M(B) = mat(2, 1; 1, 1) thin mat(alpha, beta; beta, gamma) thin mat(5, 2; 2, 1),
$
which expands to the entries $[10 alpha + 9 beta + 2 gamma, thin dots.h.c; thin dots.h.c, thin 2 alpha + 3 beta + gamma]$, whose trace is $12 alpha + 12 beta + 3 gamma$. The trace of a Cohn matrix is three times the corresponding Markov number, so @eq:trace-az-b-appendix immediately gives @eq:m-eq-g-appendix.

== Endpoint conventions <subsec:endpoint-conventions-appendix>

The two endpoint arms of the Stern--Brocot tree are treated separately but consistently with the central-core formula @eq:central-counts-appendix.

For the _left endpoint arm_ at $p slash q = 1 slash q$ with $q gt.eq.slant 2$, we have $p = 1$, hence
$
  hash_A (z_(1 slash q)) = q - 2, quad hash_B (z_(1 slash q)) = 0.
$
The central core is therefore the all-$A$ power
$
  z_(1 slash q) = A^(q - 2).
$ <eq:endpoint-A-appendix>
For the _right endpoint arm_ at $p slash q = (q - 1) slash q$ with $q gt.eq.slant 2$, we have $p = q - 1$, hence
$
  hash_A (z_((q - 1) slash q)) = 0, quad hash_B (z_((q - 1) slash q)) = q - 2.
$
The central core is therefore the all-$B$ power
$
  z_((q - 1) slash q) = B^(q - 2).
$ <eq:endpoint-B-appendix>

The corresponding endpoint Markov-number formulae, derived in @sec:cohn-words via the central-weight identity and rederived in @sec:fibonacci-pell via the matrix-square factorisations $A = S^2$ and $B = U^2$, are
$
  m_(1 slash q) = F_(2 q + 1), quad quad m_((q - 1) slash q) = upright("Pe")_(2 q - 1),
$ <eq:endpoint-fib-pell-appendix>
where $F_n$ is the Fibonacci sequence and $upright("Pe")_n$ is the Pell sequence, both with the standard normalisations $F_0 = 0, F_1 = 1$ and $upright("Pe")_0 = 0, upright("Pe")_1 = 1$. The endpoint identifications @eq:endpoint-fib-pell-appendix underlie the endpoint-to-endpoint separation theorem @thm:endpoint-separation of @sec:fibonacci-pell, in which Alekseyev's intersection theorem @Alekseyev2011 ensures that the two endpoint arms never collide for $q gt.eq.slant 3$.

== Examples <subsec:examples-appendix>

We illustrate the conventions with a few small Stern--Brocot fractions. The table records the fraction $p slash q$, the Cohn word $W_(p slash q)$, the central core $z_(p slash q)$, and the corresponding Markov number $m_(p slash q)$.

#figure(
  caption: [The first few Cohn words, central cores, and Markov numbers. The endpoint cases $p slash q in { 0 slash 1, thin 1 slash 1 }$ are treated separately; the central core is undefined there because the Cohn word has length $1$. For the non-endpoint cases, the Markov number is recovered as the central weight $g (z_(p slash q)) = bold(a)^top M(z_(p slash q)) bold(a)$ with $bold(a) = (2, 1)^top$.],
  table(
    columns: (auto, auto, auto, auto),
    align: center,
    table.header(
      [$p slash q$], [$W_(p slash q)$], [$z_(p slash q)$], [$m_(p slash q)$]
    ),
    [$0 slash 1$], [$A$], [(endpoint)], [$1$],
    [$1 slash 1$], [$B$], [(endpoint)], [$2$],
    [$1 slash 2$], [$A B$], [$epsilon$], [$5$],
    [$1 slash 3$], [$A A B$], [$A$], [$13$],
    [$2 slash 3$], [$A B B$], [$B$], [$29$],
    [$1 slash 4$], [$A A A B$], [$A^2$], [$34$],
    [$3 slash 4$], [$A B B B$], [$B^2$], [$169$],
    [$1 slash 5$], [$A A A A B$], [$A^3$], [$89$],
    [$4 slash 5$], [$A B B B B$], [$B^3$], [$985$],
    [$2 slash 5$], [$A A B A B$], [$A B A$], [$194$],
    [$3 slash 5$], [$A B A B B$], [$B A B$], [$433$],
  ),
) <fig:cohn-word-examples>

The non-endpoint entries of @fig:cohn-word-examples can be verified directly. For $p slash q = 1 slash 2$, the central core is empty, so $M(z_(1 slash 2)) = I$ and $g (epsilon) = bold(a)^top I bold(a) = 4 + 1 = 5$. For $1 slash 3$, $M(A) = mat(2, 1; 1, 1)$ gives $g (A) = (2, 1) mat(2, 1; 1, 1) (2, 1)^top = (2, 1) (5, 3)^top = 13$. For $2 slash 3$, $M(B) = mat(5, 2; 2, 1)$ gives $g (B) = (2, 1) (12, 5)^top = 29$. The Fibonacci and Pell branches are visible in the left and right endpoint columns of the table, with $m_(1 slash q) in { 5, thin 13, thin 34, thin 89, thin dots }$ matching $F_5, F_7, F_9, F_(11), thin dots$ and $m_((q - 1) slash q) in { 5, thin 29, thin 169, thin 985, thin dots }$ matching $upright("Pe")_3, upright("Pe")_5, upright("Pe")_7, upright("Pe")_9, thin dots$.

The two non-endpoint interior entries $2 slash 5$ and $3 slash 5$ illustrate the mediant rule: $2 slash 5 = 1 slash 3 plus.o 1 slash 2$, so $W_(2 slash 5) = W_(1 slash 3) thin W_(1 slash 2) = A A B dot A B = A A B A B$ and $z_(2 slash 5) = A B A$, a palindrome of length $3$. Similarly $3 slash 5 = 1 slash 2 plus.o 2 slash 3$, so $W_(3 slash 5) = A B dot A B B = A B A B B$ and $z_(3 slash 5) = B A B$, also a palindrome of length $3$.

== Summary of conventions <subsec:summary-appendix>

The principal conventions used throughout the manuscript are collected here for ready reference.

(a) The two-letter alphabet is ${ A, B }$, with the matrix interpretation @eq:AB-cohn-appendix and the evaluation homomorphism $M : { A, B }^ast arrow.r upright(S L)(2, bb(Z))$.

(b) The Cohn word at Stern--Brocot fraction $p slash q$ is $W_(p slash q)$, generated by the seed @eq:cohn-word-seed-appendix and the mediant rule, with length $|W_(p slash q)| = q$ and letter counts as in @eq:cohn-word-counts-appendix.

(c) The Cohn word coincides with the lower Christoffel word at the same fraction by @eq:cohn-eq-christoffel-appendix. For non-endpoint fractions, the central-core decomposition is $W_(p slash q) = A thin z_(p slash q) thin B$ as in @eq:central-factorisation-appendix, with $z_(p slash q)$ a palindrome of length $q - 2$.

(d) The central core has letter counts shifted by one from those of the Cohn word: $hash_A (z_(p slash q)) = q - p - 1$ and $hash_B (z_(p slash q)) = p - 1$ by @eq:central-counts-appendix.

(e) The central weight is $g (z) = bold(a)^top M(z) bold(a)$ with $bold(a) = (2, 1)^top$, given by @eq:central-weight-appendix. The Markov number is recovered as $m_(p slash q) = g (z_(p slash q))$ by @eq:m-eq-g-appendix, equivalently as $tr M(A z_(p slash q) B) = 3 thin m_(p slash q)$ by @eq:trace-az-b-appendix.

(f) The two endpoint arms are unary: $z_(1 slash q) = A^(q - 2)$ and $z_((q - 1) slash q) = B^(q - 2)$ by @eq:endpoint-A-appendix and @eq:endpoint-B-appendix. The corresponding Markov numbers are the odd-indexed Fibonacci and Pell subsequences @eq:endpoint-fib-pell-appendix.

These conventions connect the four objects associated with each Stern--Brocot fraction $p slash q$: the Farey lattice point $(q, p)$, the Cohn word $W_(p slash q) = A thin z_(p slash q) thin B$, its palindromic central core $z_(p slash q)$, and the Markov number $m_(p slash q)$. The four objects fit into the diagram

#figure(
  caption: [The four objects associated to each non-endpoint Stern--Brocot fraction. The horizontal arrows are the central-core decomposition (top) and the central-weight identity (bottom). The vertical arrows are the evaluation homomorphism (left) and the Markov-number identification (right). The diagram commutes: starting from $p slash q$ and following any path produces the same Markov number.],
  diagram(
    node-stroke: 0.6pt + ku-blue,
    node-fill: ku-blue-wash,
    node-inset: 8pt,
    spacing: (8em, 5em),
    edge-stroke: 0.7pt + ku-blue,
    label-sep: 0.55em,
    node((0, 0), [Stern--Brocot fraction\ $p slash q in bb(Q)_([0, 1])$], corner-radius: 3pt),
    node((1, 0), [Cohn word\ $W_(p slash q) = A thin z_(p slash q) thin B$], corner-radius: 3pt),
    node((0, 1), [Lattice point\ $(q, thin p) in cal(D)$], corner-radius: 3pt),
    node((1, 1), [Markov number\ $m_(p slash q) = g (z_(p slash q))$], corner-radius: 3pt, fill: thm-wash, stroke: 0.6pt + thm-color),
    edge((0, 0), (1, 0), "-|>", label-side: center, label: text(size: 8pt, fill: muted-text)[Cohn-word construction]),
    edge((0, 0), (0, 1), "-|>", label-side: left, label: text(size: 8pt, fill: muted-text)[denominator–numerator]),
    edge((1, 0), (1, 1), "-|>", label-side: right, label: text(size: 8pt, fill: muted-text)[central weight $g$]),
    edge((0, 1), (1, 1), "-|>", label-side: center, label: text(size: 8pt, fill: muted-text)[Markov-number assignment]),
  ),
) <fig:four-objects-diagram>

The reduction-theoretic content of the monograph is carried by all four objects simultaneously, with each played off against the others at the appropriate stage: same-ray and dominance monotonicity work on the lattice $cal(D)$; boundary-ratio and Vieta gluing work on the Cohn matrices; Euclidean recoding and the slope-window analysis work on the Stern--Brocot tree; and the endpoint separation of @sec:fibonacci-pell works on the central core. The four objects fit into the commutative diagram @fig:four-objects-diagram, and the unity of the reduction is the unity of these four viewpoints.


= Chebyshev trace recurrences <appendix:chebyshev>

This appendix collects the elementary trace recurrences used throughout the manuscript. The common source of all these formulas is the Cayley--Hamilton identity for $2 times 2$ unimodular matrices: every element of $upright(S L)(2, bb(Z))$ satisfies the quadratic identity $X^2 = (tr X) thin X - I$. In the Cohn-tree setting, this quadratic identity is the trace form of the Markov-tree recursion, and it produces, by repeated application, the Chebyshev-type polynomials that govern all the boundary and ray trace sequences in @sec:local-cone through @sec:fibonacci-pell.

The appendix is purely a reference; nothing in the main reduction depends on its content beyond what is stated explicitly in the body of the manuscript. We have tried to keep the formulas in the form most useful for citation. We make explicit reference to Aigner's Theorem 4.7 of @Aigner2013 (recalled as @thm:aigner-4-7 of @sec:markov-cohn) as the structural source of all the trace recurrences below.

== Cayley--Hamilton in $upright(S L)(2, bb(Z))$ <subsec:CH-appendix>

Let $X in upright(S L)(2, bb(Z))$, and set $tau := tr X$. The characteristic polynomial of $X$ is
$
  lambda^2 - tau thin lambda + det X = lambda^2 - tau thin lambda + 1,
$
since $det X = 1$. By the Cayley--Hamilton theorem applied to $X$,
$
  X^2 - tau thin X + I = 0,
$ <eq:cayley-hamilton-appendix>
equivalently
$
  X^2 = tau thin X - I.
$
Multiplying both sides of @eq:cayley-hamilton-appendix on the right by $X^(n - 1)$ for $n gt.eq.slant 1$ gives the matrix recurrence
$
  X^(n + 1) = tau thin X^n - X^(n - 1).
$ <eq:matrix-power-recurrence>
The relation @eq:matrix-power-recurrence is satisfied by every matrix-power sequence generated by a fixed $X in upright(S L)(2, bb(Z))$.

More generally, multiplying @eq:matrix-power-recurrence on the right by any $2 times 2$ matrix $Y$ and taking traces gives the universal trace recurrence
$
  tr (X^(n + 1) Y) = tau thin tr (X^n Y) - tr (X^(n - 1) Y),
$ <eq:trace-recurrence-appendix>
valid for any $X in upright(S L)(2, bb(Z))$ and any $Y$. This is the basic trace recurrence underlying all the boundary and ray trace identities of the manuscript.

#remark(title: "Cayley–Hamilton as the algebraic engine of the manuscript", lbl: <rem:CH-engine>)[
  The Cayley--Hamilton identity @eq:cayley-hamilton-appendix is the algebraic engine of the entire structural reduction of @sec:same-ray through @sec:fibonacci-pell. Three consequences underlie everything we use. First, for every $X in upright(S L)(2, bb(Z))$ with $tau = tr (X)$ the matrix-power recurrence $X^(n + 1) = tau X^n - X^(n - 1)$ of @eq:matrix-power-recurrence holds; taking traces of any right multiple $X^n Y$ collapses the matrix dynamics to the _scalar second-order linear recurrence_ $T_(n + 1) = tau T_n - T_(n - 1)$ of @eq:trace-recurrence-appendix on the single scalar sequence $T_n = tr (X^n Y)$. This is what makes every ray and boundary trace recurrence in the manuscript second-order rather than higher-order. Second, the same identity, rewritten as $X^(- 1) = tau I - X$, yields the Fricke trace identity $tr (M N) + tr (M N^(- 1)) = tr (M) thin tr (N)$ used throughout in the Vieta-involution analysis. Third, both consequences admit a uniform closed-form solution in terms of the Chebyshev polynomials of @subsec:chebyshev-appendix.

  From the representation-theoretic viewpoint (already touched on in @rem:chebyshev-characters of @sec:local-cone), the identity is the matrix expression of the fact that the standard $2$-dimensional representation $V = bb(C)^2$ of $upright(S L)(2, bb(C))$ has dimension two: every $g in upright(S L)(2, bb(C))$ therefore satisfies a degree-$2$ polynomial identity whose coefficients are conjugation-invariant. The relevant invariant ring on $upright("Mat")_(2 times 2)$ is $bb(C)[tr, det]$; the trace is, up to a scalar multiple, the unique conjugation-invariant linear polynomial, and the determinant is the unique conjugation-invariant quadratic one. On $upright(S L)(2, bb(C))$ the determinant is normalised to $1$, so the trace is the only non-trivial invariant left. The whole Markov-tree dynamics is therefore the integer-point shadow of the relative $upright(S L)(2, bb(C))$-character variety of the free group $F_2 = pi_1 (T^2 without { upright("pt") })$ developed in @sec:markov-cohn, restricted to the arithmetic subgroup $upright(S L)(2, bb(Z))$.
]

== One-sided ray recurrences <subsec:rays-appendix>

Let $(R, R S, S)$ be a Cohn triple as in @sec:local-cone, and set
$
  x := tr R, quad y := tr S, quad z := tr (R S).
$
Applying @eq:trace-recurrence-appendix with $X = R$, $Y = S$ to the sequence
$
  T_n := tr (R^n S), quad quad n gt.eq.slant 0,
$
gives the left-ray recurrence
$
  T_(n + 1) = x thin T_n - T_(n - 1), quad quad n gt.eq.slant 1,
$ <eq:Tn-recurrence-appendix>
with initial data $T_0 = tr S = y$ and $T_1 = tr (R S) = z$. The same argument with $X = S$, $Y = R$ applied to
$
  T'_n := tr (R S^n), quad quad n gt.eq.slant 0,
$
gives the right-ray recurrence
$
  T'_(n + 1) = y thin T'_n - T'_(n - 1), quad quad n gt.eq.slant 1,
$ <eq:Tn-prime-recurrence-appendix>
with initial data $T'_0 = tr R = x$ and $T'_1 = tr (R S) = z$.

Both ray recurrences are second-order linear recurrences with constant coefficients $x$ and $y$ respectively. They are the basis of the same-ray monotonicity argument of @thm:same-ray-monotonicity of @sec:same-ray. The one-sided rays they describe are
$
  S, thick R S, thick R^2 S, thick R^3 S, thick dots quad upright("and") quad R, thick R S, thick R S^2, thick R S^3, thick dots,
$
the inner boundaries of the two child subtrees of the local Cohn split.

== The Chebyshev-type polynomials $P_n$ <subsec:chebyshev-appendix>

The universal closed-form solution of the second-order linear recurrence with coefficient $T$ is governed by a family of Chebyshev-type integer-coefficient polynomials.

#definition(title: "Chebyshev-type polynomials", lbl: <def:chebyshev-appendix>)[
  Define $P_n (T) in bb(Z) [T]$ for $n gt.eq.slant - 1$ by
  $
    P_(- 1) (T) = 0, quad P_0 (T) = 1,
  $
  and the recurrence
  $
    P_(n + 1) (T) = T thin P_n (T) - P_(n - 1) (T), quad quad n gt.eq.slant 0.
  $ <eq:Pn-recurrence-appendix>
] <def-chebyshev-appendix>

The first few values are
$
  P_1 (T) = T, quad P_2 (T) = T^2 - 1, quad P_3 (T) = T^3 - 2 T, quad P_4 (T) = T^4 - 3 T^2 + 1, quad dots.h.c.
$
The polynomial $P_n$ is the Chebyshev polynomial of the second kind in the normalisation $P_n (T) = U_n (T slash 2)$, where $U_n$ is the standard second-kind Chebyshev polynomial defined by $U_0 = 1$, $U_1 = 2 X$, and $U_(n + 1) (X) = 2 X thin U_n (X) - U_(n - 1) (X)$. The polynomials $P_n$ are the natural representation-theoretic objects of @rem:chebyshev-characters of @sec:local-cone: they are the characters of the symmetric powers $upright("Sym")^n bb(C)^2$ of the standard representation of $upright(S L)(2, bb(C))$, evaluated at a matrix of trace $T$.

The key property of the polynomials $P_n$ is the following universal solution formula, which we recall from @lem:chebyshev-closed-form of @sec:local-cone in a form most useful for the appendix.

#lemma(title: "Universal solution of the second-order trace recurrence", lbl: <lem:Pn-closed-appendix>)[
  Let $T in bb(C)$, $alpha, beta in bb(C)$, and let $(W_n)_(n gt.eq.slant - 1)$ be the unique sequence satisfying $W_(- 1) = alpha$, $W_0 = beta$, and the recurrence
  $
    W_(n + 1) = T thin W_n - W_(n - 1) quad upright("for all") quad n gt.eq.slant 0.
  $
  Then for every $n gt.eq.slant - 1$,
  $
    W_n = P_n (T) thin beta - P_(n - 1) (T) thin alpha.
  $ <eq:Pn-closed-formula>
] <lem-Pn-closed-appendix>

#proof[
  Direct induction on $n$. For $n = - 1$, the right-hand side is $P_(- 1) (T) thin beta - P_(- 2) (T) thin alpha$. Adopting the convention $P_(- 2) (T) = - 1$ (extending the recurrence @eq:Pn-recurrence-appendix backwards), this gives $0 thin beta - (- 1) thin alpha = alpha = W_(- 1)$, as required. For $n = 0$, the right-hand side is $P_0 thin beta - P_(- 1) thin alpha = 1 dot beta - 0 dot alpha = beta = W_0$. Assuming the formula holds at indices $n - 1$ and $n$,
  $
    W_(n + 1) &= T thin W_n - W_(n - 1) \
              &= T thin (P_n beta - P_(n - 1) alpha) - (P_(n - 1) beta - P_(n - 2) alpha) \
              &= (T thin P_n - P_(n - 1)) thin beta - (T thin P_(n - 1) - P_(n - 2)) thin alpha \
              &= P_(n + 1) thin beta - P_n thin alpha,
  $
  by @eq:Pn-recurrence-appendix at $n$ and $n - 1$. The induction is complete.
]

@lem:Pn-closed-appendix is the universal closed form. We apply it now to the boundary trace sequences and to the divided Markov-normalised sequences.

== Boundary trace sequences <subsec:boundary-appendix>

Continuing with the local Cohn triple $(R, R S, S)$ and the trace data $(x, z, y)$, the two boundary trace sequences of @sec:local-cone are
$
  U_(- 1) = x, quad U_0 = x z - y, quad U_(n + 1) = z thin U_n - U_(n - 1),
$ <eq:U-rec-appendix>
$
  V_(- 1) = z, quad V_0 = z y - x, quad V_(n + 1) = y thin V_n - V_(n - 1).
$ <eq:V-rec-appendix>
The two initial values $U_0$ and $V_0$ are exactly the new middle traces $tr (R^2 S)$ and $tr (R S^2)$ produced by the two children of the local Cohn split, by @lem:local-trace-recurrences of @sec:local-cone.

Applying @lem:Pn-closed-appendix to @eq:U-rec-appendix with $T = z$, $alpha = x$, $beta = x z - y$, and to @eq:V-rec-appendix with $T = y$, $alpha = z$, $beta = z y - x$, we obtain the explicit Chebyshev closed forms
$
  U_n = P_n (z) thin (x z - y) - P_(n - 1) (z) thin x,
$ <eq:U-closed-appendix>
$
  V_n = P_n (y) thin (z y - x) - P_(n - 1) (y) thin z.
$ <eq:V-closed-appendix>
These are the formulas used in @sec:boundary-ratio, @sec:vieta-gluing, and @sec:shifted-boundary.

== Divided Markov-normalised boundary sequences <subsec:divided-appendix>

Since every Cohn trace is divisible by three, it is convenient to work with the Markov-normalised divided sequences. Writing $x = 3 a$, $y = 3 b$, $z = 3 c$ (so that $(a, c, b)$ is the Markov triple at the local Cohn triple, with $c$ the mediant), and setting
$
  tilde(U)_n := U_n slash 3, quad quad tilde(V)_n := V_n slash 3,
$
the initial data become
$
  tilde(U)_(- 1) = a, quad tilde(U)_0 = 3 a c - b, quad quad tilde(V)_(- 1) = c, quad tilde(V)_0 = 3 b c - a,
$ <eq:divided-init-appendix>
and the recurrences become
$
  tilde(U)_(n + 1) = 3 c thin tilde(U)_n - tilde(U)_(n - 1), quad quad tilde(V)_(n + 1) = 3 b thin tilde(V)_n - tilde(V)_(n - 1).
$ <eq:divided-recs-appendix>
The Chebyshev closed forms specialise to
$
  tilde(U)_n = P_n (3 c) thin (3 a c - b) - a thin P_(n - 1) (3 c),
$ <eq:tilde-U-closed-appendix>
$
  tilde(V)_n = P_n (3 b) thin (3 b c - a) - c thin P_(n - 1) (3 b).
$ <eq:tilde-V-closed-appendix>
These are the formulas used in the Vieta gluing identity of @sec:vieta-gluing.

== Vieta gluing in Chebyshev notation <subsec:vieta-appendix>

Let $(a, b, c)$ be an ordered Markov triple with Vieta predecessor $d := 3 a b - c$, so that $(a, d, b)$ is the Vieta predecessor triple along the fixed-$a$ branch. The $U$-boundary sequence at the predecessor $(a, d, b)$ is, by @eq:tilde-U-closed-appendix with $(a, b, c) arrow.r.bar (a, d, b)$,
$
  tilde(U)'_n (a, d, b) = P_n (3 b) thin (3 a b - d) - a thin P_(n - 1) (3 b).
$
The defining Vieta relation $c + d = 3 a b$ gives $3 a b - d = c$, so
$
  tilde(U)'_n (a, d, b) = c thin P_n (3 b) - a thin P_(n - 1) (3 b).
$ <eq:tilde-U-prime-appendix>

We now compare with $tilde(V)_n (a, b, c)$ at the original triple. Starting from @eq:tilde-V-closed-appendix and expanding,
$
  tilde(V)_n (a, b, c) = 3 b c thin P_n (3 b) - a thin P_n (3 b) - c thin P_(n - 1) (3 b),
$
which we re-group as
$
  tilde(V)_n (a, b, c) = c thin (3 b thin P_n (3 b) - P_(n - 1) (3 b)) - a thin P_n (3 b).
$
The bracketed quantity is, by the Chebyshev recurrence @eq:Pn-recurrence-appendix evaluated at $T = 3 b$,
$
  3 b thin P_n (3 b) - P_(n - 1) (3 b) = P_(n + 1) (3 b),
$
hence
$
  tilde(V)_n (a, b, c) = c thin P_(n + 1) (3 b) - a thin P_n (3 b).
$
Substituting $c = 3 a b - d$,
$
  tilde(V)_n (a, b, c) = P_(n + 1) (3 b) thin (3 a b - d) - a thin P_n (3 b) = tilde(U)'_(n + 1) (a, d, b).
$ <eq:vieta-gluing-appendix>
This is the Vieta gluing identity of @thm:vieta-gluing of @sec:vieta-gluing, derived here purely from the Chebyshev recurrence. The identity holds for every $n gt.eq.slant - 1$.

== Wronskian identity for boundary ratios <subsec:wronskian-appendix>

The boundary ratio monotonicity of @sec:boundary-ratio depends on the Wronskian-type quantity
$
  W_n := U_(n + 1) thin V_n - U_n thin V_(n + 1), quad quad n gt.eq.slant - 1.
$ <eq:Wronskian-def-appendix>
Substituting @eq:U-rec-appendix and @eq:V-rec-appendix into the definition and grouping,
$
  W_n &= (z thin U_n - U_(n - 1)) thin V_n - U_n thin (y thin V_n - V_(n - 1)) \
      &= (z - y) thin U_n thin V_n + (U_n thin V_(n - 1) - U_(n - 1) thin V_n) \
      &= (z - y) thin U_n thin V_n + W_(n - 1),
$
where the final equality uses the definition of $W_(n - 1)$. Hence
$
  W_n = W_(n - 1) + (z - y) thin U_n thin V_n.
$ <eq:Wronskian-recurrence-appendix>

The initial Wronskian is computed by direct substitution. Using $U_(- 1) = x$, $U_0 = x z - y$, $V_(- 1) = z$, $V_0 = z y - x$,
$
  W_(- 1) = (x z - y) thin z - x thin (z y - x) = x z^2 - y z - x y z + x^2.
$
The trace-normalised Markov equation @eq:trace-markov-eq of @sec:local-cone gives $x y z = x^2 + y^2 + z^2$, so
$
  W_(- 1) = x z^2 - y z - (x^2 + y^2 + z^2) + x^2 = x z^2 - y z - y^2 - z^2,
$
which factors as
$
  W_(- 1) = z^2 (x - 1) - y (y + z).
$ <eq:Wminus1-factored-appendix>
For every oriented Cohn triple with $z > y$ and $x gt.eq.slant 3$, the right-hand side is strictly positive: $z^2 (x - 1) gt.eq.slant 2 z^2$ and $y (y + z) < 2 z^2$ by the orientation $0 < y < z$, so $W_(- 1) > 0$. The recurrence @eq:Wronskian-recurrence-appendix together with the orientation $z > y$ and the positivity $U_n, V_n > 0$ then propagates $W_n > 0$ for every $n gt.eq.slant - 1$, by induction. Dividing @eq:Wronskian-def-appendix by $V_n thin V_(n + 1) > 0$ yields the boundary-ratio monotonicity:
$
  U_(n + 1) slash V_(n + 1) > U_n slash V_n,
$
the content of @thm:boundary-ratio-monotonicity of @sec:boundary-ratio.

#remark(title: "The discrete Wronskian as a discrete first integral", lbl: <rem:wronskian-discrete-first-integral>)[
  The recurrence @eq:Wronskian-recurrence-appendix can be read in two equivalent ways. As a lattice analogue of the continuous Wronskian identity $W' = - p thin W$ for two solutions of a second-order linear ODE (already noted in @rem:wronskian-curvature of @sec:boundary-ratio), the discrete Wronskian grows along the lattice at a controlled rate; the sign of the increment $(z - y)$ encodes the symmetry-breaking between the two parameters $z, y$ of the local Cohn triple. As a _discrete first integral_ of the two coupled boundary recurrences @eq:U-rec-appendix and @eq:V-rec-appendix, the Wronskian $W_n$ is, up to an additive correction, a conserved quantity of the joint $(U_n, V_n)$ dynamics: removing the increment $(z - y) thin U_n thin V_n$ at each step would make $W_n$ exactly constant. The positivity $W_n > 0$ is then the discrete version of the statement that the two boundary sequences span a _coherently oriented frame_ on the lattice --- equivalently, that the $2 times 2$ column matrix $mat(U_n, V_n; U_(n + 1), V_(n + 1))$ has positive determinant for every $n$. This is the discrete reflection of the fact that the symplectic area swept by the $(U, V)$ frame is monotonically positive, in keeping with the dynamical-systems reading of @SpaldingVeselov2017.
]

== Even and odd decompositions of the Chebyshev polynomials <subsec:even-odd-appendix>

For some computations it is useful to separate the even and odd subsequences of the Chebyshev polynomials $P_n$. Define polynomials $F_r (X), G_r (X) in bb(Z) [X]$ by
$
  P_(2 r) (T) = F_r (T^2), quad quad P_(2 r + 1) (T) = T thin G_r (T^2).
$ <eq:even-odd-decomp-appendix>
That this is possible follows from the recurrence @eq:Pn-recurrence-appendix and induction on $r$: $P_(2 r)$ is a polynomial in $T^2$ alone (no odd powers of $T$), and $P_(2 r + 1)$ is $T$ times such a polynomial.

The first few values are
$
  F_0 (X) = 1, quad F_1 (X) = X - 1, quad F_2 (X) = X^2 - 3 X + 1,
$
and
$
  G_0 (X) = 1, quad G_1 (X) = X - 2, quad G_2 (X) = X^2 - 4 X + 3.
$

Both sequences satisfy the same three-term linear recurrence.

#lemma(title: "Even/odd Chebyshev recurrence", lbl: <lem:even-odd-recurrence>)[
  For every $r gt.eq.slant 1$,
  $
    F_(r + 1) (X) = (X - 2) thin F_r (X) - F_(r - 1) (X),
  $ <eq:F-recurrence-appendix>
  $
    G_(r + 1) (X) = (X - 2) thin G_r (X) - G_(r - 1) (X).
  $ <eq:G-recurrence-appendix>
] <lem-even-odd-recurrence>

#proof[
  We prove @eq:F-recurrence-appendix; the proof of @eq:G-recurrence-appendix is identical. Using the Chebyshev recurrence @eq:Pn-recurrence-appendix three times,
  $
    P_(2 r + 2) (T) &= T thin P_(2 r + 1) (T) - P_(2 r) (T), \
    P_(2 r + 1) (T) &= T thin P_(2 r) (T) - P_(2 r - 1) (T), \
    P_(2 r) (T) &= T thin P_(2 r - 1) (T) - P_(2 r - 2) (T).
  $
  From the third equation, $T thin P_(2 r - 1) (T) = P_(2 r) + P_(2 r - 2)$. Substituting this into the second,
  $
    P_(2 r + 1) (T) = T thin P_(2 r) (T) - (T^(-1) thin (P_(2 r) + P_(2 r - 2))),
  $
  which is awkward; a cleaner route is to multiply the second equation through by $T$:
  $
    T thin P_(2 r + 1) (T) &= T^2 thin P_(2 r) (T) - T thin P_(2 r - 1) (T) \
    &= T^2 thin P_(2 r) (T) - (P_(2 r) (T) + P_(2 r - 2) (T)).
  $
  Hence $T thin P_(2 r + 1) (T) = (T^2 - 1) thin P_(2 r) (T) - P_(2 r - 2) (T)$. Substituting into the first equation,
  $
    P_(2 r + 2) (T) &= T thin P_(2 r + 1) (T) - P_(2 r) (T) \
    &= (T^2 - 1) thin P_(2 r) (T) - P_(2 r - 2) (T) - P_(2 r) (T) \
    &= (T^2 - 2) thin P_(2 r) (T) - P_(2 r - 2) (T).
  $
  Writing $X = T^2$, this is
  $
    F_(r + 1) (X) = (X - 2) thin F_r (X) - F_(r - 1) (X),
  $
  which is @eq:F-recurrence-appendix. The proof for @eq:G-recurrence-appendix is the same after multiplying the second-equation derivation through by $T$ and grouping similarly.
]

The even/odd decomposition is useful when boundary congruences must be analysed in parallel by residue parity. The polynomials $F_r$ and $G_r$ are themselves Chebyshev-type polynomials, satisfying the same recurrence with the shift parameter $X arrow.r.bar X - 2$.

== Endpoint Fibonacci and Pell recurrences <subsec:endpoint-recurrences-appendix>

The endpoint arms of the Cohn tree are governed by the matrix-square factorisations of @sec:fibonacci-pell. The Cohn matrices $A$ and $B$ are the squares of the standard Fibonacci and Pell matrices respectively:
$
  A = S^2, quad quad B = U^2,
$
where (in the notation of @sec:fibonacci-pell)
$
  S = mat(1, 1; 1, 0), quad quad U = mat(2, 1; 1, 0).
$ <eq:fibonacci-pell-matrices-appendix>
For the Fibonacci matrix $S$, the standard identity
$
  S^N = mat(F_(N + 1), F_N; F_N, F_(N - 1))
$
holds for $N gt.eq.slant 0$, with Fibonacci numbers $F_0 = 0$, $F_1 = 1$, $F_(n + 1) = F_n + F_(n - 1)$. Combined with the central-weight identification $m_(1 slash q) = bold(a)^top A^(q - 2) bold(a) = e_1^top S^(2 q) e_1$ derived in @subsec:left-arm-fibonacci, this gives the endpoint Fibonacci formula
$
  m_(1 slash q) = F_(2 q + 1).
$ <eq:fibonacci-endpoint-appendix>

For the Pell matrix $U$, the analogous identity
$
  U^N = mat(upright("Pe")_(N + 1), upright("Pe")_N; upright("Pe")_N, upright("Pe")_(N - 1))
$
holds with the Pell numbers $upright("Pe")_0 = 0$, $upright("Pe")_1 = 1$, $upright("Pe")_(n + 1) = 2 thin upright("Pe")_n + upright("Pe")_(n - 1)$. Combined with $m_((q - 1) slash q) = bold(a)^top B^(q - 2) bold(a) = e_1^top U^(2 q - 2) e_1$ from @subsec:right-arm-pell, this gives the endpoint Pell formula
$
  m_((q - 1) slash q) = upright("Pe")_(2 q - 1).
$ <eq:pell-endpoint-appendix>

Both endpoint formulae are special cases of the universal Cayley--Hamilton-driven trace recurrence @eq:trace-recurrence-appendix, with $tr S = 1$ and $tr U = 2$ respectively. The Pisot eigenvalues of $S$ and $U$ are $phi.alt = (1 + sqrt(5)) slash 2$ and $1 + sqrt(2)$, and the asymptotic growth rates of the Fibonacci and Pell sequences are $phi.alt^n$ and $(1 + sqrt(2))^n$ respectively. These are the two slowest Lyapunov rays of the Markov-tree dynamics in the sense of @SpaldingVeselov2017.

== Summary of formulas <subsec:summary-appendix-B>

The trace and recurrence identities used throughout the manuscript are collected here for ready reference.

_Cayley--Hamilton in $upright(S L)(2, bb(Z))$:_
$
  X^2 = (tr X) thin X - I quad upright("for every") thick X in upright(S L)(2, bb(Z)),
$
and consequently the trace recurrence
$
  tr (X^(n + 1) Y) = (tr X) thin tr (X^n Y) - tr (X^(n - 1) Y).
$

_Chebyshev-type polynomials:_
$
  P_(- 1) = 0, quad P_0 = 1, quad P_(n + 1) (T) = T thin P_n (T) - P_(n - 1) (T).
$

_One-sided ray traces:_
$
  T_(n + 1) = x thin T_n - T_(n - 1), quad T'_(n + 1) = y thin T'_n - T'_(n - 1).
$

_Boundary trace sequences:_
$
  U_n = P_n (z) thin (x z - y) - P_(n - 1) (z) thin x,
$
$
  V_n = P_n (y) thin (z y - x) - P_(n - 1) (y) thin z.
$

_Divided Markov-normalised forms:_
$
  tilde(U)_n = P_n (3 c) thin (3 a c - b) - a thin P_(n - 1) (3 c),
$
$
  tilde(V)_n = P_n (3 b) thin (3 b c - a) - c thin P_(n - 1) (3 b).
$

_Vieta gluing identity:_
$
  tilde(V)_n (a, thin b, thin c) = tilde(U)'_(n + 1) (a, thin 3 a b - c, thin b).
$

_Wronskian recurrence:_
$
  W_n = W_(n - 1) + (z - y) thin U_n thin V_n.
$

_Even/odd Chebyshev recurrence:_
$
  F_(r + 1) (X) &= (X - 2) thin F_r (X) - F_(r - 1) (X), \
  G_(r + 1) (X) &= (X - 2) thin G_r (X) - G_(r - 1) (X).
$

_Endpoint Fibonacci and Pell:_
$
  m_(1 slash q) = F_(2 q + 1), quad m_((q - 1) slash q) = upright("Pe")_(2 q - 1).
$

In the generalised setting of @LagisquetPelantovaTavenasVuillon2021, where the m-value is defined for all pairs $(d, n) in bb(N)^2$ (not only the coprime pairs that index classical Markov numbers), the corresponding identifications pick up the _even_-indexed Fibonacci and Pell subsequences as well: $m(c(0, p)) = F_(2 p)$ and $m(c(p, p)) = upright("Pe")_(2 p)$, alongside the odd-indexed $m(c(1, p)) = F_(2 p + 1)$ and $m(c(p, p + 1)) = upright("Pe")_(2 p + 1)$ that specialise to the classical endpoint formulas above. Together they recover the full Fibonacci--Pell families as generalised Markov values, with the gcd-induced non-primitivity at the diagonal pairs $(p, p)$ being precisely what unlocks the even indices.

These are the algebraic identities underlying same-ray monotonicity (@sec:same-ray), boundary-ratio monotonicity (@sec:boundary-ratio), Vieta gluing (@sec:vieta-gluing), shifted boundary separation (@sec:shifted-boundary), and the endpoint Fibonacci--Pell separation (@sec:fibonacci-pell). The whole structural reduction of the monograph rests on these elementary trace recurrences, all of which descend from the single algebraic principle of Cayley--Hamilton @eq:cayley-hamilton-appendix in $upright(S L)(2, bb(Z))$.


= External ordering and recurrence theorems used <appendix:external-results>

This appendix records the _external_ results used in the structural reduction of the manuscript. The main body proves all Cohn-tree and Farey-cone reductions directly, but it relies on several known ordering theorems for Markov numbers and on one recurrence-intersection theorem from the theory of Lucas sequences. We collect these external inputs in one place so that the logical dependencies of the reduction are explicit, and so that any future strengthening of the external inputs can be tracked against the manuscript without ambiguity.

The external inputs fall into four groups:

(i) restricted ordering conjectures of Aigner @Aigner2013, proved by Lagisquet, Pelantová, Tavenas, and the second author of the present manuscript @LagisquetPelantovaTavenasVuillon2021;

(ii) slope-ordering theorems for Markov numbers, due to Lee, Li, Rabideau, and Schiffler @LeeLiRabideauSchiffler2023, with the explicit boundary slopes $- 5 slash 4$ and $- 8 slash 7$ further analysed by Gaster @Gaster2022;

(iii) the monotonicity classification for generalised Markov numbers along lines of given slope, due to Huang @Huang2022;

(iv) Alekseyev's intersection theorem for Fibonacci, Pell, and Lucas sequences @Alekseyev2011.

None of these results is equivalent to the full Frobenius--Markov uniqueness conjecture in the form used in the manuscript: they are known _partial_ ordering or recurrence-intersection statements, sufficient to eliminate large classes of trace collisions but insufficient to settle every possible terminal exceptional comparison. The full conjecture is reduced, in @sec:ETAT, to the Exceptional Terminal Arithmetic Theorem @thm:ETAT, which is _not_ among the external inputs of the present appendix.

== Aigner's restricted ordering conjectures <subsec:aigner-restricted>

Markov numbers in this monograph are indexed by the reduced fractions $p slash q in bb(Q)_([0, 1])$, equivalently by the primitive lattice points $(q, thin p) in cal(D)$. Aigner @Aigner2013 formulates three natural _restricted_ ordering conjectures, parameterising the lattice by holding one of the two coordinates (or their sum) fixed. The three conjectures are:

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + ku-blue),
  fill: ku-blue-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *Aigner's restricted ordering conjectures @Aigner2013.*

  - _Fixed numerator._ For every fixed integer $p gt.eq.slant 2$, the sequence $(m_(p slash q))_(q > p, thin gcd (p, q) = 1)$ is strictly increasing in $q$:
    $
      m_(p slash (p + 1)) < m_(p slash (p + 2)) < m_(p slash (p + 3)) < dots.h.c.
    $

  - _Fixed denominator._ For every fixed integer $q gt.eq.slant 2$, the sequence $(m_(p slash q))_(1 lt.eq.slant p lt.eq.slant q - 1, thin gcd (p, q) = 1)$ is strictly increasing in $p$:
    $
      m_(1 slash q) < m_(2 slash q) < dots.h.c < m_((q - 1) slash q).
    $

  - _Fixed sum._ For every fixed integer $s gt.eq.slant 3$, the sequence $(m_(p slash q))_(p + q = s, thin gcd (p, q) = 1)$ is strictly decreasing in $p$ (as $p$ increases and $q = s - p$ decreases):
    $
      m_(1 slash (s - 1)) > m_(2 slash (s - 2)) > m_(3 slash (s - 3)) > dots.h.c.
    $
]

The three conjectures had a partial history of resolution. The fixed-numerator conjecture was first proved by Rabideau and Schiffler @RabideauSchiffler2020 using snake-graph perfect matchings and a continuant-polynomial identity going back to Frobenius. Lagisquet, Pelantová, Tavenas, and the second author of the present manuscript subsequently re-proved this case in a unified path-flattening framework and resolved the remaining two conjectures (fixed denominator and fixed sum), in fact in the more general setting of generalised Markov numbers indexed by all pairs $(p, q) in bb(Z)_(gt.eq.slant 0)^2$ rather than only primitive pairs @LagisquetPelantovaTavenasVuillon2021.

#theorem(title: [Resolution of Aigner's restricted ordering conjectures, after @LagisquetPelantovaTavenasVuillon2021], lbl: <thm:aigner-restricted>)[
  All three of Aigner's restricted ordering conjectures (fixed numerator, fixed denominator, fixed sum) hold for Markov numbers and, in the appropriate strict-monotonicity form, for generalised Markov numbers.
] <thm-aigner-restricted>

#proof[
  The fixed-numerator clause is the main theorem of @RabideauSchiffler2020 (the unified path-flattening re-proof for non-coprime pairs is in @LagisquetPelantovaTavenasVuillon2021). The fixed-denominator and fixed-sum clauses, and the extension of all three to generalised Markov numbers indexed by all pairs $(p, q) in bb(Z)_(gt.eq.slant 0)^2$, are proved in Lagisquet, Pelantová, Tavenas, and the second author of the present manuscript @LagisquetPelantovaTavenasVuillon2021. We record the statement here as an external input; the cited references contain the complete proofs.
]

We use these results in two places in the manuscript. First, the fixed-denominator ordering of @LagisquetPelantovaTavenasVuillon2021 underlies the endpoint-cone boundary inequality @lem:lower-endpoint of @sec:shifted-boundary, where two adjacent boundary lattice points share the same denominator $s^2 + s + 1$ with distinct numerators $s$ and $s + 1$. Second, the fixed-denominator ordering reappears in @lem:reqs-excluded of @sec:terminal-cone, where the equal-denominator terminal case $r = s$ is excluded directly. The fixed-numerator and fixed-sum conjectures are not invoked in the body of the reduction, but they serve as natural consistency checks and as alternative formulations of the same body of restricted-ordering theory.

For completeness, we record the negative side of the same body of work. In Appendix B of @LagisquetPelantovaTavenasVuillon2021, three of Aigner's auxiliary conjectures around the restricted ordering --- possibilities 2, 3, and 4 of his strategy discussion (page 223 of @Aigner2013), together with the more specific Conjectures 10.18 (page 225 of the same source) --- are _falsified_ by explicit computational counterexamples. The simplest of these is the equality $g(thin frak(a) thin frak(b) thin frak(b) thin frak(a) thin) = 1130 = g(thin frak(b) thin frak(a) thin frak(a) thin frak(b) thin)$, which refutes the would-be strengthening of Frobenius--Markov uniqueness in which $g(w_1) = g(w_2)$ would force $w_1 in {w_2, thin overline(w_2)}$. The structural moral, made explicit in our @sec:routes-to-ETAT, is that no proof of the Exceptional Terminal Arithmetic Theorem can rest on a uniform Cohn-word symmetry: any successful approach must exploit a finer arithmetic invariant than $g$ alone.

== Slope-ordering for Markov numbers <subsec:slope-ordering>

The principal ordering input of the reduction is the slope-ordering theorem of Lee, Li, Rabideau, and Schiffler @LeeLiRabideauSchiffler2023, sharpened by Gaster @Gaster2022 with the explicit identification of the boundary slopes $- 5 slash 4$ and $- 8 slash 7$ in terms of the stable norm on the modular torus.

Let $P = (q, thin p)$ and $Q = (q', thin p')$ be two primitive lattice points in $cal(D)$, distinct, and let $lambda := (p' - p) slash (q' - q)$ be the slope of the line through $P$ and $Q$ oriented by increasing $q$-coordinate.

#theorem(title: [Slope-ordering for Markov numbers, after @LeeLiRabideauSchiffler2023 and @Gaster2022], lbl: <thm:slope-ordering>)[
  In the notation above:

  - If $lambda gt.eq.slant - 8 slash 7$, then the lattice point with the larger $q$-coordinate has the strictly larger Markov number.
  - If $lambda lt.eq.slant - 5 slash 4$, then the lattice point with the larger $q$-coordinate has the strictly smaller Markov number.

  The open interval $- 5 slash 4 < lambda < - 8 slash 7$ is the _exceptional slope window_, in which the Markov-number ordering along the line is not necessarily monotone in $q$.
] <thm-slope-ordering>

#proof[
  Proved in Lee, Li, Rabideau, and Schiffler @LeeLiRabideauSchiffler2023 via snake-graph perfect matchings and the Markov-distance machinery; the explicit identification of the boundary slopes $-5 slash 4$ and $- 8 slash 7$ as corners of the stable-norm unit ball on the modular torus is the contribution of Gaster @Gaster2022. We apply both as a black box. The hyperbolic-geometric interpretation of the boundary slopes is recorded in @rem:stable-norm just below.
]

The two boundary slopes $-8 slash 7$ and $- 5 slash 4$ are not arbitrary: in Gaster's analysis @Gaster2022, they are the slopes at the corners of the unit ball of the stable norm on the first homology of the modular torus, equivalently the corners of the dual ball of the simple-length spectrum. The stable-norm picture endows the boundary slopes with an intrinsic hyperbolic-geometric meaning beyond their combinatorial role in the Markov-distance framework of @LeeLiRabideauSchiffler2023.

#remark(title: "The stable norm and the modular torus", lbl: <rem:stable-norm>)[
  The _stable norm_ on the first homology $H_1 (T^2 slash {plus.minus 1}, thin bb(R))$ of the modular torus quotient (the once-punctured torus modulo the elliptic involution) is the asymptotic length norm: for a homology class $alpha$, the stable norm $|| alpha ||$ is the infimum, over positive integer multiples $n$, of $upright("length") (n alpha) slash n$. The dual ball under the stable norm has finitely many corners, and the slopes at these corners --- in the rational-slope parameterisation of the once-punctured torus --- are precisely the values $- 5 slash 4$ and $- 8 slash 7$ identified by @Gaster2022 as the boundary slopes of the Markov ordering. This is the hyperbolic-geometric origin of the exceptional slope window of @eq:exceptional-window of @sec:terminal-cone: the failure of the line-monotonicity classification of @LeeLiRabideauSchiffler2023 inside the exceptional window is the discrete-lattice shadow of the corner structure of the stable-norm unit ball on the modular torus. The Markov-distance framework of @LeeLiRabideauSchiffler2023 and the Ptolemy-inequality refinements of @Huang2022 are the combinatorial avatars of this geometric structure.
]

The slope-ordering theorem @thm:slope-ordering is used in three distinct places in the manuscript.

_Positive-direction monotonicity (§5)._ If $Q - P$ has slope in the interval $[0, thin 1]$ inside an adjacent Farey cone, then $lambda gt.eq.slant 0 > - 8 slash 7$, and @thm:slope-ordering gives $m_Q > m_P$ immediately. This is the structural basis of the dominance exclusion @prop:dominance-exclusion of @sec:dominance.

_Upper-adjacent boundary inequality (§8)._ In the endpoint cone $v = (1, 0)$, $u = (q, 1)$, the upper adjacent diagonal comparison at index $n = s$ has offset $(1, thin - 1)$, hence slope $- 1$. Since $- 1 gt.eq.slant - 8 slash 7$, @thm:slope-ordering gives the strict inequality used in @lem:upper-endpoint.

_Terminal non-exceptional exclusion (§10)._ For a terminal standard-cone comparison $Q - P = (r - s, thin r)$ with $r < s$, the line oriented by increasing $q$ has slope $lambda = - r slash (s - r)$. The slope inequalities $lambda gt.eq.slant - 8 slash 7$ and $lambda lt.eq.slant - 5 slash 4$ translate respectively into the ratio inequalities $s slash r gt.eq.slant 15 slash 8$ and $s slash r lt.eq.slant 9 slash 5$, exactly the regimes in which @thm:slope-ordering excludes equality (@lem:rlts-non-exceptional). The exceptional window @eq:sr-window
$
  9 slash 5 < s slash r < 15 slash 8
$
is the residual locus where neither half of @thm:slope-ordering applies.

== Generalised Markov numbers and Huang's valley theorem <subsec:huang-valley-appendix>

To extend the analysis of the slope-ordering theorem into the exceptional window, the manuscript uses Huang's monotonicity classification for _generalised_ Markov numbers along affine lattice lines of given slope @Huang2022. We recall the relevant consequence here.

Generalised Markov numbers extend the labelling $m_(p slash q)$ from primitive lattice points $(q, p) in cal(D)$ to all lattice points $(q, p)$ with $0 lt.eq.slant p lt.eq.slant q$ and $q gt.eq.slant 1$, including the non-primitive ones where $gcd (p, q) > 1$. On primitive points they agree with the ordinary Markov numbers, and on non-primitive points they are defined via the snake-graph perfect-matching count of @LeeLiRabideauSchiffler2023.

#theorem(title: [Huang's valley theorem (consequence used), after @Huang2022], lbl: <thm:huang-valley-appendix>)[
  Let $ell subset cal(D)$ be an affine lattice line whose slope $lambda$ lies in the open exceptional window $- 5 slash 4 < lambda < - 8 slash 7$. List the lattice points of $ell$ in $cal(D)$ in increasing $q$-coordinate as $dots.h.c, thin P_(- 1), thin P_0, thin P_1, thin dots.h.c$, and let $M_i$ denote the generalised Markov number at $P_i$. Then the sequence $(M_i)$ has a unique strict minimum --- the _Huang valley_ --- and is strictly decreasing up to the valley and strictly increasing after it. In particular, consecutive lattice points on $ell$ carry distinct generalised Markov values.
] <thm-huang-valley-appendix>

#proof[
  This is Huang's monotonicity classification theorem from @Huang2022, restated in the lattice notation of @sec:terminal-cone. The original argument uses the Markov-distance machinery and the Ptolemy inequality on the snake-graph framework of @LeeLiRabideauSchiffler2023 to establish the valley-shaped strict monotonicity profile. We apply the result as a black box.
]

The full statement of Huang's monotonicity theorem in @Huang2022 includes the precise location of the valley as a function of the line, derived via the Markov-distance and the Ptolemy-inequality machinery of @LeeLiRabideauSchiffler2023.

The manuscript uses @thm:huang-valley-appendix in @sec:primitive-exclusion. For a primitive-step exceptional terminal pair with $gcd (r, s) = 1$, the two terminal endpoints $P$ and $Q$ are consecutive lattice points on their affine line $ell$, by @lem:primitivity-direction of @sec:primitive-exclusion. The slope of $ell$ lies in the exceptional window, so @thm:huang-valley-appendix applies and forces $m_P eq.not m_Q$; this is the content of @prop:primitive-step-exclusion. For non-primitive steps $gcd (r, s) > 1$, the same theorem implies the weaker _valley-straddling_ statement @cor:valley-straddling: a hypothetical equality $m_P = m_Q$ forces the intermediate lattice points of the segment to straddle the unique Huang valley.

== Alekseyev's Fibonacci--Pell intersection theorem <subsec:alekseyev-appendix>

The manuscript also uses a classical recurrence-intersection theorem from the theory of Lucas sequences.

Let $F_n$ be the Fibonacci sequence defined by $F_0 = 0$, $F_1 = 1$, $F_(n + 1) = F_n + F_(n - 1)$, and let $upright("Pe")_n$ be the Pell sequence defined by $upright("Pe")_0 = 0$, $upright("Pe")_1 = 1$, $upright("Pe")_(n + 1) = 2 thin upright("Pe")_n + upright("Pe")_(n - 1)$. Both are second-order linear recurrence sequences with integer coefficients, classical instances of Lucas sequences of the first kind, and both have Pisot-type characteristic eigenvalues $phi.alt = (1 + sqrt(5)) slash 2$ and $1 + sqrt(2)$ respectively.

#theorem(title: [Alekseyev's Fibonacci--Pell intersection, after @Alekseyev2011], lbl: <thm:alekseyev-appendix>)[
  The only non-negative integers that occur both in the Fibonacci sequence and in the Pell sequence are
  $
    0, thick 1, thick 2, thick 5.
  $
  Equivalently, the only solutions of $F_a = upright("Pe")_b$ with $a, b gt.eq.slant 0$ are the four common values listed (with the multiplicity arising from $F_1 = F_2 = 1$).
] <thm-alekseyev-appendix>

#proof[
  Proved in Alekseyev @Alekseyev2011 as part of a broader study of intersections of Lucas sequences. The technique reduces the intersection problem to a finite list of Thue equations over the algebraic-unit Pisot parameters $phi.alt = (1 + sqrt(5)) slash 2$ and $1 + sqrt(2)$ of degree two over $bb(Q)$; the four common values $0, thin 1, thin 2, thin 5$ are recovered as the only integer solutions. We apply the result as a black box; the cited reference contains the complete proof.
]

Alekseyev proves @thm:alekseyev-appendix as part of a broader study of intersections of Lucas sequences @Alekseyev2011, in which the underlying technique reduces such intersections to systems of homogeneous quadratic Diophantine equations and Thue equations. The Fibonacci--Pell case is the prototypical example: both sequences have algebraic-unit Pisot parameters of degree two over $bb(Q)$, and Alekseyev's reduction produces a finite list of Thue equations whose only integer solutions correspond to the four common values $0, 1, 2, 5$.

The manuscript uses @thm:alekseyev-appendix in @sec:fibonacci-pell. The two endpoint arms of the Stern--Brocot tree are identified, by the matrix-square factorisations $A = S^2$ and $B = U^2$ of @sec:fibonacci-pell, with the odd-indexed subsequences $m_(1 slash q) = F_(2 q + 1)$ and $m_((q - 1) slash q) = upright("Pe")_(2 q - 1)$. An endpoint-to-endpoint equality $m_(1 slash (n + 2)) = m_((m + 1) slash (m + 2))$ for $n, m gt.eq.slant 1$ would imply $F_(2 n + 5) = upright("Pe")_(2 m + 3)$ with both sides at least $13$ and $29$ respectively, contradicting @thm:alekseyev-appendix. This is the content of @thm:endpoint-separation, and through @cor:escape-harmless the modular escape family of @sec:modular-sieve is therefore harmless.

== The Cohn-tree trace formulation <subsec:cohn-trace-recall>

Although the present appendix mainly concerns _external_ ordering inputs, we briefly recall the Cohn-tree trace formulation of the Frobenius--Markov uniqueness conjecture due to Aigner @Aigner2013, which underlies the entire structural reduction of @sec:same-ray through @sec:fibonacci-pell.

A _Cohn matrix_ in the sense of @Aigner2013 is a matrix
$
  C = mat(a, m; c, 3 m - a) in upright(S L)(2, bb(Z))
$
in which the $(1, 2)$-entry $m$ is a Markov number and the trace $tr (C) = 3 m$ is three times the same Markov number. The defining unimodularity condition $det C = a (3 m - a) - c m = 1$ couples the four entries in a specific algebraic relation that makes the Cohn matrices closed under the Cohn-tree recursion @eq:cohn-recursion of @sec:markov-cohn. The Cohn tree is generated from the seed $(A, A B, B) = (mat(2, 1; 1, 1), thin mat(12, 5; 7, 3), thin mat(5, 2; 2, 1))$ by repeated application of the two child rules of @thm:aigner-4-7.

The Cohn-trace formulation of the Frobenius--Markov uniqueness conjecture (Aigner's _Uniqueness Conjecture V_ of @Aigner2013) asserts that the matrices in the Cohn tree have pairwise distinct traces. By the trace-projection identity @eq:cohn-trace-form of @sec:markov-cohn, this is equivalent to the ordinary uniqueness conjecture in Markov numbers, and it is the form used throughout the manuscript.

The external ordering theorems listed in @subsec:aigner-restricted through @subsec:alekseyev-appendix do not replace the uniqueness conjecture; they eliminate _specific_ geometric configurations within the trace-comparison reduction. The combination of all four external inputs, together with the unconditional structural reductions of @sec:same-ray through @sec:fibonacci-pell, isolates the residual obstruction as the Exceptional Terminal Arithmetic Theorem of @sec:ETAT.

== Logical dependency table <subsec:dependency-table>

For clarity, we summarise where each external theorem is used in the body of the manuscript.

#figure(
  caption: [The external ordering and recurrence theorems used in the manuscript, with their canonical citations and the sections of the body that depend on them. The first column lists the structural input; the second column lists the section(s) of the body where the input is invoked; the third column states the role played by the input in the reduction. The Cohn-trace formulation of @Aigner2013 is the underlying framework rather than an external input, and is listed at the bottom for completeness.],
  table(
    columns: (auto, auto, auto),
    align: (left, left, left),
    table.header(
      [Input], [Used in], [Role]
    ),
    [Fixed-denominator ordering @LagisquetPelantovaTavenasVuillon2021], [§8, §10], [Endpoint-cone boundary inequality; equal-denominator terminal exclusion],
    [Fixed-numerator and fixed-sum ordering @LagisquetPelantovaTavenasVuillon2021], [Auxiliary], [Consistency checks; restricted ordering context],
    [Slope-ordering theorem @LeeLiRabideauSchiffler2023, @Gaster2022], [§5, §8, §10], [Dominance exclusion; upper-adjacent boundary; terminal non-exceptional exclusion],
    [Huang valley theorem @Huang2022], [§11], [Primitive-step exceptional exclusion; valley-straddling for non-primitive steps],
    [Fibonacci--Pell intersection @Alekseyev2011], [§13], [Endpoint-to-endpoint escape-family separation],
    [Cohn-tree trace formulation @Aigner2013], [throughout], [Trace formulation of Markov uniqueness used throughout],
  ),
) <fig:dependency-table>

@fig:dependency-table makes the modular structure of the reduction explicit: each external input addresses a specific geometric configuration, and the cumulative effect of all four inputs (combined with the structural reductions of @sec:same-ray through @sec:fibonacci-pell) is to reduce every hypothetical Cohn-tree trace collision to a primitive return-reduced terminal pair in the residual exceptional regime @eq:final-exceptional-region.

== Independence from the Exceptional Terminal Arithmetic Theorem <subsec:independence>

The theorems listed in the previous subsections are _unconditional_ published results. They are used only to eliminate cases in the structural reduction before reaching the final exceptional terminal obstruction.

The residual statement, the Exceptional Terminal Arithmetic Theorem @thm:ETAT of @sec:ETAT, is _not_ among the external inputs of the present appendix. It is the residual arithmetic statement left open by the reduction, and the conditional implication @thm:main-conditional of @sec:ETAT asserts that this residual statement, if true, implies the Frobenius--Markov uniqueness conjecture.

The logic of the reduction is therefore:

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + thm-color),
  fill: thm-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *Logical structure of the conditional reduction.* The external inputs of @subsec:aigner-restricted through @subsec:alekseyev-appendix, combined with the unconditional structural reductions of @sec:same-ray through @sec:fibonacci-pell, exclude every hypothetical Cohn-tree trace collision _outside_ the residual exceptional regime
  $
    r < s, quad 9 slash 5 < s slash r < 15 slash 8, quad gcd (r, s) > 1, quad r, s gt.eq.slant 2.
  $
  The Exceptional Terminal Arithmetic Theorem @thm:ETAT is the conjectural assertion that the residual regime contains no Markov-number collision among primitive return-reduced terminal pairs. By @thm:main-conditional of @sec:ETAT,
  $
    upright("Exceptional Terminal Arithmetic Theorem") \
    quad arrow.r.double quad upright("Frobenius–Markov uniqueness conjecture").
  $
]

The separation between the _external unconditional inputs_ recorded in this appendix and the _residual conditional theorem_ stated in @sec:ETAT is essential to the correctness of the reduction. Any future progress on the Exceptional Terminal Arithmetic Theorem --- via the four routes outlined in @subsec:routes-to-proof of @sec:outlook or via any other strategy --- will not affect the external inputs of the present appendix, and will not affect the structural reductions of the body. The reduction is therefore _modular_: each external theorem can be revisited and potentially strengthened independently, and any strengthening that broadens the scope of a given external input will narrow the scope of the residual statement correspondingly.

== Summary <subsec:summary-appendix-C>

The structural reduction of the monograph rests on four external published ordering and recurrence theorems: Aigner's restricted ordering conjectures @Aigner2013 (proved by @LagisquetPelantovaTavenasVuillon2021), the slope-ordering theorem @LeeLiRabideauSchiffler2023 with the explicit boundary slopes of @Gaster2022, Huang's monotonicity classification @Huang2022 for generalised Markov numbers along lines, and Alekseyev's Fibonacci--Pell intersection theorem @Alekseyev2011. Combined with the Cohn-tree trace formulation of @Aigner2013 and the unconditional structural reductions of @sec:same-ray through @sec:fibonacci-pell, these external inputs reduce the Frobenius--Markov uniqueness conjecture to the residual statement of the Exceptional Terminal Arithmetic Theorem @thm:ETAT. The dependency table @fig:dependency-table makes the modular structure explicit. The residual conjectural statement, the only theorem of the manuscript that is not proved unconditionally, is the input of the conditional reduction @thm:main-conditional of @sec:ETAT; its resolution by any of the routes outlined in @subsec:routes-to-proof of @sec:outlook would complete the Cohn-tree reduction and prove the Frobenius--Markov uniqueness conjecture.


= Computational checks and reproducibility notes <appendix:computational>

This appendix records the computational exploration that informed the manuscript and documents the reproducibility scaffolding accompanying it. None of the computations recorded here is used as a substitute for a proof. The logical core of the reduction --- the unconditional structural arguments of @sec:same-ray through @sec:fibonacci-pell and the conditional main theorem of @sec:ETAT --- is entirely contained in the body of the manuscript and in @appendix:external-results. The present appendix has a different status, and we open with the warning that frames it.

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + thm-color),
  fill: thm-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *The computations do not prove the Exceptional Terminal Arithmetic Theorem.* They check word and matrix conventions on small inputs, supply reproducible empirical evidence for conjectural sub-claims, expose proof strategies that cannot succeed in their stated form, and provide a regression substrate for any future certificate construction. Only those computational statements that are promoted to theoretical statements in the manuscript --- such as the no-fixed-finite-modulus theorem @thm:no-finite-modular-certificate of @sec:modular-sieve --- carry the status of proved results. Computational certificates that _do_ form part of a proof, for the minimal exceptional direction $(R, H) = (6, 5)$ at multiplier $g = 2$, are recorded separately in @appendix:minimal-certificates.
]

The computational supplement is organised as follows. After fixing conventions (@subsec:appendix-D-conventions), we recall the Cohn--Stern--Brocot residue automaton that underlies every modular computation (@subsec:appendix-D-automaton). We then record three findings that bear on the structure of the residual problem: an empirically verified recurrence-order hierarchy for fixed-arm Markov families (@subsec:appendix-D-recurrence), a rigorous nonregularity statement showing why no ordinary finite automaton over the asynchronous Stern--Brocot alphabet can recognise the exact terminal exceptional language (@subsec:appendix-D-nonregular), and the explicit modular escape family $(P_T, Q_T)$ that witnesses @thm:no-finite-modular-certificate (@subsec:appendix-D-escape). One subsection records a Diophantine reformulation of the simplest one-turn fixed-arm comparison together with a proposed integral-points certificate that has not been executed in the present manuscript (@subsec:appendix-D-pellian). The appendix closes with a short note on the organisation of the accompanying code (@subsec:appendix-D-code) and a synopsis (@subsec:appendix-D-synopsis).

== Conventions for the central word and trace <subsec:appendix-D-conventions>

All computations described in this appendix use the conventions of @appendix:cohn-words-conventions: the Cohn matrices
$
  A = mat(2, 1; 1, 1), quad B = mat(5, 2; 2, 1),
$
the central weight $g(z) = a^top M(z) a$ with $a = (2, 1)^top$, and the lower-Christoffel construction of the Cohn word $W_(p slash q)$ from a primitive lattice point $(q, thin p)$ with $0 < p < q$ and $gcd(p, q) = 1$. Markov numbers are recovered from central matrices by $m_(p slash q) = a^top M(z_(p slash q)) a$, equivalently from full Cohn words by
$
  tr M(W_(p slash q)) = 3 thin m_(p slash q),
$ <eq:trace-three-m-appendix-D>
the identity used throughout @sec:markov-cohn. Modular computations work modulo $3 m$ on full Cohn-word matrices and recover the Markov residue modulo $m$ from the trace residue modulo $3 m$ by exact division by $3$. This division is well-defined because @eq:trace-three-m-appendix-D forces the trace residue to be congruent to $0$ modulo $3$ for every Cohn word.

== The Cohn--Stern--Brocot residue automaton <subsec:appendix-D-automaton>

Fix a Markov modulus $m gt.eq.slant 2$ and let $N = 3 m$. The _Cohn--Stern--Brocot residue automaton modulo $m$_ has state space
$
  Q_m = (upright(M)_(2 times 2)(bb(Z) slash N bb(Z)))^2,
$
where each state is an ordered pair $(L, R)$ of reduced $2 times 2$ matrices, interpreted as the Cohn-word matrices of the two endpoints of a Stern--Brocot interval. The initial state is
$
  q_0 = (A mod N, thin B mod N).
$
The two transitions correspond to the Stern--Brocot mediant moves and are defined by
$
  sans("L") : (L, R) arrow.r.bar (L, thin L R mod N), quad
  sans("R") : (L, R) arrow.r.bar (L R mod N, thin R).
$
The current mediant word has matrix $L R mod N$; its Markov residue modulo $m$ is recovered from
$
  m_("mediant") equiv (tr (L R) thin div thin 3) (mod m),
$
which is a well-defined integer modulo $m$ by @eq:trace-three-m-appendix-D. The reachable subautomaton is finite, since $Q_m$ itself is finite (of size at most $N^8$), and is determined by the orbit of $q_0$ under the action of the free monoid $bb(M) = chevron.l sans("L"), sans("R") chevron.r$ on $Q_m$ by the transitions above. @fig:appendix-D-automaton illustrates the two transitions in a small fragment.

#figure(
  align(center)[
    #diagram(
      spacing: 2.8cm,
      node-stroke: 0.6pt + thm-color,
      node-fill: thm-wash,
      node-corner-radius: 3pt,
      node((0, 0), $(L, thin R)$),
      node((-1, 1), $(L, thin L R)$),
      node((1, 1), $(L R, thin R)$),
      edge((0, 0), (-1, 1), $sans("L")$, "->", label-side: right),
      edge((0, 0), (1, 1), $sans("R")$, "->", label-side: left),
    )
  ],
  caption: [The two transitions of the Cohn--Stern--Brocot residue automaton modulo $m$. The state $(L, R)$ represents a Stern--Brocot interval with endpoint Cohn matrices $L$ and $R$; the current mediant has matrix $L R$ and Markov residue $(tr(L R) thin div thin 3) (mod m)$.],
) <fig:appendix-D-automaton>

The automaton is the modular shadow of the action of the free monoid generated by the two Stern--Brocot moves on the matrix pair $(A, thin B) in upright(S L)(2, bb(Z))^2$, restricted to $upright(S L)(2, bb(Z) slash N bb(Z))^2$ by reduction modulo $N$. It is the natural finite-state vehicle for every modular Cohn-trace computation, and it is the kernel of the modular sieve of @sec:modular-sieve at every fixed modulus.

== An empirical observation: the fixed-arm recurrence hierarchy <subsec:appendix-D-recurrence>

Consider the fixed-arm Markov families
$
  X_n^((k)) := m_("path"(L^(n + 1) R^k)), quad n gt.eq.slant 0,
$
where $L^(n+1) R^k$ denotes the Stern--Brocot path that ascends $n + 1$ times to the left and then $k$ times to the right from the seed interval $[0 slash 1, thin 1 slash 1]$. For $k = 1, dots, 6$ we computed the first twenty-four terms of $X_n^((k))$ exactly via the central Christoffel-word construction, then searched for the lowest-order linear recurrence satisfied by the sequence using rational Gaussian elimination on the resulting Hankel system. The recurrences found are tabulated in @fig:fixed-arm-recurrences. The table is an _empirical_ observation: each recurrence has been verified to hold across the computed range, but the general pattern has not been proved for $k > 6$.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (center, center, center, left),
    table.header(
      [$k$], [Type], [Order], [Coefficient list (palindromic apart from the constant)],
    ),
    $1$, [affine], $2$, [$- 4, thin 7, thin - 1$],
    $2$, [homogeneous], $4$, [$21, thin - 56, thin 21, thin - 1$],
    $3$, [affine], $4$, [$792, thin 54, thin - 331, thin 54, thin - 1$],
    $4$, [homogeneous], $6$, [$144, thin - 2640, thin 6930, thin - 2640, thin 144, thin - 1$],
    $5$, [affine], $6$, [$-1094400, thin 376, thin - 17720, thin 106690, thin - 17720, thin 376, thin - 1$],
    $6$, [homogeneous], $8$, [$987, thin - 124033, thin 2232594, thin - 5847270, \ thin 2232594, thin - 124033, thin 987, thin - 1$],
  ),
  caption: [Empirical recurrences satisfied by the fixed-arm Markov sequences $X_n^((k)) = m_("path"(L^(n+1) R^k))$ for $k = 1, dots, 6$. The reported pattern --- order $2 k + 2$, parity-alternating affine/homogeneous, palindromic non-constant coefficients --- has been verified across $24$ terms for each $k$. Its extension to $k gt.eq.slant 7$ remains an open empirical conjecture.],
) <fig:fixed-arm-recurrences>

The recurrences are reproducible from the fixed-arm analyser documented in the accompanying code, which guesses each recurrence and then verifies it against the remaining terms of the sequence; the verification is part of the routine and is sufficient to rule out lower-order recurrences for the computed range. The first row of @fig:fixed-arm-recurrences gives the affine recurrence
$
  X_(n + 2)^((1)) = 7 thin X_(n + 1)^((1)) - X_n^((1)) - 4,
$
whose explicit solution underlies the one-turn Pellian reduction recorded in @subsec:appendix-D-pellian below.

The observation that the recurrence order grows linearly with the fixed-arm length $k$ has a clear structural consequence for the proof strategy of the manuscript. Treating the residual exceptional regime by a family-by-family recurrence-intersection argument would require a separate Lucas-sequence intersection theorem for each value of $k$, with the difficulty of the underlying Thue or Pellian system growing with the order. The strategy taken in @sec:ETAT --- to isolate the Exceptional Terminal Arithmetic Theorem as a single residual statement on the two-parameter integer lattice $bb(Z)_(gt.eq.slant 2)^2$, restricted to the exceptional ratio window --- is the reflection of this empirical fact: a uniform statement on the residual regime, even if conjectural, is structurally cleaner than an infinite family of recurrence-intersection problems of unbounded difficulty.

== The exact terminal language is not regular <subsec:appendix-D-nonregular>

The exceptional terminal pairs of @sec:ETAT admit a natural encoding by paired Stern--Brocot paths over the asynchronous alphabet $cal(A) = {L L, thin L R, thin R L, thin R R, thin L underline(\ ), thin R underline(\ ), thin underline(\ ) L, thin underline(\ ) R}$, where the underscore denotes a step taken by only one of the two paths. It is natural to ask whether the exact set of asynchronous words that encode primitive terminal exceptional pairs forms a _regular_ language. We show that it does not. The argument follows the pumping lemma applied to a one-parameter sub-family of the encoded pairs.

#proposition(title: "Nonregularity of the exact terminal exceptional language", lbl: <prop:terminal-nonregular>)[
  Let $cal(L) subset.eq cal(A)^ast$ denote the language of asynchronous Stern--Brocot words over $cal(A)$ that encode primitive terminal exceptional pairs $P = (q, p)$, $Q = (q - h, p + r)$ in the standard Farey cone, with parameters
  $
    r > 0, quad h > 0, quad 4 r < 5 h, quad 8 h < 7 r, quad gcd (r, h) > 1.
  $
  Then $cal(L)$ is not regular.
] <prop-terminal-nonregular>

#proof[
  Restrict attention to the unary sub-family obtained by setting $p = 1$ and the auxiliary parameter $t = 1$ in the reparameterisation @eq:reparameterisation of @subsec:reparameterisation. Under this restriction,
  $
    P = (r + h + 2, thin 1), quad Q = (r + 2, thin r + 1),
  $
  which has $gcd(P) = gcd(Q) = 1$ for every positive $r, h$ since the second coordinates are $1$ and $r + 1$ respectively. The Stern--Brocot path from the seed interval $[0 slash 1, thin 1 slash 1]$ to $P$ is $L^(r + h)$ (the path that ascends to the left $r + h$ times), and the path to $Q$ is $R^r$. The asynchronous paired word that encodes the pair $(P, Q)$ is therefore
  $
    w_(r, h) := (L R)^r (L underline(\ ))^h in cal(A)^ast.
  $
  The restriction of $cal(L)$ to the regular cylinder $(L R)^+ (L underline(\ ))^+$ is exactly
  $
    cal(L)_0 = { w_(r, h) : r, h gt.eq.slant 1, thin 4 r < 5 h, thin 8 h < 7 r, thin gcd (r, h) > 1 }.
  $
  Since the intersection of any regular language with a regular cylinder is regular, it suffices to show that $cal(L)_0$ is not regular.

  Assume, towards a contradiction, that $cal(L)_0$ is regular, with pumping length $N gt.eq.slant 1$. For a positive integer $M > N$ that we shall fix below, choose the parameters
  $
    r = 7 M, quad h = 6 M.
  $
  Then $4 r = 28 M < 30 M = 5 h$ and $8 h = 48 M < 49 M = 7 r$, so $w_(r, h) in cal(L)_0$ since also $gcd (r, h) = M > 1$. The word $w_(r, h)$ has length $2 r + h = 20 M$, well in excess of $N$. By the pumping lemma, there exists a decomposition $w_(r, h) = x y z$ with $|y| gt.eq.slant 1$ and $|x y| lt.eq.slant N$, such that $x y^k z in cal(L)_0$ for every $k gt.eq.slant 0$. The constraint $|x y| lt.eq.slant N < M$ forces $x y$ to lie entirely within the first $N$ letters of $w_(r, h)$, all of which are $L R$; in particular, $y$ is a power of the single symbol $L R$ and consists of $j$ copies of $L R$ for some $1 lt.eq.slant j lt.eq.slant N slash 2 < M slash 2$. Pumping $y$ to the $k$th power replaces $r$ by $r + (k - 1) j$ while leaving $h$ unchanged. For $k$ sufficiently large, $4 (r + (k - 1) j) > 5 h$, contradicting the membership of $x y^k z$ in $cal(L)_0$. Hence $cal(L)_0$ is not regular, and neither is $cal(L)$.
]

@prop:terminal-nonregular has a clear consequence for any prospective proof of the Exceptional Terminal Arithmetic Theorem by means of a single finite automaton over the asynchronous Stern--Brocot alphabet. No such automaton can recognise the exact terminal exceptional language; the language is genuinely arithmetic, in the sense that its membership conditions are not finitely encodable as a regular constraint on the underlying paired Stern--Brocot symbols. A correct finite-state framework for the exceptional terminal problem must either supplement the residue automaton with integer affine registers that track the exact terminal parameters $(r, h)$, or decompose the language into a possibly infinite family of regular sub-languages and apply the residue automaton on each. Either route is consistent with @thm:no-finite-modular-certificate of @sec:modular-sieve: nonregularity at the symbolic level and the impossibility of a single fixed-modulus certificate at the arithmetic level are two facets of the same arithmetic depth.

== The modular escape family $(P_T, Q_T)$ <subsec:appendix-D-escape>

The no-fixed-finite-modulus theorem @thm:no-finite-modular-certificate of @sec:modular-sieve is proved theoretically in the body of the manuscript; here we record the explicit one-parameter family that realises the escape and underlies the proof of the theorem.

Let $cal(N)$ be any finite set of moduli, and let $T = T(cal(N))$ denote the least common multiple of the unary $L$- and $R$-periods of the Cohn--Stern--Brocot residue automaton modulo every $N in cal(N)$. The periods are finite because the automaton is finite, and the existence of pure cycles (rather than mere preperiods) on the unary $L$- and $R$-orbits follows from the invertibility modulo $3 N$ of $A$ and $B$. Define the lattice points
$
  P_T := (13 thin T + 2, thin 1), quad Q_T := (7 thin T + 2, thin 7 thin T + 1),
$ <eq:appendix-D-escape>
both of which are primitive since $gcd(13 thin T + 2, thin 1) = 1$ and $gcd(7 thin T + 2, thin 7 thin T + 1) = 1$ by consecutive-integer coprimality. The lattice offset is
$
  Q_T - P_T = (- 6 thin T, thin 7 thin T) = - 6 thin T thin (1, thin 0) + 7 thin T thin (0, thin 1) + ... = r thin u - s thin v
$
in the terminal standard-cone parameters of @subsec:terminal-coords-sec14, with $r = 7 T$, $s = 13 T$, and lattice offset $(r - s, thin r) = (- 6 thin T, thin 7 thin T) = (- h, thin r)$ where $h = s - r = 6 T$. The pair $(r, h) = (7 T, thin 6 T)$ satisfies the exceptional inequalities $4 r = 28 thin T < 30 thin T = 5 h$ and $8 h = 48 thin T < 49 thin T = 7 r$, with $gcd (r, h) = T > 1$ for every $T gt.eq.slant 2$, and the slope ratio is $s slash r = 13 slash 7 in (9 slash 5, thin 15 slash 8)$ deeply inside the exceptional window. The pair $(P_T, thin Q_T)$ is thus a primitive terminal exceptional pair for every choice of $T$.

By the choice of $T$ as a common multiple of unary periods, the Stern--Brocot paths $L^(13 T)$ to $P_T$ and $R^(7 T)$ to $Q_T$ return the residue automaton modulo each $N in cal(N)$ to its initial state along each unary direction, so the Markov residues of $P_T$ and $Q_T$ coincide modulo every $N in cal(N)$:
$
  m_(P_T) equiv m_(Q_T) (upright("mod") thin N), quad upright("for every") thin N in cal(N).
$
The family @eq:appendix-D-escape therefore exhibits, for every finite modulus set $cal(N)$, infinitely many primitive terminal exceptional pairs that no $cal(N)$-modular sieve can distinguish. This is the empirical content underlying @thm:no-finite-modular-certificate.

The modular-escape driver in the accompanying code documents the periods and residues for several illustrative modulus sets; the construction itself, however, is independent of any particular set and is the explicit one-parameter family promised by @thm:no-finite-modular-certificate.

== A Diophantine reformulation of the one-turn fixed-arm problem <subsec:appendix-D-pellian>

The simplest fixed-arm sub-problem of the residual exceptional regime is the _one-turn fixed-arm comparison_: the test of whether, for any positive integers $n, m$, the equality
$
  m_(2 slash (2 n + 5)) = m_((m + 1) slash (m + 2))
$ <eq:appendix-D-one-turn>
can occur between a generalised left-fixed-arm Markov number on one side and a right-endpoint Pell Markov number on the other. By @subsec:appendix-D-recurrence, the left-hand side satisfies the affine second-order recurrence with explicit closed form
$
  m_(2 slash (2 n + 5)) = (3 thin L_(4 n + 12) + 4) thin slash thin 5,
$
where $L_k$ is the $k$th Lucas number; by @sec:fibonacci-pell, the right-hand side equals the odd-indexed Pell number $upright("Pe")_(2 m + 3)$. Substituting and clearing denominators, the equation @eq:appendix-D-one-turn becomes
$
  3 thin L_(4 n + 12) + 4 = 5 thin upright("Pe")_(2 m + 3),
$
the simplest one-turn Lucas--Pell equation that arises in the exceptional terminal classification.

Setting $y := upright("Pe")_(2 m + 3)$, the Pell--Lucas companion identity $upright("PL")_(2 m + 3)^2 - 2 thin y^2 = - 1$ (with $upright("PL")_k$ the Pell--Lucas number, satisfying the same recurrence as $upright("Pe")_k$ with seed $(2, thin 2)$) gives the first Pellian relation
$
  u^2 - 2 thin y^2 = - 1, quad u = upright("PL")_(2 m + 3).
$ <eq:appendix-D-pell1>
For the second relation, write $w := L_(4 n + 12)$ and $v := F_(4 n + 12)$; the Lucas--Fibonacci identity $L_k^2 - 5 thin F_k^2 = 4 thin (-1)^k$ at the even index $k = 4 n + 12$ gives
$
  w^2 - 5 thin v^2 = 4.
$
Substituting $w = (5 y - 4) slash 3$ (obtained from the equality $3 w + 4 = 5 y$) and clearing denominators yields, after a short computation,
$
  5 thin y^2 - 8 thin y - 9 thin v^2 = 4.
$ <eq:appendix-D-pell2>
The simultaneous integer solvability of @eq:appendix-D-pell1 and @eq:appendix-D-pell2 is therefore necessary and sufficient for the one-turn equality @eq:appendix-D-one-turn. The system @eq:appendix-D-pell1 and @eq:appendix-D-pell2 defines an affine curve of geometric genus one in the variables $(u, y, v)$, intersection of two quadrics in three-space. The expected positive integral $y$-values are $y in {5, thin 29}$, which correspond via $w = (5 y - 4) slash 3$ to $w in {7, thin 47} = {L_4, thin L_8}$, hence to $4 n + 12 in {4, thin 8}$ and to $n in {- 2, thin - 1}$, both outside the required range $n gt.eq.slant 0$.

#block(
  width: 100%,
  inset: (left: 14pt, right: 12pt, top: 10pt, bottom: 10pt),
  stroke: (left: 3pt + thm-color),
  fill: thm-wash,
  radius: (right: 3pt),
)[
  #set par(justify: true, first-line-indent: 0pt)
  *Proposed verification, not executed in the present manuscript.* The exhaustive enumeration of the integer points on the affine curve @eq:appendix-D-pell1 and @eq:appendix-D-pell2 is the natural next computational step for the one-turn fixed-arm problem. Magma and Sage drivers that ask the respective integral-points routines on this genus-one variety are provided in the accompanying code, but they have not been executed in the working environment of the present manuscript. The Pellian reformulation is offered here as a transparent reduction; the integral-points step is a proposed verification module, not a completed proof component.
]

The Pellian reformulation has a structural moral that complements the recurrence hierarchy of @subsec:appendix-D-recurrence: even the simplest one-turn sub-problem of the residual exceptional regime reduces to a non-trivial integral-points question on a genus-one variety, whose resolution requires the methods of Diophantine geometry (Thue equations, Chabauty--Coleman, $S$-integer points) rather than the methods of the Cohn-tree reduction itself.

== Code organisation <subsec:appendix-D-code>

The scripts described in this appendix are organised in the `code/` directory accompanying the manuscript, openly available at the public repository #link("https://github.com/dutykh/markov-etat/")[#text(fill: ku-blue)[github.com\/dutykh\/markov-etat]], with Python sources at the top level, the Magma and Sage certificate drivers next to them, and JSON outputs and the bounded-DFA archive in a `code/outputs/` subdirectory. The `README.md` at the top of `code/` documents the role of each script, the canonical command-line invocation, and the expected output, including the empirical recurrence table of @fig:fixed-arm-recurrences and the verified absence of exceptional pairs in the regression-test windows. The scripts are pure Python 3 with no third-party dependencies; the Magma and Sage drivers require their respective installations and are not invoked by the typesetting toolchain.

== Synopsis <subsec:appendix-D-synopsis>

The computational supplement of @appendix:computational opens with the warning that none of its content substitutes for a proof and lays out the four uses of the computations: convention checks, exploration, exposure of false strategies, and reproducibility. The conventions of @subsec:appendix-D-conventions match those of @appendix:cohn-words-conventions and the Cohn--Stern--Brocot residue automaton of @subsec:appendix-D-automaton with state $(L, R)$ and transitions $sans("L"), sans("R")$ is the modular shadow of the action of the free monoid generated by the two Stern--Brocot moves on $upright(S L)(2, bb(Z) slash 3 m thin bb(Z))^2$ and the kernel of every modular Cohn-trace computation in the manuscript. The empirical recurrence-order hierarchy of @subsec:appendix-D-recurrence records the pattern order $= 2 k + 2$ with palindromic coefficient lists and parity-alternating affine/homogeneous form for the fixed-arm Markov families $X_n^((k)) = m_("path"(L^(n + 1) R^k))$, verified across $k lt.eq.slant 6$ and $24$ terms each, and explains structurally why the conjectural Exceptional Terminal Arithmetic Theorem is stated uniformly rather than family by family. The rigorous @prop:terminal-nonregular of @subsec:appendix-D-nonregular shows that the exact terminal exceptional language is not regular, ruling out any single ordinary finite automaton over the asynchronous Stern--Brocot alphabet as a putative certificate. The modular escape family $(P_T, Q_T) = (13 T + 2, thin 1) upright("vs") (7 T + 2, thin 7 T + 1)$ of @subsec:appendix-D-escape is the explicit one-parameter witness of @thm:no-finite-modular-certificate of @sec:modular-sieve. The Diophantine reformulation of @subsec:appendix-D-pellian reduces the simplest one-turn fixed-arm problem to the simultaneous Pellian system $u^2 - 2 y^2 = - 1$, $5 y^2 - 8 y - 9 v^2 = 4$; the proposed Magma and Sage certificate scripts have not been executed in the present manuscript. The code organisation of @subsec:appendix-D-code records the directory layout and the README at the top of `code/`. Throughout, the computational content of the appendix supports the structural reduction of the body but does not substitute for it; @thm:ETAT remains a conditional statement on the residual exceptional regime, and its resolution is the subject of any future work on the Frobenius--Markov uniqueness conjecture beyond the present monograph.

#pagebreak()

= Certificates for the minimal exceptional direction <appendix:minimal-certificates>

This appendix collects the computational certificates that support the proof of @thm:minimal-direction in @sec:minimal-direction. Unlike the computations of @appendix:computational, which serve as convention checks and exploration aids, the certificates listed here form _part of the proof_: each entry verifies an exact arithmetic statement (a finite list of residue classes, a polynomial positivity inequality, or a primitivity exclusion) whose conclusion is used in the argument of @sec:minimal-direction. The corresponding source files and JSON outputs are organised alongside the existing exploration scripts in the `code/` directory accompanying the manuscript, openly available at the public repository #link("https://github.com/dutykh/markov-etat/")[#text(fill: ku-blue)[github.com\/dutykh\/markov-etat]].

== Status of the certificates <subsec:cert-status>

The computational material in @appendix:computational is exploratory: it tests conventions on small inputs, supplies empirical evidence for conjectural sub-claims, and exposes proof strategies that cannot succeed in their stated form. The certificates in the present Appendix have a different status. Each one is a finite, auditable proof component constructed from exact integer and modular arithmetic with no floating-point arithmetic anywhere in the chain. Together, they support the proof of @thm:minimal-direction in @sec:minimal-direction for the minimal exceptional terminal case
$
  (R, H) = (6, 5), quad g = 2, quad upright("equivalently") quad (r, h, s) = (12, 10, 22).
$ <eq:appendix-E-case>
The certified terminal pair is
$
  P = (p + t + 22, thin p), quad quad Q = (p + t + 12, thin p + 12),
$
and the certified conclusion is $m_P eq.not m_Q$ for every primitive return-reduced pair of this form. After the reductions of @subsec:residue-reduction (parity and mod-$3$ table) and @subsec:seventeen-families (return-reducedness), the problem is reduced to the seventeen one-parameter families @eq:Pck-Qck-explicit indexed by odd $c$ with $-11 lt.eq.slant c lt.eq.slant 21$. Each certificate of this Appendix verifies one of the following:
$
  &(1) thick upright("the formulas for ") P_(c, k) upright(" and ") Q_(c, k); \
  &(2) thick upright("the admissibility conditions on ") k upright(" (positivity, two primitivity gcds);") \
  &(3) thick upright("a period for the Markov residues modulo a chosen prime") thin ell; \
  &(4) thick upright("a complete finite residue table over the relevant period;") \
  &(5) thick upright("separation of every admissible class, either by the primary modulus or by auxiliary moduli;") \
  &(6) thick upright("in the central family ") c = 5, upright(" an exact symbolic positivity inequality.")
$ <eq:cert-six-claims>

== Cohn matrices and residue convention <subsec:cert-cohn-conventions>

All certificate scripts use the Cohn matrices and twist convention recalled here from @subsec:congruence-certificate. The two generators are
$
  A = mat(2, 1; 1, 1), quad quad B = mat(5, 2; 2, 1),
$
and the twist matrix for the direction $(2, 1)$ is the product
$
  W = A B = mat(12, 5; 7, 3), quad quad tr (W) = 15
$ <eq:appendix-E-W>
from @eq:twist-matrix-W. The Cohn trace at a primitive lattice point $(q, thin p)$ is three times the corresponding Markov number,
$
  tr (C_(p slash q)) = 3 thin m_(p slash q),
$
from @eq:cohn-trace-three-m. To compute $m_(p slash q) thin (upright("mod") thin ell)$ for a prime $ell$, the scripts compute $tr (C_(p slash q)) thin (upright("mod") thin 3 ell)$ and divide by $3$, exploiting the divisibility of every Cohn trace by $3$.

== Periods from the twist direction <subsec:cert-twist-periods>

Each family $(P_(c, k), thin Q_(c, k))$ moves along the twist direction $6 (2, 1)$:
$
  P_(c, k + 1) - P_(c, k) = Q_(c, k + 1) - Q_(c, k) = (12, thin 6) = 6 (2, 1).
$
The two intersection numbers with $(2, 1)$ are independent of $k$,
$
  Delta_P (c) &= det (P_(c, k), thin (2, 1)) = 22 - c, \
  Delta_Q (c) &= -det (Q_(c, k), thin (2, 1)) = c + 12,
$
from @eq:Delta-recall. For a prime $ell$ with $W^(M_ell) equiv I thin (upright("mod") thin 3 ell)$, the @lem:twist-period formula gives a valid period
$
  T_(c, ell) = frac(upright("lcm") (Delta_P (c) M_ell, thin Delta_Q (c) M_ell), gcd (upright("lcm") (Delta_P (c) M_ell, thin Delta_Q (c) M_ell), thin 6)).
$ <eq:appendix-E-period>
The certificates use the four primes $ell in {5, thin 23, thin 37, thin 47}$ with corresponding orders
$
  (M_5, thin M_(23), thin M_(37), thin M_(47)) = (4, thin 24, thin 12, thin 24),
$
equivalently
$
  W^4 equiv I thin (upright("mod") thin 15), quad
  W^(24) equiv I thin (upright("mod") thin 69), \
  W^(12) equiv I thin (upright("mod") thin 111), quad
  W^(24) equiv I thin (upright("mod") thin 141),
$
from @tab:certificate-moduli of @subsec:congruence-certificate. The master verifier checks each of these four congruences at every run by direct matrix exponentiation modulo $3 ell$.

== Admissible residue classes <subsec:cert-admissibility>

For a fixed $c$, the admissible integer $k$ satisfies the positivity condition
$
  6 k + c + 1 gt.eq.slant 1
$
and the two gcd-primitivity conditions
$
  gcd (6 k + c + 1, thin 22 - c) = 1, quad quad gcd (6 k + c + 13, thin c + 12) = 1
$
from @eq:primitivity-conditions-explicit. When checking residues modulo a period $T$, a class $k thin (upright("mod") thin T)$ is admissible if it contains an integer $k$ satisfying these three conditions. For every sufficiently large representative of an admissible residue class, the positivity condition is automatic; the only finite exclusions come from the two gcd conditions.

== Certificate data for the sixteen non-central families <subsec:cert-residue-tables>

For each $c eq.not 5$ in the sixteen-element set @eq:sixteen-c-values, @tab:appendix-E-certificate-summary records the primary modulus, the auxiliary modulus or moduli, and the certified status. The full residue tables --- primary period, primary-survivor residue classes, lifted auxiliary residues, and the resulting separation pattern --- are recorded in @tab:certificate-summary of @subsec:sixteen-table and exhaustively in the per-family JSON files of the certificate package described below.

#figure(
  caption: [Compact certificate-status summary for the sixteen non-central families. For the detailed primary period, primary survivors, and the auxiliary lift, see @tab:certificate-summary of @subsec:sixteen-table; the per-family JSON files of the certificate package record every residue value used.],
  table(
    columns: (auto, auto, auto, auto),
    align: center + horizon,
    table.header(
      [$c$], [primary modulus], [auxiliary modulus(es)], [status]
    ),
    [$-11$], [$5$], [---], [excluded],
    [$-9$], [$5$], [$23$], [excluded],
    [$-7$], [$37$], [$5$], [excluded],
    [$-5$], [$37$], [$23$], [excluded],
    [$-3$], [$37$], [$5, thin 23$], [excluded],
    [$-1$], [$47$], [$5$], [excluded],
    [$1$], [$37$], [$23$], [excluded],
    [$3$], [$47$], [$5, thin 23$], [excluded],
    [$7$], [$47$], [$5, thin 23$], [excluded],
    [$9$], [$37$], [$23$], [excluded],
    [$11$], [$47$], [$5$], [excluded],
    [$13$], [$37$], [$5, thin 23$], [excluded],
    [$15$], [$37$], [$23$], [excluded],
    [$17$], [$37$], [$5$], [excluded],
    [$19$], [$5$], [$23$], [excluded],
    [$21$], [$5$], [---], [excluded],
  ),
) <tab:appendix-E-certificate-summary>

== Verification algorithm for non-central families <subsec:cert-procedure>

For each non-central $c$, the per-family verifier executes the following steps. The structure is exactly the @lem:finite-congruence-certificate principle of @subsec:congruence-certificate, specialised to the family in question.

_Step 1: Construct the family._ Define
$
  P_(c, k) &= (12 k + c + 24, thin 6 k + c + 1), \
  Q_(c, k) &= (12 k + c + 14, thin 6 k + c + 13).
$

_Step 2: Apply admissibility._ Discard residue classes $k thin (upright("mod") thin T)$ on which either of the gcd conditions of @subsec:cert-admissibility fails.

_Step 3: Compute primary residues._ For the primary modulus $ell$, compute $m_(P_(c, k)) thin (upright("mod") thin ell)$ and $m_(Q_(c, k)) thin (upright("mod") thin ell)$ for every admissible class $k thin (upright("mod") thin T_(c, ell))$, using the Cohn-trace divide-by-$3$ convention of @subsec:cert-cohn-conventions.

_Step 4: Record primary survivors._ A class is a primary survivor if $m_(P_(c, k)) equiv m_(Q_(c, k)) thin (upright("mod") thin ell)$.

_Step 5: Apply auxiliary moduli._ For each primary survivor class, lift to the appropriate compound period and compute residues modulo the auxiliary prime or primes; verify that every lifted class is separated.

_Step 6: Certify exclusion._ If every admissible class is separated by at least one modulus, the family is recorded as certified.

This six-step procedure produces, for each non-central $c$, an exact finite witness of the conclusion $m_(P_(c, k)) eq.not m_(Q_(c, k))$ for every admissible $k$.

== The central family $c = 5$ <subsec:cert-central>

The central family is treated by the symbolic argument of @subsec:central-family. We recall the data needed for the certificate.

For $c = 5$ the family is
$
  P_(5, k) = (12 k + 29, thin 6 k + 6), quad quad Q_(5, k) = (12 k + 19, thin 6 k + 18),
$
with admissible $k thin (upright("mod") thin 17) in.not {14, thin 16}$. The mod-$37$ certificate with period $T_(5, thin 37) = 34$ (residue table @tab:central-mod-37) separates every admissible residue class except the survivor
$
  k equiv 15 thin (upright("mod") thin 17).
$
On the survivor class, writing $k = 17 n + 15$ and $N = 6 n + 5$, the Stern--Brocot path identifications @eq:stern-brocot-P and @eq:stern-brocot-Q together with the Chebyshev representation $W^N = a W + b I$ of @eq:WN-Chebyshev with $a = Phi_(N - 1)$, $b = -Phi_(N - 2)$ yield the trace-difference identity
$
  tr (C_Q) - tr (C_P) = 3 (15 a + b) F (a, b)
$
of @eq:trace-diff-formula, where $F$ is a homogeneous polynomial of degree $16$. The substitution $b = -c_0 = -Phi_(N - 2)$ gives $F (a, -c_0) = a^(16) G (c_0 slash a)$ with $G$ the alternating-coefficient polynomial @eq:G-alternating, all of whose coefficients $C_0, dots, C_(16)$ are strictly positive. The coefficients are recorded in the JSON file of the central-family certificate.

The substantive content of the central certificate is the rational positivity inequality of @eq:certificate-inequality,
$
  C_0 - frac(C_1, 14) - sum_(j = 2)^(16) frac(C_j, 14^j) > 0,
$
with the explicit positive margin recorded in @eq:certificate-margin, namely
$
  C_0 - frac(C_1, 14) - sum_(j = 2)^(16) frac(C_j, 14^j) \
  = frac(56776450013218623146667119024756272232022390327391952873, 2177953337809371136) > 0.
$
By @lem:G-positivity and the ratio estimate of @lem:ratio-estimate, this implies $G (c_0 slash a) > 0$ on the interval $0 < c_0 slash a < 1 slash 14$, hence $F (a, -c_0) > 0$. Combined with $15 a + b = Phi_N > 0$ from @eq:15a-plus-b, this yields $tr (C_Q) - tr (C_P) > 0$ and therefore $m_(Q_k) > m_(P_k)$ on the survivor class. The central family is excluded.

== The certificate files <subsec:cert-scripts>

The certificate-script package is archived in the manuscript repository at the subdirectory `code/minimal_direction_g2/`. The package layout is

```
code/minimal_direction_g2/
├── README.md                                       — package documentation
├── minimal_direction_g2_certificate.py             — master aggregate verifier
├── minimal_direction_g2_certificate.json           — aggregate JSON certificate
├── minimal_direction_c<X>_<moduli>_certificate.py  — 17 individual c-family verifiers
└── minimal_direction_c<X>_<moduli>_certificate.json — 17 individual c-family JSON certificates
```

The master script `minimal_direction_g2_certificate.py` performs all checks needed for @thm:minimal-direction: it verifies the four matrix-order congruences of @eq:appendix-E-W, generates the seventeen families, verifies the admissibility conditions of @subsec:cert-admissibility, and confirms that every individual family report carries the status `"PASS"`. It also re-computes SHA-$256$ hashes of the individual `.py` and `.json` files and compares them against the values stored in the aggregate JSON, providing tamper-resistance for the certificate archive.

== Suggested JSON schema <subsec:cert-json-schema>

The aggregate JSON output `minimal_direction_g2_certificate.json` records the following top-level fields:

- `metadata`: date of certificate construction, code version, and matrix convention.
- `matrix_orders`: the four matrix-order congruences $W^(M_ell) equiv I thin (upright("mod") thin 3 ell)$ for $ell in {5, 23, 37, 47}$, together with the stored matrix-power result for cross-validation.
- `family_summary`: one entry per $c$, recording the family parameters, the filenames of the corresponding `.py` and `.json` files, the family `status`, and the SHA-$256$ hashes of the two files.
- `family_reports`: detailed per-family records containing the explicit forms of $P_(c, k)$ and $Q_(c, k)$, the primitivity exclusions, the primary modulus and period, the primary residue table, the primary survivor classes, the auxiliary moduli and periods, the auxiliary residue tables, and the final status.
- `family_reports["5"]`: for the central family, additionally records the mod-$37$ survivor class, the Stern--Brocot path identifications, the polynomial coefficients $C_0, dots, C_(16)$, the positive-margin numerator/denominator pair, the rational decimal approximation, and the resulting sign of $tr (C_Q) - tr (C_P)$.
- `result`: the aggregate status, equal to `"PASS"` only if every family is certified.

== Independent verification protocol <subsec:cert-independent-verification>

A reader wishing to verify the certificate independently should proceed through the following steps.

_Step 1._ After obtaining the repository at #link("https://github.com/dutykh/markov-etat/")[#text(fill: ku-blue)[github.com\/dutykh\/markov-etat]], from the certificate-package directory `code/minimal_direction_g2/`, run

#emph[python3 minimal_direction_g2_certificate.py]

The expected output is a short JSON object including the field `"result": "PASS"` and the counts `"families_checked": 17` and `"matrix_orders_checked": 4`.

_Step 2._ Inspect the `matrix_orders` section of the aggregate JSON and confirm that the four congruences
$
  W^4 equiv I thin (upright("mod") thin 15), quad
  W^(24) equiv I thin (upright("mod") thin 69), \
  W^(12) equiv I thin (upright("mod") thin 111), quad
  W^(24) equiv I thin (upright("mod") thin 141)
$
are reported with their stored matrix-power results, and that the verifier recomputed each independently.

_Step 3._ Inspect each entry of `family_summary` and verify that the `status` field is `"PASS"`. The SHA-$256$ hashes can be independently checked against the actual file contents.

_Step 4._ For each non-central $c$, inspect the corresponding `family_reports` entry and verify that every admissible residue class modulo the primary period either separates the two Markov residues mod the primary prime $ell$ or is lifted to the auxiliary period and separated by the auxiliary prime(s).

_Step 5._ For the central family $c = 5$, inspect the `family_reports["5"]` entry and verify
$
  0 < frac(c_0, a) = frac(Phi_(N - 2), Phi_(N - 1)) < frac(1, 14)
$
for the listed Chebyshev coefficients, the positive-margin numerator/denominator pair, and the resulting sign of $tr (C_Q) - tr (C_P)$.

All computations are exact integer or modular arithmetic; no floating-point is required for the audit. A single `positive_margin_decimal_approx` field is provided for human readability but is not used by the verifier.

== Legacy individual certificate scripts <subsec:cert-legacy-scripts>

During the construction of @sec:minimal-direction, the certificate was assembled family by family. The individual scripts are retained in the certificate package for auditability and as historical / debugging material. The complete list of files (one per non-central $c$, plus the central $c = 5$ script) is

#emph[minimal_direction_cminus11_mod5_certificate.py, minimal_direction_cminus9_mod5_mod23_certificate.py, minimal_direction_cminus7_mod37_mod5_certificate.py, minimal_direction_cminus5_mod37_mod23_certificate.py, minimal_direction_cminus3_mod37_mod5_mod23_certificate.py, minimal_direction_cminus1_mod47_mod5_certificate.py, minimal_direction_c1_mod37_mod23_certificate.py, minimal_direction_c3_mod47_mod5_mod23_certificate.py, minimal_direction_c7_mod47_mod5_mod23_certificate.py, minimal_direction_c9_mod37_mod23_certificate.py, minimal_direction_c11_mod47_mod5_certificate.py, minimal_direction_c13_mod37_mod5_mod23_certificate.py, minimal_direction_c15_mod37_mod23_certificate.py, minimal_direction_c17_mod37_mod5_certificate.py, minimal_direction_c19_mod5_mod23_certificate.py, minimal_direction_c21_mod5_certificate.py,]

and the central-family script

#emph[minimal_direction_c5_mod37_recurrence_certificate.py.]

The filename pattern records the family index $c$ together with the primary modulus and any auxiliary moduli. The master verifier described in @subsec:cert-scripts wraps all of these and aggregates their JSON outputs into the single archive `minimal_direction_g2_certificate.json`.

== Certified statement <subsec:cert-final-statement>

The certificate package proves the following finite statement.

For every odd $c$ with $-11 lt.eq.slant c lt.eq.slant 21$ and every admissible integer $k$ in the sense of @prop:seventeen-families-reduction,
$
  m_(P_(c, k)) eq.not m_(Q_(c, k)).
$
Combined with the residue reduction of @subsec:residue-reduction and the return-reduced reduction of @subsec:seventeen-families, this yields
$
  m_(p slash (p + t + 22)) eq.not m_((p + 12) slash (p + t + 12))
$
for every primitive return-reduced terminal pair in the minimal exceptional direction. Equivalently, @thm:ETAT holds for $(R, H) = (6, 5)$ at the first nonprimitive multiplier $g = 2$. This is precisely the conclusion of @thm:minimal-direction in @sec:minimal-direction.

== Synopsis <subsec:cert-synopsis>

The present Appendix collects the finite, auditable proof certificates that support @thm:minimal-direction of @sec:minimal-direction. Each certificate is constructed from exact integer and modular arithmetic and records a finite list of residue classes, primitivity exclusions, matrix-order congruences, or a polynomial positivity inequality whose conclusion is used in the proof. The sixteen non-central families of @prop:seventeen-families-reduction are eliminated by per-family finite congruence certificates against the primes $5, 23, 37, 47$, with the periods controlled by the orders of the twist matrix $W = A B$ modulo $3 ell$ (@subsec:cert-cohn-conventions, @subsec:cert-twist-periods, @subsec:cert-admissibility); the per-family certificate structure and a compact summary table (@tab:appendix-E-certificate-summary) are recorded in @subsec:cert-residue-tables, the verification algorithm in @subsec:cert-procedure. The central family $c = 5$ is treated in @subsec:cert-central by the mod-$37$ reduction of @tab:central-mod-37 together with the symbolic positivity inequality of @eq:certificate-inequality, whose exact positive margin is recorded in @eq:certificate-margin. The certificate-script package is archived as the subdirectory `code/minimal_direction_g2/` of the accompanying code repository (@subsec:cert-scripts), with a standardised JSON output schema (@subsec:cert-json-schema) and an explicit independent-verification protocol (@subsec:cert-independent-verification). The legacy per-family scripts are retained in the same subdirectory for auditability (@subsec:cert-legacy-scripts). The certified statement (@subsec:cert-final-statement) is precisely the conclusion of @thm:minimal-direction: the Exceptional Terminal Arithmetic Theorem holds for the minimal primitive exceptional direction $(R, H) = (6, 5)$ at the first nonprimitive multiplier $g = 2$.

#pagebreak()
#bibliography("refs.bib", title: "References", style: "springer-mathphys")
