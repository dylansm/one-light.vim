set background=light

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "onelight"

let s:low_color = 0

" Color approximation functions by Henry So, Jr. and David Liang {{{
" Added to onelight.vim by Daniel Herbert

" returns an approximate grey index for the given grey level
fun! s:grey_number(x)
  if &t_Co == 88
    if a:x < 23
      return 0
    elseif a:x < 69
      return 1
    elseif a:x < 103
      return 2
    elseif a:x < 127
      return 3
    elseif a:x < 150
      return 4
    elseif a:x < 173
      return 5
    elseif a:x < 196
      return 6
    elseif a:x < 219
      return 7
    elseif a:x < 243
      return 8
    else
      return 9
    endif
  else
    if a:x < 14
      return 0
    else
      let l:n = (a:x - 8) / 10
      let l:m = (a:x - 8) % 10
      if l:m < 5
        return l:n
      else
        return l:n + 1
      endif
    endif
  endif
endfun

" returns the actual grey level represented by the grey index
fun! s:grey_level(n)
  if &t_Co == 88
    if a:n == 0
      return 0
    elseif a:n == 1
      return 46
    elseif a:n == 2
      return 92
    elseif a:n == 3
      return 115
    elseif a:n == 4
      return 139
    elseif a:n == 5
      return 162
    elseif a:n == 6
      return 185
    elseif a:n == 7
      return 208
    elseif a:n == 8
      return 231
    else
      return 255
    endif
  else
    if a:n == 0
      return 0
    else
      return 8 + (a:n * 10)
    endif
  endif
endfun

" returns the palette index for the given grey index
fun! s:grey_color(n)
  if &t_Co == 88
    if a:n == 0
      return 16
    elseif a:n == 9
      return 79
    else
      return 79 + a:n
    endif
  else
    if a:n == 0
      return 16
    elseif a:n == 25
      return 231
    else
      return 231 + a:n
    endif
  endif
endfun

" returns an approximate color index for the given color level
fun! s:rgb_number(x)
  if &t_Co == 88
    if a:x < 69
      return 0
    elseif a:x < 172
      return 1
    elseif a:x < 230
      return 2
    else
      return 3
    endif
  else
    if a:x < 75
      return 0
    else
      let l:n = (a:x - 55) / 40
      let l:m = (a:x - 55) % 40
      if l:m < 20
        return l:n
      else
        return l:n + 1
      endif
    endif
  endif
endfun

" returns the actual color level for the given color index
fun! s:rgb_level(n)
  if &t_Co == 88
    if a:n == 0
      return 0
    elseif a:n == 1
      return 139
    elseif a:n == 2
      return 205
    else
      return 255
    endif
  else
    if a:n == 0
      return 0
    else
      return 55 + (a:n * 40)
    endif
  endif
endfun

" returns the palette index for the given R/G/B color indices
fun! s:rgb_color(x, y, z)
  if &t_Co == 88
    return 16 + (a:x * 16) + (a:y * 4) + a:z
  else
    return 16 + (a:x * 36) + (a:y * 6) + a:z
  endif
endfun

" returns the palette index to approximate the given R/G/B color levels
fun! s:color(r, g, b)
  " get the closest grey
  let l:gx = s:grey_number(a:r)
  let l:gy = s:grey_number(a:g)
  let l:gz = s:grey_number(a:b)

  " get the closest color
  let l:x = s:rgb_number(a:r)
  let l:y = s:rgb_number(a:g)
  let l:z = s:rgb_number(a:b)

  if l:gx == l:gy && l:gy == l:gz
    " there are two possibilities
    let l:dgr = s:grey_level(l:gx) - a:r
    let l:dgg = s:grey_level(l:gy) - a:g
    let l:dgb = s:grey_level(l:gz) - a:b
    let l:dgrey = (l:dgr * l:dgr) + (l:dgg * l:dgg) + (l:dgb * l:dgb)
    let l:dr = s:rgb_level(l:gx) - a:r
    let l:dg = s:rgb_level(l:gy) - a:g
    let l:db = s:rgb_level(l:gz) - a:b
    let l:drgb = (l:dr * l:dr) + (l:dg * l:dg) + (l:db * l:db)
    if l:dgrey < l:drgb
      " use the grey
      return s:grey_color(l:gx)
    else
      " use the color
      return s:rgb_color(l:x, l:y, l:z)
    endif
  else
    " only one possibility
    return s:rgb_color(l:x, l:y, l:z)
  endif
