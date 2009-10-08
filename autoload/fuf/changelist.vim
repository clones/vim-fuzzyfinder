"=============================================================================
" Copyright (c) 2007-2009 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if exists('g:loaded_autoload_fuf_changelist') || v:version < 702
  finish
endif
let g:loaded_autoload_fuf_changelist = 1

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#changelist#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#changelist#getSwitchOrder()
  return g:fuf_changelist_switchOrder
endfunction

"
function fuf#changelist#renewCache()
endfunction

"
function fuf#changelist#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#changelist#onInit()
  call fuf#defineLaunchCommand('FufChangeList', s:MODE_NAME, '""')
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:getChangesLines()
  redir => result
  :silent changes
  redir END
  return split(result, "\n")
endfunction

"
function s:parseChangesLine(line)
  return matchlist(a:line, '^\(.\)\s\+\(\d\+\)\s\(.*\)$')
endfunction

"
function s:makeItem(line)
  let elements =  s:parseChangesLine(a:line)
  if empty(elements)
    return {}
  endif
  let item = fuf#makeNonPathItem(elements[3], '')
  let item.abbrPrefix = elements[1]
  return item
endfunction

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
  return g:fuf_changelist_prompt
endfunction

"
function s:handler.targetsPath()
  return 0
endfunction

"
function s:handler.onComplete(patternSet)
  return fuf#filterMatchesAndMapToSetRanks(
        \ self.items, a:patternSet, self.getFilteredStats(a:patternSet.raw))
endfunction

"
function s:handler.onOpen(expr, mode)
  call fuf#prejump(a:mode)
  let older = 0
  for line in reverse(s:getChangesLines())
    if stridx(line, '>') == 0
      let older = 1
    endif
    let elements = s:parseChangesLine(line)
    if !empty(elements) && elements[3] ==# a:expr
      if elements[2] != 0
        execute 'normal! ' . elements[2] . (older ? 'g;' : 'g,') . 'zvzz'
      endif
      break
    endif
  endfor
endfunction

"
function s:handler.onModeEnterPre()
  let self.items = s:getChangesLines()
endfunction

"
function s:handler.onModeEnterPost()
  call map(self.items, 's:makeItem(v:val)')
  call filter(self.items, '!empty(v:val)')
  call reverse(self.items)
  call fuf#mapToSetSerialIndex(self.items, 1)
  call map(self.items, 'fuf#setAbbrWithFormattedWord(v:val)')
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:

