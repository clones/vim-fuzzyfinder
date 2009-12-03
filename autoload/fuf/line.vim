"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_line') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_line = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#line#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#line#getSwitchOrder()
  return g:fuf_line_switchOrder
endfunction

"
function fuf#line#renewCache()
endfunction

"
function fuf#line#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#line#onInit()
  call fuf#defineLaunchCommand('FufLine', s:MODE_NAME, '""')
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')
let s:OPEN_TYPE_DELETE = -1

" }}}1
"=============================================================================
" s:handler {{{1

let s:handler = {}

"
function s:handler.getModeName()
  return s:MODE_NAME
endfunction

"
function s:handler.getPrompt()
  return fuf#formatPrompt(g:fuf_line_prompt, self.partialMatching)
endfunction

"
function s:handler.getPreviewHeight()
  return g:fuf_previewHeight
endfunction

"
function s:handler.targetsPath()
  return 0
endfunction

"
function s:handler.makePatternSet(patternBase)
  return fuf#makePatternSet(a:patternBase, 's:interpretPrimaryPatternForNonPath',
        \                   self.partialMatching)
endfunction

"
function s:handler.makePreviewLines(word, count)
  "TODO
endfunction

"
function s:handler.getCompleteItems(patternPrimary)
  return self.items
endfunction

"
function s:handler.onOpen(word, mode)
  "TODO
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
  let tab = repeat(' ', getbufvar(self.bufNrPrev, '&tabstop'))
  let self.items = getbufline(self.bufNrPrev, 1, '$')
  let lnumFormat = '%' . len(string(len(self.items) + 1)) . 'd|'
  for i in range(len(self.items))
    let self.items[i] = substitute(self.items[i], "\t", tab, 'g')
    let self.items[i] = printf(lnumFormat, i + 1) . self.items[i]
  endfor
  call map(self.items, 'fuf#makeNonPathItem(v:val, "")')
  call fuf#mapToSetSerialIndex(self.items, 1)
  "TODO do not append index to abbr
  call map(self.items, 'fuf#setAbbrWithFormattedWord(v:val)')
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