endfun

" returns the palette index to approximate the 'rrggbb' hex string
fun! s:rgb(rgb)
  let l:r = ("0x" . strpart(a:rgb, 0, 2)) + 0
  let l:g = ("0x" . strpart(a:rgb, 2, 2)) + 0
  let l:b = ("0x" . strpart(a:rgb, 4, 2)) + 0
  return s:color(l:r, l:g, l:b)
endfun

" sets the highlighting for the given group
fun! s:X(group, fg, bg, attr, lcfg, lcbg)
  let l:fge = empty(a:fg)
  let l:bge = empty(a:bg)

  if !l:fge && !l:bge
    exec "hi ".a:group." guifg=#".a:fg." guibg=#".a:bg." ctermfg=".s:rgb(a:fg)." ctermbg=".s:rgb(a:bg)
  elseif !l:fge && l:bge
    exec "hi ".a:group." guifg=#".a:fg." guibg=NONE ctermfg=".s:rgb(a:fg)." ctermbg=NONE"
  elseif l:fge && !l:bge
    exec "hi ".a:group." guifg=NONE guibg=#".a:bg." ctermfg=NONE ctermbg=".s:rgb(a:bg)
  endif

endfun
" }}}

let normal_font_color = "ABB2BF"
let blue = "61afef"
let purple = "c678dd"
let green = "98c379"
let yellow = "e5c07b"
let orange = "d19a66"
let red = "e06c75"
let cyan = "56b6c2"

if !exists("g:onelight_background_color")
  " let g:onelight_background_color = "fdf6e4"
  let g:onelight_background_color = "ffffff"
end

call s:X("Normal",normal_font_color,g:onelight_background_color,"","fdf6e4","")

let s:termBlack = "Grey"

if version >= 700
  call s:X("CursorLine","","3E3D37","","",s:termBlack)
  call s:X("CursorColumn","","3E3D37","","",s:termBlack)
  call s:X("MatchParen","ffffff","556779","bold","","DarkCyan")

  call s:X("TabLine","000000","b0b8c0","italic","",s:termBlack)

  call s:X("TabLineFill","9098a0","","","",s:termBlack)
  call s:X("TabLineSel","000000","f0f0f0","italic,bold",s:termBlack,"White")

  " Auto-completion
  call s:X("Pmenu","ffffff","606060","","White",s:termBlack)
  call s:X("PmenuSel","101010","eeeeee","",s:termBlack,"White")
endif

call s:X("Visual","","404040","","",s:termBlack)
call s:X("Cursor",g:onelight_background_color,"b0d0f0","","","")

call s:X("LineNr","605958",g:onelight_background_color,"none",s:termBlack,"")
call s:X("CursorLineNr","ccc5c4","","none","White","")
call s:X("Comment","5f6b85","","italic","Grey","")
call s:X("Todo","c7c7c7","","bold","White",s:termBlack)

call s:X("StatusLine","95a2bb","22252b","italic","","White")
call s:X("StatusLineNC","ffffff","403c41","italic","White","Black")
call s:X("VertSplit","777777","403c41","",s:termBlack,s:termBlack)
call s:X("WildMenu","f0a0c0","302028","","Magenta","")

call s:X("Folded","a0a8b0","384048","italic",s:termBlack,"")
call s:X("FoldColumn","535D66","1f1f1f","","",s:termBlack)
call s:X("SignColumn","777777","333333","","",s:termBlack)
call s:X("ColorColumn","","282828","","",s:termBlack)

call s:X("Title","70b950","","bold","Green","")

call s:X("Constant",orange,"","","Red","")
call s:X("Special","799d6a","","","Green","")
call s:X("Delimiter","668799","","","Grey","")
call s:X("Define", purple, "", "", "", "")

call s:X("String",green,"","","Green","")
call s:X("StringDelimiter",green,"","","DarkGreen","")

call s:X("Identifier","c6b6ee","","","LightCyan","")
call s:X("Structure",purple,"","","Violet","")
call s:X("Function",blue,"","","SolarizedBlue","")
call s:X("Statement",purple,"","","Violet","")
call s:X("Attribute",orange,"","italic","Violet","")
call s:X("PreProc",purple,"","","Violet","")
call s:X("Boolean", orange, "", "", "", "")
call s:X("Keyword", purple, "", "", "", "")
call s:X("Typedef",yellow,"","","DarkYellow","")

