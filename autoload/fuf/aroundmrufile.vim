"=============================================================================
" Copyright (c) 2010 Takeshi NISHIDA
"
"=============================================================================
" LOAD GUARD {{{1

if !l9#guardScriptLoading(expand('<sfile>:p'), 702, 100)
  finish
endif

" }}}1
"=============================================================================
" GLOBAL FUNCTIONS {{{1

"
function fuf#aroundmrufile#createHandler(base)
  return a:base.concretize(copy(s:handler))
endfunction

"
function fuf#aroundmrufile#getSwitchOrder()
  return g:fuf_aroundmrufile_switchOrder
endfunction

"
function fuf#aroundmrufile#renewCache()
  let s:cache = {}
endfunction

"
function fuf#aroundmrufile#requiresOnCommandPre()
  return 0
endfunction

"
function fuf#aroundmrufile#onInit()
  call fuf#defineLaunchCommand('FufAroundMruFile', s:MODE_NAME, '""')
  augroup fuf#aroundmrufile
    autocmd!
    autocmd BufEnter     * call s:updateInfo()
    autocmd BufWritePost * call s:updateInfo()
  augroup END
endfunction

" }}}1
"=============================================================================
" LOCAL FUNCTIONS/VARIABLES {{{1

let s:MODE_NAME = expand('<sfile>:t:r')

"
function s:updateInfo()
  if !empty(&buftype) || !filereadable(expand('%'))
    return
  endif
  let items = fuf#loadDataFile(s:MODE_NAME, 'items')
  let items = fuf#updateMruList(
        \ items, { 'word' : expand('%:p:h') },
        \ g:fuf_aroundmrufile_maxDir, g:fuf_aroundmrufile_exclude)
  call fuf#saveDataFile(s:MODE_NAME, 'items', items)
endfunction

"
function s:listFilesUsingCache(dir)
  if !exists('s:cache[a:dir]')
    let s:cache[a:dir] = [a:dir] +
          \              split(glob(a:dir . l9#getPathSeparator() . "*" ), "\n") +
          \              split(glob(a:dir . l9#getPathSeparator() . ".*"), "\n")
    call filter(s:cache[a:dir], 'v:val !~ ''\v(^|[/\\])\.\.?$''')
    call map(s:cache[a:dir], 'fuf#makePathItem(fnamemodify(v:val, ":~"), "", 1)')
    if len(g:fuf_aroundmrufile_exclude)
      call filter(s:cache[a:dir], 'v:val.word !~ g:fuf_aroundmrufile_exclude')
    endif
  endif
  return s:cache[a:dir]
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
  return fuf#formatPrompt(g:fuf_aroundmrufile_prompt, self.partialMatching)
endfunction

"
function s:handler.getPreviewHeight()
  return g:fuf_previewHeight
endfunction

"
function s:handler.isOpenable(enteredPattern)
  return 1
endfunction

"
function s:handler.makePatternSet(patternBase)
  return fuf#makePatternSet(a:patternBase, 's:interpretPrimaryPatternForPath',
        \                   self.partialMatching)
endfunction

"
function s:handler.makePreviewLines(word, count)
  return fuf#makePreviewLinesForFile(a:word, a:count, self.getPreviewHeight())
endfunction

"
function s:handler.getCompleteItems(patternPrimary)
  return self.items
endfunction

"
function s:handler.onOpen(word, mode)
  if isdirectory(expand(a:word))
    let self.reservedMode = 'file'
    let self.lastPattern = a:word
  else
    call fuf#openFile(a:word, a:mode, g:fuf_reuseWindow)
  endif
endfunction

"
function s:handler.onModeEnterPre()
endfunction

"
function s:handler.onModeEnterPost()
  " NOTE: Comparing filenames is faster than bufnr('^' . fname . '$')
  let bufNamePrev = fnamemodify(bufname(self.bufNrPrev), ':p:~')
  let self.items = fuf#loadDataFile(s:MODE_NAME, 'items')
  call map(self.items, 's:listFilesUsingCache(v:val.word)')
  let self.items = l9#concat(self.items)
  call filter(self.items, '!empty(v:val) && v:val.word !=# bufNamePrev')
  call fuf#mapToSetSerialIndex(self.items, 1)
  call fuf#mapToSetAbbrWithSnippedWordAsPath(self.items)
endfunction

"
function s:handler.onModeLeavePost(opened)
endfunction

" }}}1
"=============================================================================
" vim: set fdm=marker:
