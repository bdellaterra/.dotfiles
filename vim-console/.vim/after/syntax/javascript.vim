
" From Pangloss/vim-javascript, 2019, https://github.com/pangloss/vim-javascript/blob/master/syntax/javascript.vim
syntax keyword jsImport                       import skipwhite skipempty nextgroup=jsModuleAsterisk,jsModuleKeyword,jsModuleGroup,jsFlowImportType
syntax keyword jsExport                       export skipwhite skipempty nextgroup=@jsAll,jsModuleGroup,jsExportDefault,jsModuleAsterisk,jsModuleKeyword,jsFlowTypeStatement
syntax match   jsModuleKeyword      contained /\<\K\k*/ skipwhite skipempty nextgroup=jsModuleAs,jsFrom,jsModuleComma
syntax keyword jsExportDefault      contained default skipwhite skipempty nextgroup=@jsExpression
syntax keyword jsExportDefaultGroup contained default skipwhite skipempty nextgroup=jsModuleAs,jsFrom,jsModuleComma
syntax match   jsModuleAsterisk     contained /\*/ skipwhite skipempty nextgroup=jsModuleKeyword,jsModuleAs,jsFrom
syntax keyword jsModuleAs           contained as skipwhite skipempty nextgroup=jsModuleKeyword,jsExportDefaultGroup
syntax keyword jsFrom               contained from skipwhite skipempty nextgroup=jsString
syntax match jsModuleComma contained /,/ skipwhite skipempty nextgroup=jsModuleKeyword,jsModuleAsterisk,jsModuleGroup,jsFlowTypeKeyword
syntax region  jsModuleGroup        contained matchgroup=jsModuleBraces        start=/{/ end=/}/   contains=jsModuleKeyword,jsModuleComma,jsModuleAs,jsComment,jsFlowTypeKeyword skipwhite skipempty nextgroup=jsFrom fold
                       

syntax match jsAnd "&&" conceal cchar=∧ containedin=jsOperator
syntax match jsOr "||" conceal cchar=∨ containedin=jsOperator
syntax match jsNot "!" conceal cchar=￢ containedin=jsOperator,jsFuncArgs " ¬~～
syntax match jsDivisionSign "/" contained conceal cchar=÷ containedin=jsOperator nextgroup=@jsExpression
syntax match jsMultiplicationSign "*" conceal cchar=× containedin=jsOperator nextgroup=@jsExpression

" syntax match jsDecrement "++" conceal cchar=⧺ containedin=jsOperator
" syntax match jsDecrement "--" conceal cchar=╌ containedin=jsOperator
" syntax match jsEqual "+=" conceal cchar=∆ containedin=jsOperator
" syntax match jsEqual "-=" conceal cchar=∇ containedin=jsOperator
syntax match jsEqual ">=" conceal cchar=≥ containedin=jsOperator,jsObject
syntax match jsEqual "<=" conceal cchar=≤ containedin=jsOperator,jsObject
syntax match jsEqual "!==" conceal cchar=≠ containedin=jsOperator,jsObject
syntax match jsEqual "=" conceal cchar=≔ containedin=jsOperator,jsObject " ←
syntax match jsEqual "==" conceal cchar=≟ containedin=jsOperator,jsObject " ≒
syntax match jsEqual "===" conceal cchar=≡ containedin=jsOperator,jsObject " 〓
syntax match jsDot "\.\.\." conceal cchar=… containedin=noise
" syntax match jsComment "//" conceal cchar=〜
" syntax region  jsComment        start=+//+ end=/$/ contains=jsCommentTodo,@Spell extend keepend
" syntax region  jsComment        start=+/\*+  end=+\*/+ contains=jsCommentTodo,@Spell fold extend keepend

syntax match jsFunction /\<function\>/ skipwhite skipempty nextgroup=jsGenerator,jsFuncName,jsFuncArgs,jsFlowFunctionGroup skipwhite conceal cchar=ƒ
syntax match jsFuncArgOperator "=>" conceal cchar=⇒ containedin=jsObject,jsFuncArgs
syntax match jsArrowFunction /=>/ skipwhite skipempty nextgroup=jsFuncBlock,jsObject,jsFuncArgs,jsCommentFunction conceal cchar=⇒
syntax match jsArrowFunction /()\ze\s*=>/ skipwhite skipempty nextgroup=jsArrowFunction conceal cchar=○
syntax match jsArrowFunction /_\ze\s*=>/ skipwhite skipempty nextgroup=jsArrowFunction conceal cchar=○

" syntax keyword jsImport import conceal cchar=⇲
" syntax keyword jsExport export conceal cchar=⇱

syntax keyword jsClassKeyword class conceal cchar=∀
syntax match jsClassExtension "extends" conceal cchar=⊂

syntax keyword jsStorageClass const conceal cchar=◆ containedin=jsOperator,jsObject " ▣◉◈◇⋄◆● ∃
syntax keyword jsStorageClass let conceal cchar=⊙ containedin=jsOperator,jsObject
syntax keyword jsStorageClass var conceal cchar=◍ containedin=jsOperator,jsObject

syntax keyword jsConditional if conceal cchar=ϕ  containedin=jsOperator,jsObject " Φφϕ⏀ψΨ⋔↔∵∷☰⁇⊃※∗*＊
syntax keyword jsConditional else conceal cchar=⊢ containedin=jsOperator,jsObject
" syntax keyword jsConditional "else if" conceal cchar=⊨
" syntax keyword jsConditional switch conceal cchar=∈
" syntax keyword jsLabel case conceal cchar=→
" syntax keyword jsTry try conceal cchar=ψ " ⍕⍦◇◊⟠◻†
" syntax keyword jsFuncBlock catch conceal cchar=↯

syntax keyword jsBooleanTrue true conceal cchar=⊤
syntax keyword jsBooleanFalse false conceal cchar=⟂ " ⊥ (bottom) looks too light
syntax keyword jsNull null conceal cchar=ø
syntax keyword jsReturn return contained conceal cchar=↲ skipwhite containedin=jsOperator,jsObject nextgroup=@jsExpression
syntax keyword jsStatement yield contained conceal cchar=↳ skipwhite nextgroup=@jsExpression " ↬⇄↔⟷
syntax keyword jsAsyncKeyword async conceal cchar=☾ skipwhite
syntax keyword jsAsyncKeyword await conceal cchar=☽ skipwhite

syntax keyword jsUndefined undefined conceal cchar=␣
syntax keyword jsNan NaN conceal cchar=Ӣ
syntax keyword jsNumber Infinity conceal cchar=∞
" syntax keyword jsPrototype prototype conceal cchar=℗
" syntax keyword jsFuncArgs this conceal cchar=@
" syntax keyword jsObjectShorthandProp this conceal cchar=@
" syntax keyword jsThis this conceal cchar=@
syntax match jsThis "this" conceal cchar=@ containedin=jsFuncArgs,jsObjectShorthandProp
syntax keyword jsSuper super contained conceal cchar=Ω

