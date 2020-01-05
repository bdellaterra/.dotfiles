" To avoid conceal syntax that's redundant with ligatures:
" let g:font_ligatures = 1
let hasFontLigatures = get(g:, 'font_ligatures_enabled', 0)

syntax keyword jsVariableType const conceal cchar=● containedin=jsOperator,jsObject " ■▣◉◈◇⋄◆● ∃
syntax keyword jsVariableType let conceal cchar=⊙ containedin=jsOperator,jsObject
syntax keyword jsVariableType var conceal cchar=◍ containedin=jsOperator,jsObject

syntax keyword jsBuiltinValues null cchar=ø conceal contained " ␀
syntax keyword jsBuiltinValues undefined cchar=⬚ conceal contained " ␣
syntax keyword jsBuiltinValues NaN conceal cchar=Ӣ " Ꜻ
syntax keyword jsBuiltinValues true conceal cchar=⊤
syntax keyword jsBuiltinValues false conceal cchar=⊥ " use ⟂ (perpendicular) if ⊥ (bottom) looks too light
syntax keyword jsBuiltinValues Infinity conceal cchar=∞

syntax keyword jsFunction function conceal cchar=ƒ
syntax keyword jsReturn return contained conceal cchar=↲ skipwhite containedin=jsOperator,jsObject nextgroup=@jsExpression
syntax keyword jsYield yield contained conceal cchar=↳ skipwhite nextgroup=@jsExpression " ↬⇄↔⟷
syntax keyword jsAsync async conceal cchar=⍋ skipwhite " ☾⇲ª
syntax keyword jsAwait await conceal cchar=⍒ skipwhite " ☽⇱⍹
syntax match jsThis "this" conceal cchar=@ containedin=jsFuncArgs,jsObjectShorthandProp

if (!hasFontLigatures)
  syntax match jsAnd "&&" conceal cchar=∧ containedin=jsOperator
  syntax match jsOr "||" conceal cchar=∨ containedin=jsOperator
  syntax match jsNot "!" conceal cchar=￢ containedin=jsOperator,jsFuncArgs " ¬~～
  syntax match jsEqual ">=" conceal cchar=≥ containedin=jsOperator,jsObject
  syntax match jsEqual "<=" conceal cchar=≤ containedin=jsOperator,jsObject
  syntax match jsEqual "!==" conceal cchar=≠ containedin=jsOperator,jsObject
  syntax match jsEqual "=" conceal cchar=≔ containedin=jsOperator,jsObject " ←
  syntax match jsEqual "==" conceal cchar=≟ containedin=jsOperator,jsObject " ≒
  syntax match jsEqual "===" conceal cchar=≡ containedin=jsOperator,jsObject " 〓
  syntax match jsDot "\.\.\." conceal cchar=… containedin=noise
  syntax match jsFuncArgOperator "=>" conceal cchar=⇒ containedin=jsObject,jsFuncArgs
  syntax match jsArrowFunction /=>/ skipwhite skipempty nextgroup=jsFuncBlock,jsObject,jsFuncArgs,jsCommentFunction conceal cchar=⇒
endif

"" " Under Consideration:
"" syntax match jsOperator "/" conceal cchar=÷ contained skipwhite skipempty nextgroup=@jsExpression
"" syntax match jsOperator "*" conceal cchar=× contained skipwhite skipempty nextgroup=@jsExpression
"" syntax keyword jsIf if conceal cchar=↘ containedin=jsOperator,jsObject " ↕↔→◇⁇ϕΦφϕ⏀ψΨ⋔↔∵∷☰≡⁇⊃※∗*＊
"" syntax keyword jsIdentifier else conceal cchar=∨ containedin=jsOperator,jsObject " →⊢⟥
"" syntax keyword jsAsync async conceal cchar=⇲ skipwhite " ☾ª
"" syntax keyword jsAwait await conceal cchar=⇱ skipwhite " ☽⍹
"" syntax keyword jsClassKeyword class conceal cchar=∀
"" syntax match jsClassExtension "extends" conceal cchar=⊂
"" syntax keyword jsSuper super contained conceal cchar=Ω
"" syntax match jsTopOperator "++" conceal cchar=⧺ containedin=jsOperator
"" syntax match jsTopOperator "--" conceal cchar=╌ containedin=jsOperator
"" syntax match jsEqual "+=" conceal cchar=∆ containedin=jsOperator
"" syntax match jsEqual "-=" conceal cchar=∇ containedin=jsOperator
"" syntax match jsComment "//" conceal cchar=〜
"" syntax region  jsComment        start=+//+ end=/$/ contains=jsCommentTodo,@Spell extend keepend
"" syntax region  jsComment        start=+/\*+  end=+\*/+ contains=jsCommentTodo,@Spell fold extend keepend
"" syntax keyword jsImport import conceal cchar=⇲
"" syntax keyword jsExport export conceal cchar=⇱
"" syntax keyword jsConditional "else if" conceal cchar=⊨
"" syntax keyword jsConditional switch conceal cchar=∈
"" syntax keyword jsLabel case conceal cchar=→
"" syntax keyword jsTry try conceal cchar=ψ " ⍕⍦◇◊⟠◻†
"" syntax match jsArrowFunction /()\ze\s*=>/ skipwhite skipempty nextgroup=jsArrowFunction conceal cchar=○ " 〇□
"" syntax match jsArrowFunction /_\ze\s*=>/ skipwhite skipempty nextgroup=jsArrowFunction conceal cchar=○
"" syntax keyword jsFuncBlock catch conceal cchar=↯
"" syntax keyword jsPrototype prototype conceal cchar=℗
"" syntax keyword jsFuncArgs this conceal cchar=@
"" syntax keyword jsObjectShorthandProp this conceal cchar=@
"" syntax keyword jsThis this conceal cchar=@
"" syntax match jsCommentLine '//' conceal cchar=╱
"" syntax match jsCommentStart '/*' conceal cchar=╱
"" syntax match jsCommentEnd '*/' conceal cchar=╱
"" syntax match jsCommentAsterisk /\(^\s*\)\@<=\*/ conceal cchar=✱ nextgroup=@jsComment " ‖⁑✻✼✽✾❀✿❁❃❇❈❉❊❋
"" syntax match jsCommentDoubleAsterisk /\(^\s*\/\)\@<=\*\*/ conceal cchar=✱ nextgroup=@jsComment