hi! link Operator Structure

call s:X("Type",purple,"","","Violet","")
call s:X("NonText","606060",g:onelight_background_color,"",s:termBlack,"")

call s:X("SpecialKey","444444",g:onelight_background_color,"",s:termBlack,"")

call s:X("Search","","63535B","underline","Magenta","")

call s:X("Directory","1199CC","","","Yellow","")
call s:X("ErrorMsg","","902020","","","DarkRed")
hi! link Error ErrorMsg
hi! link MoreMsg Special
call s:X("Question","65C254","","","Green","")


" Spell Checking

call s:X("SpellBad","e06c75","302028","underline","Magenta","")
call s:X("SpellCap",orange,"","underline","","")
call s:X("SpellRare","","540063","underline","","DarkMagenta")
call s:X("SpellLocal","","2D7067","underline","","Green")

" Diff

hi! link diffRemoved Constant
hi! link diffAdded String

" VimDiff

call s:X("DiffAdd","D2EBBE","437019","","White","DarkGreen")
call s:X("DiffDelete","40000A","700009","","DarkRed","DarkRed")
call s:X("DiffChange","","2B5B77","","White","DarkBlue")
call s:X("DiffText","8fbfdc","000000","reverse","Yellow","")

" PHP

hi! link phpFunctions Function
call s:X("StorageClass",yellow,"","","Red","")
hi! link phpSuperglobal Identifier
hi! link phpQuoteSingle StringDelimiter
hi! link phpQuoteDouble StringDelimiter
hi! link phpBoolean Constant
hi! link phpNull Constant
hi! link phpArrayPair Operator
hi! link phpOperator Normal
hi! link phpRelation Normal
hi! link phpVarSelector Identifier

" Python

hi! link pythonOperator Statement

" Ruby

hi! link rubySharpBang Comment
" call s:X("rubyClass","447799","","","DarkBlue","")
call s:X("rubyIdentifier","c6b6fe","","","Cyan","")
call s:X("rubyPredefinedConstant", "bf6e7c", "", "", "", "")
call s:X("rubyInclude","66a5df","","","Cyan","")
call s:X("rubyInterpolation","88b379","","","Cyan","")
call s:X("rubyInterpolationDelimiter","8f5355","","","Cyan","")
call s:X("rubyConstant",yellow,"","","Cyan","")
call s:X("rubyRailsFilterMethod",cyan,"","","Cyan","")
call s:X("rubyRailsRenderMethod",cyan,"","","Cyan","")
hi! link rubyFunction Function

call s:X("rubyInstanceVariable","c6b6fe","","","Cyan","")
call s:X("rubySymbol",cyan,"","","Blue","")
hi! link rubyGlobalVariable rubyInstanceVariable
" hi! link rubyModule rubyClass
call s:X("rubyControl",purple,"","","Blue","")
call s:X("rubyBlockParameterList", red, "", "", "", "")
call s:X("rubyBlockParameter", red, "", "", "", "")

hi! link rubyString String
" hi! link rubyStringDelimiter StringDelimiter
hi! link rubyStringDelimiter String
" hi! link rubyInterpolationDelimiter Identifier


call s:X("rubyRegexpDelimiter",cyan,"","","Cyan","")
call s:X("rubyRegexp",cyan,"","","Cyan","")
call s:X("rubyRegexpSpecial","a40073","","","Magenta","")

call s:X("rubyPredefinedIdentifier","de5577","","","Red","")

" Erlang

hi! link erlangAtom rubySymbol
hi! link erlangBIF rubyPredefinedIdentifier
hi! link erlangFunction rubyPredefinedIdentifier
hi! link erlangDirective Statement
hi! link erlangNode Identifier

" JavaScript
call s:X("jsStatement",red,"","","Cyan","") " pangloss/javascript return statement
call s:X("jsImportContainer",blue,"","","Blue","")
" call s:X("javascriptReturn",red,"","","Cyan","") " yajs return statement
" call s:X("javascriptImportDef",blue,"","","Blue","")
" call s:X("javascriptImport",yellow,"","","Blue","")
" call s:X("javascriptImportBlock",blue,"","","Blue","")
" call s:X("javascriptIdentifierName",blue,"","","Blue","")
" call s:X("javascriptArrowFunc",cyan,"","","Blue","")
" call s:X("javascriptBraces",cyan,"","","Blue","")


