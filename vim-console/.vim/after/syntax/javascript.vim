
syntax match jsAnd "&&" conceal cchar=∧ containedin=jsOperator
syntax match jsOr "||" conceal cchar=∨ containedin=jsOperator
syntax match jsNot "!" conceal cchar=￢ containedin=jsOperator " ¬~～
syntax match jsDivisionSign "/" contained conceal cchar=÷ containedin=jsOperator nextgroup=@jsExpression
syntax match jsMultiplicationSign "*" conceal cchar=× containedin=jsOperator nextgroup=@jsExpression

" syntax match jsDecrement "++" conceal cchar=⧺ containedin=jsOperator
" syntax match jsDecrement "--" conceal cchar=╌ containedin=jsOperator
" syntax match jsEqual "+=" conceal cchar=∆ containedin=jsOperator
" syntax match jsEqual "-=" conceal cchar=∇ containedin=jsOperator
syntax match jsEqual ">=" conceal cchar=≥ containedin=jsOperator
syntax match jsEqual "<=" conceal cchar=≤ containedin=jsOperator
syntax match jsEqual "!==" conceal cchar=≠ containedin=jsOperator
syntax match jsEqual "=" conceal cchar=≔ containedin=jsOperator " ←
syntax match jsEqual "==" conceal cchar=≟ containedin=jsOperator " ≒
syntax match jsEqual "===" conceal cchar=＝ containedin=jsOperator
syntax match jsDot "\.\.\." conceal cchar=… containedin=noise
" syntax match jsComment "//" conceal cchar=〜
" syntax region  jsComment        start=+//+ end=/$/ contains=jsCommentTodo,@Spell extend keepend
" syntax region  jsComment        start=+/\*+  end=+\*/+ contains=jsCommentTodo,@Spell fold extend keepend

syntax match jsFunction /\<function\>/ skipwhite skipempty nextgroup=jsGenerator,jsFuncName,jsFuncArgs,jsFlowFunctionGroup skipwhite conceal cchar=ƒ
syntax match jsArrowFunction /=>/ skipwhite skipempty nextgroup=jsFuncBlock,jsCommentFunction conceal cchar=⇒
syntax match jsArrowFunction /()\ze\s*=>/ skipwhite skipempty nextgroup=jsArrowFunction conceal cchar=○
syntax match jsArrowFunction /_\ze\s*=>/ skipwhite skipempty nextgroup=jsArrowFunction conceal cchar=○

" syntax keyword jsImport import conceal cchar=⇲
" syntax keyword jsExport export conceal cchar=⇱

syntax keyword jsClassKeyword class conceal cchar=∀
syntax match jsClassExtension "extends" conceal cchar=⊂

syntax keyword jsStorageClass const conceal cchar=◆ " ▣◉◈◇⋄◆● ∃
syntax keyword jsStorageClass let conceal cchar=⊙
syntax keyword jsStorageClass var conceal cchar=◍

syntax keyword jsConditional if conceal cchar=≡ " ⁇⊃※∗*＊
syntax keyword jsConditional else conceal cchar=⊢ " ∵
" syntax keyword jsConditional "else if" conceal cchar=⊨

syntax keyword jsBooleanTrue true conceal cchar=⊤
syntax keyword jsBooleanFalse false conceal cchar=⟂ " ⊥ (bottom) looks too light
syntax keyword jsNull null conceal cchar=ø
syntax keyword jsReturn return contained conceal cchar=↲ skipwhite nextgroup=@jsExpression
syntax keyword jsStatement yield contained conceal cchar=↳ skipwhite nextgroup=@jsExpression " ↬⇄↔⟷
syntax keyword jsUndefined undefined conceal cchar=␣
syntax keyword jsNan NaN conceal cchar=Ӣ
syntax keyword jsNumber Infinity conceal cchar=∞
" syntax keyword jsPrototype prototype conceal cchar=℗
syntax keyword jsThis this conceal cchar=@
syntax keyword jsSuper super contained conceal cchar=Ω