hi! link javaScriptValue Constant
hi! link javaScriptRegexpString rubyRegexp
hi! link javaScriptStatement jsStatement

" CoffeeScript

hi! link coffeeRegExp javaScriptRegexpString

" Lua

hi! link luaOperator Conditional

" C

hi! link cFormat Identifier
hi! link cOperator Constant

" Objective-C/Cocoa

hi! link objcClass Type
hi! link cocoaClass objcClass
hi! link objcSubclass objcClass
hi! link objcSuperclass objcClass
hi! link objcDirective rubyClass
hi! link objcStatement Constant
hi! link cocoaFunction Function
hi! link objcMethodName Identifier
hi! link objcMethodArg Normal
hi! link objcMessageName Identifier

" Vimscript

hi! link vimOper Normal

" HTML

hi! link htmlTag Statement
hi! link htmlArg Attribute
hi! link htmlEndTag htmlTag
hi! link htmlTagName htmlTag

" Javascript.JSX
call s:X("jsBlock",cyan,"","","Violet","")
call s:X("es6FatArrow",purple,"","","Violet","")
call s:X("jsFuncID",purple,"","","Violet","")
call s:X("jsxComment","5f6b85","","italic","Grey","")
call s:X("jsxCommentDelim","5f6b85","","italic","Grey","")
call s:X("jsxParensErrC","","303030","","Grey","")
" jsParensErrC

hi! link jsBlock jsBlock
hi! link jsArrowFunction es6FatArrow
hi! link jsFuncCall jsFuncID
hi! link jsxComment jsxComment
" override mistake
" hi! link jsParensErrC jsxParensErrC

" UltiSnips Snippets
call s:X("leadingSpace",purple,"","","Violet","")

hi! link snipLeadingSpaces leadingSpace

" XML
call s:X("xmlAttribute",orange,"","italic","Violet","")
call s:X("xmlTag",purple,"","","Violet","")
call s:X("xmlEndTag",purple,"","","Violet","")
call s:X("xmlTagName",blue,"","","Violet","")
" call s:X("xmlEndTagName",blue,"","","Violet","")

" hi! link xmlTag Statement
hi! link xmlEndTag xmlEndTag
hi! link xmlTagName xmlTagName
" hi! link xmlEndTagName xmlEndTagName
hi! link xmlEqual xmlTag
hi! link xmlEntity Special
hi! link xmlEntityPunct xmlEntity
hi! link xmlDocTypeDecl PreProc
hi! link xmlDocTypeKeyword PreProc
hi! link xmlProcessingDelim xmlAttribute
hi! link xmlAttrib xmlAttribute


" Debugger.vim

call s:X("DbgCurrent","DEEBFE","345FA8","","White","DarkBlue")
call s:X("DbgBreakPt","","4F0037","","","DarkMagenta")

" vim-indent-guides

if !exists("g:indent_guides_auto_colors")
  let g:indent_guides_auto_colors = 0
endif
call s:X("IndentGuidesOdd","","232323","","","")
call s:X("IndentGuidesEven","","1b1b1b","","","")

" Plugins, etc.

hi! link TagListFileName Directory
call s:X("PreciseJumpTarget","B9ED67","405026","","White","Green")

if exists("g:onelight_overrides")
  fun! s:load_colors(defs)
    for [l:group, l:v] in items(a:defs)
      call s:X(l:group, get(l:v, 'guifg', ''), get(l:v, 'guibg', ''),
      \                 get(l:v, 'attr', ''),
      \                 get(l:v, 'ctermfg', ''), get(l:v, 'ctermbg', ''))
      " if !s:low_color
        " for l:prop in ['ctermfg', 'ctermbg']
          " let l:override_key = '256'.l:prop
          " if has_key(l:v, l:override_key)
            " exec "hi ".l:group." ".l:prop."=".l:v[l:override_key]
          " endif
        " endfor
      " endif
      unlet l:group
      unlet l:v
    endfor
  endfun
  call s:load_colors(g:onelight_overrides)
  delf s:load_colors
endif

" delete functions {{{
delf s:X
delf s:rgb
delf s:color
delf s:rgb_color
delf s:rgb_level
delf s:rgb_number
delf s:grey_color
delf s:grey_level
delf s:grey_number
" }}}

